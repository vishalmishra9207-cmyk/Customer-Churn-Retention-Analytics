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