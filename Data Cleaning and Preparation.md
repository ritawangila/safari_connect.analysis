# 🛠️ Data Engineering & Technical Process Report — Safari Connect

⬅️ [Back to Business Performance Insights Report](Business_Report.md)

---

## Project Overview
This report details the technical pipeline built to transform Safari Connect's raw operational data into an enterprise-ready reporting asset. The project traces the journey of booking logs from an unorganized flat CSV file, through structural database cleaning using SQL, and finally into an optimized model for Power BI visualization.

---

## The Data Pipeline Architecture

[ Messy CSV File ] ──> [ PostgreSQL Database ] ──> [ SQL Data Cleaning ] ──> [ Power BI Model ]


### 1. Data Schema Mapping
The original dataset consisted of roughly 290 unique booking records spanning August 2024 to April 2025. Each record captured 21 distinct structural attributes:

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `booking_id` | Text (Primary Key) | Unique code for each booking (e.g., BK0001) |
| `passenger_name` | Text | Name of the traveler |
| `passenger_phone` | Text | Phone number |
| `passenger_gender` | Text | Gender classification |
| `passenger_city` | Text | Resident city of the passenger |
| `route_code` | Text | Code for the transit route |
| `route_from` | Text | Departure station |
| `route_to` | Text | Destination station |
| `vehicle_plate` | Text | Vehicle registration number |
| `vehicle_type` | Text | Category of fleet asset (Bus / Matatu / Minibus) |
| `driver_name` | Text | Assigned operator |
| `driver_rating` | Numeric | Operator rating on the platform |
| `departure_date` | Date | Scheduled date of travel |
| `departure_time` | Time | Scheduled time of departure |
| `seat_class` | Text | Service tier (Economy / Business) |
| `seats_booked` | Integer | Volume of seats secured |
| `fare_per_seat` | Numeric | Unit price per seat (KES) |
| `total_fare` | Numeric | Aggregate transaction revenue (KES) |
| `payment_method` | Text | Payment channel utilized (M-Pesa / Cash / Card) |
| `booking_status` | Text | Operational status (Completed / Cancelled / No Show) |
| `trip_rating` | Integer | Post-travel passenger feedback score (1–5) |

---

## Data Cleaning & Transformation (SQL Pipeline)

Upon initial audit, the raw CSV exhibited significant structural issues common to manual data entry setups. I staged the raw file into a **PostgreSQL** database environment to execute automated cleaning, harmonization, and deduplication scripts.

### Core Pipeline Scripts

#### Text Case Harmonization
Passenger names and operational statuses were typed inconsistently across records (e.g., lowercase, uppercase, mixed). I standardized these into clean Title Case layouts:
```sql
UPDATE bookings
SET passenger_name = INITCAP(LOWER(passenger_name));

UPDATE bookings
SET booking_status = INITCAP(LOWER(booking_status));
Phone Number Standardization
Phone data was fractured across local formats and international prefixes (e.g., starting with +254 or dropping leading zeroes). I standardized all numbers to a uniform 10-digit Kenyan format:

SQL


UPDATE bookings
SET passenger_phone = CONCAT('0', RIGHT(passenger_phone, 9))
WHERE passenger_phone LIKE '+254%';
Categorical Variable Alignment
Gender categories contained fragmented entries (e.g., M, male, MALE). I normalized these into discrete parameters to ensure clean filtering in the dashboard:

SQL


UPDATE bookings
SET passenger_gender = CASE
    WHEN LOWER(passenger_gender) IN ('m', 'male') THEN 'Male'
    WHEN LOWER(passenger_gender) IN ('f', 'female') THEN 'Female'
    ELSE NULL
END;

Technical Environment Summary
Ingestion Layer: Raw flat-file data processing.

Database Layer: PostgreSQL Engine for data scrubbing, table definitions, and structural aggregation.

Visualization Layer: Power BI Desktop for dimensional modeling, data visualization, and analytical reporting.
