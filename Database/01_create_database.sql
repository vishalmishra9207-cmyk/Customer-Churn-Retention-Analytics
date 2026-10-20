create database churn_retention_analytics ;

use churn_retention_analytics;

create table customers (
    customer_id int primary key AUTO_INCREMENT ,
    customer_name varchar(50) not null,
    mobile_number char(10) not null unique ,
    EMAIL varchar(50) not null unique,
    joining_date timestamp default current_timestamp , 
    age int not null ,
    gender enum("MALE" , "FEMALE" , "OTHERS") ,
    house_no varchar (20)  default null ,
    street_no varchar(50) default null ,
    area_name varchar(100) default null ,
    city varchar(100) default null ,
    state varchar (100) default null , 
    country varchar(100) default "INDIA" 
)
;



CREATE TABLE customer_accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0.00,
    account_status VARCHAR(25) DEFAULT 'Active',
    open_date DATE NOT NULL,
    closed_date DATE DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


CREATE TABLE subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    plan_type ENUM('Basic', 'Standard', 'Premium') DEFAULT NULL,
    contract_type VARCHAR(20),
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date DATE DEFAULT NULL,
    monthly_charges DECIMAL(10,2) DEFAULT 0.00,
    subscription_status ENUM(
        'Active',
        'Hold',
        'Suspended',
        'Deactivated',
        'Terminated'
    ) DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_customer_accounts
        FOREIGN KEY (account_id)
        REFERENCES customer_accounts(account_id)
);

select * from customers ;


CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,

    subscription_id INT NOT NULL,

    transaction_id VARCHAR(50) NOT NULL UNIQUE,

    payment_amount DECIMAL(10,2) NOT NULL,

    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    payment_received_date TIMESTAMP NULL DEFAULT NULL,

    payment_status ENUM(
        'Successful',
        'Failed',
        'Pending',
        'Refunded'
    ) NOT NULL DEFAULT 'Pending',

    payment_mode ENUM(
        'UPI',
        'Net Banking',
        'Credit Card',
        'Debit Card',
        'Auto Debit',
        'Other'
    ) NOT NULL,

    payment_type ENUM(
        'Recurring',
        'One-time',
        'Refund'
    ) NOT NULL DEFAULT 'Recurring',

    currency CHAR(3) NOT NULL DEFAULT 'INR',

    failure_reason VARCHAR(255) DEFAULT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_payments_subscription
        FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id),

    CONSTRAINT chk_payment_amount
        CHECK (payment_amount >= 0)
);


CREATE TABLE customer_services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,

    account_id INT NOT NULL,

    service_type ENUM(
        'Internet',
        'Streaming',
        'Cloud Storage',
        'Premium Support'
    ) NOT NULL,

    category ENUM(
        'Basic',
        'Standard',
        'Premium'
    ) DEFAULT NULL,

    activation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    deactivation_date DATE DEFAULT NULL,

    service_status ENUM(
        'Active',
        'Suspended',
        'Deactivated',
        'Terminated',
        'Hold'
    ) NOT NULL DEFAULT 'Active',

    monthly_charge DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    auto_renewal BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_customer_services_account
        FOREIGN KEY (account_id)
        REFERENCES customer_accounts(account_id),

    CONSTRAINT chk_service_monthly_charge
        CHECK (monthly_charge >= 0)
);



CREATE TABLE support_tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,

    customer_id INT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    issue_category ENUM(
        'Billing',
        'Internet',
        'Payment',
        'Technical',
        'Service Request',
        'Account',
        'Other'
    ) NOT NULL DEFAULT 'Other',

    priority ENUM(
        'Low',
        'Medium',
        'High',
        'Critical'
    ) NOT NULL DEFAULT 'Medium',

    ticket_status ENUM(
        'Open',
        'In Progress',
        'Waiting for Customer',
        'Waiting for External Team',
        'Resolved',
        'Closed',
        'Cancelled'
    ) NOT NULL DEFAULT 'Open',

    resolve_date TIMESTAMP NULL DEFAULT NULL,

    resolution VARCHAR(500) DEFAULT NULL,

    resolved_by VARCHAR(100) DEFAULT NULL,

    resolution_category ENUM(
        'User Training',
        'Data Fix',
        'Bulk Fix',
        'User Mistake',
        'Technical Fix',
        'Other'
    ) DEFAULT NULL,

    contact_email VARCHAR(254) DEFAULT NULL,

    issue_description VARCHAR(3000) NOT NULL,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_support_tickets_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT chk_ticket_resolution_date
        CHECK (resolve_date IS NULL OR resolve_date >= created_at)
);


CREATE TABLE churn_events (
    churn_id INT AUTO_INCREMENT PRIMARY KEY,
    subscription_id INT NOT NULL,

    churn_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    leaving_reason ENUM(
        'High Price',
        'Poor Service',
        'Better Competitor Offer',
        'Poor Quality',
        'Lack of Usage',
        'Technical Issues',
        'Other'
    ) DEFAULT 'Other',

    cancellation_channel ENUM(
        'Customer Support',
        'Mobile App',
        'Website',
        'Email',
        'In Store',
        'Other'
    ) DEFAULT 'Other',

    feedback TEXT DEFAULT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_churn_events_subscription
        FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id)
);

CREATE TABLE retention_activity (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    subscription_id INT NOT NULL,

    activity_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    activity_type ENUM(
        'Discount Offer',
        'Upgrade Offer',
        'Downgrade Offer',
        'Free Service',
        'Loyalty Reward',
        'Customer Support',
        'Personalized Offer',
        'Other'
    ) NOT NULL DEFAULT 'Other',

    offer_amount DECIMAL(10,2) DEFAULT 0.00,

    outcome ENUM(
        'Accepted',
        'Rejected',
        'Pending',
        'No Response'
    ) NOT NULL DEFAULT 'Pending',

    retention_status ENUM(
        'Retained',
        'Churned',
        'Still Active'
    ) NOT NULL DEFAULT 'Still Active',

    notes TEXT DEFAULT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_retention_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_retention_subscription
        FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id),

    CONSTRAINT chk_offer_amount
        CHECK (offer_amount >= 0)
);

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'churn_retention_analytics'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME;

select * from customers; 

DESCRIBE churn_retention_analytics.subscriptions;        

SELECT MIN(account_id), MAX(account_id), COUNT(*)
FROM customer_accounts;

select * from customer_accounts where closed_date is null; 

select * from customers ;

select * from customer_services;

DESCRIBE churn_retention_analytics.subscriptions;        

SELECT MIN(account_id), MAX(account_id), COUNT(*)
FROM customer_accounts;

SELECT
    COUNT(*) AS total_accounts,
    COUNT(DISTINCT account_number) AS unique_accounts,
    COUNT(DISTINCT customer_id) AS linked_customers
FROM customer_accounts;


SELECT COUNT(*) AS total_accounts FROM customer_accounts;

SELECT COUNT(*) AS existing_subscriptions FROM subscriptions;

SELECT COUNT(*) AS total_rows FROM subscriptions;

SELECT *
FROM subscriptions
LIMIT 5;

select * from subscriptions ;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT subscription_id) AS unique_subscriptions,
    COUNT(DISTINCT account_id) AS linked_accounts
FROM subscriptions;

SELECT subscription_status, COUNT(*) AS total
FROM subscriptions
GROUP BY subscription_status;

SELECT COUNT(*) AS total_payments
FROM payments;

SELECT COUNT(*) AS total_subscriptions
FROM subscriptions;

SELECT
    MIN(subscription_id) AS min_id,
    MAX(subscription_id) AS max_id,
    COUNT(DISTINCT subscription_id) AS unique_ids
FROM subscriptions;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT account_id) AS unique_accounts,
    MIN(start_date) AS earliest_subscription,
    MAX(start_date) AS latest_subscription
FROM subscriptions;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT account_id) AS unique_accounts,
    MIN(start_date) AS earliest_subscription,
    MAX(start_date) AS latest_subscription
FROM subscriptions;


SELECT *
FROM subscriptions
ORDER BY subscription_id
LIMIT 10;

SELECT
    (SELECT COUNT(*) FROM payments) AS payment_rows,
    (SELECT COUNT(*) FROM churn_events) AS churn_rows,
    (SELECT COUNT(*) FROM retention_activity) AS retention_rows;
    
CREATE TABLE subscriptions_backup_20261016 AS
SELECT * FROM subscriptions;

SELECT COUNT(*) AS backup_rows
FROM subscriptions_backup_20261016;

SET SQL_SAFE_UPDATES = 0;

DELETE FROM subscriptions;

SELECT COUNT(*) AS total_subscriptions
FROM subscriptions;

select *  from payments 

SELECT COUNT(*) AS total_tickets
FROM support_tickets;

SELECT ticket_status, COUNT(*) AS total
FROM support_tickets
GROUP BY ticket_status;

SELECT issue_category, priority, COUNT(*) AS total
FROM support_tickets
GROUP BY issue_category, priority
ORDER BY issue_category, priority;

SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'customer_accounts', COUNT(*) FROM customer_accounts
UNION ALL
SELECT 'subscriptions', COUNT(*) FROM subscriptions
UNION ALL
SELECT 'customer_services', COUNT(*) FROM customer_services
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'support_tickets', COUNT(*) FROM support_tickets
UNION ALL
SELECT 'churn_events', COUNT(*) FROM churn_events
UNION ALL
SELECT 'retention_activity', COUNT(*) FROM retention_activity;



SELECT 'customer_accounts → customers' AS validation,
       COUNT(*) AS orphan_rows
FROM customer_accounts ca
LEFT JOIN customers c ON ca.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 'subscriptions → customer_accounts',
       COUNT(*)
FROM subscriptions s
LEFT JOIN customer_accounts ca ON s.account_id = ca.account_id
WHERE ca.account_id IS NULL

UNION ALL

SELECT 'customer_services → customer_accounts',
       COUNT(*)
FROM customer_services cs
LEFT JOIN customer_accounts ca ON cs.account_id = ca.account_id
WHERE ca.account_id IS NULL

UNION ALL

SELECT 'payments → subscriptions',
       COUNT(*)
FROM payments p
LEFT JOIN subscriptions s ON p.subscription_id = s.subscription_id
WHERE s.subscription_id IS NULL

UNION ALL

SELECT 'support_tickets → customers',
       COUNT(*)
FROM support_tickets st
LEFT JOIN customers c ON st.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 'churn_events → subscriptions',
       COUNT(*)
FROM churn_events ce
LEFT JOIN subscriptions s ON ce.subscription_id = s.subscription_id
WHERE s.subscription_id IS NULL

UNION ALL

SELECT 'retention_activity → customers',
       COUNT(*)
FROM retention_activity ra
LEFT JOIN customers c ON ra.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 'retention_activity → subscriptions',
       COUNT(*)
FROM retention_activity ra
LEFT JOIN subscriptions s ON ra.subscription_id = s.subscription_id
WHERE s.subscription_id IS NULL;

SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT mobile_number) AS unique_mobile_numbers,
    COUNT(DISTINCT email) AS unique_emails,
    SUM(CASE WHEN mobile_number IS NULL OR TRIM(mobile_number) = '' THEN 1 ELSE 0 END) AS missing_mobile,
    SUM(CASE WHEN email IS NULL OR TRIM(email) = '' THEN 1 ELSE 0 END) AS missing_email,
    SUM(CASE WHEN customer_name IS NULL OR TRIM(customer_name) = '' THEN 1 ELSE 0 END) AS missing_names
FROM customers;



SELECT
    COUNT(*) AS total_payments,

    SUM(CASE
        WHEN payment_amount <= 0 THEN 1
        ELSE 0
    END) AS invalid_amounts,

    SUM(CASE
        WHEN payment_status = 'Failed'
         AND (failure_reason IS NULL OR TRIM(failure_reason) = '')
        THEN 1 ELSE 0
    END) AS failed_without_reason,

    SUM(CASE
        WHEN payment_status IN ('Successful', 'Refunded')
         AND payment_received_date IS NULL
        THEN 1 ELSE 0
    END) AS missing_received_date,

    SUM(CASE
        WHEN payment_received_date < payment_date
        THEN 1 ELSE 0
    END) AS received_before_payment

FROM payments;


SELECT
    COUNT(*) AS total_churn_events,

    SUM(CASE
        WHEN s.subscription_status NOT IN ('Terminated', 'Deactivated')
        THEN 1 ELSE 0
    END) AS invalid_subscription_status,

    SUM(CASE
        WHEN s.end_date IS NULL
        THEN 1 ELSE 0
    END) AS missing_subscription_end_date,

    SUM(CASE
        WHEN ce.churn_date > CURRENT_TIMESTAMP
        THEN 1 ELSE 0
    END) AS future_churn_dates,

    SUM(CASE
        WHEN s.end_date IS NOT NULL
         AND ce.churn_date > s.end_date
        THEN 1 ELSE 0
    END) AS churn_after_subscription_end

FROM churn_events ce
JOIN subscriptions s
    ON ce.subscription_id = s.subscription_id;

SELECT
    ce.churn_id,
    ce.subscription_id,
    ce.churn_date,
    s.end_date,
    s.subscription_status
FROM churn_events ce
JOIN subscriptions s
    ON ce.subscription_id = s.subscription_id
WHERE DATE(ce.churn_date) > s.end_date
ORDER BY ce.churn_date DESC
LIMIT 10;



SELECT
    COUNT(*) AS total_subscriptions,
    SUM(CASE
        WHEN subscription_status IN ('Terminated', 'Deactivated')
        THEN 1 ELSE 0
    END) AS terminated_or_deactivated,
    SUM(CASE
        WHEN subscription_status IN ('Terminated', 'Deactivated')
         AND end_date IS NOT NULL
        THEN 1 ELSE 0
    END) AS with_end_date
FROM subscriptions;



SELECT
    YEAR(ce.churn_date) AS churn_year,
    COUNT(*) AS churn_events,
    SUM(
        CASE
            WHEN DATE(ce.churn_date) > s.end_date
            THEN 1 ELSE 0
        END
    ) AS dates_after_end_date
FROM churn_events ce
JOIN subscriptions s
    ON ce.subscription_id = s.subscription_id
GROUP BY YEAR(ce.churn_date)
ORDER BY churn_year;



SELECT
    COUNT(*) AS total_churn_events,

    SUM(CASE
        WHEN s.end_date IS NULL THEN 1
        ELSE 0
    END) AS missing_end_date,

    SUM(CASE
        WHEN s.end_date IS NOT NULL
         AND DATE(ce.churn_date) > s.end_date
        THEN 1 ELSE 0
    END) AS churn_after_end_date,

    SUM(CASE
        WHEN s.end_date IS NOT NULL
         AND DATE(ce.churn_date) <= s.end_date
        THEN 1 ELSE 0
    END) AS churn_on_or_before_end_date

FROM churn_events ce
JOIN subscriptions s
    ON ce.subscription_id = s.subscription_id;

select * from churn_events;



SELECT
    (SELECT COUNT(*)
     FROM customers) AS total_customers,

    (SELECT COUNT(*)
     FROM subscriptions
     WHERE subscription_status = 'Active'
    ) AS active_subscriptions,

    (SELECT COUNT(DISTINCT subscription_id)
     FROM churn_events
    ) AS churned_subscriptions,

    (SELECT ROUND(SUM(monthly_charges), 2)
     FROM subscriptions
     WHERE subscription_status = 'Active'
    ) AS monthly_recurring_revenue,

    (SELECT ROUND(AVG(monthly_charges), 2)
     FROM subscriptions
     WHERE subscription_status = 'Active'
    ) AS avg_active_subscription_charge;


SELECT
    DATE_FORMAT(churn_date, '%Y-%m') AS churn_month,
    COUNT(*) AS churn_events,
    COUNT(DISTINCT subscription_id) AS unique_subscriptions
FROM churn_events
GROUP BY DATE_FORMAT(churn_date, '%Y-%m')
ORDER BY churn_month;


SELECT
    DATE_FORMAT(churn_date, '%Y-%m') AS churn_month,
    COUNT(*) AS churn_events,
    COUNT(DISTINCT subscription_id) AS unique_subscriptions
FROM churn_events
GROUP BY DATE_FORMAT(churn_date, '%Y-%m')
ORDER BY churn_month;
