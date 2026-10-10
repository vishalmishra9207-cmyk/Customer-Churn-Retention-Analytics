import csv
import random
from datetime import date, datetime, timedelta
from pathlib import Path

random.seed(42)

TOTAL_SUBSCRIPTIONS = 60_000
OUTPUT_FILE = Path(__file__).parent / "subscriptions_data.csv"

# Account IDs must exist in customer_accounts
ACCOUNT_IDS = list(range(1, 50_001))

plan_types = ["Basic", "Standard", "Premium"]
plan_weights = [50, 35, 15]

contract_types = ["Monthly", "One Year", "Two Year"]
contract_weights = [50, 30, 20]

subscription_statuses = [
    "Active", "Hold", "Suspended", "Deactivated", "Terminated"
]
status_weights = [65, 5, 8, 7, 15]

start_date = date(2021, 1, 1)
end_date = date(2026, 10, 1)
date_range = (end_date - start_date).days

with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)

    writer.writerow([
        "account_id",
        "plan_type",
        "contract_type",
        "start_date",
        "end_date",
        "monthly_charges",
        "subscription_status"
    ])

    for _ in range(TOTAL_SUBSCRIPTIONS):
        account_id = random.choice(ACCOUNT_IDS)

        plan_type = random.choices(
            plan_types, weights=plan_weights, k=1
        )[0]

        contract_type = random.choices(
            contract_types, weights=contract_weights, k=1
        )[0]

        subscription_status = random.choices(
            subscription_statuses, weights=status_weights, k=1
        )[0]

        subscription_start = start_date + timedelta(
            days=random.randint(0, date_range)
        )

        # Plan charges in INR, with small realistic variation
        base_charges = {
            "Basic": 399,
            "Standard": 699,
            "Premium": 1199
        }
        monthly_charges = round(
            base_charges[plan_type] + random.uniform(-50, 100), 2
        )
        monthly_charges = max(199, monthly_charges)

        end_date_value = ""

        if subscription_status in ["Deactivated", "Terminated"]:
            latest_end_date = max(subscription_start, end_date)
            end_date_value = (
                subscription_start
                + timedelta(
                    days=random.randint(
                        1, max(1, (latest_end_date - subscription_start).days)
                    )
                )
            )
            end_date_value = min(end_date_value, end_date).isoformat()

        writer.writerow([
            account_id,
            plan_type,
            contract_type,
            datetime.combine(
                subscription_start, datetime.min.time()
            ).strftime("%Y-%m-%d %H:%M:%S"),
            end_date_value,
            f"{monthly_charges:.2f}",
            subscription_status
        ])

print(f"Generated {TOTAL_SUBSCRIPTIONS:,} subscriptions.")
print(f"CSV saved at: {OUTPUT_FILE}")