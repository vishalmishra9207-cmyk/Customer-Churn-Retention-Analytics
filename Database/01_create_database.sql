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

