
import random
from datetime import date, datetime, timedelta
from decimal import Decimal

import mysql.connector
from mysql.connector import Error

# ==========================================
# CONFIGURATION
# ==========================================

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "SQl Password",  # Apna MySQL password daalna
    "database": "churn_retention_analytics"
}

TOTAL_SERVICES = 100_000
BATCH_SIZE = 1000

random.seed(42)

# ==========================================
# DATA DISTRIBUTIONS
# ==========================================

SERVICE_TYPES = [
    "Internet",
    "Streaming",
    "Cloud Storage",
    "Premium Support"
]

SERVICE_WEIGHTS = [40, 30, 15, 15]

CATEGORIES = ["Basic", "Standard", "Premium"]
CATEGORY_WEIGHTS = [50, 35, 15]

STATUSES = [
    "Active",
    "Suspended",
    "Deactivated",
    "Terminated",
    "Hold"
]
STATUS_WEIGHTS = [70, 8, 10, 8, 4]

START_DATE = date(2021, 1, 1)
END_DATE = date(2026, 10, 1)

# ==========================================
# HELPER FUNCTIONS
# ==========================================

def random_date(start, end):
    days = (end - start).days
    return start + timedelta(days=random.randint(0, days))


def get_monthly_charge(service_type, category):
    prices = {
        "Internet": {
            "Basic": (299, 499),
            "Standard": (500, 899),
            "Premium": (900, 1499)
        },
        "Streaming": {
            "Basic": (99, 199),
            "Standard": (200, 399),
            "Premium": (400, 699)
        },
        "Cloud Storage": {
            "Basic": (49, 99),
            "Standard": (100, 249),
            "Premium": (250, 599)
        },
        "Premium Support": {
            "Basic": (99, 199),
            "Standard": (200, 399),
            "Premium": (400, 999)
        }
    }

    low, high = prices[service_type][category]
    return Decimal(str(round(random.uniform(low, high), 2)))


def generate_service(account_id):
    service_type = random.choices(
        SERVICE_TYPES, weights=SERVICE_WEIGHTS, k=1
    )[0]

    category = random.choices(
        CATEGORIES, weights=CATEGORY_WEIGHTS, k=1
    )[0]

    status = random.choices(
        STATUSES, weights=STATUS_WEIGHTS, k=1
    )[0]

    activation_day = random_date(START_DATE, END_DATE)

    activation_datetime = datetime.combine(
        activation_day,
        datetime.min.time()
    ) + timedelta(
        hours=random.randint(0, 23),
        minutes=random.randint(0, 59),
        seconds=random.randint(0, 59)
    )

    deactivation_date = None

    if status in ("Deactivated", "Terminated"):
        # Ensure deactivation is after activation.
        latest_day = max(activation_day, END_DATE)
        days_available = (latest_day - activation_day).days

        if days_available > 0:
            deactivation_date = activation_day + timedelta(
                days=random.randint(1, days_available)
            )
        else:
            deactivation_date = activation_day + timedelta(days=1)

    auto_renewal = (
        status in ("Active", "Hold", "Suspended")
        and random.random() < 0.80
    )

    monthly_charge = get_monthly_charge(
        service_type, category
    )

    return (
        account_id,
        service_type,
        category,
        activation_datetime,
        deactivation_date,
        status,
        monthly_charge,
        auto_renewal
    )


# ==========================================
# MAIN IMPORT PROCESS
# ==========================================

connection = None
cursor = None

try:
    print("Connecting to MySQL...")

    connection = mysql.connector.connect(**DB_CONFIG)
    cursor = connection.cursor()

    # Check existing records before importing.
    cursor.execute(
        "SELECT COUNT(*) FROM customer_services"
    )
    existing_count = cursor.fetchone()[0]

    if existing_count > 0:
        print(
            f"STOPPED: customer_services already has "
            f"{existing_count} rows."
        )
        print(
            "No data was inserted. Check the existing "
            "records before rerunning."
        )
        raise SystemExit(0)

    # Retrieve valid foreign keys.
    cursor.execute(
        "SELECT account_id FROM customer_accounts"
    )
    account_ids = [row[0] for row in cursor.fetchall()]

    if not account_ids:
        raise ValueError(
            "No account IDs found. Import customer_accounts first."
        )

    if len(account_ids) < 1000:
        raise ValueError(
            f"Only {len(account_ids)} accounts found. "
            "Check customer_accounts before proceeding."
        )

    print(f"Available accounts: {len(account_ids)}")
    print(f"Generating and importing {TOTAL_SERVICES:,} services...")

    insert_sql = """
        INSERT INTO customer_services (
            account_id,
            service_type,
            category,
            activation_date,
            deactivation_date,
            service_status,
            monthly_charge,
            auto_renewal
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """

    imported = 0

    # All inserts are part of one transaction.
    for start in range(0, TOTAL_SERVICES, BATCH_SIZE):
        batch_count = min(
            BATCH_SIZE,
            TOTAL_SERVICES - start
        )

        batch = [
            generate_service(random.choice(account_ids))
            for _ in range(batch_count)
        ]

        cursor.executemany(insert_sql, batch)
        imported += len(batch)

        print(
            f"Prepared {imported:,}/{TOTAL_SERVICES:,} rows"
        )

    connection.commit()

    cursor.execute(
        "SELECT COUNT(*) FROM customer_services"
    )
    final_count = cursor.fetchone()[0]

    print("\nIMPORT COMPLETED SUCCESSFULLY!")
    print(f"Rows imported in this run: {imported:,}")
    print(f"Total rows in table: {final_count:,}")

except SystemExit:
    pass

except (Error, ValueError) as error:
    if connection and connection.is_connected():
        connection.rollback()

    print("\nIMPORT FAILED.")
    print(f"Reason: {error}")
    print("Database changes from this run have been rolled back.")

except Exception as error:
    if connection and connection.is_connected():
        connection.rollback()

    print(f"\nUnexpected error: {error}")
    print("Database changes from this run have been rolled back.")

finally:
    if cursor:
        cursor.close()

    if connection and connection.is_connected():
        connection.close()

    print("MySQL connection closed.")
