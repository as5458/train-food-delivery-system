"""
routes/users.py

GET    /api/users          — list all users (admin only)
GET    /api/users/<id>     — get one user
POST   /api/users          — create user (admin only)
PUT    /api/users/<id>     — update user
DELETE /api/users/<id>     — soft-delete (set is_active = 0)
GET    /api/users/staff    — list delivery staff only
"""

import bcrypt
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from db import query, execute

users_bp = Blueprint("users", __name__)


def _clean(user):
    """Remove password hash from response."""
    user.pop("password_hash", None)
    return user


# ── GET /api/users ────────────────────────────────────────
@users_bp.route("/", methods=["GET"])
@jwt_required()
def list_users():
    role_filter = request.args.get("role")      # ?role=delivery_staff
    station     = request.args.get("station")   # ?station=Nagpur
    search      = request.args.get("q")         # ?q=rakesh

    sql    = "SELECT * FROM users WHERE 1=1"
    params = []

    if role_filter:
        sql += " AND role = %s"
        params.append(role_filter)
    if station:
        sql += " AND station = %s"
        params.append(station)
    if search:
        sql += " AND (name LIKE %s OR email LIKE %s OR phone LIKE %s)"
        like = f"%{search}%"
        params.extend([like, like, like])

    sql += " ORDER BY created_at DESC"

    users = query(sql, params)
    return jsonify([_clean(u) for u in users]), 200


# ── GET /api/users/staff ──────────────────────────────────
@users_bp.route("/staff", methods=["GET"])
@jwt_required()
def list_staff():
    station = request.args.get("station", "Nagpur")
    staff = query(
        "SELECT id, name, email, phone, station, is_active FROM users "
        "WHERE role = 'delivery_staff' AND station = %s AND is_active = 1",
        (station,)
    )
    return jsonify(staff), 200


# ── GET /api/users/<id> ───────────────────────────────────
@users_bp.route("/<int:user_id>", methods=["GET"])
@jwt_required()
def get_user(user_id):
    user = query("SELECT * FROM users WHERE id = %s", (user_id,), fetchone=True)
    if not user:
        return jsonify({"error": "User not found"}), 404
    return jsonify(_clean(user)), 200


# ── POST /api/users ───────────────────────────────────────
@users_bp.route("/", methods=["POST"])
@jwt_required()
def create_user():
    data     = request.get_json(silent=True) or {}
    name     = (data.get("name")     or "").strip()
    email    = (data.get("email")    or "").strip().lower()
    phone    = (data.get("phone")    or "").strip()
    password = (data.get("password") or "")
    role     = data.get("role", "customer")
    station  = data.get("station")

    if not all([name, email, phone, password]):
        return jsonify({"error": "name, email, phone and password are required"}), 400

    existing = query("SELECT id FROM users WHERE email = %s", (email,), fetchone=True)
    if existing:
        return jsonify({"error": "Email already registered"}), 409

    pw_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

    user_id, _ = execute(
        "INSERT INTO users (name, email, phone, password_hash, role, station) "
        "VALUES (%s, %s, %s, %s, %s, %s)",
        (name, email, phone, pw_hash, role, station)
    )

    new_user = query("SELECT * FROM users WHERE id = %s", (user_id,), fetchone=True)
    return jsonify({"message": "User created", "user": _clean(new_user)}), 201


# ── PUT /api/users/<id> ───────────────────────────────────
@users_bp.route("/<int:user_id>", methods=["PUT"])
@jwt_required()
def update_user(user_id):
    user = query("SELECT * FROM users WHERE id = %s", (user_id,), fetchone=True)
    if not user:
        return jsonify({"error": "User not found"}), 404

    data    = request.get_json(silent=True) or {}
    name    = data.get("name",    user["name"])
    phone   = data.get("phone",   user["phone"])
    station = data.get("station", user["station"])
    role    = data.get("role",    user["role"])

    execute(
        "UPDATE users SET name=%s, phone=%s, station=%s, role=%s WHERE id=%s",
        (name, phone, station, role, user_id)
    )

    # Optional password change
    if data.get("password"):
        pw_hash = bcrypt.hashpw(data["password"].encode(), bcrypt.gensalt()).decode()
        execute("UPDATE users SET password_hash=%s WHERE id=%s", (pw_hash, user_id))

    updated = query("SELECT * FROM users WHERE id = %s", (user_id,), fetchone=True)
    return jsonify({"message": "User updated", "user": _clean(updated)}), 200


# ── DELETE /api/users/<id> ────────────────────────────────
@users_bp.route("/<int:user_id>", methods=["DELETE"])
@jwt_required()
def delete_user(user_id):
    user = query("SELECT id FROM users WHERE id = %s", (user_id,), fetchone=True)
    if not user:
        return jsonify({"error": "User not found"}), 404

    execute("UPDATE users SET is_active = 0 WHERE id = %s", (user_id,))
    return jsonify({"message": f"User {user_id} deactivated"}), 200
