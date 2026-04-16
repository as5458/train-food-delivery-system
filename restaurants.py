"""
routes/restaurants.py

GET    /api/restaurants          — list all restaurants
GET    /api/restaurants/<id>     — get one restaurant
POST   /api/restaurants          — add restaurant
PUT    /api/restaurants/<id>     — update restaurant
DELETE /api/restaurants/<id>     — deactivate
"""

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from db import query, execute

restaurants_bp = Blueprint("restaurants", __name__)


@restaurants_bp.route("/", methods=["GET"])
@jwt_required()
def list_restaurants():
    station = request.args.get("station")
    if station:
        rows = query(
            "SELECT * FROM restaurants WHERE station = %s AND is_active = 1 ORDER BY name",
            (station,)
        )
    else:
        rows = query("SELECT * FROM restaurants WHERE is_active = 1 ORDER BY name")
    return jsonify(rows), 200


@restaurants_bp.route("/<int:rest_id>", methods=["GET"])
@jwt_required()
def get_restaurant(rest_id):
    row = query("SELECT * FROM restaurants WHERE id = %s", (rest_id,), fetchone=True)
    if not row:
        return jsonify({"error": "Restaurant not found"}), 404
    return jsonify(row), 200


@restaurants_bp.route("/", methods=["POST"])
@jwt_required()
def create_restaurant():
    data        = request.get_json(silent=True) or {}
    name        = (data.get("name")        or "").strip()
    outlet_name = data.get("outlet_name")
    station     = (data.get("station")     or "").strip()
    phone       = data.get("phone")
    email       = data.get("email")

    if not name or not station:
        return jsonify({"error": "name and station are required"}), 400

    rest_id, _ = execute(
        "INSERT INTO restaurants (name, outlet_name, station, phone, email) VALUES (%s,%s,%s,%s,%s)",
        (name, outlet_name, station, phone, email)
    )
    row = query("SELECT * FROM restaurants WHERE id = %s", (rest_id,), fetchone=True)
    return jsonify({"message": "Restaurant created", "restaurant": row}), 201


@restaurants_bp.route("/<int:rest_id>", methods=["PUT"])
@jwt_required()
def update_restaurant(rest_id):
    row = query("SELECT * FROM restaurants WHERE id = %s", (rest_id,), fetchone=True)
    if not row:
        return jsonify({"error": "Restaurant not found"}), 404

    data = request.get_json(silent=True) or {}
    execute(
        "UPDATE restaurants SET name=%s, outlet_name=%s, station=%s, phone=%s, email=%s WHERE id=%s",
        (
            data.get("name",        row["name"]),
            data.get("outlet_name", row["outlet_name"]),
            data.get("station",     row["station"]),
            data.get("phone",       row["phone"]),
            data.get("email",       row["email"]),
            rest_id
        )
    )
    updated = query("SELECT * FROM restaurants WHERE id = %s", (rest_id,), fetchone=True)
    return jsonify({"message": "Restaurant updated", "restaurant": updated}), 200


@restaurants_bp.route("/<int:rest_id>", methods=["DELETE"])
@jwt_required()
def delete_restaurant(rest_id):
    row = query("SELECT id FROM restaurants WHERE id = %s", (rest_id,), fetchone=True)
    if not row:
        return jsonify({"error": "Restaurant not found"}), 404
    execute("UPDATE restaurants SET is_active = 0 WHERE id = %s", (rest_id,))
    return jsonify({"message": f"Restaurant {rest_id} deactivated"}), 200
