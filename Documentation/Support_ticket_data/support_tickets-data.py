
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

TOTAL_TICKETS = 100_000
BATCH_SIZE = 1000

random.seed(42)

NOW = datetime.now()
START_DATE = datetime(2021, 1, 1)

# ==========================================
# REALISTIC DATA DISTRIBUTIONS
# ==========================================

ISSUE_CATEGORIES = [
    "Billing", "Internet", "Payment", "Technical",
    "Service Request", "Account", "Other"
]
ISSUE_WEIGHTS = [20, 22, 15, 18, 12, 8, 5]

PRIORITIES = ["Low", "Medium", "High", "Critical"]
PRIORITY_WEIGHTS = [20, 45, 27, 8]

TICKET_STATUSES = [
    "Open", "In Progress", "Waiting for Customer",
    "Waiting for External Team", "Resolved",
    "Closed", "Cancelled"
]
STATUS_WEIGHTS = [10, 12, 8, 5, 45, 17, 3]

RESOLUTION_CATEGORIES = [
    "User Training", "Data Fix", "Bulk Fix",
    "User Mistake", "Technical Fix", "Other"
]

RESOLUTIONS = {
    "Billing": [
        "Billing statement reviewed and issue clarified",
        "Incorrect charge investigated and corrected",
        "Billing adjustment processed"
    ],
    "Internet": [
        "Network configuration checked and restored",
        "Connectivity issue resolved after troubleshooting",
        "Internet service restored"
    ],
    "Payment": [
        "Payment status verified with transaction records",
        "Payment discrepancy investigated and corrected",
        "Payment issue escalated to payment team"
    ],
    "Technical": [
        "Technical issue diagnosed and resolved",
        "System configuration corrected",
        "Technical fix applied and verified"
    ],
    "Service Request": [
        "Customer service request completed",
        "Requested service configuration updated",
        "Service request fulfilled"
    ],
    "Account": [
        "Customer account details verified and updated",
        "Account access issue resolved",
        "Account information corrected"
    ],
    "Other": [
        "Issue investigated and appropriate action taken",
        "Customer concern reviewed and addressed",
        "Issue referred to the relevant team"
    ]
}

DESCRIPTIONS = {
    "Billing": [
        "Customer reported an unexpected charge on the latest bill",
        "Customer requested clarification of the monthly invoice",
        "Customer reported a billing amount mismatch"
    ],
    "Internet": [
        "Customer reported intermittent internet connectivity",
        "Internet service was slow during peak hours",
        "Customer reported loss of internet connection"
    ],
    "Payment": [
        "Customer reported a payment status mismatch",
        "Payment was deducted but confirmation was not received",
        "Customer requested help with a failed transaction"
    ],
    "Technical": [
        "Customer reported a technical error while using the service",
        "Application displayed an unexpected error",
        "Customer reported repeated system failures"
    ],
    "Service Request": [
        "Customer requested a change to an existing service",
        "Customer requested activation of an additional service",
        "Customer requested assistance with service settings"
    ],
    "Account": [
        "Customer reported an issue accessing their account",
        "Customer requested an update to account information",
        "Customer reported an account detail mismatch"
    ],
    "Other": [
        "Customer contacted support regarding a general concern",
        "Customer requested assistance with a service query",
        "Customer reported an issue requiring investigation"
    ]
}

AGENTS = [
    "Support Agent 101", "Support Agent 102",
    "Support Agent 103", "Support Agent 104",
    "Support Agent 105", "Support Agent 106",
    "Support Agent 107", "Support Agent 108"
]

# ==========================================
# GENERATE A TICKET
# ==========================================

def generate_ticket(customer_id, email):
    created_at = START_DATE + timedelta(
        seconds=random.randint(
            0, int((NOW - START_DATE).total_seconds())
        )
    )

    category = random.choices(
        ISSUE_CATEGORIES, weights=ISSUE_WEIGHTS, k=1
    )[0]

    priority = random.choices(
        PRIORITIES, weights=PRIORITY_WEIGHTS, k=1
    )[0]

    status = random.choices(
        TICKET_STATUSES, weights=STATUS_WEIGHTS, k=1
    )[0]

    # Resolve date is required for resolved/closed tickets.
    resolve_date = None
    resolution = None
    resolved_by = None
    resolution_category = None

    if status in ("Resolved", "Closed"):
        max_seconds = max(
            0, int((NOW - created_at).total_seconds())
        )

        # Resolution time varies from minutes to several days.
        desired_seconds = int(
            random.triangular(3600, 10 * 86400, 86400)
        )

        seconds_to_resolve = min(
            max_seconds, desired_seconds
        )

        resolve_date = created_at + timedelta(
            seconds=seconds_to_resolve
        )

        resolution = random.choice(RESOLUTIONS[category])
        resolved_by = random.choice(AGENTS)
        resolution_category = random.choice(
            RESOLUTION_CATEGORIES
        )

    description = random.choice(DESCRIPTIONS[category])

    return (
        customer_id,
        created_at,
        category,
        priority,
        status,
        resolve_date,
        resolution,
        resolved_by,
        resolution_category,
        email,
        description
    )

# ==========================================
# MAIN DATABASE PROCESS
# ==========================================

connection = None
cursor = None

try:
    print("Connecting to MySQL...")

    connection = mysql.connector.connect(**DB_CONFIG)
    cursor = connection.cursor()

    # Prevent accidental duplicate imports.
    cursor.execute("SELECT COUNT(*) FROM support_tickets")
    existing_count = cursor.fetchone()[0]

    if existing_count > 0:
        print(
            f"STOPPED: support_tickets already contains "
            f"{existing_count:,} rows."
        )
        print("No records inserted. Check the table first.")
        raise SystemExit(0)

    # Fetch valid customer IDs and their actual emails.
    cursor.execute(
        "SELECT customer_id, EMAIL FROM customers"
    )
    customers = cursor.fetchall()

    if not customers:
        raise ValueError(
            "No customers found. Import customers first."
        )

    if len(customers) < 1000:
        raise ValueError(
            f"Only {len(customers)} customers found. "
            "Check the customers table first."
        )

    print(f"Available customers: {len(customers):,}")
    print(f"Target tickets: {TOTAL_TICKETS:,}")

    insert_sql = """
        INSERT INTO support_tickets (
            customer_id,
            created_at,
            issue_category,
            priority,
            ticket_status,
            resolve_date,
            resolution,
            resolved_by,
            resolution_category,
            contact_email,
            issue_description
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    inserted = 0

    # Insert all batches in one transaction.
    for start in range(0, TOTAL_TICKETS, BATCH_SIZE):
        current_batch_size = min(
            BATCH_SIZE, TOTAL_TICKETS - start
        )

        batch = []

        for _ in range(current_batch_size):
            customer_id, email = random.choice(customers)
            batch.append(generate_ticket(customer_id, email))

        cursor.executemany(insert_sql, batch)
        inserted += len(batch)

        if inserted % 10_000 == 0:
            print(f"Processed {inserted:,}/{TOTAL_TICKETS:,}")

    connection.commit()

    cursor.execute("SELECT COUNT(*) FROM support_tickets")
    final_count = cursor.fetchone()[0]

    print("\nSUPPORT TICKETS IMPORT SUCCESSFUL!")
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
