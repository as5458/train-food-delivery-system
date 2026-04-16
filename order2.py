import csv
from io import StringIO
from flask import Blueprint, jsonify, Response
from flask_jwt_extended import jwt_required
from db import query

# ✅ Blueprint
order2_bp = Blueprint("order2", __name__)


# ─────────────────────────────────────────────
# 📦 GET ORDERS (SHUFFLED)
# ─────────────────────────────────────────────
@order2_bp.route("/", methods=["GET"])
@jwt_required()
def get_orders():

    rows = query("""
        SELECT 
            o.id,
            o.order_ref,
            o.coach,
            o.seat,
            LOWER(o.status) AS status,
            t.train_number,
            t.train_name,
            r.name AS restaurant_name
        FROM orders o
        LEFT JOIN trains t ON o.train_id = t.id
        LEFT JOIN restaurants r ON o.restaurant_id = r.id
        ORDER BY RAND()
    """)

    return jsonify({
        "orders": rows
    }), 200


# ─────────────────────────────────────────────
# 📥 EXPORT CSV
# ─────────────────────────────────────────────
@order2_bp.route("/export", methods=["GET"])
@jwt_required()
def export_orders():

    rows = query("""
        SELECT 
            o.order_ref,
            t.train_number,
            t.train_name,
            o.coach,
            o.seat,
            r.name AS restaurant_name,
            o.status
        FROM orders o
        LEFT JOIN trains t ON o.train_id = t.id
        LEFT JOIN restaurants r ON o.restaurant_id = r.id
        ORDER BY RAND()
    """)

    si = StringIO()
    writer = csv.writer(si)

    writer.writerow([
        "Order ID",
        "Train",
        "Coach",
        "Seat",
        "Restaurant",
        "Status"
    ])

    for r in rows:
        writer.writerow([
            r["order_ref"],
            f'{r["train_number"]} ({r["train_name"]})',
            r["coach"],
            r["seat"],
            r["restaurant_name"],
            r["status"]
        ])

    return Response(
        si.getvalue(),
        mimetype="text/csv",
        headers={
            "Content-Disposition": "attachment; filename=orders.csv"
        }
    )