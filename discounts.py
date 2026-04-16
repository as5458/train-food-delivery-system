"""
routes/discounts.py

GET  /api/discounts              — list all campaigns
POST /api/discounts              — create campaign
POST /api/discounts/validate     — validate a coupon code
PUT  /api/discounts/<id>         — update campaign
DELETE /api/discounts/<id>       — deactivate campaign
"""

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import date
from db import query, execute

discounts_bp = Blueprint("discounts", __name__)


@discounts_bp.route("/", methods=["GET"])
@jwt_required()
def list_campaigns():
    active_only = request.args.get("active") == "1"
    if active_only:
        rows = query(
            "SELECT * FROM discount_campaigns WHERE is_active = 1 AND end_date >= CURDATE() ORDER BY created_at DESC"
        )
    else:
        rows = query("SELECT * FROM discount_campaigns ORDER BY created_at DESC")
    return jsonify(rows), 200


@discounts_bp.route("/", methods=["POST"])
@jwt_required()
def create_campaign():
    data           = request.get_json(silent=True) or {}
    title          = (data.get("title")          or "").strip()
    coupon_code    = (data.get("coupon_code")     or "").strip().upper()
    discount_type  = data.get("discount_type", "percentage")
    discount_value = data.get("discount_value", 0)
    usage_limit    = data.get("usage_limit", 100)
    start_date     = data.get("start_date")
    end_date       = data.get("end_date")
    description    = data.get("description")

    if not all([title, coupon_code, start_date, end_date]):
        return jsonify({"error": "title, coupon_code, start_date and end_date are required"}), 400

    if discount_type not in ("percentage", "flat"):
        return jsonify({"error": "discount_type must be 'percentage' or 'flat'"}), 400

    existing = query("SELECT id FROM discount_campaigns WHERE coupon_code = %s", (coupon_code,), fetchone=True)
    if existing:
        return jsonify({"error": "Coupon code already exists"}), 409

    camp_id, _ = execute(
        """INSERT INTO discount_campaigns
           (title, description, coupon_code, discount_type, discount_value,
            usage_limit, start_date, end_date, created_by)
           VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
        (title, description, coupon_code, discount_type, discount_value,
         usage_limit, start_date, end_date, get_jwt_identity())
    )
    row = query("SELECT * FROM discount_campaigns WHERE id = %s", (camp_id,), fetchone=True)
    return jsonify({"message": "Campaign created", "campaign": row}), 201


@discounts_bp.route("/validate", methods=["POST"])
@jwt_required()
def validate_coupon():
    data   = request.get_json(silent=True) or {}
    code   = (data.get("coupon_code") or "").strip().upper()
    amount = float(data.get("order_amount", 0))

    if not code:
        return jsonify({"error": "coupon_code is required"}), 400

    camp = query("SELECT * FROM discount_campaigns WHERE coupon_code = %s", (code,), fetchone=True)

    if not camp:
        return jsonify({"valid": False, "error": "Invalid coupon code"}), 404
    if not camp["is_active"]:
        return jsonify({"valid": False, "error": "Coupon is no longer active"}), 400
    if str(camp["end_date"]) < str(date.today()):
        return jsonify({"valid": False, "error": "Coupon has expired"}), 400
    if camp["used_count"] >= camp["usage_limit"]:
        return jsonify({"valid": False, "error": "Coupon usage limit reached"}), 400

    # Calculate discount
    if camp["discount_type"] == "percentage":
        discount = round(amount * float(camp["discount_value"]) / 100, 2)
    else:
        discount = float(camp["discount_value"])

    final = max(0, amount - discount)

    return jsonify({
        "valid":          True,
        "coupon_code":    code,
        "discount_type":  camp["discount_type"],
        "discount_value": float(camp["discount_value"]),
        "discount_amount": discount,
        "final_amount":   final
    }), 200


@discounts_bp.route("/<int:camp_id>", methods=["PUT"])
@jwt_required()
def update_campaign(camp_id):
    camp = query("SELECT * FROM discount_campaigns WHERE id = %s", (camp_id,), fetchone=True)
    if not camp:
        return jsonify({"error": "Campaign not found"}), 404

    data = request.get_json(silent=True) or {}
    execute(
        """UPDATE discount_campaigns
           SET title=%s, description=%s, discount_value=%s,
               usage_limit=%s, end_date=%s, is_active=%s
           WHERE id=%s""",
        (
            data.get("title",          camp["title"]),
            data.get("description",    camp["description"]),
            data.get("discount_value", camp["discount_value"]),
            data.get("usage_limit",    camp["usage_limit"]),
            data.get("end_date",       str(camp["end_date"])),
            int(data.get("is_active",  camp["is_active"])),
            camp_id
        )
    )
    updated = query("SELECT * FROM discount_campaigns WHERE id = %s", (camp_id,), fetchone=True)
    return jsonify({"message": "Campaign updated", "campaign": updated}), 200


@discounts_bp.route("/<int:camp_id>", methods=["DELETE"])
@jwt_required()
def delete_campaign(camp_id):
    camp = query("SELECT id FROM discount_campaigns WHERE id = %s", (camp_id,), fetchone=True)
    if not camp:
        return jsonify({"error": "Campaign not found"}), 404
    execute("UPDATE discount_campaigns SET is_active = 0 WHERE id = %s", (camp_id,))
    return jsonify({"message": "Campaign deactivated"}), 200
