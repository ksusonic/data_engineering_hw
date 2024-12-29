from datetime import datetime

from psycopg2._psycopg import cursor


def expired_bad_passport(cur: cursor, date: datetime):
    with open(f"sql_scripts/fraud_bad_passport.sql", "r") as file:
        query = file.read()

    cur.execute(query, [date, date, date])


def invalid_contract(cur: cursor, date: datetime):
    with open(f"sql_scripts/fraud_invalid_contract.sql", "r") as file:
        query = file.read()

    cur.execute(query, [date, date, date])
