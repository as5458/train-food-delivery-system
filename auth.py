"""
routes/auth.py

POST /api/auth/register  — create new account
POST /api/auth/login     — get JWT token
GET  /api/auth/me        — get current user info (requires token)
"""

import bcrypt
from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity

from db import query, execute

auth_bp = Blueprint("auth", __name__)


# ── Helper ────────────────────────────────────────────────
def _user_dict(row):
    """Strip password_hash before sending to client."""
    row.pop("password_hash", None)
    return row


# ── POST /api/auth/register ───────────────────────────────
@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json(silent=True) or {}

    name     = (data.get("name")  or "").strip()
    email    = (data.get("email") or "").strip().lower()
    phone    = (data.get("phone") or "").strip()
    password = (data.get("password") or "")
    role     = data.get("role", "customer")

    # ── Validation ────────────────────────────────────────
    if not all([name, email, phone, password]):
        return jsonify({"error": "name, email, phone and password are required"}), 400

    if len(password) < 6:
        return jsonify({"error": "Password must be at least 6 characters"}), 400

    if role not in ("admin", "station_master", "delivery_staff", "customer"):
        role = "customer"

    # ── Check duplicate email ─────────────────────────────
    existing = query("SELECT id FROM users WHERE email = %s", (email,), fetchone=True)
    if existing:
        return jsonify({"error": "Email already registered"}), 409

    # ── Hash password ─────────────────────────────────────
    pw_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

    # ── Insert ────────────────────────────────────────────
    user_id, _ = execute(
        """INSERT INTO users (name, email, phone, password_hash, role, station)
           VALUES (%s, %s, %s, %s, %s, %s)""",
        (name, email, phone, pw_hash, role, data.get("station"))
    )

    new_user = query("SELECT * FROM users WHERE id = %s", (user_id,), fetchone=True)
    token    = create_access_token(identity=str(user_id))

    return jsonify({
        "message": "Account created successfully",
        "token":   token,
        "user":    _user_dict(new_user)
    }), 201


# ── POST /api/auth/login ──────────────────────────────────
@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json(silent=True) or {}

    email    = (data.get("email")    or "").strip().lower()
    password = (data.get("password") or "")

    if not email or not password:
        return jsonify({"error": "Email and password are required"}), 400

    user = query("SELECT * FROM users WHERE email = %s", (email,), fetchone=True)

    if not user or not bcrypt.checkpw(password.encode(), user["password_hash"].encode()):
        return jsonify({"error": "Invalid email or password"}), 401

    if not user["is_active"]:
        return jsonify({"error": "Account is deactivated"}), 403

    token = create_access_token(identity=str(user["id"]))

    return jsonify({
        "message": "Login successful",
        "token":   token,
        "user":    _user_dict(user)
    }), 200


# ── GET /api/auth/me ──────────────────────────────────────
@auth_bp.route("/me", methods=["GET"])
@jwt_required()
def me():
    user_id = get_jwt_identity()
    user    = query("SELECT * FROM users WHERE id = %s", (user_id,), fetchone=True)

    if not user:
        return jsonify({"error": "User not found"}), 404

    return jsonify(_user_dict(user)), 200
