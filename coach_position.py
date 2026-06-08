
from flask import Blueprint, jsonify
from db import query
import re

coach_bp = Blueprint("coach", __name__)

# =========================
# GET TRAINS
# =========================
@coach_bp.route("/api/trains")
def get_trains():
    return jsonify(query("SELECT * FROM trains"))


# =========================
# COACH MAP (STRUCTURE + POSITION)
# =========================
@coach_bp.route("/api/coach/map/<int:train_id>")
def coach_map(train_id):
    data = query("""
        SELECT tc.coach_name, tc.coach_type,
               cp.position_meter, cp.nearest_landmark
        FROM train_coaches tc
        LEFT JOIN coach_positions cp
        ON tc.train_id = cp.train_id
        AND tc.coach_name = cp.coach_name
        WHERE tc.train_id=%s
        ORDER BY tc.position_index
    """, (train_id,))

    return jsonify(data)


# =========================
# ACTIVE DELIVERY COACHES
# =========================
@coach_bp.route("/api/coach/active/<int:train_id>")
def active(train_id):
    return jsonify(query("""
        SELECT DISTINCT coach
        FROM orders
        WHERE train_id=%s
        AND status IN ('ready','assigned')
    """, (train_id,)))


# =========================
# STATS (ACTIVE + WALK TIME)
# =========================
@coach_bp.route("/api/coach/stats/<int:train_id>")
def stats(train_id):

    active_count = query("""
        SELECT COUNT(*) AS total
        FROM orders
        WHERE train_id=%s
        AND status IN ('ready','assigned')
    """, (train_id,))[0]["total"]

    return jsonify({
        "active": active_count,
        "avg_walk": round(1 + active_count * 0.2, 1)
    })


# =========================
# PENDING DELIVERIES (FINAL FIXED)
# =========================
@coach_bp.route("/api/coach/pending/<int:train_id>")
def get_pending_deliveries(train_id):

    data = query("""
        SELECT 
            o.order_ref,
            o.train_id,
            o.coach,
            o.seat,
            o.drop_time,
            o.status,
            t.train_number,
            t.train_name,
            tc.position_index,
            cp.position_meter,
            cp.nearest_landmark
        FROM orders o
        JOIN trains t ON o.train_id = t.id

        LEFT JOIN train_coaches tc
            ON o.train_id = tc.train_id
            AND o.coach = tc.coach_name

        LEFT JOIN coach_positions cp
            ON o.train_id = cp.train_id
            AND o.coach = cp.coach_name

        WHERE o.train_id = %s
        AND o.status IN ('pending','ready','assigned')
        ORDER BY o.id DESC
    """, (train_id,))

    for row in data:

        # =========================
        # 🔥 FIX INVALID COACHES (H1 → S1)
        # =========================
        coach = row.get("coach", "")

        if coach.startswith("H"):
            row["coach"] = "S1"

        # =========================
        # FIX TIME FORMAT
        # =========================
        if row.get("drop_time"):
            row["drop_time"] = str(row["drop_time"])

        # =========================
        # FIX POSITION IF NULL
        # =========================
        if not row.get("position_meter"):

            if row.get("position_index"):
                row["position_meter"] = row["position_index"] * 40

            else:
                match = re.search(r'\d+', row["coach"])

                if match:
                    num = int(match.group())
                    row["position_meter"] = num * 60
                else:
                    row["position_meter"] = 50

        # =========================
        # FIX LANDMARK IF NULL
        # =========================
        if not row.get("nearest_landmark"):

            meter = row["position_meter"]

            if meter < 100:
                row["nearest_landmark"] = "Entry Gate"
            elif meter < 200:
                row["nearest_landmark"] = "Pillar 6"
            elif meter < 300:
                row["nearest_landmark"] = "FOB Stairs"
            elif meter < 400:
                row["nearest_landmark"] = "Food Counter"
            else:
                row["nearest_landmark"] = "Water Booth"

    return jsonify(data)