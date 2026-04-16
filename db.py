"""
db.py — MySQL connection helper using PyMySQL.
Every request gets a fresh connection from get_db()
and it is closed automatically after the request.
"""

import pymysql
import pymysql.cursors
from flask import g
from config import Config


def get_db():
    """
    Return a database connection attached to Flask's request context (g).
    Creates a new connection if one doesn't exist yet for this request.
    """
    if "db" not in g:
        g.db = pymysql.connect(
            host=Config.DB_HOST,
            port=Config.DB_PORT,
            user=Config.DB_USER,
            password=Config.DB_PASSWORD,
            database=Config.DB_NAME,
            charset="utf8mb4",
            cursorclass=pymysql.cursors.DictCursor,   # rows as dicts
            autocommit=False,
        )
    return g.db


def close_db(e=None):
    """Close the DB connection at the end of the request."""
    db = g.pop("db", None)
    if db is not None:
        db.close()


def query(sql, params=None, fetchone=False):
    """
    Shortcut helper — run a SELECT and return results as list of dicts.
    Set fetchone=True to get a single row or None.
    """
    db  = get_db()
    cur = db.cursor()
    cur.execute(sql, params or ())
    return cur.fetchone() if fetchone else cur.fetchall()


def execute(sql, params=None):
    """
    Shortcut helper — run INSERT / UPDATE / DELETE.
    Returns (lastrowid, rowcount).
    """
    db  = get_db()
    cur = db.cursor()
    cur.execute(sql, params or ())
    db.commit()
    return cur.lastrowid, cur.rowcount
