
import random
from datetime import datetime, timedelta

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

TOTAL_CHURN_EVENTS = 12_000
BATCH_SIZE = 1000

random.seed(42)

START_DATE = datetime(2021, 1, 1)
END_DATE = datetime(2026, 10, 18)

CHURN_REASONS = [
    "High Price",
    "Poor Service",
    "Better Competitor Offer",
    "Poor Quality",
    "Lack of Usage",
    "Technical Issues",
    "Other"
]
REASON_WEIGHTS = [22, 20, 18, 12, 10, 10, 8]

CANCELLATION_CHANNELS = [
    "Customer Support",
    "Mobile App",
    "Website",
    "Email",
    "In Store",
    "Other"
]
CHANNEL_WEIGHTS = [30, 25, 20, 12, 5, 8]

FEEDBACK = {
    "High Price": [
        "The monthly plan is too expensive for my budget.",
        "I found a more affordable plan elsewhere.",
        "The price increase made the service less attractive."
    ],
    "Poor Service": [
        "My support requests were not resolved promptly.",
        "The service experience did not meet expectations.",
        "I experienced repeated customer service problems."
    ],
    "Better Competitor Offer": [
        "A competitor offered a better package.",
        "I switched to a provider with more benefits.",
        "Another provider offered better value for money."
    ],
    "Poor Quality": [
        "The quality of service was inconsistent.",
        "The service did not meet my quality expectations.",
        "I experienced repeated quality problems."
    ],
    "Lack of Usage": [
        "I no longer need this service regularly.",
        "My usage has decreased significantly.",
        "I am not using the subscription enough."
    ],
    "Technical Issues": [
        "Recurring technical issues affected my experience.",
        "The technical problems were inconvenient.",
        "I experienced repeated interruptions."
    ],
    "Other": [
        "My requirements have changed.",
        "I no longer need this subscription.",
        "I cancelled for personal reasons."
    ]
}


def generate_churn_event(subscription_id):
    churn_date = START_DATE + timedelta(
        seconds=random.randint(
            0, int((END_DATE - START_DATE).total_seconds())
        )
    )

    reason = random.choices(
        CHURN_REASONS, weights=REASON_WEIGHTS, k=1
    )[0]

    channel = random.choices(
        CANCELLATION_CHANNELS, weights=CHANNEL_WEIGHTS, k=1
    )[0]

    feedback = random.choice(FEEDBACK[reason])

    return (
        subscription_id,
        churn_date,
        reason,
        channel,
        feedback
    )


connection = None
cursor = None

try:
    print("Connecting to MySQL...")
    connection = mysql.connector.connect(**DB_CONFIG)
    cursor = connection.cursor()

    # Prevent accidental duplicate imports.
    cursor.execute("SELECT COUNT(*) FROM churn_events")
    existing_count = cursor.fetchone()[0]

    if existing_count > 0:
        print(
            f"STOPPED: churn_events already contains "
            f"{existing_count:,} rows."
        )
        print("No records inserted. Check the table first.")
        raise SystemExit(0)

    # Get eligible subscriptions.
    cursor.execute("""
        SELECT subscription_id
        FROM subscriptions
        WHERE subscription_status IN ('Terminated', 'Deactivated')
          AND end_date IS NOT NULL
          AND end_date >= '2021-01-01'
          AND end_date <= '2026-10-18'
    """)

    subscription_ids = [row[0] for row in cursor.fetchall()]

    if not subscription_ids:
        raise ValueError(
            "No eligible subscriptions found. Check subscription "
            "statuses and end dates before proceeding."
        )

    if len(subscription_ids) < TOTAL_CHURN_EVENTS:
        raise ValueError(
            f"Only {len(subscription_ids):,} eligible subscriptions "
            f"found; {TOTAL_CHURN_EVENTS:,} unique events required. "
            "Check the subscription data first."
        )

    # One churn event per eligible subscription.
    selected_ids = random.sample(
        subscription_ids, TOTAL_CHURN_EVENTS
    )

    print(f"Eligible subscriptions: {len(subscription_ids):,}")
    print(f"Generating {TOTAL_CHURN_EVENTS:,} churn events...")

    insert_sql = """
        INSERT INTO churn_events (
            subscription_id,
            churn_date,
            leaving_reason,
            cancellation_channel,
            feedback
        )
        VALUES (%s, %s, %s, %s, %s)
    """

    inserted = 0

    for start in range(0, TOTAL_CHURN_EVENTS, BATCH_SIZE):
        ids_batch = selected_ids[start:start + BATCH_SIZE]

        batch = [
            generate_churn_event(subscription_id)
            for subscription_id in ids_batch
        ]

        cursor.executemany(insert_sql, batch)
        inserted += len(batch)

        print(
            f"Processed {inserted:,}/{TOTAL_CHURN_EVENTS:,}"
        )

    connection.commit()

    cursor.execute("SELECT COUNT(*) FROM churn_events")
    final_count = cursor.fetchone()[0]

    print("\nCHURN EVENTS IMPORT SUCCESSFUL!")
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
