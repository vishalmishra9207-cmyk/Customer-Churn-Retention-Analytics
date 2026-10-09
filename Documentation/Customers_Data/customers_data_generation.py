import csv
import random
from datetime import date, timedelta
from pathlib import Path

# Reproducible data for project testing
random.seed(42)

TOTAL_CUSTOMERS = 50_000

# Save CSV in the same folder as this Python script
OUTPUT_FILE = Path(__file__).parent / "customers_data.csv"

# Indian names for synthetic demo data
first_names = [
    "Aarav", "Vivaan", "Aditya", "Arjun", "Rahul", "Amit",
    "Vishal", "Rohit", "Karan", "Ankit", "Suresh", "Rajesh",
    "Priya", "Ananya", "Aditi", "Neha", "Pooja", "Sneha",
    "Kavya", "Isha", "Riya", "Simran", "Meera", "Divya"
]

last_names = [
    "Sharma", "Verma", "Gupta", "Singh", "Mishra", "Yadav",
    "Patel", "Shah", "Kumar", "Jain", "Mehta", "Reddy",
    "Nair", "Iyer", "Das", "Roy", "Joshi", "Malhotra"
]

# Cities mapped to their states
locations = {
    "Uttar Pradesh": ["Lucknow", "Kanpur", "Varanasi", "Agra", "Sitapur"],
    "Maharashtra": ["Mumbai", "Pune", "Nagpur", "Nashik"],
    "Delhi": ["New Delhi", "Delhi"],
    "Karnataka": ["Bengaluru", "Mysuru", "Mangaluru"],
    "Tamil Nadu": ["Chennai", "Coimbatore", "Madurai"],
    "Rajasthan": ["Jaipur", "Jodhpur", "Udaipur"],
    "Gujarat": ["Ahmedabad", "Surat", "Vadodara"],
    "Haryana": ["Gurugram", "Faridabad", "Panipat"],
    "West Bengal": ["Kolkata", "Howrah", "Durgapur"],
    "Madhya Pradesh": ["Bhopal", "Indore", "Jabalpur"],
    "Telangana": ["Hyderabad", "Warangal"],
    "Bihar": ["Patna", "Gaya", "Muzaffarpur"],
    "Punjab": ["Ludhiana", "Amritsar", "Jalandhar"],
    "Kerala": ["Kochi", "Kozhikode", "Thiruvananthapuram"],
    "Odisha": ["Bhubaneswar", "Cuttack"],
    "Assam": ["Guwahati", "Silchar"],
    "Jharkhand": ["Ranchi", "Jamshedpur"],
    "Chhattisgarh": ["Raipur", "Bilaspur"],
    "Uttarakhand": ["Dehradun", "Haridwar"],
    "Himachal Pradesh": ["Shimla", "Dharamshala"]
}

states = list(locations.keys())

# Spread joining dates across the last five years
start_date = date(2021, 1, 1)
end_date = date(2026, 10, 1)
date_range_days = (end_date - start_date).days

# Reserved fictional phone-number range for synthetic datasets:
# 6000000000–6999999999; never use these as real contact details.
used_phones = set()

with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)

    writer.writerow([
        "customer_name",
        "mobile_number",
        "EMAIL",
        "joining_date",
        "age",
        "gender",
        "house_no",
        "street_no",
        "area_name",
        "city",
        "state",
        "country"
    ])

    for i in range(1, TOTAL_CUSTOMERS + 1):
        first = random.choice(first_names)
        last = random.choice(last_names)
        customer_name = f"{first} {last}"

        # Unique synthetic mobile numbers
        while True:
            mobile_number = str(random.randint(6000000000, 6999999999))
            if mobile_number not in used_phones:
                used_phones.add(mobile_number)
                break

        # Unique example-domain email address
        email = f"customer{i:05d}@example.com"

        joining_date = start_date + timedelta(
            days=random.randint(0, date_range_days)
        )

        # Weighted age distribution
        age = random.choices(
            population=[18, 25, 35, 45, 55, 65, 75],
            weights=[8, 22, 25, 20, 14, 8, 3],
            k=1
        )[0] + random.randint(0, 9)

        gender = random.choices(
            population=["MALE", "FEMALE", "OTHERS"],
            weights=[51, 47, 2],
            k=1
        )[0]

        state = random.choice(states)
        city = random.choice(locations[state])

        house_no = f"H-{random.randint(1, 999)}"
        street_no = f"Street {random.randint(1, 100)}"
        area_name = f"Sector {random.randint(1, 50)}"

        writer.writerow([
            customer_name,
            mobile_number,
            email,
            joining_date.isoformat(),
            age,
            gender,
            house_no,
            street_no,
            area_name,
            city,
            state,
            "INDIA"
        ])

print(f"Successfully generated {TOTAL_CUSTOMERS:,} synthetic customers.")
print(f"CSV saved at: {OUTPUT_FILE}")
