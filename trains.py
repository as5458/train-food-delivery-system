from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from db import query, execute

trains_bp = Blueprint("trains", __name__, url_prefix="/api/trains")

# ===============================
# GET ALL TRAINS
# ===============================
@trains_bp.route("/", methods=["GET"])
@jwt_required()
def list_trains():
    rows = query("SELECT * FROM trains ORDER BY train_number")
    return jsonify(rows), 200


# ===============================
# GET DELAYS
# ===============================
@trains_bp.route("/delays", methods=["GET"])
@jwt_required()
def list_delays():
    rows = query("""
        SELECT
            d.id,
            d.delay_minutes,
            d.reason,
            d.reported_at,

            t.id as train_id,
            t.train_number,
            t.train_name,
            t.route,

            (
                SELECT COUNT(*)
                FROM orders o
                WHERE o.train_id = t.id
                AND o.status IN ('pending','ready','assigned')
            ) AS affected_orders

        FROM train_delays d
        JOIN trains t ON d.train_id = t.id

        ORDER BY d.reported_at DESC
    """)

    return jsonify(rows), 200


# ===============================
# 🚀 TRAIN DETAILS (POPUP API)
# ===============================
@trains_bp.route("/<int:train_number>/details", methods=["GET"])
@jwt_required()
def train_details(train_number):

    train = query("""
        SELECT * FROM trains WHERE train_number = %s
    """, (train_number,), fetchone=True)

    if not train:
        return jsonify({"error": "Train not found"}), 404

    delay = query("""
        SELECT delay_minutes, reason, reported_at
        FROM train_delays
        WHERE train_id = %s
        ORDER BY reported_at DESC
        LIMIT 1
    """, (train["id"],), fetchone=True)

    orders = query("""
        SELECT order_ref
        FROM orders
        WHERE train_id = %s
        AND status IN ('pending','ready','assigned')
        LIMIT 5
    """, (train["id"],))

    return jsonify({
        "train_number": train["train_number"],
        "train_name": train["train_name"],
        "route": train["route"],
        "delay": delay or {"delay_minutes": 0},
        "affected_orders": orders
    }), 200


# ===============================
# REPORT DELAY
# ===============================
@trains_bp.route("/delays", methods=["POST"])
@jwt_required()
def report_delay():
    data = request.get_json()

    train_number = data.get("train_number")
    delay_minutes = data.get("delay_minutes", 0)
    reason = data.get("reason")
    user = get_jwt_identity()

    train = query(
        "SELECT id FROM trains WHERE train_number=%s",
        (train_number,),
        fetchone=True
    )

    if not train:
        return jsonify({"error": "Train not found"}), 404

    delay_id, _ = execute(
        "INSERT INTO train_delays (train_id, delay_minutes, reason, reported_by) VALUES (%s,%s,%s,%s)",
        (train["id"], delay_minutes, reason, user)
    )

    return jsonify({"message": "Delay reported", "id": delay_id}), 201