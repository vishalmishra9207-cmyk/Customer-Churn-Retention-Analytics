# Customer Churn & Retention Analytics

### SQL + Power BI \| MySQL \| DAX

## Project Overview

Customer Churn & Retention Analytics is an end-to-end portfolio project
focused on understanding customer churn, retention behaviour, payment
performance, and revenue trends.

The project uses a relational customer dataset and combines advanced SQL
analysis with an interactive Power BI report. The goal is to turn raw
operational data into useful business insights that can help identify
churn patterns, understand revenue performance, and highlight customer
segments that may need attention.

> **Data note:** This is a portfolio project built with a
> sample/synthetic dataset. It does not represent real customer
> information or an actual company's results.

## Business Objectives

-   Measure customer and subscription churn.
-   Understand churn patterns across subscription plans and time
    periods.
-   Analyse successful, failed, pending, and refunded payments.
-   Evaluate customer revenue and payment behaviour.
-   Review retention activity and the latest retention outcome for each
    customer.
-   Segment customers by revenue contribution and retention status.
-   Present the findings in an interactive Power BI report.

## Dataset

The database contains the following tables:

  Table                       Rows
  ---------------------- ---------
  `customers`               50,000
  `customer_accounts`       50,000
  `subscriptions`           60,000
  `customer_services`      100,000
  `payments`               200,000
  `support_tickets`        100,000
  `churn_events`            12,000
  `retention_activity`      20,000

**Total records: 592,000**

## Tools & Technologies

-   **MySQL** --- database design, querying, analysis, and data
    validation
-   **MySQL Workbench** --- database development and query execution
-   **Power BI Desktop** --- data modelling, DAX measures, and
    interactive dashboards
-   **DAX** --- calculated measures and customer-level segmentation
-   **Git & GitHub** --- version control and project documentation

## SQL Analysis

The SQL analysis covers a range of business questions and techniques,
including:

-   Joins across customer, account, subscription, payment, support,
    churn, and retention tables
-   Aggregations using `GROUP BY`, `HAVING`, and conditional aggregation
    with `CASE`
-   Common Table Expressions (CTEs) for multi-step analysis
-   Window functions such as `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`,
    `LAG()`, and running totals
-   Monthly revenue trends and moving averages
-   Customer lifetime revenue and payment behaviour
-   Churn tenure and churn reasons by subscription plan
-   Revenue leakage and payment collection analysis
-   Cohort retention analysis
-   Customer revenue and retention-risk segmentation

### Advanced Customer Segmentation

A multi-CTE analysis combines: 1. Customer-level successful revenue and
successful/failed payment counts. 2. The latest retention status per
customer, identified using `ROW_NUMBER()` ordered by activity date and
activity ID. 3. Revenue ranking and customer segmentation using window
functions and `CASE`.

The SQL segmentation identifies groups such as: - High Value Risk - High
Value Active - Low Value Risk - Low Value Active - Needs Monitoring

These are descriptive business segments based on historical revenue and
the latest recorded retention status. They are **not** predictions from
a machine-learning churn model.

## Power BI Report

The Power BI report turns the SQL analysis into interactive views,
including:

-   Customer and subscription churn overview
-   Churn trends and churn reasons
-   Churn by subscription plan
-   Payment status and revenue insights
-   Retention activity and customer retention rate
-   Monthly successful payment revenue
-   Average monthly charges by plan
-   Successful vs. failed payments by payment mode
-   Customer revenue and retention-risk segmentation
-   Revenue contribution and failed-payment behaviour by customer
    segment

### Interactive Filters

-   Subscription Plan
-   Revenue Bucket

The report uses DAX measures and a customer-level calculated table to
support the segmentation visuals.

> **Methodology note:** SQL `NTILE(5)` and the Power BI rank-based
> revenue bucket calculation can produce slightly different bucket
> assignments, particularly when customers have equal revenue. The SQL
> and Power BI results should be reconciled before treating their
> segment counts as identical.

## Key Learning Outcomes

-   Designed and worked with a multi-table relational database.
-   Practised translating business questions into SQL queries.
-   Used CTEs and window functions to solve multi-step analytical
    problems.
-   Learned to avoid inflated totals when joining multiple one-to-many
    tables by aggregating at the correct grain.
-   Built DAX measures and a calculated table for customer segmentation.
-   Developed an interactive Power BI report to communicate analytical
    findings.
-   Documented and version-controlled the project using GitHub.

## Repository Structure

The main SQL analysis file is located at:

``` text
SQL_Analysis/
└── sql_analysis.sql
```

Other database scripts, data files, and report assets are maintained in
their respective project folders in the repository.

## How to Explore the Project

1.  Clone or download this repository.
2.  Create or select the MySQL database used by the project.
3.  Load the database schema and sample data using the SQL scripts
    provided in the repository.
4.  Open `SQL_Analysis/sql_analysis.sql` in MySQL Workbench and run the
    analysis queries.
5.  Open the Power BI report file in Power BI Desktop to explore the
    report and filters.

Refer to the SQL scripts and report assets in the repository for the
exact execution order and file names.

## Disclaimer

This project is created for learning and portfolio demonstration. The
dataset is sample/synthetic, and the customer segments are analytical
classifications based on historical data---not operational
recommendations or predictive outputs.

## Author

**Vishal Mishra**\
Aspiring Data Analyst \| SQL \| Power BI \| Excel \| Python

-   GitHub:
    [vishalmishra9207-cmyk](https://github.com/vishalmishra9207-cmyk)
-   LinkedIn: [Vishal
    Mishra](https://www.linkedin.com/in/vishal-mishra-2a5570284/)
