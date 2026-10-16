
import random
from datetime import date, datetime, timedelta
from decimal import Decimal

import mysql.connector
from mysql.connector import Error

# ==========================================
# DATABASE CONFIGURATION
# ==========================================

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "Vishal@12",
    "database": "churn_retention_analytics"
}

TOTAL_SUBSCRIPTIONS = 60_000
BATCH_SIZE = 1000

random.seed(42)

START_DATE = date(2021, 1, 1)
END_DATE = date(2026, 10, 1)

PLAN_TYPES = ["Basic", "Standard", "Premium"]
PLAN_WEIGHTS = [50, 35, 15]

CONTRACT_TYPES = ["Monthly", "One Year", "Two Year"]
CONTRACT_WEIGHTS = [50, 30, 20]

STATUSES = [
    "Active", "Hold", "Suspended", "Deactivated", "Terminated"
]
STATUS_WEIGHTS = [65, 5, 8, 7, 15]


def random_date(start, end):
    days = (end - start).days
    return start + timedelta(days=random.randint(0, days))


def generate_subscription(account_id):
    plan = random.choices(
        PLAN_TYPES, weights=PLAN_WEIGHTS, k=1
    )[0]

    contract = random.choices(
        CONTRACT_TYPES, weights=CONTRACT_WEIGHTS, k=1
    )[0]

    status = random.choices(
        STATUSES, weights=STATUS_WEIGHTS, k=1
    )[0]

    start_day = random_date(START_DATE, END_DATE)

    start_datetime = datetime.combine(
        start_day, datetime.min.time()
    ) + timedelta(
        hours=random.randint(0, 23),
        minutes=random.randint(0, 59),
        seconds=random.randint(0, 59)
    )

    # Only deactivated/terminated subscriptions get an end date.
    end_day = None

    if status in ("Deactivated", "Terminated"):
        days_available = (END_DATE - start_day).days

        if days_available > 0:
            end_day = start_day + timedelta(
                days=random.randint(1, days_available)
            )

    base_prices = {
        "Basic": 399,
        "Standard": 699,
        "Premium": 1199
    }

    monthly_charges = Decimal(
        str(round(
            max(199, base_prices[plan] + random.uniform(-50, 100)),
            2
        ))
    )

    return (
        account_id,
        plan,
        contract,
        start_datetime,
        end_day,
        monthly_charges,
        status
    )


connection = None
cursor = None

try:
    print("Connecting to MySQL...")

    connection = mysql.connector.connect(**DB_CONFIG)
    cursor = connection.cursor()

    # Stop rather than accidentally duplicate records.
    cursor.execute("SELECT COUNT(*) FROM subscriptions")
    existing_count = cursor.fetchone()[0]

    if existing_count != 0:
        print(
            f"STOPPED: subscriptions has {existing_count:,} rows."
        )
        print("No data inserted. Check the table first.")
        raise SystemExit(0)

    # Load valid account IDs for the foreign key.
    cursor.execute(
        "SELECT account_id FROM customer_accounts"
    )
    account_ids = [row[0] for row in cursor.fetchall()]

    if not account_ids:
        raise ValueError(
            "No accounts found. Import customer_accounts first."
        )

    print(f"Valid accounts available: {len(account_ids):,}")
    print(f"Generating {TOTAL_SUBSCRIPTIONS:,} subscriptions...")

    insert_sql = """
        INSERT INTO subscriptions (
            account_id,
            plan_type,
            contract_type,
            start_date,
            end_date,
            monthly_charges,
            subscription_status
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """

    inserted = 0

    # Single transaction: any failure rolls back this run.
    for start in range(0, TOTAL_SUBSCRIPTIONS, BATCH_SIZE):
        current_batch_size = min(
            BATCH_SIZE, TOTAL_SUBSCRIPTIONS - start
        )

        batch = [
            generate_subscription(random.choice(account_ids))
            for _ in range(current_batch_size)
        ]

        cursor.executemany(insert_sql, batch)
        inserted += len(batch)

        if inserted % 10_000 == 0:
            print(
                f"Inserted in transaction: "
                f"{inserted:,}/{TOTAL_SUBSCRIPTIONS:,}"
            )

    connection.commit()

    cursor.execute("SELECT COUNT(*) FROM subscriptions")
    final_count = cursor.fetchone()[0]

    print("\nSUCCESS!")
    print(f"Rows inserted this run: {inserted:,}")
    print(f"Total subscriptions in table: {final_count:,}")

except SystemExit:
    pass

except (Error, ValueError) as error:
    if connection and connection.is_connected():
        connection.rollback()

    print("\nIMPORT FAILED.")
    print(f"Reason: {error}")
    print("This run has been rolled back.")

except Exception as error:
    if connection and connection.is_connected():
        connection.rollback()

    print(f"\nUnexpected error: {error}")
    print("This run has been rolled back.")

finally:
    if cursor:
        cursor.close()

    if connection and connection.is_connected():
        connection.close()

    print("MySQL connection closed.")
