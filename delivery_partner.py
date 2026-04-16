from flask import Blueprint, render_template, request, redirect, url_for, jsonify
from db import query

delivery_partner_bp = Blueprint("delivery_partner", __name__)


# ✅ MAIN PAGE
@delivery_partner_bp.route("/delivery-partner")
def delivery_partner():

    # Stats
    active = query("SELECT COUNT(*) as count FROM delivery_partners WHERE status='ACTIVE'")[0]['count']
    busy = query("SELECT COUNT(*) as count FROM delivery_partners WHERE status='BUSY'")[0]['count']

    delivered = query("""
        SELECT COUNT(*) as count 
        FROM deliveries 
        WHERE status='DELIVERED'
    """)[0]['count']

    assigned = query("""
        SELECT COUNT(*) as count 
        FROM deliveries 
        WHERE status='ASSIGNED'
    """)[0]['count']

    # Partner list with delivery count
    partners = query("""
        SELECT dp.id, dp.name, dp.phone, dp.status,
        COUNT(d.id) as total_deliveries
        FROM delivery_partners dp
        LEFT JOIN deliveries d 
        ON dp.id = d.partner_id AND d.status='DELIVERED'
        GROUP BY dp.id
    """)

    return render_template(
        "deliverypartner.html",
        partners=partners,
        active=active,
        busy=busy,
        delivered=delivered,
        assigned=assigned
    )


# ✅ ADD NEW PARTNER
@delivery_partner_bp.route("/delivery-partner/add", methods=["POST"])
def add_partner():
    name = request.form.get("name")
    phone = request.form.get("phone")

    query(
        "INSERT INTO delivery_partners (name, phone) VALUES (%s, %s)",
        (name, phone)
    )

    return redirect(url_for("delivery_partner.delivery_partner"))


# ✅ UPDATE STATUS (ACTIVE / BUSY / OFFLINE)
@delivery_partner_bp.route("/delivery-partner/status/<int:id>/<status>")
def update_status(id, status):
    query(
        "UPDATE delivery_partners SET status=%s WHERE id=%s",
        (status, id)
    )

    return redirect(url_for("delivery_partner.delivery_partner"))


# ✅ API (OPTIONAL - for JS)
@delivery_partner_bp.route("/api/delivery-partners")
def api_partners():
    data = query("SELECT * FROM delivery_partners")
    return jsonify(data)