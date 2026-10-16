
import random
import uuid
from datetime import datetime, timedelta
from decimal import Decimal

import mysql.connector
from mysql.connector import Error

# ==========================================
# DATABASE CONFIGURATION
# ==========================================

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "SQL Password",  
    "database": "churn_retention_analytics"
}

TOTAL_PAYMENTS = 200_000
BATCH_SIZE = 1000

random.seed(42)

# ==========================================
# PAYMENT CONFIGURATION
# ==========================================

PAYMENT_STATUSES = [
    "Successful", "Failed", "Pending", "Refunded"
]
STATUS_WEIGHTS = [82, 10, 5, 3]

PAYMENT_MODES = [
    "UPI", "Net Banking", "Credit Card",
    "Debit Card", "Auto Debit", "Other"
]
MODE_WEIGHTS = [40, 12, 15, 15, 15, 3]

PAYMENT_TYPES = ["Recurring", "One-time", "Refund"]
TYPE_WEIGHTS = [85, 12, 3]

FAILURE_REASONS = [
    "Insufficient Balance",
    "Bank Server Error",
    "Incorrect Payment Details",
    "Payment Timeout",
    "Transaction Declined",
    "UPI Technical Error"
]

START_DATE = datetime(2021, 1, 1)
END_DATE = datetime(2026, 10, 15)

# ==========================================
# GENERATE ONE PAYMENT
# ==========================================

def generate_payment(subscription_id):
    payment_status = random.choices(
        PAYMENT_STATUSES,
        weights=STATUS_WEIGHTS,
        k=1
    )[0]

    payment_mode = random.choices(
        PAYMENT_MODES,
        weights=MODE_WEIGHTS,
        k=1
    )[0]

    payment_type = random.choices(
        PAYMENT_TYPES,
        weights=TYPE_WEIGHTS,
        k=1
    )[0]

    payment_date = START_DATE + timedelta(
        seconds=random.randint(
            0, int((END_DATE - START_DATE).total_seconds())
        )
    )

    payment_amount = Decimal(
        str(round(random.uniform(199, 2499), 2))
    )

    payment_received_date = None
    failure_reason = None

    if payment_status == "Successful":
        payment_received_date = payment_date + timedelta(
            minutes=random.randint(0, 30)
        )

    elif payment_status == "Failed":
        failure_reason = random.choice(FAILURE_REASONS)

    elif payment_status == "Refunded":
        payment_received_date = payment_date + timedelta(
            days=random.randint(1, 5)
        )

    transaction_id = f"TXN-{uuid.uuid4().hex[:20].upper()}"

    return (
        subscription_id,
        transaction_id,
        payment_amount,
        payment_date,
        payment_received_date,
        payment_status,
        payment_mode,
        payment_type,
        "INR",
        failure_reason
    )

# ==========================================
# MAIN PROCESS
# ==========================================

connection = None
cursor = None

try:
    print("Connecting to MySQL...")
    connection = mysql.connector.connect(**DB_CONFIG)
    cursor = connection.cursor()

    # Prevent duplicate full imports.
    cursor.execute("SELECT COUNT(*) FROM payments")
    existing_payments = cursor.fetchone()[0]

    if existing_payments > 0:
        print(
            f"STOPPED: payments table already has "
            f"{existing_payments:,} rows."
        )
        print("No new records inserted. Check the table first.")
        raise SystemExit(0)

    # Get valid subscription IDs from MySQL.
    cursor.execute(
        "SELECT subscription_id FROM subscriptions"
    )
    subscription_ids = [
        row[0] for row in cursor.fetchall()
    ]

    if not subscription_ids:
        raise ValueError(
            "No subscriptions found. Import subscriptions first."
        )

    if len(subscription_ids) < 1000:
        raise ValueError(
            f"Only {len(subscription_ids)} subscriptions found. "
            "Check the subscriptions table first."
        )

    print(f"Available subscriptions: {len(subscription_ids):,}")
    print(f"Generating {TOTAL_PAYMENTS:,} payments...")

    insert_query = """
        INSERT INTO payments (
            subscription_id,
            transaction_id,
            payment_amount,
            payment_date,
            payment_received_date,
            payment_status,
            payment_mode,
            payment_type,
            currency,
            failure_reason
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    imported = 0

    for start in range(0, TOTAL_PAYMENTS, BATCH_SIZE):
        batch_size = min(
            BATCH_SIZE,
            TOTAL_PAYMENTS - start
        )

        batch = [
            generate_payment(random.choice(subscription_ids))
            for _ in range(batch_size)
        ]

        cursor.executemany(insert_query, batch)
        imported += len(batch)

        if imported % 10_000 == 0:
            print(
                f"Processed {imported:,}/"
                f"{TOTAL_PAYMENTS:,} payments"
            )

    connection.commit()

    cursor.execute("SELECT COUNT(*) FROM payments")
    final_count = cursor.fetchone()[0]

    print("\nPAYMENTS IMPORT SUCCESSFUL!")
    print(f"Rows inserted: {imported:,}")
    print(f"Total payments in table: {final_count:,}")

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
