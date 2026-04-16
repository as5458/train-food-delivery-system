from flask import Flask, jsonify, render_template
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from datetime import timedelta
from orders import orders_bp
from dashboard import dashboard_bp



from config import Config
from db import close_db

# Blueprints
from auth import auth_bp
from users import users_bp
from orders import orders_bp
from restaurants import restaurants_bp
from trains import trains_bp
from delivery import delivery_bp
from discounts import discounts_bp
from analytics import analytics_bp
from delivery_partner import delivery_partner_bp


from order2 import order2_bp

# 🔥 NEW (Stations API)
from routes.stations import stations_bp 

def create_app():
    app = Flask(__name__)

    # =========================
    # CONFIG
    # =========================
    app.config["JWT_SECRET_KEY"] = Config.JWT_SECRET_KEY
    app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(
        seconds=Config.JWT_ACCESS_TOKEN_EXPIRES
    )
    app.config["DEBUG"] = Config.DEBUG

    # =========================
    # EXTENSIONS
    # =========================
    CORS(app)
    JWTManager(app)

    app.teardown_appcontext(close_db)

    # =========================
    # API ROUTES (BACKEND)
    # =========================
    app.register_blueprint(auth_bp, url_prefix="/api/auth")
   
    app.register_blueprint(users_bp, url_prefix="/api/users")
    app.register_blueprint(orders_bp, url_prefix="/api/orders")
    app.register_blueprint(restaurants_bp, url_prefix="/api/restaurants")
    app.register_blueprint(trains_bp, url_prefix="/api/trains")
    app.register_blueprint(delivery_bp, url_prefix="/api/delivery")
    app.register_blueprint(discounts_bp, url_prefix="/api/discounts")
    app.register_blueprint(analytics_bp, url_prefix="/api/analytics")
    # 🔥 IMPORTANT: STATIONS API CONNECTED TO DB
    app.register_blueprint(delivery_partner_bp)
    app.register_blueprint(dashboard_bp, url_prefix="/api/dashboard")
    app.register_blueprint(stations_bp, url_prefix="/api/stations")
    app.register_blueprint(order2_bp, url_prefix="/api/order2")
    # =========================
    # FRONTEND ROUTES (PAGES)
    # =========================

    @app.route("/")
    def login_page():
        return render_template("login.html")

    @app.route("/signup")
    def signup_page():
        return render_template("signup.html")

    @app.route("/dashboard")
    def dashboard_page():
        return render_template("dashboard.html")

    @app.route("/orders")
    def orders_page():
        return render_template("orders.html")

    @app.route("/stations")
    def stations_page():
        return render_template("stations.html")

    @app.route("/delivery")
    def delivery_page():
        return render_template("delivery.html")

    @app.route("/train")
    def train_page():
        return render_template("train.html")

    @app.route("/cancelled")
    def cancelled_page():
        return render_template("cancelled.html")

    @app.route("/discount")
    def discount_page():
        return render_template("discount.html")

    @app.route("/analytics")
    def analytics_page():
        return render_template("analytics.html")

    # =========================
    # HEALTH CHECK
    # =========================
    @app.route("/api/health")
    def health():
        return jsonify({"status": "ok"})

    return app


# =========================
# RUN APP
# =========================
app = create_app()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=Config.DEBUG)