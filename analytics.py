"""
routes/analytics.py
"""

from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required
from db import query

analytics_bp = Blueprint("analytics", __name__, url_prefix="/api/analytics")


# =========================
# SUMMARY
# =========================
@analytics_bp.route("/summary", methods=["GET"])
# @jwt_required()   # enable if needed
def summary():

    total = query(
        "SELECT COUNT(*) AS cnt FROM orders",
        fetchone=True
    )["cnt"]

    by_status = query("""
        SELECT status, COUNT(*) AS cnt
        FROM orders
        GROUP BY status
    """)

    status_map = {r["status"]: r["cnt"] for r in by_status}

    staff_count = query(
        "SELECT COUNT(*) AS cnt FROM users WHERE role='delivery_staff' AND is_active=1",
        fetchone=True
    )["cnt"]

    delays = query(
        "SELECT COUNT(*) AS cnt FROM train_delays",
        fetchone=True
    )["cnt"]

    return jsonify({
        "total_orders_today": total,
        "pending": status_map.get("pending", 0),
        "ready": status_map.get("ready", 0),
        "assigned": status_map.get("assigned", 0),
        "dispatched": status_map.get("dispatched", 0),
        "delivered": status_map.get("delivered", 0),
        "cancelled": status_map.get("cancelled", 0),
        "delivery_staff_active": staff_count,
        "active_delays_today": delays
    }), 200


# =========================
# HOURLY
# =========================
@analytics_bp.route("/hourly", methods=["GET"])
# @jwt_required()
def hourly():

    rows = query("""
        SELECT
            HOUR(created_at) AS hour,
            COUNT(*) AS order_count
        FROM orders
        GROUP BY HOUR(created_at)
        ORDER BY hour
    """)

    return jsonify(rows), 200


# =========================
# REVENUE
# =========================
@analytics_bp.route("/revenue", methods=["GET"])
# @jwt_required()
def revenue():

    rows = query("""
        SELECT
            r.name AS restaurant,
            COUNT(o.id) AS order_count,
            COALESCE(SUM(o.total_amount), 0) AS total_revenue
        FROM orders o
        JOIN restaurants r ON o.restaurant_id = r.id
        WHERE o.status != 'cancelled'
        GROUP BY r.id, r.name
        ORDER BY total_revenue DESC
    """)

    return jsonify(rows), 200