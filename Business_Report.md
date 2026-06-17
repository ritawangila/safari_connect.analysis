# 🚌 Safari Connect — Performance Dashboard Report

ℹ️ **Looking for the technical data engineering process?** [Read the Data Cleaning & Preparation Report here](Data%20Cleaning%20and%20Preparation.md)

---

## Executive Summary
This project serves as an operational analysis portfolio piece based on the transactional records of Safari Connect, an emerging long-distance transit booking platform running out of Nairobi. The core focus of this project was to ingest a disorganized data system, extract clear business signals, and construct an interactive dashboard capable of guiding strategic market entry and asset optimization.

---

## Target Audience & Strategic Context
This analysis was developed specifically for the leadership team of a **new transportation startup in Kenya looking to explore its market potential**. As a fresh player in East Africa's competitive long-distance mobility sector, scaling efficiently requires moving away from gut-feel decisions and leaning entirely into clear operational data.

Historically, transactional records sat unmanaged in a shared spreadsheet. To unlock clear expansion opportunities, de-risk growth, and optimize the fleet, this analysis answers four critical strategic questions:
1. **Route Yield:** Which corridors drive the highest revenue volume and show the most market potential?
2. **Personnel Optimization:** Which operators are executing the highest-value trips?
3. **Temporal Trends:** When do platform revenues experience natural ebbs and flows?
4. **Revenue Leakage:** What is the financial cost associated with booking cancellations, and how do we protect our margins?

---

## Key Performance Indicators (KPIs)
The following metrics summarize the operational baseline established from the underlying data for the period spanning August 2024 to April 2025:

* **Total Revenue:** KES 260,860
* **Total Bookings Logged:** 289
* **Average Ticket Value (AOV):** KES 902.63
* **Platform Cancellation Rate:** 7.27% (21 Cancelled Bookings)
* **Average Passenger Satisfaction Score:** 3.53 / 5.00

---

## Detailed Visual Breakdown & Insights

### 1. Route Revenue & Pricing Mechanics
Long-haul corridors combine strong demand with higher pricing power, forming the primary financial anchor of the business.

| Route Code | Journey | Total Revenue (KES) | Average Ticket Price (KES) |
| :--- | :--- | :--- | :--- |
| **RT001** | Nairobi ➔ Mombasa | **62,000** | ~2,080 |
| **RT004** | Nairobi ➔ Eldoret | **45,000** | ~1,600 |
| **RT002** | Nairobi ➔ Kisumu | **45,000** | ~1,536 |
| **RT007** | Nairobi ➔ Nyeri | **25,000** | ~850 |
| **RT003** | Nairobi ➔ Nakuru | **24,000** | ~700 |
| **RT006** | Mombasa ➔ Malindi | **17,000** | ~650 |
| **RT010** | Nairobi ➔ Naivasha | **16,000** | ~550 |
| **RT005** | Nairobi ➔ Thika | **9,000** | ~250 |
| **RT009** | Nairobi ➔ Machakos | **9,000** | ~350 |
| **RT008** | Kisumu ➔ Kakamega | **9,000** | ~400 |

* **The Corridor Winner:** The Nairobi–Mombasa route (`RT001`) stands out as the single most critical asset, driving over KES 62,000 in revenue—nearly double any other route.
* **Low-Yield Short Hauls:** Short-distance routes like `RT005` (Nairobi–Thika) show low margins due to a rock-bottom average ticket cost of KES 250, signaling a need to review asset allocation on short routes.

### 2. Fleet & Service Tier Dynamics
* **Fleet Mix Yields:** Large Busses generate the largest slice of aggregate monthly revenue, with Matatus following closely behind. Minibuses show a low contribution across the tracked months.
* **Seat Class Division:** Economy Class tickets account for the bulk of consistent volume. While Business Class generates higher margins per passenger, its total volume line remains lower and mimics standard seasonal trends without major breakout spikes.

### 3. Demographic & Operator Metrics
* **Nairobi Centrality:** Passenger location data shows a significant concentration of customers based out of Nairobi, confirming that marketing and fleet allocation should start with Nairobi departures.
* **Operator Consistency:** Driver performance is tightly balanced among the core team. Kelvin Omondi (KES 36,000), Brian Kamau (KES 36,000), and Isaac Korir (KES 35,000) lead total revenue creation, backed by high driver rating metrics across the board (all holding scores above 4.0).

---

## Data-Driven Strategic Recommendations

### 📊 1. Maximize High-Yield Transit Corridors
The data confirms that long-haul routes—specifically Nairobi–Mombasa (`RT001`) and Nairobi–Eldoret/Kisumu—generate the highest returns. 
* **Action:** For a new company exploring potential, scale up vehicle allocations and departure frequencies along these long-haul routes first. Testing a premium, higher-priced Business Class tier on the Mombasa run could capture extra value without needing to source completely new passengers.

### 👨‍✈️ 2. Institutionalize Top Operator Practices
Top-tier operators like Kelvin Omondi and Brian Kamau drive the highest total fare collections while maintaining excellent platform reviews. 
* **Action:** Build out an internal incentive structure to reward these high-performing operators. Documenting their onboarding, communication style, and route tracking can help set a standard company-wide training program to lift passenger satisfaction scores past the current 3.53 average.

### 📉 3. Implement an Automated Booking Cancellation Safeguard
With 21 cancellations accounting for a 7.27% leakage rate, Safari Connect lost approximately **KES 18,955** in uncollected fares during this period.
* **Action:** Introduce a partial upfront booking fee or a rolling 24-hour non-refundable cancellation window via M-Pesa. This simple change locks in baseline protection for empty seats, encourages serious bookings, and instantly recovers a portion of leaking operational revenue.

---

## Project Repository File Structure
