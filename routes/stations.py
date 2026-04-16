from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required
from db import query

stations_bp = Blueprint("stations", __name__)

@stations_bp.route("/", methods=["GET"])
@jwt_required()
def get_station_data():

    sql = """
        SELECT 
            o.order_ref,
            o.coach,
            o.seat,
            o.status,
            o.drop_time,

            r.name AS restaurant_name,
            r.outlet_name,

            t.train_number,
            t.train_name

        FROM orders o
        LEFT JOIN restaurants r ON o.restaurant_id = r.id
        LEFT JOIN trains t ON o.train_id = t.id

        ORDER BY o.drop_time ASC
    """

    data = query(sql)

    for row in data:
        dt = row.get("drop_time")

        # 🔥 ALWAYS SAFE CONVERSION
        if dt:
            dt_str = str(dt)   # handles time/datetime/string
            row["drop_time"] = dt_str[:5]  # "12:15"
        else:
            row["drop_time"] = None

        # 🔥 REMOVE # FOR API (IMPORTANT FOR VERIFY BUTTON)
        if row.get("order_ref"):
            row["order_ref"] = row["order_ref"].replace("#", "")

    return jsonify(data), 200