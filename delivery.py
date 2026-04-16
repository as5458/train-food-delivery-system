from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from db import query, execute

delivery_bp = Blueprint("delivery", __name__)


# ─────────────────────────────────────────────
# GET /api/delivery
# List all assignments
# ─────────────────────────────────────────────
@delivery_bp.route("/", methods=["GET"])
@jwt_required()
def list_assignments():

    rows = query(
        """
        SELECT
            da.id,
            da.assigned_at,
            da.delivered_at,

            o.id AS order_id,
            o.order_ref,
            o.coach,
            o.seat,
            o.status AS order_status,
            o.drop_time,

            u.name  AS staff_name,
            u.phone AS staff_phone,

            r.name  AS restaurant,

            t.train_number,
            t.train_name,

            c.name  AS customer_name

        FROM delivery_assignments da
        JOIN orders      o ON da.order_id   = o.id
        JOIN users       u ON da.staff_id   = u.id
        JOIN restaurants r ON o.restaurant_id = r.id
        JOIN trains      t ON o.train_id    = t.id
        JOIN users       c ON o.customer_id = c.id

        ORDER BY da.assigned_at DESC
        """
    )

    # 🔥 Clean drop_time format
    for r in rows:
        if r.get("drop_time"):
            r["drop_time"] = str(r["drop_time"])[:5]

    return jsonify(rows), 200


# ─────────────────────────────────────────────
# GET /api/delivery/ready-orders
# Orders ready for assignment
# ─────────────────────────────────────────────
@delivery_bp.route("/ready-orders", methods=["GET"])
@jwt_required()
def ready_orders():

    rows = query(
        """
        SELECT
            o.id,
            o.order_ref,
            o.coach,
            o.seat,
            o.drop_time,

            r.name  AS restaurant,
            r.outlet_name,

            t.train_number,
            t.train_name

        FROM orders o
        JOIN restaurants r ON o.restaurant_id = r.id
        JOIN trains      t ON o.train_id      = t.id

        WHERE o.status = 'ready'

        ORDER BY o.drop_time ASC
        """
    )

    # 🔥 Clean drop_time
    for r in rows:
        if r.get("drop_time"):
            r["drop_time"] = str(r["drop_time"])[:5]

    return jsonify(rows), 200


# ─────────────────────────────────────────────
# POST /api/delivery
# Assign delivery staff
# ─────────────────────────────────────────────
@delivery_bp.route("/", methods=["POST"])
@jwt_required()
def assign_order():

    data = request.get_json(silent=True) or {}

    order_id = data.get("order_id")
    staff_id = data.get("staff_id")

    # ✅ Validation
    if not order_id or not staff_id:
        return jsonify({"error": "order_id and staff_id are required"}), 400

    # ✅ Check order exists
    order = query(
        "SELECT id, status FROM orders WHERE id = %s",
        (order_id,),
        fetchone=True
    )

    if not order:
        return jsonify({"error": "Order not found"}), 404

    if order["status"] != "ready":
        return jsonify({"error": f"Order must be 'ready', current: {order['status']}"}), 400

    # ✅ Check staff exists
    staff = query(
        "SELECT id FROM users WHERE id = %s AND role = 'delivery_staff'",
        (staff_id,),
        fetchone=True
    )

    if not staff:
        return jsonify({"error": "Delivery staff not found"}), 404

    # 🔥 Insert assignment
    assign_id, _ = execute(
        """
        INSERT INTO delivery_assignments (order_id, staff_id)
        VALUES (%s, %s)
        """,
        (order_id, staff_id)
    )

    # 🔥 Update order status
    execute(
        "UPDATE orders SET status = 'assigned' WHERE id = %s",
        (order_id,)
    )

    return jsonify({
        "message": "Order assigned successfully",
        "assignment_id": assign_id
    }), 201


# ─────────────────────────────────────────────
# PUT /api/delivery/<id>/deliver
# Mark order delivered
# ─────────────────────────────────────────────
@delivery_bp.route("/<int:assign_id>/deliver", methods=["PUT"])
@jwt_required()
def mark_delivered(assign_id):

    assignment = query(
        "SELECT * FROM delivery_assignments WHERE id = %s",
        (assign_id,),
        fetchone=True
    )

    if not assignment:
        return jsonify({"error": "Assignment not found"}), 404

    # 🔥 Mark delivered
    execute(
        "UPDATE delivery_assignments SET delivered_at = NOW() WHERE id = %s",
        (assign_id,)
    )

    execute(
        "UPDATE orders SET status = 'delivered' WHERE id = %s",
        (assignment["order_id"],)
    )

    return jsonify({"message": "Order marked as delivered"}), 200