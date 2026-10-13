import csv
import mysql.connector
from pathlib import Path
from datetime import date
from decimal import Decimal

CSV_FILE = Path(__file__).parent / "customer_accounts_data.csv"
BATCH_SIZE = 1000

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "SQL_Password",
    "database": "churn_retention_analytics"
}


def main():
    connection = None
    cursor = None

    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()

        if not CSV_FILE.exists():
            raise FileNotFoundError(f"CSV file not found: {CSV_FILE}")

        cursor.execute("SELECT COUNT(*) FROM customers")
        customer_count = cursor.fetchone()[0]

        if customer_count < 50000:
            raise ValueError(
                f"Expected 50,000 customers, found {customer_count}."
            )

        cursor.execute("SELECT COUNT(*) FROM customer_accounts")
        before_count = cursor.fetchone()[0]

        insert_sql = """
            INSERT INTO customer_accounts (
                customer_id,
                account_number,
                account_type,
                balance,
                account_status,
                open_date,
                closed_date
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE
                account_number = VALUES(account_number)
        """

        processed = 0

        with open(CSV_FILE, "r", newline="", encoding="utf-8") as file:
            reader = csv.DictReader(file)
            batch = []

            for row in reader:
                raw_closed_date = row["closed_date"].strip()

                if raw_closed_date in ("", r"\N", "NULL", "None"):
                    closed_date = None
                else:
                    closed_date = date.fromisoformat(raw_closed_date)

                batch.append((
                    int(row["customer_id"]),
                    row["account_number"],
                    row["account_type"],
                    Decimal(row["balance"]),
                    row["account_status"],
                    date.fromisoformat(row["open_date"]),
                    closed_date
                ))

                if len(batch) >= BATCH_SIZE:
                    cursor.executemany(insert_sql, batch)
                    processed += len(batch)
                    batch.clear()

            if batch:
                cursor.executemany(insert_sql, batch)
                processed += len(batch)

        connection.commit()

        cursor.execute("SELECT COUNT(*) FROM customer_accounts")
        after_count = cursor.fetchone()[0]

        print("\nImport completed successfully!")
        print(f"Rows processed from CSV: {processed:,}")
        print(f"Accounts before import: {before_count:,}")
        print(f"Accounts after import: {after_count:,}")
        print(f"New accounts added: {after_count - before_count:,}")

    except Exception as error:
        if connection and connection.is_connected():
            connection.rollback()
        print(f"Import failed: {error}")

    finally:
        if cursor:
            cursor.close()
        if connection and connection.is_connected():
            connection.close()


if __name__ == "__main__":
    main()