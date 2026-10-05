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