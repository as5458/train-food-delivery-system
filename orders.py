import random
import uuid
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from db import query, execute
from flask import Response
import csv
from io import StringIO


orders_bp = Blueprint("orders", __name__)

VALID_STATUSES = ("pending", "ready", "assigned", "dispatched", "delivered", "cancelled")


# 🔹 Generate UNIQUE Order Ref (FIXED)
def _gen_ref():
    return f"ORD-{uuid.uuid4().hex[:6].upper()}"


# ─────────────────────────────────────────────
# ✅ GET ALL ORDERS (FIXED FILTER)
# ─────────────────────────────────────────────
@orders_bp.route("/", methods=["GET"])
@jwt_required()
def list_orders():

    status = request.args.get("status")

    sql = """
        SELECT 
            o.id,
            o.order_ref,
            o.coach,
            o.seat,
            o.status,
            o.drop_time,

            COALESCE(o.reason, 'No reason') AS reason,

            COALESCE(r.name, 'Unknown Restaurant') AS restaurant,
            COALESCE(t.train_number, '-') AS train_number,
            COALESCE(t.train_name, '') AS train_name

        FROM orders o
        LEFT JOIN restaurants r ON o.restaurant_id = r.id
        LEFT JOIN trains t ON o.train_id = t.id
    """

    params = []

    # 🔥 CASE-INSENSITIVE FILTER (VERY IMPORTANT FIX)
    if status:
        sql += " WHERE LOWER(o.status) = LOWER(%s)"
        params.append(status)

    sql += " ORDER BY o.created_at DESC"

    rows = query(sql, tuple(params))

    result = []
    for o in rows:
        result.append({
            "id": o["id"],
            "order_ref": o["order_ref"],
            "coach": o["coach"],
            "seat": o["seat"],
            "status": o["status"],
            "drop_time": str(o["drop_time"]) if o["drop_time"] else None,
            "reason": o["reason"],
            "restaurant": o["restaurant"],
            "train_number": o["train_number"],
            "train_name": o["train_name"]
        })

    return jsonify(result), 200


# ─────────────────────────────────────────────
# 🔥 GET CANCELLED ORDERS (WORKING)
# ─────────────────────────────────────────────
@orders_bp.route("/cancelled", methods=["GET"])
@jwt_required()
def get_cancelled_orders():

    rows = query("""
        SELECT 
            o.order_ref,
            o.drop_time,

            COALESCE(c.reason, 'No reason') AS reason,

            COALESCE(r.name, 'Unknown Restaurant') AS restaurant,
            COALESCE(t.train_number, '-') AS train_number,
            COALESCE(t.train_name, '') AS train_name

        FROM cancelled_orders c
        JOIN orders o ON c.order_id = o.id
        LEFT JOIN restaurants r ON o.restaurant_id = r.id
        LEFT JOIN trains t ON o.train_id = t.id

        ORDER BY c.cancelled_at DESC
    """)

    result = []
    for r in rows:
        result.append({
            "order_ref": r["order_ref"],
            "restaurant": r["restaurant"],
            "reason": r["reason"],
            "drop_time": str(r["drop_time"]) if r["drop_time"] else None,
            "train_number": r["train_number"],
            "train_name": r["train_name"]
        })

    return jsonify(result), 200


# ─────────────────────────────────────────────
# GET SINGLE ORDER
# ─────────────────────────────────────────────
@orders_bp.route("/<string:order_ref>", methods=["GET"])
@jwt_required()
def get_order(order_ref):

    order = query("""
        SELECT 
            o.*,
            COALESCE(r.name, 'Unknown') AS restaurant,
            COALESCE(t.train_number, '-') AS train_number,
            COALESCE(t.train_name, '') AS train_name
        FROM orders o
        LEFT JOIN restaurants r ON o.restaurant_id = r.id
        LEFT JOIN trains t ON o.train_id = t.id
        WHERE o.order_ref = %s
    """, (order_ref,), fetchone=True)

    if not order:
        return jsonify({"error": "Order not found"}), 404

    return jsonify({
        "id": order["id"],
        "order_ref": order["order_ref"],
        "coach": order["coach"],
        "seat": order["seat"],
        "status": order["status"],
        "drop_time": str(order["drop_time"]) if order["drop_time"] else None,
        "reason": order.get("reason"),
        "restaurant": order["restaurant"],
        "train_number": order["train_number"],
        "train_name": order["train_name"]
    }), 200


# ─────────────────────────────────────────────
# CREATE ORDER (FIXED UNIQUE REF)
# ─────────────────────────────────────────────
@orders_bp.route("/", methods=["POST"])
@jwt_required()
def create_order():

    data = request.get_json()

    customer_id = data.get("customer_id") or get_jwt_identity()
    restaurant_id = data.get("restaurant_id")
    train_id = data.get("train_id")
    coach = data.get("coach")
    seat = data.get("seat")
    drop_time = data.get("drop_time")

    if not all([customer_id, restaurant_id, train_id, coach, seat]):
        return jsonify({"error": "Missing fields"}), 400

    order_ref = _gen_ref()

    execute("""
        INSERT INTO orders
        (order_ref, customer_id, restaurant_id, train_id, coach, seat, drop_time)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (order_ref, customer_id, restaurant_id, train_id, coach, seat, drop_time))

    return jsonify({
        "message": "Order created",
        "order_ref": order_ref
    }), 201


# ─────────────────────────────────────────────
# UPDATE STATUS
# ─────────────────────────────────────────────
@orders_bp.route("/<string:order_ref>/status", methods=["PUT"])
@jwt_required()
def update_status(order_ref):

    data = request.get_json()
    status = data.get("status", "").lower()

    if status not in VALID_STATUSES:
        return jsonify({"error": "Invalid status"}), 400

    execute(
        "UPDATE orders SET status=%s WHERE order_ref=%s",
        (status, order_ref)
    )

    return jsonify({"message": "Status updated"}), 200


# ─────────────────────────────────────────────
# ❌ CANCEL ORDER (FINAL FIX)
# ─────────────────────────────────────────────
@orders_bp.route("/<string:order_ref>", methods=["DELETE"])
@jwt_required()
def cancel_order(order_ref):

    data = request.get_json(silent=True) or {}
    reason = data.get("reason", "Cancelled")
    user_id = get_jwt_identity()

    order = query(
        "SELECT id FROM orders WHERE order_ref = %s",
        (order_ref,),
        fetchone=True
    )

    if not order:
        return jsonify({"error": "Order not found"}), 404

    order_id = order["id"]

    # ✅ Update status
    execute(
        "UPDATE orders SET status='cancelled' WHERE id=%s",
        (order_id,)
    )

    # ✅ Insert log
    execute(
        """
        INSERT INTO cancelled_orders (order_id, reason, cancelled_by)
        VALUES (%s, %s, %s)
        """,
        (order_id, reason, user_id)
    )
    # ─────────────────────────────────────────────
# 📥 EXPORT CANCELLED ORDERS (CSV)
# ─────────────────────────────────────────────
@orders_bp.route("/cancelled/export", methods=["GET"])
@jwt_required()
def export_cancelled_orders():

    rows = query("""
        SELECT 
            o.order_ref,
            t.train_number,
            t.train_name,
            r.name AS restaurant,
            COALESCE(c.reason, 'No reason') AS reason,
            o.drop_time
        FROM cancelled_orders c
        JOIN orders o ON c.order_id = o.id
        LEFT JOIN restaurants r ON o.restaurant_id = r.id
        LEFT JOIN trains t ON o.train_id = t.id
        ORDER BY c.cancelled_at DESC
    """)

    si = StringIO()
    writer = csv.writer(si)

    # Header
    writer.writerow([
        "Order ID",
        "Train",
        "Restaurant",
        "Reason",
        "Time"
    ])

    # Data
    for r in rows:
        writer.writerow([
            r["order_ref"],
            f'{r["train_number"]} ({r["train_name"]})',
            r["restaurant"],
            r["reason"],
            r["drop_time"]
        ])

    return Response(
        si.getvalue(),
        mimetype="text/csv",
        headers={
            "Content-Disposition": "attachment; filename=cancelled_orders.csv"
        }
    )
    

    return jsonify({"message": "Order cancelled successfully"}), 200