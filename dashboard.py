from flask import Blueprint, jsonify, Response
from flask_jwt_extended import jwt_required
from db import query

import csv
from io import StringIO

# ✅ Blueprint
dashboard_bp = Blueprint("dashboard", __name__)


# =========================
# DASHBOARD API
# =========================
@dashboard_bp.route("/", methods=["GET"])
@jwt_required()
def dashboard_summary():

    total = query("SELECT COUNT(*) AS cnt FROM orders", fetchone=True)["cnt"]

    waiting = query("""
        SELECT COUNT(*) AS cnt 
        FROM orders 
        WHERE LOWER(status) IN ('pending','ready','assigned')
    """, fetchone=True)["cnt"]

    cancelled = query("""
        SELECT COUNT(*) AS cnt 
        FROM orders 
        WHERE LOWER(status) = 'cancelled'
    """, fetchone=True)["cnt"]

    staff = query("""
        SELECT COUNT(*) AS cnt 
        FROM users 
        WHERE role='delivery_staff' AND is_active=1
    """, fetchone=True)["cnt"]

    # 🔥 SHUFFLED DATA (important)
    recent = query("""
        SELECT 
            o.order_ref,
            o.coach,
            o.seat,
            LOWER(o.status) AS status,
            t.train_number,
            t.train_name,
            r.name AS restaurant
        FROM orders o
        LEFT JOIN trains t ON o.train_id = t.id
        LEFT JOIN restaurants r ON o.restaurant_id = r.id
        ORDER BY RAND()
    """)

    return jsonify({
        "total_orders": total,
        "waiting_orders": waiting,
        "cancelled_orders": cancelled,
        "delivery_staff": staff,
        "recent_orders": recent
    }), 200


# =========================
# ✅ EXPORT CSV (FIXED)
# =========================
@dashboard_bp.route("/export", methods=["GET"])
@jwt_required()
def export_dashboard():

    rows = query("""
        SELECT 
            o.order_ref,
            t.train_number,
            t.train_name,
            o.coach,
            o.seat,
            r.name AS restaurant,
            o.status
        FROM orders o
        LEFT JOIN trains t ON o.train_id = t.id
        LEFT JOIN restaurants r ON o.restaurant_id = r.id
        ORDER BY RAND()
    """)

    si = StringIO()
    writer = csv.writer(si)

    # Header
    writer.writerow([
        "Order ID",
        "Train",
        "Coach",
        "Seat",
        "Restaurant",
        "Status"
    ])

    # Rows
    for r in rows:
        writer.writerow([
            r["order_ref"],
            f'{r["train_number"]} ({r["train_name"]})',
            r["coach"],
            r["seat"],
            r["restaurant"],
            r["status"]
        ])

    return Response(
        si.getvalue(),
        mimetype="text/csv",
        headers={
            "Content-Disposition": "attachment; filename=dashboard_orders.csv"
        }
    )