# 📊 Customer Churn Analysis

**End-to-end Data Analyst project** tracing 15,000 customer records through a full analytics pipeline — **Excel → Python (Pandas) → MySQL (SQL) → Power BI** — to answer one business question:

> *Why are customers leaving, and how much revenue is at risk?*

---

## 📁 Table of Contents
- [Business Problem](#-business-problem)
- [Dataset](#-dataset)
- [Project Workflow](#-project-workflow)
- [Excel — Data Quality Check](#1️⃣-excel--data-quality-check)
- [Python — Cleaning & Feature Engineering](#2️⃣-python--cleaning--feature-engineering)
- [MySQL — Business Questions](#3️⃣-mysql--business-questions)
- [Power BI — Dashboard](#4️⃣-power-bi--dashboard)
- [Key Business Insights](#-key-business-insights)
- [Business Recommendations](#-business-recommendations)
- [Tech Stack](#-tech-stack)
- [Repo Structure](#-repo-structure)
- [Author](#-author)

---

## 🎯 Business Problem

Subscription-based businesses lose recurring revenue every time a customer cancels. Acquiring a new customer costs far more than retaining an existing one — so a company that can't identify **which** customers are likely to leave, and **why**, keeps losing money without a clear way to stop it.

This project analyzes customer behavior to find:
- How many customers are churning
- What factors are driving that churn
- How much monthly recurring revenue (MRR) is at risk

---

## 📦 Dataset

**File:** `synthetic_customer_behavior_and_churn.csv`
**Size:** 15,000 customer records · 21 original columns
**Quality:** No missing values, no duplicate rows

| Category | Columns |
|---|---|
| Demographics | age, gender, region, income_level |
| Subscription | subscription_type, contract_type, monthly_charges, total_charges |
| Behavior | usage_frequency, avg_session_duration_minutes, number_of_logins_per_month, last_login_days_ago |
| Service | number_of_support_tickets, satisfaction_score |
| Target | `churn` (1 = churned, 0 = retained) |

---

## 🔄 Project Workflow

```
Excel (Power Query)  →  Python (Pandas/NumPy)  →  MySQL (SQL)  →  Power BI
   Data quality           Cleaning +               Business         Interactive
   check                  feature engineering      questions        dashboard
```

---

## 1️⃣ Excel — Data Quality Check

Before deeper analysis, the raw CSV was opened in Excel and passed through **Power Query Editor**:

- Loaded the file via Data → Get Data → From Text/CSV → Transform Data
- Checked and corrected column data types (dates, decimals)
- Used **Remove Duplicates** on `customer_id` to confirm no duplicate customers
- Checked for blank/missing values using Power Query's column quality indicators
- Trimmed/cleaned text columns (gender, region, payment_method)
- Did a first-pass PivotTable look at churn by region before moving to Python

---

## 2️⃣ Python — Cleaning & Feature Engineering

Using **Pandas** and **NumPy**, four new columns were engineered:

```python
# Revenue per month (avoids divide-by-zero for new customers)
df['revenue_by_month'] = np.where(df['tenure_months'] > 0,
                                   df['total_charges'] / df['tenure_months'], 0)

# Total engagement (watch time)
df['total_watch_time'] = df['number_of_logins_per_month'] * df['avg_session_duration_minutes']

# High-risk flag: low satisfaction OR many support tickets
df['high_risk'] = np.where((df['satisfaction_score'] <= 2) |
                            (df['number_of_support_tickets'] >= 3), 1, 0)

# Inactivity flag: no login in 30+ days
df['risk_by_login'] = np.where(df['last_login_days_ago'] >= 30, 1, 0)
```

The cleaned, feature-enriched DataFrame was then uploaded to MySQL:

```python
from sqlalchemy import create_engine

engine = create_engine("mysql+pymysql://user:password@localhost:3306/chrun_data_analysis")
df.to_sql(name="customer_churn", con=engine, if_exists="replace", index=False)
```

📁 See [`/python`](./python) for the full notebook.

---

## 3️⃣ MySQL — Business Questions

Ten business questions were answered directly in SQL. A few highlights:

| # | Question | Result |
|---|---|---|
| 1 | Overall churn rate | **31.89%** |
| 3 | Does contract type impact churn? | Monthly **47.68%** vs Yearly **19.68%** |
| 4 | Churn by satisfaction score | Drops from **39.32%** (score 3) to **7.93%** (score 4) |
| 5 | Does the high-risk flag predict churn? | **53.80%** (flagged) vs **7.05%** (not flagged) |
| 6 | Do inactive customers churn more? | **75.41%** (inactive 30+ days) vs **15.98%** (active) |
| 7 | MRR at risk from churned customers | **$257,661.96** |
| 9 | Does discount usage reduce churn? | **30.99%** (discount) vs **32.80%** (no discount) |
| 10 | Engagement: churned vs retained | **858** min vs **1,239** min avg watch time |

📁 Full query list in [`/sql`](./sql).

---

## 4️⃣ Power BI — Dashboard

A single-page, interactive dashboard was built connecting directly to the MySQL table.

**KPI Cards:** Churn Rate · Total Customers · Total Charges · MRR at Risk · High-Risk Customers

**Visuals:**
- Churn Rate by Contract Type (bar chart)
- Churned vs Retained Customers (donut chart)
- Churn Rate by Satisfaction Score (line chart)
- Top 10 VIP At-Risk Customers (table)
- Average Watch Time: Churned vs Retained (bar chart)

**Filters:** Region, Payment Method, Subscription Type slicers + signup year buttons (2022/2023/2024)

📁 Dashboard file and screenshots in [`/powerbi`](./powerbi).

---

## 💡 Key Business Insights

- Overall churn rate is **31.89%** — roughly 1 in 3 customers leaves.
- **Monthly contracts churn 2.4x more** than yearly contracts — the strongest single driver.
- Churn rises sharply once satisfaction score falls to **3 or below**.
- The `high_risk` and `risk_by_login` flags are both strong, working predictors of churn.
- **$257,661.96** in monthly recurring revenue is already tied to churned customers.
- The highest-value at-risk customers are concentrated on the **Premium plan**.
- **Discounts barely move churn** — engagement and login recency are far stronger signals.
- Churned customers show **noticeably lower product engagement** before leaving.

---

## ✅ Business Recommendations

| Recommendation | Supporting Insight |
|---|---|
| Encourage a shift from monthly to yearly contracts | Monthly churn is 2.4x higher |
| Build an early-warning process for satisfaction scores ≤ 3 | Churn cliff at score 3→4 |
| Prioritize retention on `high_risk` and inactive customers | Both flags strongly predict churn |
| Protect high-value Premium customers specifically | Biggest $ losses are on Premium plan |
| Reconsider blanket discounting as a retention lever | Minimal churn impact from discounts |
| Use watch-time drops as an early warning signal | Churners show lower engagement before leaving |

*(Full reasoning and expected benefit for each recommendation is in the [PDF report](Customer_Churn_Analysis_Project_Report.pdf).)*

---

## 🛠 Tech Stack

`Excel` · `Power Query` · `Python` · `Pandas` · `NumPy` · `SQLAlchemy` · `MySQL` · `SQL` · `Power BI` · `DAX`

---

## 📂 Repo Structure

```
customer-churn-analysis/
├── README.md
├── Customer_Churn_Analysis_Project_Report.pdf
├── data/
│   └── synthetic_customer_behavior_and_churn.csv
├── python/
│   └── churn_data_cleaning_and_features.ipynb
├── sql/
│   └── churn_business_questions.sql
├── powerbi/
│   ├── churn_dashboard.pbix
│   └── screenshots/
└── screenshots/
    └── Chrun_dashboard.png
```

---

## 👤 Author

Built as a hands-on Data Analyst portfolio project — covering data cleaning, feature engineering, SQL analysis, and dashboard storytelling end to end.

Feel free to connect or reach out with feedback!
