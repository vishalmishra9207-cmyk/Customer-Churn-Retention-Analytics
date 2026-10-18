
import random
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

TOTAL_ACTIVITIES = 20_000
BATCH_SIZE = 1000

random.seed(42)

START_DATE = datetime(2021, 1, 1)
END_DATE = datetime(2026, 10, 18)

ACTIVITY_TYPES = [
    "Discount Offer",
    "Upgrade Offer",
    "Downgrade Offer",
    "Free Service",
    "Loyalty Reward",
    "Customer Support",
    "Personalized Offer",
    "Other"
]
ACTIVITY_WEIGHTS = [25, 12, 10, 10, 15, 12, 12, 4]

OUTCOMES = ["Accepted", "Rejected", "Pending", "No Response"]
OUTCOME_WEIGHTS = [40, 25, 15, 20]

RETENTION_STATUSES = ["Retained", "Churned", "Still Active"]

NOTES = {
    "Discount Offer": [
        "Discount offered to encourage subscription renewal",
        "Special pricing offered after billing concerns",
        "Temporary discount offered to improve retention"
    ],
    "Upgrade Offer": [
        "Higher-tier plan offered based on customer needs",
        "Upgrade promotion shared with the customer",
        "Premium features offered to increase engagement"
    ],
    "Downgrade Offer": [
        "Lower-cost plan offered to reduce cancellation risk",
        "Affordable subscription option discussed",
        "Customer offered a lower-tier plan"
    ],
    "Free Service": [
        "Complimentary service period offered",
        "Trial of an additional service offered",
        "Free service benefit offered to improve engagement"
    ],
    "Loyalty Reward": [
        "Loyalty reward offered to a long-term customer",
        "Customer offered a loyalty benefit",
        "Reward offered in recognition of continued usage"
    ],
    "Customer Support": [
        "Support team contacted customer to address concerns",
        "Follow-up completed after a support interaction",
        "Customer concerns reviewed by the support team"
    ],
    "Personalized Offer": [
        "Offer tailored to the customer's usage pattern",
        "Personalized retention offer communicated",
        "Customer received a targeted service recommendation"
    ],
    "Other": [
        "Retention follow-up completed",
        "Customer engagement activity recorded",
        "Additional retention action documented"
    ]
}


def generate_activity(customer_id, subscription_id, is_churned):
    activity_type = random.choices(
        ACTIVITY_TYPES,
        weights=ACTIVITY_WEIGHTS,
        k=1
    )[0]

    outcome = random.choices(
        OUTCOMES,
        weights=OUTCOME_WEIGHTS,
        k=1
    )[0]

    # Use a plausible retention status.
    if is_churned:
        retention_status = "Churned"
    elif outcome == "Accepted":
        retention_status = "Retained"
    else:
        retention_status = "Still Active"

    activity_date = START_DATE + timedelta(
        seconds=random.randint(
            0, int((END_DATE - START_DATE).total_seconds())
        )
    )

    if activity_type in ("Discount Offer", "Upgrade Offer",
                         "Downgrade Offer", "Personalized Offer"):
        offer_amount = Decimal(
            str(round(random.uniform(50, 1000), 2))
        )
    elif activity_type in ("Free Service", "Loyalty Reward"):
        offer_amount = Decimal(
            str(round(random.uniform(50, 500), 2))
        )
    else:
        offer_amount = Decimal("0.00")

    note = random.choice(NOTES[activity_type])

    return (
        customer_id,
        subscription_id,
        activity_date,
        activity_type,
        offer_amount,
        outcome,
        retention_status,
        note
    )


connection = None
cursor = None

try:
    print("Connecting to MySQL...")

    connection = mysql.connector.connect(**DB_CONFIG)
    cursor = connection.cursor()

    # Prevent accidental duplicate imports.
    cursor.execute("SELECT COUNT(*) FROM retention_activity")
    existing_count = cursor.fetchone()[0]

    if existing_count > 0:
        print(
            f"STOPPED: retention_activity already contains "
            f"{existing_count:,} rows."
        )
        print("No records inserted. Check the table first.")
        raise SystemExit(0)

    # Build valid customer-subscription pairs.
    cursor.execute("""
        SELECT
            ca.customer_id,
            s.subscription_id,
            CASE
                WHEN ce.subscription_id IS NOT NULL THEN 1
                ELSE 0
            END AS is_churned
        FROM subscriptions s
        JOIN customer_accounts ca
            ON s.account_id = ca.account_id
        LEFT JOIN churn_events ce
            ON s.subscription_id = ce.subscription_id
    """)

    eligible_pairs = cursor.fetchall()

    if not eligible_pairs:
        raise ValueError(
            "No valid customer-subscription pairs found. "
            "Check customers, customer_accounts and subscriptions."
        )

    if len(eligible_pairs) < 1000:
        raise ValueError(
            f"Only {len(eligible_pairs):,} valid pairs found. "
            "Check the source tables first."
        )

    print(f"Valid customer-subscription pairs: {len(eligible_pairs):,}")
    print(f"Generating {TOTAL_ACTIVITIES:,} retention activities...")

    insert_sql = """
        INSERT INTO retention_activity (
            customer_id,
            subscription_id,
            activity_date,
            activity_type,
            offer_amount,
            outcome,
            retention_status,
            notes
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """

    inserted = 0

    # One transaction; failures roll back this run.
    for start in range(0, TOTAL_ACTIVITIES, BATCH_SIZE):
        current_batch_size = min(
            BATCH_SIZE, TOTAL_ACTIVITIES - start
        )

        batch = []

        for _ in range(current_batch_size):
            customer_id, subscription_id, is_churned = (
                random.choice(eligible_pairs)
            )

            batch.append(
                generate_activity(
                    customer_id,
                    subscription_id,
                    bool(is_churned)
                )
            )

        cursor.executemany(insert_sql, batch)
        inserted += len(batch)

        if inserted % 5000 == 0:
            print(
                f"Processed {inserted:,}/{TOTAL_ACTIVITIES:,}"
            )

    connection.commit()

    cursor.execute("SELECT COUNT(*) FROM retention_activity")
    final_count = cursor.fetchone()[0]

    print("\nRETENTION ACTIVITY IMPORT SUCCESSFUL!")
    print(f"Rows inserted: {inserted:,}")
    print(f"Total rows in table: {final_count:,}")

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
