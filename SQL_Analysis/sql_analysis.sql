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