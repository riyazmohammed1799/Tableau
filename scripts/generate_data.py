"""
DentaKart Analytics — Master Enterprise Data Generator (5M Scale)
Generates 5 full years (2021-2025) of realistic Indian dental distribution data.
Produces clean CSV and Parquet outputs with 100% referential integrity,
plus an isolated synthetic dirty dataset for data quality auditing.

Usage:
    python scripts/generate_data.py --rows 5000000 --batch-size 250000 --seed 42
"""

import os
import sys
import argparse
import time
import math
from datetime import date, datetime, timedelta
import numpy as np
import pandas as pd

# --- Configuration & Paths ---
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CLEAN_CSV_DIR = os.path.join(BASE_DIR, "data", "clean", "csv")
CLEAN_PARQUET_DIR = os.path.join(BASE_DIR, "data", "clean", "parquet")
DIRTY_DIR = os.path.join(BASE_DIR, "data", "dirty")


def save_parquet(df, path):
    try:
        df.to_parquet(path, index=False, engine="fastparquet")
    except Exception:
        df.to_parquet(path, index=False)


def ensure_dirs():
    for d in [CLEAN_CSV_DIR, CLEAN_PARQUET_DIR, DIRTY_DIR]:
        os.makedirs(d, exist_ok=True)
    for fact in ["fact_sales", "fact_orders"]:
        os.makedirs(os.path.join(CLEAN_PARQUET_DIR, fact), exist_ok=True)


def parse_args():
    parser = argparse.ArgumentParser(description="DentaKart 5M+ Enterprise Data Generator")
    parser.add_argument("--rows", type=int, default=5000000, help="Target Fact_Sales rows (default: 5,000,000)")
    parser.add_argument("--batch-size", type=int, default=250000, help="Chunk size for sales lines (default: 250,000)")
    parser.add_argument("--seed", type=int, default=42, help="Deterministic random seed (default: 42)")
    return parser.parse_args()


# ==============================================================================
# 1. DIMENSION GENERATORS
# ==============================================================================

def generate_dim_date():
    print("[1/14] Generating Dim_Date (1,826 days: 2021-01-01 to 2025-12-31)...")
    start_date = date(2021, 1, 1)
    end_date = date(2025, 12, 31)
    delta = (end_date - start_date).days + 1

    records = []
    month_names = ["", "January", "February", "March", "April", "May", "June", 
                   "July", "August", "September", "October", "November", "December"]
    day_names = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    indian_holidays = {126, 815, 1002}

    for i in range(delta):
        curr = start_date + timedelta(days=i)
        d_key = curr.year * 10000 + curr.month * 100 + curr.day
        year = curr.year
        month = curr.month
        day = curr.day
        weekday = curr.weekday()
        quarter = (month - 1) // 3 + 1
        is_weekend = 1 if weekday in (5, 6) else 0

        if month >= 4:
            fy = f"FY{year}-{str(year+1)[-2:]}"
            fq = f"FQ{quarter - 1}"
        else:
            fy = f"FY{year-1}-{str(year)[-2:]}"
            fq = "FQ4"

        mmdd = month * 100 + day
        is_holiday = 1 if mmdd in indian_holidays else 0

        records.append({
            "date_key": d_key,
            "calendar_date": curr.strftime("%Y-%m-%d"),
            "year": year,
            "quarter": quarter,
            "month_number": month,
            "month_name": month_names[month],
            "month_year": f"{year}-{month:02d}",
            "week_of_year": curr.isocalendar()[1],
            "day_of_month": day,
            "day_of_week": weekday + 1,
            "day_name": day_names[weekday],
            "is_weekend": is_weekend,
            "fiscal_year": fy,
            "fiscal_quarter": fq,
            "is_holiday_in": is_holiday
        })

    df = pd.DataFrame(records)
    df.to_csv(os.path.join(CLEAN_CSV_DIR, "dim_date.csv"), index=False)
    save_parquet(df, os.path.join(CLEAN_PARQUET_DIR, "dim_date.parquet"))
    print(f"      Saved Dim_Date ({len(df)} rows).")
    return df


def generate_dim_location():
    print("[2/14] Generating Dim_Location (60 Indian cities across 5 geographic regions)...")
    cities_north = [
        ("Delhi", "Delhi", "North", "Tier 1"),
        ("Noida", "Uttar Pradesh", "North", "Tier 2"),
        ("Gurugram", "Haryana", "North", "Tier 2"),
        ("Faridabad", "Haryana", "North", "Tier 2"),
        ("Ghaziabad", "Uttar Pradesh", "North", "Tier 2"),
        ("Chandigarh", "Punjab", "North", "Tier 2"),
        ("Ludhiana", "Punjab", "North", "Tier 2"),
        ("Amritsar", "Punjab", "North", "Tier 2"),
        ("Jalandhar", "Punjab", "North", "Tier 3"),
        ("Jaipur", "Rajasthan", "North", "Tier 2"),
        ("Jodhpur", "Rajasthan", "North", "Tier 2"),
        ("Lucknow", "Uttar Pradesh", "North", "Tier 2"),
        ("Kanpur", "Uttar Pradesh", "North", "Tier 2"),
        ("Varanasi", "Uttar Pradesh", "North", "Tier 2")
    ]
    cities_south = [
        ("Bengaluru", "Karnataka", "South", "Tier 1"),
        ("Mysuru", "Karnataka", "South", "Tier 2"),
        ("Mangaluru", "Karnataka", "South", "Tier 2"),
        ("Hubballi", "Karnataka", "South", "Tier 3"),
        ("Chennai", "Tamil Nadu", "South", "Tier 1"),
        ("Coimbatore", "Tamil Nadu", "South", "Tier 2"),
        ("Madurai", "Tamil Nadu", "South", "Tier 2"),
        ("Tiruchirappalli", "Tamil Nadu", "South", "Tier 2"),
        ("Salem", "Tamil Nadu", "South", "Tier 3"),
        ("Hyderabad", "Telangana", "South", "Tier 1"),
        ("Warangal", "Telangana", "South", "Tier 3"),
        ("Visakhapatnam", "Andhra Pradesh", "South", "Tier 2"),
        ("Vijayawada", "Andhra Pradesh", "South", "Tier 2"),
        ("Guntur", "Andhra Pradesh", "South", "Tier 3"),
        ("Kochi", "Kerala", "South", "Tier 2"),
        ("Thiruvananthapuram", "Kerala", "South", "Tier 2")
    ]
    cities_west = [
        ("Mumbai", "Maharashtra", "West", "Tier 1"),
        ("Pune", "Maharashtra", "West", "Tier 1"),
        ("Nagpur", "Maharashtra", "West", "Tier 2"),
        ("Nashik", "Maharashtra", "West", "Tier 2"),
        ("Aurangabad", "Maharashtra", "West", "Tier 2"),
        ("Solapur", "Maharashtra", "West", "Tier 3"),
        ("Kolhapur", "Maharashtra", "West", "Tier 3"),
        ("Thane", "Maharashtra", "West", "Tier 2"),
        ("Navi Mumbai", "Maharashtra", "West", "Tier 2"),
        ("Ahmedabad", "Gujarat", "West", "Tier 1"),
        ("Surat", "Gujarat", "West", "Tier 1"),
        ("Vadodara", "Gujarat", "West", "Tier 2"),
        ("Rajkot", "Gujarat", "West", "Tier 2"),
        ("Bhavnagar", "Gujarat", "West", "Tier 3"),
        ("Panaji", "Goa", "West", "Tier 3")
    ]
    cities_east = [
        ("Kolkata", "West Bengal", "East", "Tier 1"),
        ("Howrah", "West Bengal", "East", "Tier 2"),
        ("Siliguri", "West Bengal", "East", "Tier 3"),
        ("Patna", "Bihar", "East", "Tier 2"),
        ("Gaya", "Bihar", "East", "Tier 3"),
        ("Bhubaneswar", "Odisha", "East", "Tier 2"),
        ("Ranchi", "Jharkhand", "East", "Tier 2"),
        ("Jamshedpur", "Jharkhand", "East", "Tier 2"),
        ("Guwahati", "Assam", "East", "Tier 2")
    ]
    cities_central = [
        ("Bhopal", "Madhya Pradesh", "Central", "Tier 2"),
        ("Indore", "Madhya Pradesh", "Central", "Tier 2"),
        ("Gwalior", "Madhya Pradesh", "Central", "Tier 3"),
        ("Jabalpur", "Madhya Pradesh", "Central", "Tier 3"),
        ("Ujjain", "Madhya Pradesh", "Central", "Tier 3"),
        ("Raipur", "Chhattisgarh", "Central", "Tier 2")
    ]

    expected_region_counts = {
        "North": 14,
        "South": 16,
        "West": 15,
        "East": 9,
        "Central": 6
    }
    regional_groups = {
        "North": cities_north,
        "South": cities_south,
        "West": cities_west,
        "East": cities_east,
        "Central": cities_central
    }
    for region_name, expected_count in expected_region_counts.items():
        actual_count = len(regional_groups[region_name])
        assert actual_count == expected_count, (
            f"Regional coverage validation failed for {region_name}: "
            f"expected {expected_count}, got {actual_count}"
        )

    cities_data = cities_north + cities_south + cities_west + cities_east + cities_central
    assert len(cities_data) == 60, f"Expected exactly 60 cities, got {len(cities_data)}"

    records = []
    for idx, (city, state, region, tier) in enumerate(cities_data, start=101):
        records.append({
            "city_id": idx,
            "city_name": city,
            "state_name": state,
            "customer_geographic_region": region,
            "city_tier": tier
        })

    df = pd.DataFrame(records)
    df.to_csv(os.path.join(CLEAN_CSV_DIR, "dim_location.csv"), index=False)
    save_parquet(df, os.path.join(CLEAN_PARQUET_DIR, "dim_location.parquet"))
    print(f"      Saved Dim_Location ({len(df)} rows).")
    return df


def generate_dim_warehouse():
    print("[3/14] Generating Dim_Warehouse (6 fulfillment hubs)...")
    warehouses = [
        {"warehouse_id": 1, "warehouse_name": "Bhiwandi Hub (Mumbai)", "state_name": "Maharashtra"},
        {"warehouse_id": 2, "warehouse_name": "Gurgaon Hub (Delhi-NCR)", "state_name": "Haryana"},
        {"warehouse_id": 3, "warehouse_name": "Nelamangala Hub (Bengaluru)", "state_name": "Karnataka"},
        {"warehouse_id": 4, "warehouse_name": "Kolkata Hub", "state_name": "West Bengal"},
        {"warehouse_id": 5, "warehouse_name": "Hyderabad Hub", "state_name": "Telangana"},
        {"warehouse_id": 6, "warehouse_name": "Chennai Hub", "state_name": "Tamil Nadu"}
    ]
    df = pd.DataFrame(warehouses)
    df.to_csv(os.path.join(CLEAN_CSV_DIR, "dim_warehouse.csv"), index=False)
    save_parquet(df, os.path.join(CLEAN_PARQUET_DIR, "dim_warehouse.parquet"))
    print(f"      Saved Dim_Warehouse ({len(df)} rows).")
    return df


def generate_dim_supplier():
    print("[4/14] Generating Dim_Supplier (50 OEM manufacturers)...")
    names = [
        ("Kavo Kerr Dental", "Germany"), ("Dentsply Sirona India", "USA"), ("Ivoclar Vivadent", "Switzerland"),
        ("Planmeca Imaging", "Finland"), ("W&H Dentalwerk", "Austria"), ("Septodont Healthcare", "France"),
        ("GC India Dental", "Japan"), ("3M Oral Care", "USA"), ("Acteon Imaging", "France"),
        ("Carestream Dental", "USA"), ("Waldent Innovations", "India"), ("Unicorn DenMart", "India"),
        ("Confident Dental Care", "India"), ("Gnatus Dental Equipments", "Brazil"), ("Anthos Dental", "Italy"),
        ("Castellini Dental Systems", "Italy"), ("NSK Nakanishi", "Japan"), ("Morita Corporation", "Japan"),
        ("Woodpecker Medical", "China"), ("Dabi Atlante", "Brazil"), ("Mectron Medical", "Italy"),
        ("Bego Dental", "Germany"), ("Shofu Dental", "Japan"), ("Kulzer Dental", "Germany"),
        ("Kuraray Noritake", "Japan"), ("VITA Zahnfabrik", "Germany"), ("Coltene Whaledent", "Switzerland"),
        ("Bisco Dental Products", "USA"), ("Ultradent Products", "USA"), ("Hu-Friedy Group", "USA"),
        ("Kerr Restoratives", "USA"), ("DiaDent Group", "Korea"), ("Meta Biomed", "Korea"),
        ("Vatech Global", "Korea"), ("Genoray Imaging", "Korea"), ("Eighteeth Medical", "China"),
        ("Coxotec Dental", "China"), ("Cefla Medical Equipment", "Italy"), ("Euronda Sterilization", "Italy"),
        ("Melag Medizintechnik", "Germany"), ("Tuttnauer Sterilization", "USA"), ("SciCan Medical", "Canada"),
        ("Midmark Corporation", "USA"), ("A-dec Dental", "USA"), ("Belmont Dental", "Japan"),
        ("Takara Belmont", "Japan"), ("Osstem Implant", "Korea"), ("Dentium Implants", "Korea"),
        ("Straumann India", "Switzerland"), ("Nobel Biocare India", "Sweden")
    ]
    records = [{"supplier_id": i, "supplier_name": n, "country": c} for i, (n, c) in enumerate(names, start=1)]
    df = pd.DataFrame(records)
    df.to_csv(os.path.join(CLEAN_CSV_DIR, "dim_supplier.csv"), index=False)
    save_parquet(df, os.path.join(CLEAN_PARQUET_DIR, "dim_supplier.parquet"))
    print(f"      Saved Dim_Supplier ({len(df)} rows).")
    return df


def generate_dim_channel():
    print("[5/14] Generating Dim_Channel (5 commercial channels)...")
    channels = [
        {"channel_id": 1, "channel_name": "Direct Field Sales"},
        {"channel_id": 2, "channel_name": "B2B eCommerce Portal"},
        {"channel_id": 3, "channel_name": "Inside Sales"},
        {"channel_id": 4, "channel_name": "Distributor Network"},
        {"channel_id": 5, "channel_name": "Institutional Tender"}
    ]
    df = pd.DataFrame(channels)
    df.to_csv(os.path.join(CLEAN_CSV_DIR, "dim_channel.csv"), index=False)
    save_parquet(df, os.path.join(CLEAN_PARQUET_DIR, "dim_channel.parquet"))
    print(f"      Saved Dim_Channel ({len(df)} rows).")
    return df


def generate_dim_salesperson(num_reps=500):
    print(f"[6/14] Generating Dim_Salesperson ({num_reps} reps across 5 territory regions)...")
    regions = ["North", "South", "West", "East", "Central"]
    region_weights = [0.24, 0.28, 0.26, 0.12, 0.10]

    first_names = ["Rajesh", "Amit", "Pooja", "Vikram", "Sneha", "Rohan", "Ananya", "Suresh",
                   "Deepak", "Priya", "Manoj", "Kavita", "Arun", "Divya", "Sanjay", "Neha",
                   "Gaurav", "Swati", "Naveen", "Meera", "Rahul", "Preeti", "Kiran", "Ashok"]
    last_names = ["Sharma", "Varma", "Patel", "Reddy", "Nair", "Iyer", "Mehta", "Singh",
                  "Gupta", "Deshmukh", "Joshi", "Bose", "Banerjee", "Chopra", "Kulkarni", "Rao"]

    np.random.seed(42)
    assigned_regions = np.random.choice(regions, size=num_reps, p=region_weights)
    
    records = []
    for i in range(1, num_reps + 1):
        fn = np.random.choice(first_names)
        ln = np.random.choice(last_names)
        full_name = f"{fn} {ln}"
        email = f"{fn.lower()}.{ln.lower()}{i}@dentakart.in"
        reg = assigned_regions[i - 1]
        
        if i <= 10:
            mgr_id = None
        else:
            mgr_id = (i % 10) + 1

        hire_year = np.random.choice([2018, 2019, 2020, 2021, 2022], p=[0.2, 0.2, 0.3, 0.2, 0.1])
        hire_month = np.random.randint(1, 13)
        hire_day = np.random.randint(1, 28)
        hire_date = f"{hire_year}-{hire_month:02d}-{hire_day:02d}"

        records.append({
            "salesperson_id": i,
            "salesperson_name": full_name,
            "email": email,
            "sales_territory_region": reg,
            "manager_id": mgr_id,
            "hire_date": hire_date,
            "is_active": 1
        })

    df = pd.DataFrame(records)
    df["manager_id"] = pd.to_numeric(df["manager_id"]).astype("Int64")
    df.to_csv(os.path.join(CLEAN_CSV_DIR, "dim_salesperson.csv"), index=False)
    save_parquet(df, os.path.join(CLEAN_PARQUET_DIR, "dim_salesperson.parquet"))
    print(f"      Saved Dim_Salesperson ({len(df)} rows).")
    return df


def generate_dim_product(num_products=1000):
    print(f"[7/14] Generating Dim_Product ({num_products} SKUs with 4 Target Categories + Non-Targeted)...")
    np.random.seed(42)

    categories_spec = [
        ("Dental Capital Equipment", [
            ("Dental Chairs", 60, (120000.0, 750000.0), 1, 0.18, 24),
            ("Compressors", 40, (25000.0, 110000.0), 1, 0.18, 12),
            ("Suction Systems", 30, (35000.0, 140000.0), 1, 0.18, 12),
            ("Surgical Lasers", 20, (180000.0, 650000.0), 1, 0.18, 24)
        ]),
        ("Dental Clinical Consumables", [
            ("Composite Resins", 120, (800.0, 3800.0), 0, 0.12, 0),
            ("Bonding & Adhesives", 80, (1200.0, 4500.0), 0, 0.12, 0),
            ("Impression Materials", 90, (650.0, 3200.0), 0, 0.12, 0),
            ("Dental Burs & Rotary", 80, (300.0, 1800.0), 0, 0.12, 0),
            ("Endodontic Files", 80, (750.0, 2900.0), 0, 0.12, 0)
        ]),
        ("Digital Imaging & Radiology", [
            ("RVG Sensors", 40, (85000.0, 220000.0), 1, 0.18, 24),
            ("Intraoral Scanners", 30, (450000.0, 1800000.0), 1, 0.18, 24),
            ("Portable X-Ray Units", 30, (65000.0, 160000.0), 1, 0.18, 12),
            ("OPG & CBCT Scanners", 20, (950000.0, 3200000.0), 1, 0.18, 36)
        ]),
        ("Sterilization & Infection Control", [
            ("Autoclaves (Class B)", 50, (65000.0, 280000.0), 1, 0.18, 24),
            ("Ultrasonic Cleaners", 30, (18000.0, 65000.0), 1, 0.18, 12),
            ("Pouch Sealing Units", 20, (12000.0, 35000.0), 1, 0.18, 12)
        ]),
        ("General / Non-Targeted", [
            ("Air Turbine Handpieces", 60, (4500.0, 28000.0), 0, 0.12, 6),
            ("Micromotors", 40, (8500.0, 35000.0), 0, 0.18, 12),
            ("Ultrasonic Scalers", 40, (6500.0, 32000.0), 0, 0.18, 12),
            ("Dental Lab Furnaces", 40, (140000.0, 480000.0), 1, 0.18, 24)
        ])
    ]

    records = []
    prod_id = 1
    brands = ["DentaPro", "ApexDent", "AlphaDent", "TitaniumPlus", "OmniDent", "Precision", "MaxiCare"]

    for cat_name, subcats in categories_spec:
        for subcat_name, count, (price_min, price_max), is_capital, gst, warranty in subcats:
            for _ in range(count):
                brand = np.random.choice(brands)
                sku = f"DK-{cat_name[:3].upper()}-{subcat_name[:3].upper()}-{prod_id:04d}"
                name = f"{brand} {subcat_name} {np.random.choice(['Pro', 'Elite', 'Plus', 'Ultra', 'Classic'])} Model-{prod_id%100:02d}"
                list_price = round(float(np.random.uniform(price_min, price_max)), 2)
                margin_pct = np.random.uniform(0.22, 0.35)
                unit_cost = round(list_price * (1.0 - margin_pct), 2)
                supplier_id = np.random.randint(1, 51)

                records.append({
                    "product_id": prod_id,
                    "product_sku": sku,
                    "product_name": name,
                    "target_category": cat_name,
                    "sub_category": subcat_name,
                    "brand": brand,
                    "supplier_id": supplier_id,
                    "unit_cost_inr": unit_cost,
                    "list_price_inr": list_price,
                    "is_capital_equipment": is_capital,
                    "gst_rate": gst,
                    "warranty_months": warranty
                })
                prod_id += 1

    df = pd.DataFrame(records)
    df.to_csv(os.path.join(CLEAN_CSV_DIR, "dim_product.csv"), index=False)
    save_parquet(df, os.path.join(CLEAN_PARQUET_DIR, "dim_product.parquet"))
    print(f"      Saved Dim_Product ({len(df)} rows).")
    return df


def generate_dim_customer(num_customers=100000):
    print(f"[8/14] Generating Dim_Customer ({num_customers} dental accounts)...")
    np.random.seed(42)

    cust_types = ["Dental Clinic", "Hospital Chain", "Dental College", "Dental Laboratory", "Distributor"]
    cust_weights = [0.75, 0.10, 0.05, 0.05, 0.05]

    cust_tiers = ["Platinum", "Gold", "Standard", "Value"]
    tier_weights = [0.05, 0.20, 0.45, 0.30]

    prefixes = ["Dr. Sharma", "Dr. Patel", "Dr. Varma", "Dr. Rao", "Dr. Nair", "Dr. Gupta", "Dr. Iyer", "Dr. Mehta"]
    specialties = ["Orthodontic Care", "Dental Implantology", "Multi-Specialty Clinic", "Aesthetic Dental Center", 
                   "Dental Studio", "Smile Center", "Oral & Maxillofacial", "Laser Dental Care"]
    hospitals = ["Apollo White Dental", "Clove Dental Care", "Axiss Dental", "Fortis Dental Sciences", "Max Healthcare Dental"]
    colleges = ["Government Dental College", "Manipal College of Dental Sciences", "Maulana Azad Dental Institute", "SRM Dental College"]
    labs = ["Crest Dental Prosthetics Lab", "Apex Crown & Bridge Lab", "Precision Milling Center", "Digital Dental Studio Lab"]
    distributors = ["Apex Dental Supplies", "MediDent Wholesalers", "DentSupply Enterprises", "National Dental Trade"]

    types_arr = np.random.choice(cust_types, size=num_customers, p=cust_weights)
    tiers_arr = np.random.choice(cust_tiers, size=num_customers, p=tier_weights)
    city_ids_arr = np.random.randint(101, 161, size=num_customers)

    onboard_start = date(2020, 1, 1).toordinal()
    onboard_end = date(2024, 12, 31).toordinal()
    onboard_ordinals = np.random.randint(onboard_start, onboard_end, size=num_customers)

    credit_limits = {
        "Platinum": 1500000.0,
        "Gold": 500000.0,
        "Standard": 200000.0,
        "Value": 50000.0
    }

    records = []
    for i in range(1, num_customers + 1):
        c_type = types_arr[i - 1]
        c_tier = tiers_arr[i - 1]
        c_city = int(city_ids_arr[i - 1])
        onboard_dt = date.fromordinal(int(onboard_ordinals[i - 1])).strftime("%Y-%m-%d")

        if c_type == "Dental Clinic":
            c_name = f"{np.random.choice(prefixes)} {np.random.choice(specialties)}"
        elif c_type == "Hospital Chain":
            c_name = f"{np.random.choice(hospitals)} Branch-{i%200:03d}"
        elif c_type == "Dental College":
            c_name = f"{np.random.choice(colleges)} Campus-{i%50:02d}"
        elif c_type == "Dental Laboratory":
            c_name = f"{np.random.choice(labs)} Unit-{i%100:02d}"
        else:
            c_name = f"{np.random.choice(distributors)} Agency-{i%100:02d}"

        pincode = f"{c_city * 37 % 899999 + 100000}"

        records.append({
            "customer_id": i,
            "customer_name": c_name,
            "customer_type": c_type,
            "customer_tier": c_tier,
            "city_id": c_city,
            "pin_code": pincode,
            "onboarding_date": onboard_dt,
            "credit_limit_inr": credit_limits[c_tier],
            "is_active": 1
        })

    df = pd.DataFrame(records)
    df.to_csv(os.path.join(CLEAN_CSV_DIR, "dim_customer.csv"), index=False)
    save_parquet(df, os.path.join(CLEAN_PARQUET_DIR, "dim_customer.parquet"))
    print(f"      Saved Dim_Customer ({len(df)} rows).")
    return df


# ==============================================================================
# 2. FACT GENERATORS: TARGETS & INVENTORY SNAPSHOT
# ==============================================================================

def generate_fact_sales_targets(salesperson_df):
    print("[9/14] Generating Fact_Sales_Targets (120,000 rows: 60 months x 500 reps x 4 categories)...")
    np.random.seed(42)

    target_categories = [
        ("Dental Capital Equipment", 800000.0, 2200000.0, 0.22),
        ("Dental Clinical Consumables", 500000.0, 1500000.0, 0.30),
        ("Digital Imaging & Radiology", 600000.0, 2500000.0, 0.20),
        ("Sterilization & Infection Control", 300000.0, 900000.0, 0.25)
    ]

    months = []
    for y in range(2021, 2026):
        for m in range(1, 13):
            months.append(y * 10000 + m * 100 + 1)

    records = []
    target_id = 1
    reps_data = salesperson_df[["salesperson_id", "sales_territory_region"]].values

    for m_key in months:
        year = m_key // 10000
        yoy_mult = 1.0 + (year - 2021) * 0.12
        month = (m_key % 10000) // 100
        season_mult = 1.25 if month in (1, 2, 3) else 1.0

        for rep_id, territory_region in reps_data:
            for cat_name, base_min, base_max, margin_pct in target_categories:
                target_sales = round(float(np.random.uniform(base_min, base_max) * yoy_mult * season_mult), 2)
                target_profit = round(target_sales * margin_pct, 2)

                records.append({
                    "target_id": target_id,
                    "target_month_key": m_key,
                    "region": territory_region,
                    "salesperson_id": rep_id,
                    "target_category": cat_name,
                    "target_sales_inr": target_sales,
                    "target_gross_profit_inr": target_profit
                })
                target_id += 1

    df = pd.DataFrame(records)
    df.to_csv(os.path.join(CLEAN_CSV_DIR, "fact_sales_targets.csv"), index=False)
    save_parquet(df, os.path.join(CLEAN_PARQUET_DIR, "fact_sales_targets.parquet"))
    print(f"      Saved Fact_Sales_Targets ({len(df)} rows).")
    return df


def generate_fact_inventory_snapshot(product_df):
    print("[10/14] Generating Fact_Inventory_Snapshot (360,000 rows: 1,000 products x 6 warehouses x 60 month-ends)...")
    np.random.seed(42)

    month_ends = []
    for y in range(2021, 2026):
        for m in range(1, 13):
            if m in (1, 3, 5, 7, 8, 10, 12):
                d = 31
            elif m in (4, 6, 9, 11):
                d = 30
            else:
                d = 29 if (y % 4 == 0 and y != 1900) else 28
            month_ends.append(y * 10000 + m * 100 + d)

    prod_ids = product_df["product_id"].values
    prod_costs = product_df["unit_cost_inr"].values
    prod_is_cap = product_df["is_capital_equipment"].values
    num_prods = len(prod_ids)
    num_warehouses = 6

    records = []
    snapshot_id = 1

    for dt_key in month_ends:
        for wh_id in range(1, num_warehouses + 1):
            closing_qtys = np.where(prod_is_cap == 1,
                                    np.random.randint(2, 25, size=num_prods),
                                    np.random.randint(40, 600, size=num_prods))
            reorder_points = np.where(prod_is_cap == 1,
                                      np.random.randint(4, 10, size=num_prods),
                                      np.random.randint(60, 120, size=num_prods))
            stock_values = np.round(closing_qtys * prod_costs, 2)
            is_below = (closing_qtys <= reorder_points).astype(int)

            for p_idx in range(num_prods):
                records.append({
                    "snapshot_id": snapshot_id,
                    "snapshot_date_key": dt_key,
                    "product_id": int(prod_ids[p_idx]),
                    "warehouse_id": wh_id,
                    "closing_stock_qty": int(closing_qtys[p_idx]),
                    "reorder_point_qty": int(reorder_points[p_idx]),
                    "stock_value_inr": float(stock_values[p_idx]),
                    "is_below_reorder": int(is_below[p_idx])
                })
                snapshot_id += 1

    df = pd.DataFrame(records)
    df.to_csv(os.path.join(CLEAN_CSV_DIR, "fact_inventory_snapshot.csv"), index=False)
    save_parquet(df, os.path.join(CLEAN_PARQUET_DIR, "fact_inventory_snapshot.parquet"))
    print(f"      Saved Fact_Inventory_Snapshot ({len(df)} rows).")
    return df


# ==============================================================================
# 3. STREAMING CHUNKED ENGINE: FACT_ORDERS & FACT_SALES (5M ROWS)
# ==============================================================================

def generate_fact_sales_and_orders(total_lines=5000000, batch_size=250000,
                                   product_df=None, customer_df=None, salesperson_df=None, date_df=None):
    print(f"[11/14] Streaming Fact_Sales ({total_lines:,} rows) & Fact_Orders (~1,250,000 headers)...")
    np.random.seed(42)

    num_batches = math.ceil(total_lines / batch_size)
    lines_per_order_avg = 4.0

    p_ids = product_df["product_id"].values
    p_costs = product_df["unit_cost_inr"].values
    p_prices = product_df["list_price_inr"].values
    p_gsts = product_df["gst_rate"].values
    p_is_cap = product_df["is_capital_equipment"].values
    num_products = len(p_ids)

    num_cust = len(customer_df)
    cust_ids = customer_df["customer_id"].values
    cust_weights = np.zeros(num_cust)
    cust_weights[:int(num_cust * 0.10)] = 0.45 / int(num_cust * 0.10)
    cust_weights[int(num_cust * 0.10):] = 0.55 / (num_cust - int(num_cust * 0.10))

    date_keys = date_df["date_key"].values
    years = date_df["year"].values
    months = date_df["month_number"].values
    
    base_year_weight = {2021: 0.12, 2022: 0.16, 2023: 0.20, 2024: 0.24, 2025: 0.28}
    date_weights = np.array([base_year_weight[y] for y in years])
    for i, m in enumerate(months):
        if m in (1, 2, 3):
            date_weights[i] *= 1.25
        elif m in (10, 11) and (date_keys[i] % 100 in range(20, 28)):
            date_weights[i] *= 0.60
    date_weights /= date_weights.sum()

    rep_ids = salesperson_df["salesperson_id"].values
    channels = [1, 2, 3, 4, 5]
    channel_weights = [0.40, 0.25, 0.15, 0.15, 0.05]
    warehouses = [1, 2, 3, 4, 5, 6]
    wh_weights = [0.30, 0.25, 0.20, 0.10, 0.08, 0.07]
    order_statuses = ["Delivered", "Delivered", "Delivered", "Delivered", "Shipped", "Cancelled"]
    status_weights = [0.85, 0.0, 0.0, 0.0, 0.10, 0.05]
    payment_methods = ["NEFT/RTGS", "Credit Card", "Net Banking", "UPI / Razorpay", "Cheque / 30-Day Credit"]
    payment_weights = [0.35, 0.25, 0.15, 0.15, 0.10]

    sales_csv_path = os.path.join(CLEAN_CSV_DIR, "fact_sales.csv")
    orders_csv_path = os.path.join(CLEAN_CSV_DIR, "fact_orders.csv")

    sales_cols = [
        "order_line_id", "order_id", "line_number", "order_date_key", "customer_id",
        "product_id", "salesperson_id", "warehouse_id", "channel_id", "quantity",
        "unit_cost_inr", "list_price_inr", "discount_pct", "discount_amount_inr",
        "gross_sales_inr", "net_sales_inr", "cogs_inr", "gross_profit_inr",
        "gross_margin_pct", "gst_tax_rate", "gst_tax_amount_inr", "is_returned"
    ]
    orders_cols = [
        "order_id", "order_number", "order_date", "order_date_key", "customer_id",
        "channel_id", "salesperson_id", "warehouse_id", "shipping_date",
        "order_status", "payment_method", "total_order_lines", "total_net_amount_inr",
        "total_tax_amount_inr", "shipping_cost_inr"
    ]

    with open(sales_csv_path, "w", encoding="utf-8") as f:
        f.write(",".join(sales_cols) + "\n")
    with open(orders_csv_path, "w", encoding="utf-8") as f:
        f.write(",".join(orders_cols) + "\n")

    current_order_id = 1
    current_line_id = 1
    total_sales_generated = 0
    total_orders_generated = 0

    returned_lines_sample = []
    capital_lines_sample = []

    start_time = time.time()

    for b in range(num_batches):
        batch_lines_target = min(batch_size, total_lines - total_sales_generated)
        if batch_lines_target <= 0:
            break

        b_orders = int(round(batch_lines_target / lines_per_order_avg))
        lines_counts = np.random.choice([1, 2, 3, 4, 5, 6, 7], size=b_orders, p=[0.15, 0.20, 0.25, 0.20, 0.10, 0.06, 0.04])
        
        diff = batch_lines_target - lines_counts.sum()
        if diff > 0:
            lines_counts[:diff] += 1
        elif diff < 0:
            lines_counts[:abs(diff)] = np.maximum(1, lines_counts[:abs(diff)] - 1)
        
        actual_lines_in_batch = lines_counts.sum()

        b_order_ids = np.arange(current_order_id, current_order_id + b_orders)
        b_date_indices = np.random.choice(len(date_keys), size=b_orders, p=date_weights)
        b_date_keys = date_keys[b_date_indices]
        b_cust_ids = np.random.choice(cust_ids, size=b_orders, p=cust_weights)
        b_rep_ids = np.random.choice(rep_ids, size=b_orders)
        b_ch_ids = np.random.choice(channels, size=b_orders, p=channel_weights)
        b_wh_ids = np.random.choice(warehouses, size=b_orders, p=wh_weights)
        b_statuses = np.random.choice(["Delivered", "Shipped", "Cancelled"], size=b_orders, p=[0.85, 0.10, 0.05])
        b_payments = np.random.choice(payment_methods, size=b_orders, p=payment_weights)

        shipping_dates = []
        order_dates_str = []
        for dk, st in zip(b_date_keys, b_statuses):
            d_obj = datetime.strptime(str(dk), "%Y%m%d").date()
            order_dates_str.append(d_obj.strftime("%Y-%m-%d"))
            if st in ("Delivered", "Shipped"):
                shp = d_obj + timedelta(days=int(np.random.randint(2, 6)))
                shipping_dates.append(shp.strftime("%Y-%m-%d"))
            else:
                shipping_dates.append(None)

        line_order_ids = np.repeat(b_order_ids, lines_counts)
        line_date_keys = np.repeat(b_date_keys, lines_counts)
        line_cust_ids = np.repeat(b_cust_ids, lines_counts)
        line_rep_ids = np.repeat(b_rep_ids, lines_counts)
        line_ch_ids = np.repeat(b_ch_ids, lines_counts)
        line_wh_ids = np.repeat(b_wh_ids, lines_counts)
        line_statuses = np.repeat(b_statuses, lines_counts)

        line_numbers = np.concatenate([np.arange(1, cnt + 1) for cnt in lines_counts])
        line_ids = np.arange(current_line_id, current_line_id + actual_lines_in_batch)

        prod_indices = np.random.choice(num_products, size=actual_lines_in_batch)
        line_p_ids = p_ids[prod_indices]
        line_costs = p_costs[prod_indices]
        line_prices = p_prices[prod_indices]
        line_gsts = p_gsts[prod_indices]
        line_is_cap = p_is_cap[prod_indices]

        line_qtys = np.where(line_is_cap == 1,
                             np.random.choice([1, 2], size=actual_lines_in_batch, p=[0.85, 0.15]),
                             np.random.randint(2, 35, size=actual_lines_in_batch))

        line_discounts = np.round(np.random.uniform(0.00, 0.22, size=actual_lines_in_batch), 4)

        gross_sales = np.round(line_qtys * line_prices, 2)
        disc_amounts = np.round(gross_sales * line_discounts, 2)
        net_sales = np.round(gross_sales - disc_amounts, 2)
        cogs = np.round(line_qtys * line_costs, 2)
        gross_profits = np.round(net_sales - cogs, 2)
        margin_pcts = np.round((gross_profits / np.maximum(1.0, net_sales)) * 100.0, 4)
        gst_amounts = np.round(net_sales * line_gsts, 2)

        is_returned = np.where((line_statuses == "Delivered") & (np.random.rand(actual_lines_in_batch) < 0.044), 1, 0)

        ret_mask = (is_returned == 1)
        if np.any(ret_mask):
            for lid, oid, dkey, pid, qty, nsale in zip(line_ids[ret_mask], line_order_ids[ret_mask], 
                                                        line_date_keys[ret_mask], line_p_ids[ret_mask], 
                                                        line_qtys[ret_mask], net_sales[ret_mask]):
                returned_lines_sample.append((lid, oid, dkey, pid, qty, nsale))

        cap_mask = (line_is_cap == 1) & (line_statuses == "Delivered")
        if np.any(cap_mask):
            for lid, pid, cid, dkey in zip(line_ids[cap_mask], line_p_ids[cap_mask], line_cust_ids[cap_mask], line_date_keys[cap_mask]):
                capital_lines_sample.append((lid, pid, cid, dkey))

        order_net_sums = np.bincount(line_order_ids - current_order_id, weights=net_sales, minlength=b_orders)
        order_tax_sums = np.bincount(line_order_ids - current_order_id, weights=gst_amounts, minlength=b_orders)
        order_shipping = np.where(order_net_sums > 25000.0, 0.0, np.random.uniform(250.0, 850.0, size=b_orders))
        order_shipping = np.round(order_shipping, 2)

        sales_chunk_df = pd.DataFrame({
            "order_line_id": line_ids,
            "order_id": line_order_ids,
            "line_number": line_numbers,
            "order_date_key": line_date_keys,
            "customer_id": line_cust_ids,
            "product_id": line_p_ids,
            "salesperson_id": line_rep_ids,
            "warehouse_id": line_wh_ids,
            "channel_id": line_ch_ids,
            "quantity": line_qtys,
            "unit_cost_inr": line_costs,
            "list_price_inr": line_prices,
            "discount_pct": line_discounts,
            "discount_amount_inr": disc_amounts,
            "gross_sales_inr": gross_sales,
            "net_sales_inr": net_sales,
            "cogs_inr": cogs,
            "gross_profit_inr": gross_profits,
            "gross_margin_pct": margin_pcts,
            "gst_tax_rate": line_gsts,
            "gst_tax_amount_inr": gst_amounts,
            "is_returned": is_returned
        })

        orders_chunk_df = pd.DataFrame({
            "order_id": b_order_ids,
            "order_number": [f"DK-ORD-{dstr[:4]}-{oid:07d}" for oid, dstr in zip(b_order_ids, order_dates_str)],
            "order_date": order_dates_str,
            "order_date_key": b_date_keys,
            "customer_id": b_cust_ids,
            "channel_id": b_ch_ids,
            "salesperson_id": b_rep_ids,
            "warehouse_id": b_wh_ids,
            "shipping_date": shipping_dates,
            "order_status": b_statuses,
            "payment_method": b_payments,
            "total_order_lines": lines_counts,
            "total_net_amount_inr": np.round(order_net_sums, 2),
            "total_tax_amount_inr": np.round(order_tax_sums, 2),
            "shipping_cost_inr": order_shipping
        })

        sales_chunk_df.to_csv(sales_csv_path, mode="a", header=False, index=False)
        orders_chunk_df.to_csv(orders_csv_path, mode="a", header=False, index=False)

        sales_parquet_path = os.path.join(CLEAN_PARQUET_DIR, "fact_sales", f"fact_sales_chunk_{b:02d}.parquet")
        orders_parquet_path = os.path.join(CLEAN_PARQUET_DIR, "fact_orders", f"fact_orders_chunk_{b:02d}.parquet")
        save_parquet(sales_chunk_df, sales_parquet_path)
        save_parquet(orders_chunk_df, orders_parquet_path)

        current_order_id += b_orders
        current_line_id += actual_lines_in_batch
        total_sales_generated += actual_lines_in_batch
        total_orders_generated += b_orders

        elapsed = time.time() - start_time
        pct = (total_sales_generated / total_lines) * 100.0
        print(f"      Batch {b+1:02d}/{num_batches:02d} -> {total_sales_generated:,} / {total_lines:,} lines ({pct:.1f}%) | "
              f"{total_orders_generated:,} orders | Elapsed: {elapsed:.1f}s")

    print(f"      Completed Fact_Sales ({total_sales_generated:,} rows) & Fact_Orders ({total_orders_generated:,} rows).")
    return returned_lines_sample, capital_lines_sample


# ==============================================================================
# 4. DOWNSTREAM OPERATIONAL FACTS: RETURNS & SERVICE
# ==============================================================================

def generate_fact_returns(returned_lines):
    print(f"[12/14] Generating Fact_Returns (~{len(returned_lines):,} rows)...")
    np.random.seed(42)

    reasons = [
        "Defective/Malfunction", "Damaged in Transit", "Wrong Item Shipped",
        "Order Cancelled Post-Dispatch", "Customer Dissatisfaction"
    ]
    reason_weights = [0.35, 0.25, 0.15, 0.15, 0.10]

    records = []
    for ret_id, (lid, oid, dkey, pid, qty, nsale) in enumerate(returned_lines, start=1):
        ret_qty = int(np.random.randint(1, qty + 1))
        dt_obj = datetime.strptime(str(dkey), "%Y%m%d").date()
        ret_dt = dt_obj + timedelta(days=int(np.random.randint(4, 15)))
        ret_dkey = ret_dt.year * 10000 + ret_dt.month * 100 + ret_dt.day

        reason = np.random.choice(reasons, p=reason_weights)
        refund_amount = round(float((nsale / qty) * ret_qty), 2)
        if reason == "Customer Dissatisfaction":
            restock_fee = round(refund_amount * 0.08, 2)
        else:
            restock_fee = 0.0

        records.append({
            "return_id": ret_id,
            "order_line_id": lid,
            "order_id": oid,
            "return_date_key": ret_dkey,
            "product_id": pid,
            "returned_quantity": ret_qty,
            "return_reason": reason,
            "refund_amount_inr": refund_amount,
            "restocking_fee_inr": restock_fee
        })

    df = pd.DataFrame(records)
    df.to_csv(os.path.join(CLEAN_CSV_DIR, "fact_returns.csv"), index=False)
    save_parquet(df, os.path.join(CLEAN_PARQUET_DIR, "fact_returns.parquet"))
    print(f"      Saved Fact_Returns ({len(df)} rows).")
    return df


def generate_fact_service(capital_lines, target_tickets=120000):
    print(f"[13/14] Generating Fact_Service (~{target_tickets:,} tickets from capital equipment)...")
    np.random.seed(42)

    service_types = ["New Installation", "Warranty Repair", "Routine Maintenance", "Emergency Breakdown"]
    type_weights = [0.45, 0.25, 0.20, 0.10]
    statuses = ["Resolved", "Resolved", "Resolved", "In Progress", "Pending Spare Parts"]
    status_weights = [0.80, 0.05, 0.05, 0.05, 0.05]

    indices = np.random.choice(len(capital_lines), size=target_tickets, replace=True)

    records = []
    for ticket_id, idx in enumerate(indices, start=1):
        lid, pid, cid, dkey = capital_lines[idx]
        dt_obj = datetime.strptime(str(dkey), "%Y%m%d").date()
        stype = np.random.choice(service_types, p=type_weights)

        if stype == "New Installation":
            req_dt = dt_obj + timedelta(days=int(np.random.randint(3, 10)))
            cost = 2500.0
        elif stype == "Routine Maintenance":
            req_dt = dt_obj + timedelta(days=int(np.random.randint(90, 360)))
            cost = 1500.0
        else:
            req_dt = dt_obj + timedelta(days=int(np.random.randint(30, 500)))
            cost = float(np.random.choice([0.0, 3500.0, 8500.0, 15000.0]))

        req_dkey = req_dt.year * 10000 + req_dt.month * 100 + req_dt.day
        status = np.random.choice(statuses, p=status_weights)
        if status == "Resolved":
            res_dt = req_dt + timedelta(days=int(np.random.randint(1, 8)))
            res_dkey = res_dt.year * 10000 + res_dt.month * 100 + res_dt.day
        else:
            res_dkey = None

        records.append({
            "service_ticket_id": ticket_id,
            "service_ticket_no": f"SRV-{req_dt.year}-{ticket_id:06d}",
            "order_line_id": lid,
            "product_id": pid,
            "customer_id": cid,
            "service_type": stype,
            "request_date_key": req_dkey,
            "resolved_date_key": res_dkey,
            "resolution_status": status,
            "service_cost_inr": cost
        })

    df = pd.DataFrame(records)
    df["resolved_date_key"] = pd.to_numeric(df["resolved_date_key"]).astype("Int64")
    df.to_csv(os.path.join(CLEAN_CSV_DIR, "fact_service.csv"), index=False)
    save_parquet(df, os.path.join(CLEAN_PARQUET_DIR, "fact_service.parquet"))
    print(f"      Saved Fact_Service ({len(df)} rows).")
    return df


# ==============================================================================
# 5. CONTROLLED DIRTY DATASET GENERATION (data/dirty/)
# ==============================================================================

def generate_dirty_dataset():
    print("[14/14] Generating Controlled Dirty Dataset in data/dirty/ (For Phase 5 Profiling)...")
    np.random.seed(42)

    dirty_prods = [
        {"product_id": 99901, "product_name": " Hydraulic Chair ", "target_category": "dental capital equipment", "unit_cost_inr": -500.0, "list_price_inr": 120000.0},
        {"product_id": 99902, "product_name": "Composite Resin A2", "target_category": None, "unit_cost_inr": 800.0, "list_price_inr": 1500.0},
        {"product_id": 99903, "product_name": "RVG SENSOR PRO", "target_category": "DIGITAL IMAGING & RADIOLOGY", "unit_cost_inr": 85000.0, "list_price_inr": -180000.0},
        {"product_id": 99904, "product_name": "Class B Autoclave", "target_category": "Sterilization & Infection Control", "unit_cost_inr": 65000.0, "list_price_inr": 0.0}
    ]
    pd.DataFrame(dirty_prods).to_csv(os.path.join(DIRTY_DIR, "dirty_products.csv"), index=False)

    dirty_ords = [
        {"order_id": 888001, "order_number": "DK-ORD-DUP-001", "order_date": "2024-05-10", "order_date_key": 20240510, "customer_id": 999999, "total_net_amount_inr": 15000.0},
        {"order_id": 888002, "order_number": "DK-ORD-DUP-001", "order_date": "2024-05-10", "order_date_key": 20240510, "customer_id": 105, "total_net_amount_inr": 15000.0},
        {"order_id": 888003, "order_number": "DK-ORD-2099-001", "order_date": "2099-01-01", "order_date_key": 20990101, "customer_id": 204, "total_net_amount_inr": 8500.0},
        {"order_id": 888004, "order_number": "DK-ORD-BAD-001", "order_date": None, "order_date_key": 0, "customer_id": 310, "total_net_amount_inr": 22000.0}
    ]
    pd.DataFrame(dirty_ords).to_csv(os.path.join(DIRTY_DIR, "dirty_orders.csv"), index=False)

    dirty_sales = [
        {"order_line_id": 777001, "order_id": 101, "quantity": -5, "unit_cost_inr": 1000.0, "list_price_inr": 1500.0, "discount_pct": 0.10, "net_sales_inr": -6750.0},
        {"order_line_id": 777002, "order_id": 102, "quantity": 10, "unit_cost_inr": 1000.0, "list_price_inr": 1500.0, "discount_pct": 1.50, "net_sales_inr": -7500.0},
        {"order_line_id": 777003, "order_id": 103, "quantity": 1, "unit_cost_inr": 1000.0, "list_price_inr": 1500.0, "discount_pct": 0.05, "net_sales_inr": 1425.0},
        {"order_line_id": 777003, "order_id": 103, "quantity": 1, "unit_cost_inr": 1000.0, "list_price_inr": 1500.0, "discount_pct": 0.05, "net_sales_inr": 1425.0},
        {"order_line_id": 777005, "order_id": 104, "product_id": 888888, "quantity": 2, "net_sales_inr": 5000.0}
    ]
    pd.DataFrame(dirty_sales).to_csv(os.path.join(DIRTY_DIR, "dirty_sales.csv"), index=False)

    dirty_rets = [
        {"return_id": 666001, "order_line_id": 5001, "sold_quantity": 2, "returned_quantity": 10, "refund_amount_inr": 50000.0},
        {"return_id": 666002, "order_line_id": 5002, "order_date_key": 20240510, "return_date_key": 20240101, "returned_quantity": 1}
    ]
    pd.DataFrame(dirty_rets).to_csv(os.path.join(DIRTY_DIR, "dirty_returns.csv"), index=False)
    print("      Saved controlled dirty datasets in data/dirty/.")


# ==============================================================================
# MAIN PIPELINE
# ==============================================================================

def main():
    args = parse_args()
    print("================================================================================")
    print(" DENTAKART ANALYTICS — ENTERPRISE DATA GENERATOR")
    print(f" Target Fact_Sales Rows: {args.rows:,}")
    print(f" Batch Size:             {args.batch_size:,}")
    print(f" Random Seed:            {args.seed}")
    print("================================================================================")

    np.random.seed(args.seed)
    ensure_dirs()
    total_start = time.time()

    date_df = generate_dim_date()
    loc_df = generate_dim_location()
    wh_df = generate_dim_warehouse()
    sup_df = generate_dim_supplier()
    ch_df = generate_dim_channel()

    rep_df = generate_dim_salesperson(num_reps=500)
    prod_df = generate_dim_product(num_products=1000)
    cust_df = generate_dim_customer(num_customers=100000)

    targets_df = generate_fact_sales_targets(rep_df)
    inv_df = generate_fact_inventory_snapshot(prod_df)

    ret_lines, cap_lines = generate_fact_sales_and_orders(
        total_lines=args.rows,
        batch_size=args.batch_size,
        product_df=prod_df,
        customer_df=cust_df,
        salesperson_df=rep_df,
        date_df=date_df
    )

    ret_df = generate_fact_returns(ret_lines)
    srv_df = generate_fact_service(cap_lines, target_tickets=120000)

    generate_dirty_dataset()

    total_time = time.time() - total_start
    print("================================================================================")
    print(f" GENERATION COMPLETE in {total_time:.1f} seconds ({total_time/60.0:.2f} minutes)!")
    print(f" Clean CSV:     {CLEAN_CSV_DIR}")
    print(f" Clean Parquet: {CLEAN_PARQUET_DIR}")
    print(f" Dirty Dataset: {DIRTY_DIR}")
    print("================================================================================")


if __name__ == "__main__":
    main()
