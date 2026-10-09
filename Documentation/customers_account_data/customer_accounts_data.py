import csv
import random
from datetime import date, timedelta
from pathlib import Path

random.seed(42)

TOTAL_ACCOUNTS = 50_000
OUTPUT_FILE = Path(__file__).parent / "customer_accounts_data.csv"

account_types = ["Basic", "Standard", "Premium"]
account_type_weights = [50, 35, 15]

account_statuses = ["Active", "Closed", "Suspended"]
account_status_weights = [85, 10, 5]

start_date = date(2021, 1, 1)
end_date = date(2026, 10, 1)
date_range = (end_date - start_date).days

with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)

    writer.writerow([
        "customer_id",
        "account_number",
        "account_type",
        "balance",
        "account_status",
        "open_date",
        "closed_date"
    ])

    for customer_id in range(1, TOTAL_ACCOUNTS + 1):
        account_number = f"ACC{customer_id:010d}"

        account_type = random.choices(
            account_types,
            weights=account_type_weights,
            k=1
        )[0]

        account_status = random.choices(
            account_statuses,
            weights=account_status_weights,
            k=1
        )[0]

        open_date = start_date + timedelta(
            days=random.randint(0, date_range)
        )

        closed_date = None
        if account_status == "Closed":
            closed_date = open_date + timedelta(
                days=random.randint(1, max(1, (end_date - open_date).days))
            )
            closed_date = min(closed_date, end_date)

        balance = round(random.uniform(0, 100000), 2)

        writer.writerow([
            customer_id,
            account_number,
            account_type,
            balance,
            account_status,
            open_date.isoformat(),
            closed_date.isoformat() if closed_date else ""
        ])

print(f"Generated {TOTAL_ACCOUNTS:,} account records.")
print(f"CSV saved at: {OUTPUT_FILE}")