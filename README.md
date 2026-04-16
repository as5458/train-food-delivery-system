# Right Time – Flask Backend

## File Structure

```
right-time-flask/
├── app.py               ← Flask entry point
├── config.py            ← DB + JWT config (reads .env)
├── db.py                ← PyMySQL connection helper
├── requirements.txt     ← pip dependencies
├── database.sql         ← MySQL schema + seed data
├── .env.example         ← Copy to .env and fill in values
└── routes/
    ├── __init__.py
    ├── auth.py          ← /api/auth  (register, login, me)
    ├── users.py         ← /api/users (CRUD + staff list)
    ├── orders.py        ← /api/orders (CRUD + status update)
    ├── restaurants.py   ← /api/restaurants
    ├── trains.py        ← /api/trains + /api/trains/delays
    ├── delivery.py      ← /api/delivery (assign + deliver)
    ├── discounts.py     ← /api/discounts + validate coupon
    └── analytics.py     ← /api/analytics (summary, revenue, hourly)
```

---

## Step 1 — Create the MySQL database

```bash
mysql -u root -p < database.sql
```

Or paste `database.sql` into phpMyAdmin → SQL tab.

---

## Step 2 — Set up Python environment

```bash
python -m venv venv

# Windows
venv\Scripts\activate

# Mac / Linux
source venv/bin/activate

pip install -r requirements.txt
```

---

## Step 3 — Configure environment

```bash
cp .env.example .env
```

Edit `.env` with your MySQL credentials:

```
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=right_time

JWT_SECRET_KEY=some_long_random_string
```

---

## Step 4 — Run the server

```bash
python app.py
```

Server starts at **http://localhost:5000**

---

## API Reference

### Auth
| Method | Endpoint              | Body / Notes                          |
|--------|-----------------------|---------------------------------------|
| POST   | `/api/auth/register`  | `name, email, phone, password, role`  |
| POST   | `/api/auth/login`     | `email, password` → returns JWT token |
| GET    | `/api/auth/me`        | Requires `Authorization: Bearer <token>` |

### Users
| Method | Endpoint              | Notes                          |
|--------|-----------------------|--------------------------------|
| GET    | `/api/users/`         | `?role=delivery_staff&station=Nagpur&q=search` |
| GET    | `/api/users/staff`    | Delivery staff only            |
| GET    | `/api/users/<id>`     |                                |
| POST   | `/api/users/`         | `name, email, phone, password, role` |
| PUT    | `/api/users/<id>`     | Partial update                 |
| DELETE | `/api/users/<id>`     | Soft delete (is_active=0)      |

### Orders
| Method | Endpoint                        | Notes                  |
|--------|---------------------------------|------------------------|
| GET    | `/api/orders/`                  | `?status=pending&train=12290` |
| GET    | `/api/orders/<ref>`             | e.g. `#ORD-8921`       |
| POST   | `/api/orders/`                  | Create new order        |
| PUT    | `/api/orders/<ref>/status`      | `{"status": "ready"}`  |
| DELETE | `/api/orders/<ref>`             | Cancel order            |

### Restaurants
| Method | Endpoint                   |
|--------|----------------------------|
| GET    | `/api/restaurants/`        |
| GET    | `/api/restaurants/<id>`    |
| POST   | `/api/restaurants/`        |
| PUT    | `/api/restaurants/<id>`    |
| DELETE | `/api/restaurants/<id>`    |

### Trains & Delays
| Method | Endpoint                |
|--------|-------------------------|
| GET    | `/api/trains/`          |
| POST   | `/api/trains/`          |
| GET    | `/api/trains/delays`    |
| POST   | `/api/trains/delays`    |

### Delivery
| Method | Endpoint                          | Notes              |
|--------|-----------------------------------|--------------------|
| GET    | `/api/delivery/`                  | All assignments     |
| GET    | `/api/delivery/ready-orders`      | Orders ready to assign |
| POST   | `/api/delivery/`                  | `{order_id, staff_id}` |
| PUT    | `/api/delivery/<id>/deliver`      | Mark delivered      |

### Discounts
| Method | Endpoint                    |
|--------|-----------------------------|
| GET    | `/api/discounts/?active=1`  |
| POST   | `/api/discounts/`           |
| POST   | `/api/discounts/validate`   |
| PUT    | `/api/discounts/<id>`       |
| DELETE | `/api/discounts/<id>`       |

### Analytics
| Method | Endpoint                    |
|--------|-----------------------------|
| GET    | `/api/analytics/summary`    |
| GET    | `/api/analytics/revenue`    |
| GET    | `/api/analytics/hourly`     |

---

## Using the API from the Frontend

Add this to your JS (e.g. in `data.js` or a new `api.js`):

```js
const BASE = "http://localhost:5000/api";
const token = localStorage.getItem("token");

const headers = {
  "Content-Type": "application/json",
  "Authorization": `Bearer ${token}`
};

// Login
const res  = await fetch(`${BASE}/auth/login`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ email: "rakesh@righttime.in", password: "yourpassword" })
});
const data = await res.json();
localStorage.setItem("token", data.token);

// Get orders
const orders = await fetch(`${BASE}/orders/?status=pending`, { headers });
```
