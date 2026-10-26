-- Business problem: Customer distribution by gender
-- Task: customers table se har gender ke liye:
-- - Gender
-- - Total number of customers

select gender ,  count(*)  as total_customer 
    from customers group by gender order by total_customer desc;


-- Business problem: Subscription status distribution
-- Task: subscriptions table se ye return kar:
-- - status
-- - total_subscriptions

select subscription_status , count(*) as total_subscriptions 
	from subscriptions where subscription_status not  in ("Active" , "Terminated")
    group by subscription_status  order by subscription_status desc;

-- Business problem: Average monthly charges by plan
-- Task: subscriptions table se return kar:
-- - plan
-- - average_monthly_charges — 2 decimal places tak


select 
	plan_type ,
    round(avg(monthly_charges) , 2)  as average_monthly_charges
from subscriptions 
	group by plan_type 
    order by average_monthly_charges desc;


-- Business problem: High-volume customer support categories

-- Task: support_tickets table se:
-- - status
-- - total_tickets
-- Sirf un statuses ko show kar jahan 1,000 se zyada tickets hain. Result ko ticket count ke descending order mein sort karna hai.


select 
	ticket_status,
    count(*) as total_tickets 
from support_tickets
	group by ticket_status
	having count(*) > 1000
    order by total_tickets desc ;

-- Business problem: Customers with multiple support tickets
-- Task: support_tickets table se return kar:
-- - customer_id
-- - total_tickets
-- Sirf un customers ko show kar jinke tickets 5 se zyada hain. Highest ticket count wale customer ko pehle dikhana hai.

select
    customer_id , 
    count(*) as total_tickets
from support_tickets
    group by customer_id 
    having count(*) > 5
    order by total_tickets desc;

"""
Business problem: Subscription status classification

Company ko subscriptions ko do groups mein classify karna hai:
- Active: status Active hai.
- Inactive: status Active nahi hai.
subscriptions table se do columns return kar:
- subscription_category — Active ya Inactive
- total_subscriptions — har category mein subscriptions ki count

"""


select 	
	count(*) as total_subscriptions ,
    case 
    when subscription_status = "Active" then "Active"
    else "Inactive" 
    end as subscription_category
from subscriptions group by subscription_category  order by total_subscriptions desc;

"""
Business problem: Successful vs failed payments

Finance team ko har payment mode ke liye successful aur failed payments ka comparison chahiye.

payments table se ye columns return kar:
- payment_mode
- successful_payments
- failed_payments

"""

select
	payment_mode ,
    sum(case when payment_status = "Successful" then 1 else 0 end) as successful_payment ,
    sum(case when payment_status = "Failed" then 1 else 0 end) as failed_payment
from payments
group by payment_mode order by successful_payment;


"""Business problem: Customer segmentation by monthly charges

Business team subscriptions ko monthly charges ke basis par segment karna chahti hai.

subscriptions table se har plan ke liye:
- plan — plan ka naam
- average_monthly_charges
- price_category
Category rules:
- Average charge ₹500 se kam: Low
- ₹500 se ₹1,000 tak: Medium
- ₹1,000 se zyada: High """

select
	plan_type ,
    round(avg(monthly_charges) ,2) as average_monthly_charges,
    case 
		when avg(monthly_charges) < 500 then "Low" 
        when avg(monthly_charges) < 1000 then "Medium" 
        else "High" 
        end as price_category
from subscriptions group by plan_type order by average_monthly_charges desc;

"""
Business problem: Customers with no support tickets

Customer experience team un customers ko identify karna chahti hai jinhone abhi tak koi support ticket raise nahi kiya.

Task: customers aur support_tickets tables use karke return kar:
- customer_id
- customer_name
Sirf un customers ko show karna hai jinke paas zero support tickets hain.
"""
select 
	c.customer_id ,
    c.customer_name
from customers c 
left join support_tickets s  
on c.customer_id = s.customer_id 
where s.customer_id is Null ;

"""
Business problem: High-value customers

Business team un customers ko identify karna chahti hai jinki total monthly subscription charges ₹2,000 se zyada hain.

Task: customers aur subscriptions tables se return kar:
- customer_id
- customer_name
- total_monthly_charges — 2 decimal places tak
Sirf un customers ko show kar jinka total ₹2,000 se zyada hai. Highest total charges wala customer pehle aana chahiye.
"""

select 
	c.customer_id ,
    c.customer_name,
    round(sum(s.monthly_charges) , 2) as total_monthly_charges
from customers c
join customer_accounts a 
on c.customer_id = a.customer_id 
join subscriptions s 
on a.account_id = s.account_id
group by c.customer_id , c.customer_name 
having round(sum(s.monthly_charges) , 2) > 2000 
order by total_monthly_charges desc;

"""
Business Problem: Monthly Payment Analysis
Finance team ko samajhna hai ki har month kitne payments receive hue.

payments table se ye columns return kar:
- payment_month — format YYYY-MM, jaise 2026-01
- total_payments — total payment records
- total_payment_amount — total payment amount, 2 decimal places tak
Conditions:
1. Payments ko month-wise group karna hai.
2. Latest month sabse pehle dikhna chahiye.
3. Abhi payment status ka filter mat lagana; sabhi payment records include karne hain.

"""

SELECT
    DATE_FORMAT(payment_date, '%Y-%m') AS payment_month,
    COUNT(*) AS total_payments,
    ROUND(SUM(payment_amount), 2) AS total_payment_amount
FROM payments
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY payment_month DESC;


"""
usiness Problem: Monthly Successful Payment Revenue
Finance team ko har month ki successful payments se aane wali total amount dekhni hai.

payments table se ye columns return kar:
- payment_month — YYYY-MM format
- successful_payments — successful payment records ki count
- successful_payment_amount — successful payments ki total amount, 2 decimal places tak
Conditions:
- Sirf Successful status wale payments include karne hain.
- Latest month sabse pehle dikhna chahiye.

"""

select 
	date_format(payment_date , "%Y-%m") as payment_month ,
    count(case when payment_status = "Successful" then 1 end) as successfull_payments,
    round(sum(case when payment_status = "Successful" then payment_amount else 0 end),2) as successfull_payment_amount
from payments 
	group by date_format(payment_date ,"%Y-%m")
    order by payment_month desc;

"""
payments table se har payment_mode (UPI, Card, Net Banking, etc.) ke liye ye details nikaalni hain:
- payment_mode
- Total failed payments → failed_payments
- Failed payments ki total amount → failed_payment_amount, 2 decimal places tak
- Sirf Failed status wali payments count aur sum karni hain.
- Sabse zyada failed payments wale mode ko pehle dikhana hai.
Expected output format:
payment_mode	failed_payments	failed_payment_amount
UPI	1200	450000.00
Card	900	380000.00

Ye sirf example hai, actual results tumhare database se aayenge.

"""

select 
    payment_mode,
    count(case when payment_status = "Failed" then 1 end ) as total_failed_payment ,
    round(sum(case when payment_status = "Failed" then payment_amount else 0 end),2) as failed_payment_amount
from payments 
	group by payment_mode
    order by total_failed_payment desc;

"""
Q4 — Customer Payment Summary
Ab payments table se har subscription_id ke liye ye details nikaal:
1. subscription_id
2. Total transactions → total_transactions
3. Successful transactions → successful_transactions
4. Total amount received from successful payments → successful_amount (2 decimal places)
Conditions:
- Saari transactions count karni hain.
- Successful transactions sirf Successful status wali count karni hain.
- Successful amount mein sirf Successful payments ka amount add karna hai.
- Sabse zyada transactions wale subscription ko pehle dikhana hai.

"""

SELECT
    subscription_id,
    COUNT(*) AS total_transactions,
    COUNT(
        CASE
            WHEN payment_status = 'Successful' THEN 1
        END
    ) AS successful_transactions,
    ROUND(
        SUM(
            CASE
                WHEN payment_status = 'Successful'
                THEN payment_amount
                ELSE 0
            END
        ), 2
    ) AS successful_amount
FROM payments
GROUP BY subscription_id
ORDER BY total_transactions DESC;

"""
payments table se un subscriptions ki list nikaal jinki 5 se zyada Failed payments hain.

Output mein ye columns chahiye:
- subscription_id
- failed_payments — failed payments ki count
- failed_amount — failed payments ki total amount, 2 decimal places tak
Condition: sirf un subscriptions ko dikhana jahan failed payments ki count 5 se zyada ho.

"""

SELECT
    subscription_id,
    COUNT(
        CASE
            WHEN payment_status = 'Failed' THEN 1
        END
    ) AS failed_payment,
    ROUND(
        SUM(
            CASE
                WHEN payment_status = 'Failed'
                THEN payment_amount
                ELSE 0
            END
        ), 2
    ) AS failed_amount
FROM payments
GROUP BY subscription_id
HAVING COUNT(
    CASE
        WHEN payment_status = 'Failed' THEN 1
    END
) > 5
ORDER BY failed_payment DESC;


"""
Business Problem: Customer Payment Risk Analysis

Company un customers ko identify karna chahti hai jinke payments baar-baar fail ho rahe hain.

payments table se un subscription_id ki list nikalo jinke Failed payments 10 se zyada hain.

Output mein ye columns chahiye:
1. subscription_id
2. failed_payments — failed payments ki total count.
3. failed_amount — failed payments ki total amount, 2 decimal places tak.
Sorting: Sabse zyada failed payments wala subscription pehle aana chahiye.

"""

select 
	s.subscription_id ,
    count(
		case 
			when
				p.payment_status = "Failed" 
                then 1 
					end 
                    ) as failed_payment ,
                    
	round(
		sum(
			case 
				when 
                p.payment_status = "Failed"
				then p.payment_amount 
				else 0 
				end) , 2) as failed_payment_amount 
from subscriptions s 
	join payments p 
on s.subscription_id = p.subscription_id 
group by s.subscription_id 
having     
count(
		case 
			when
				p.payment_status = "Failed" 
                then 1 
					end 
                    )  > 10 
	order by failed_payment desc;

"""
Q2 — Customer Churn Risk Analysis
Company un customers ko identify karna chahti hai jinke support tickets bahut zyada hain aur jo churn risk mein ho sakte hain.

support_tickets table se un customers ki list nikalo jinhone 10 se zyada support tickets raise kiye hain.

Output columns:
1. customer_id
2. total_tickets — total support tickets
Conditions:
- Sirf 10 se zyada tickets wale customers.
- Sabse zyada tickets wala customer pehle.

"""

select 
    c.customer_id ,
    count(s.*)as total_ticket
from customers c 
    join support_tickets s 
on c.customer_id = s.customer_id 
group by c.customer_id 
having count(s.*)> 10 order by c.customer_id desc ;

"""
Q3 — Failed Payment Customers
Ab business team ko un customers ki list chahiye jinki subscriptions par failed payments hue hain.

customers, customer_accounts, subscriptions aur payments tables ko join karke har customer ke liye:
- customer_id
- customer_name
- failed_payments — total failed payments ki count
Conditions:
- Sirf customers jinki failed payments ki count 5 se zyada hai.
- Highest failed-payment count wala customer pehle.

"""

select 
	c.customer_id , 
    c.customer_name ,
    count(
		case 
			when p.payment_status = "Failed"
            then 1 end
            ) as  failed_payments 
from customers c 
join customer_accounts a 
on c.customer_id = a.customer_id
join subscriptions s 
on a.account_id = s.account_id 
join payments p 
on s.subscription_id = p.subscription_id 
group by c.customer_id , c.customer_name 
having     
count(
case 
	when p.payment_status = "Failed"
	then 1 end
	) > 5 
    order by failed_payments desc ;

"""
Q4 — Customer Payment Success Rate
Ab business team ko pata karna hai ki har customer ki kitni payments successful rahi hain.

Ussi JOIN chain ka use kar:

customers → customer_accounts → subscriptions → payments

Output mein ye columns chahiye:
- customer_id
- customer_name
- total_payments
- successful_payments
- success_rate — successful payments ka percentage, 2 decimal places tak.

"""

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(*) AS total_payments,
    COUNT(
        CASE
            WHEN p.payment_status = 'Successful' THEN 1
        END
    ) AS successful_payments,
    ROUND(
        COUNT(
            CASE
                WHEN p.payment_status = 'Successful' THEN 1
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS success_rate
FROM customers c
JOIN customer_accounts a
    ON c.customer_id = a.customer_id
JOIN subscriptions s
    ON a.account_id = s.account_id
JOIN payments p
    ON s.subscription_id = p.subscription_id
GROUP BY c.customer_id, c.customer_name
ORDER BY success_rate DESC;


"""
Q5 — Aaj ka last question
Ab humein har customer ka payment status breakdown nikalna hai.

payments table se har subscription_id ke liye:
- subscription_id
- Successful payments count
- Failed payments count
- Pending payments count
- Refunded payments count
Har status ka count alag column mein hona chahiye. Sabse zyada total transactions wale subscription ko pehle dikhana hai.

""" 

select 
	subscription_id ,
    count(
		case when payment_status = "Successful"
        then 1 end
    ) as successfull_payment_count ,
    count(
		case when payment_status = "Failed"
        then 1 end
    ) as failed_payment_count ,
    count(
		case when payment_status = "Pending"
        then 1 end
    ) as pending_payment_count  , 
    count(
		case when payment_status = "Refunded"
        then 1 end 
    )  as refund_payment_count ,
    
    count(*) as total_transactions
    
from payments 
group by subscription_id 
order by total_transactions desc ;