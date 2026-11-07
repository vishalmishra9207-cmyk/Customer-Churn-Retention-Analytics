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

""" Day 4 """ 

"""
Business Problem: Company ko dekhna hai ki har subscription plan mein kitne customers churn hue hain aur unka churn percentage kya hai.

Output mein ye columns chahiye:
- plan_name
- total_customers
- churned_customers
- churn_percentage
"""

select 
	s.plan_type ,
    count(*) as total_subscriptions,
    count(ce.subscription_id) as churned_customers ,
    round (count(ce.subscription_id) * 100 / count(*) , 2) as churn_percentage
from subscriptions s
left join churn_events ce
	on s.subscription_id = ce.subscription_id
group by s.plan_type;

"""
Business Problem: Company dekhna chahti hai ki different retention offers mein kitne customers ne offer accept kiya.

Humein har offer type ke liye calculate karna hai:
1. offer_type
2. total_offers
3. accepted_offers
4. acceptance_percentage

"""

select 
	activity_type as offer_type ,
    count(*) as total_offers ,
    count(
		case 
			when retention_status = "Still Active" 
            then 1 
            end
        ) as accepted_offers ,
	round (
    count(
		case 
			when retention_status = "Still Active" 
            then 1 
            end ) * 100 / count(*)
    ,2 ) as accepted_percentage
from retention_activity
group by activity_type
	order by accepted_percentage desc;

"""
.
🎯 Q3 — Churn Reason Analysis
Business Problem: Company ko samajhna hai ki customers sabse zyada kis reason se churn kar rahe hain, taaki woh apni retention strategy improve kar sake.

Humein har churn reason ke liye nikalna hai:
- churn_reason
- total_churned_customers
- average_monthly_charges

""" 

SELECT
    ce.leaving_reason AS churn_reason,
    COUNT(*) AS total_churned_customers,
    ROUND(AVG(s.monthly_charges), 2) AS average_monthly_charges
FROM subscriptions s
JOIN churn_events ce
    ON s.subscription_id = ce.subscription_id
GROUP BY ce.leaving_reason
ORDER BY total_churned_customers DESC;



"""
🎯 Q4 — Retention Offer Effectiveness
Business Problem: Company check karna chahti hai ki retention offers dene ke baad kitne customers retain hue aur kitne churn ho gaye.

Output mein ye columns chahiye:
1. activity_type — retention activity ka type
2. total_activities — total activities
3. retained_customers — retention status Still Active wale records
4. churned_customers — retention status Churned wale records

"""
select 
	activity_type ,
    count(*) as total_activity,
    count(
		case
			when 
				retention_status = "Still_active"
                then 1 
                end
		) as retained_cutomers ,
	count(
		case 
			when 
				retention_status = "Churned"
                then 1 
                end
		) as churned_customers 
from retention_activity
group by activity_type;


"""
🎯 Q5 — High-Value Customers Who Churned
Business Problem: Company identify karna chahti hai ki churn hone wale customers mein kaunse customers zyada monthly charges pay kar rahe the, taaki unke churn hone ka financial impact samajh sake.

Output mein ye 4 columns chahiye:
1. customer_id
2. customer_name
3. monthly_charges
4. leaving_reason

"""
select 
    c.customer_id ,
    c.customer_name ,
    s.monthly_charges ,
    ce.leaving_reason
from customers c 
    join customer_accouts a 
on c.customer_id = a.customer_id
    join subscriptions s 
on a.account_id = s.account_id 
    join churn_events ce 
on s.subscription_id = ce.subscription_id ;

"Day 6"

"""
🎯 Day 6 — Question 1/5
Business Problem: Churned Customers se Kitna Revenue Impact Hua?
Company jaanana chahti hai ki har subscription plan mein churn hue customers ki monthly charges ki total value kitni thi.

Output mein ye columns chahiye:
Column	Meaning
plan_type	Subscription plan
churned_subscriptions	Churn hui subscriptions ki count
total_lost_monthly_revenue	Un subscriptions ke monthly charges ka total

"""

select 
	s.plan_type ,
    count( ce.subscription_id) as churned_subscriptions ,
    sum(s.monthly_charges) as total_lost_monthly_revenue 
from subscriptions s 
	join churn_events ce 
on s.subscription_id = ce.subscription_id 
group by s.plan_type
ORDER BY total_lost_monthly_revenue DESC;

"""
🎯 Q2 — Churn Rate by Contract Type
Business Problem: Company jaanana chahti hai ki kaunse contract type mein churn rate sabse zyada hai.

Output:
- contract_type
- total_subscriptions
- churned_subscriptions
- churn_percentage

"""

select 
	s.contract_type ,
    count(*) as total_subscriptions ,
    count(ce.subscription_id) as churned_subscriptions, 
    round(COUNT(ce.subscription_id) * 100 / count(*) ,2 ) as churn_percentage 
from subscriptions s
	left join churn_events ce 
on s.subscription_id = ce.subscription_id 
group by s.contract_type
order by churn_percentage desc;


"""
Business Problem: Company un customers ko identify karna chahti hai jinki subscriptions mein 5 se zyada failed payments hui hain, taaki unhe proactively support diya ja sake.

Output mein ye columns chahiye:
- customer_id
- customer_name
- failed_payments
- total_failed_amount

"""

select 
    c.customer_id ,
    c.customer_name ,
    count(
        case 
            when p.payment_status = "Failed"
            then 1 
            end
    ) as total_failed_payments ,

    sum(
        case when p.payment_status = "Failed"
        then p.payment_amount 
        else 0 
        end
    ) as failed_payment_amount 

from customers c 
    join customer_accounts a 
on c.customer_id = a.customer_id 
    join subscriptions s 
on s.account_id = a.account_id 
    join payments p 
on p.subscription_id = s.subscription_id 
group by c.customer_id , c.customer_name 
HAVING COUNT(
    CASE
        WHEN p.payment_status = 'Failed' THEN 1
    END
) > 5
order by failed_payment_amount desc;

"""
🎯 Q4/5 — Churn vs Retained Customers: Revenue Comparison
Business Problem: Company compare karna chahti hai ki churned aur currently active subscriptions ki average monthly charges kitni hain.

Output:
- customer_category — Churned ya Retained
- total_subscriptions
- average_monthly_charges
- total_monthly_charges

"""

select 
        CASE
            WHEN 
            ce.subscription_id IS NOT NULL THEN 'Churned'
        ELSE 'Retained'
        END as customer_category ,
    
    count(*) as total_subscriptions ,

    avg(s.monthly_charges) as average_monthly_charges,
    sum(s.monthly_charges) as total_monthly_charges
from subscriptions s
    left join churn_events ce
on s.subscription_id = ce.subscription_id 
group by  CASE
            WHEN 
            ce.subscription_id IS NOT NULL THEN 'Churned'
        ELSE 'Retained'
        END



"""
🎯 Q5/5 — Aaj ka last question
Business Problem: Har churn reason ke liye company ko dekhna hai ki churn hui subscriptions ka average monthly charge kitna tha aur total monthly revenue impact kitna tha.

Output:
- leaving_reason
- churned_subscriptions
- average_monthly_charges
- total_lost_monthly_revenue

"""

select 
	ce.leaving_reason,
    count(ce.subscription_id) as churned_subscriptions ,
    avg(s.monthly_charges) as average_monthly_charges ,
    sum(
		case 
			when ce.subscription_id is not null 
            then s.monthly_charges
				end
    ) as total_lost_monthly_charges
from  subscriptions s 
	join churn_events ce
on s.subscription_id = ce.subscription_id
group by ce.leaving_reason
order by total_lost_monthly_charges desc;

"Day 7"


"""
🎯 Day 7 — Question 1/5
Business Problem: High-Value Churned Customers
Company identify karna chahti hai ki kaunse churned customers sabse zyada 
monthly charges pay kar rahe the, taaki company samajh sake ki kin customers ko retain karna financially important tha.

Output mein ye columns chahiye:
Column	Meaning
customer_id	Customer ki ID
customer_name	Customer ka naam
plan_type	Subscription plan
monthly_charges	Monthly subscription charges
leaving_reason	Customer ke churn hone ka reason
"""

select 
	c.customer_id ,
    c.customer_name ,
    s.plan_type ,
    s.monthly_charges ,
    ce.leaving_reason
from customers c 
	join customer_accounts ca
on c.customer_id = ca.customer_id 
	join subscriptions s
on ca.account_id = s.account_id 
	join churn_events ce 
on ce.subscription_id = s.subscription_id 
group by 
	c.customer_id , 
    c.customer_name , 
    s.plan_type , 
    s.monthly_charges , 
    ce.leaving_reason
having s.monthly_charges > 800
	order by s.monthly_charges desc;

"""
🎯 Day 7 — Question 2/5
Business Problem: Retention Offers ka Success Rate
Company check karna chahti hai ki har retention activity type ke kitne records ka status Still Active hai.

Output columns:
- activity_type
- total_activities
- still_active_count
- still_active_percentage

"""

SELECT
    activity_type,
    COUNT(*) AS total_activities,
   COUNT(
    CASE
        WHEN retention_status = 'Still_active' THEN 1
    END
) as still_active_count,
    ROUND(
COUNT(
    CASE
        WHEN retention_status = 'Still_active' THEN 1
    END
) * 100 / COUNT(*),
        2
    ) AS still_active_percentage
FROM retention_activity
GROUP BY activity_type
ORDER BY still_active_percentage DESC;


"""
Q3. Customers with Multiple Retention Attempts
Business question: Aise customers identify karo jinhe retention team ne 3 se zyada baar contact kiya hai.

Required output:
- customer_id
- customer_name
- total_retention_attempts

"""

select 
	c.customer_id ,
    c.customer_name,
    count(ra.customer_id) as totol_retention_attempts 
from customers c 
	left join retention_activity ra 
on c.customer_id = ra.customer_id 
group by c.customer_id , c.customer_name
having count(ra.customer_id) > 3 
order by  totol_retention_attempts desc;


"""
Q4. Retention Offers vs Churn
Business question: Identify karo ki kin retention activity types ke baad customers churn hue.

Required output:
- activity_type
- total_activities
- churned_count
- churned_percentage
"""

SELECT
    ra.activity_type,
    COUNT(*) AS total_activity,
    COUNT(
        CASE
            WHEN ce.churn_id IS NOT NULL THEN 1
        END
    ) AS churned_count,
    ROUND(
        COUNT(
            CASE
                WHEN ce.churn_id IS NOT NULL THEN 1
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS churned_percentage
FROM retention_activity ra
LEFT JOIN churn_events ce
    ON ra.subscription_id = ce.subscription_id
GROUP BY ra.activity_type
ORDER BY churned_percentage DESC;

"""
Q5. Retention Activity Analysis by Plan Type
Business question: Identify karo ki Basic, Standard aur Premium plans mein kaunse plan par sabse zyada retention activities perform ki gayi hain.

Required output:
- plan_type
- total_activities
- unique_customers
- churned_activities

""" 

select 
	s.plan_type ,
    count(ra.activity_type) as total_activities ,
    count(distinct c.customer_id) as unique_customers ,
    COUNT(CASE WHEN ce.churn_id IS NOT NULL THEN 1 END) as churned_activities 
from customers c 
	join customer_accounts ca 
on c.customer_id = ca.customer_id
	join subscriptions s 
on ca.account_id = s.account_id 
	left join churn_events ce
on s.subscription_id  = ce.subscription_id 
	join retention_activity ra 
on ra.subscription_id = s.subscription_id
group by s.plan_type
ORDER BY total_activities DESC;

"""
Day 8 — Q1/5: Customer Retention Risk Analysis
Business Scenario:

Company un customers ko identify karna chahti hai jinhone:
- 3 se zyada support tickets raise kiye hain.
- Unki subscription abhi bhi Active hai.
- Unka monthly charge ₹800 se zyada hai.
Required Output:
1. customer_id
2. customer_name
3. plan_type
4. monthly_charges
5. total_tickets

"""

select 
	c.customer_id,
    c.customer_name,
    s.plan_type,
    s.monthly_charges ,
    s.subscription_status,
	count(st.ticket_id) as total_tickets 
from customers c 
	join customer_accounts ca
on c.customer_id = ca.customer_id 
	join subscriptions s 
on s.account_id = ca.account_id 
	join support_tickets st
on c.customer_id = st.customer_id 
	group by 
    c.customer_id ,
    c.customer_name , 
    s.plan_type, 
    s.monthly_charges, 
    s.subscription_status
having count(st.ticket_id) > 3  and s.monthly_charges > 800 and s.subscription_status = "Active"
order by total_tickets desc ;

"""
Day 8 — Q2/5: Failed Payment & Churn Risk
Business Scenario:

Company un customers ko identify karna chahti hai jinke:
- 2 ya usse zyada failed payments hain.
- Total failed payment amount ₹1,000 se zyada hai.
Required Output:
1. customer_id
2. customer_name
3. failed_payment_count
4. total_failed_amount

"""

select 
    c.customer_id ,
    c.customer_name ,
    count(
        case 
            when p.payment_status = "Failed" 
            then 1 
            end
        ) as failed_payment_count ,
    sum(
        case 
            when p.payment_status = "Failed" 
            then p.payment_amount 
            else 0 
            end
        ) as total_failed_amount
from customers c 
    join customer_accounts ca
on c.customer_id = ca.customer_id 
	join subscriptions s 
on s.account_id = ca.account_id 
	join payments p 
on s.subscription_id = p.subscription_id 
group by 
	c.customer_id ,
    c.customer_name
having    
    count(
            case 
                when p.payment_status = "Failed" 
                then 1 
                end
            ) >= 2 and 
        sum(
            case 
                when p.payment_status = "Failed" 
                then p.payment_amount 
                else 0 
                end
            ) > 1000
    order by total_failed_amount desc;



"""
Q3/5 — Monthly Revenue Trend
Business Scenario:

Company ko 2025 aur 2026 ke monthly successful payment revenue ka trend analyse karna hai.

Required Output:
1. payment_month — YYYY-MM format
2. total_transactions
3. total_revenue
4. average_payment_amount

"""
SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS payment_month,
    COUNT(*) AS total_transactions,
    SUM(payment_amount) AS total_revenue,
    AVG(payment_amount) AS average_payment_amount
FROM payments
WHERE payment_status = 'Successful'  AND (
        YEAR(payment_date) = 2025
        OR YEAR(payment_date) = 2026
      )
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY DATE_FORMAT(payment_date, '%Y-%m') desc ;

""" 
Q4/5 — Churn Rate by Contract Type
Business Scenario: Company identify karna chahti hai ki kis contract type mein churn rate sabse zyada hai.

Required output:
1. contract_type
2. total_subscriptions
3. churned_subscriptions
4. churn_percentage

"""
SELECT
	S.CONTRACT_TYPE ,
    COUNT(DISTINCT S.SUBSCRIPTION_ID) AS TOTAL_SUBSCRIPTIONS,
    COUNT(distinct CE.SUBSCRIPTION_ID) AS CHURNED_SUBSCRIPTIONS,
    ROUND(COUNT(DISTINCT CE.SUBSCRIPTION_ID) * 100 / COUNT(DISTINCT S.SUBSCRIPTION_ID) ,2 )  AS CHURN_PERCENTAGE
FROM SUBSCRIPTIONS S 
	LEFT JOIN CHURN_EVENTS CE 
ON CE.SUBSCRIPTION_ID = S.SUBSCRIPTION_ID 
	GROUP BY S.CONTRACT_TYPE
ORDER BY CHURN_PERCENTAGE DESC ;

"""
Q5/5 — Final Question: Revenue Contribution by Subscription Plan
Business Scenario:

Company jaana chahti hai ki Basic, Standard aur Premium plans mein se kaunsa plan successful payments ke through sabse zyada revenue generate kar raha hai.

Required Output:
1. plan_type
2. total_customers
3. successful_transactions
4. total_revenue
5. revenue_percentage

"""

SELECT
    s.plan_type,

    COUNT(DISTINCT c.customer_id) AS total_customers,

    COUNT(
        CASE
            WHEN p.payment_status = 'Successful'
            THEN 1
        END
    ) AS successful_transactions,

    SUM(
        CASE
            WHEN p.payment_status = 'Successful'
            THEN p.payment_amount
            ELSE 0
        END
    ) AS total_revenue,

    ROUND(
        SUM(
            CASE
                WHEN p.payment_status = 'Successful'
                THEN p.payment_amount
                ELSE 0
            END
        ) * 100.0 /

        (
            SELECT SUM(payment_amount)
            FROM payments
            WHERE payment_status = 'Successful'
        ),
        2
    ) AS revenue_percentage

FROM customers c

JOIN customer_accounts ca
    ON c.customer_id = ca.customer_id

JOIN subscriptions s
    ON ca.account_id = s.account_id

JOIN payments p
    ON p.subscription_id = s.subscription_id

GROUP BY s.plan_type

ORDER BY total_revenue DESC;


"""
Day 9 — Q1/5: Customer Lifetime Revenue Analysis
Business Scenario:

Company identify karna chahti hai ki kaunse customers ne ab tak sabse zyada successful payment revenue generate kiya hai.

Required Output:
1. customer_id
2. customer_name
3. total_successful_payments
4. total_revenue
5. average_payment_amount

"""
select 
	c.customer_id ,
    c.customer_name ,
    count(
		case 
			when p.payment_status = "Successful"
            then 1 
            end
    ) as total_successful_payments ,
    sum(
		case
			when p.payment_status = "Successful"
            then p.payment_amount
            end
    ) as total_revenue ,
    round (avg
		(case 
			when p.payment_status = "Successful"
            then p.payment_amount
            end
    ),2) as average_payment_amount
	from customers c 
join customer_accounts ca 
	on c.customer_id = ca.customer_id 
join subscriptions s 
	on ca.account_id = s.account_id 
join payments p 
	on p.subscription_id = s.subscription_id
group by 
	c.customer_id ,
    c.customer_name
having 
    sum(
		case
			when p.payment_status = "Successful"
            then p.payment_amount
            end
    ) > 10000 
order by total_revenue desc ;

"""
Day 9 — Q2/5: Customer Service Dependency Analysis
Business problem: Kya zyada support tickets raise karne wale customers ka churn risk zyada hai?

Find customers who:
- Have raised at least 5 support tickets.
- Have an Active subscription.
- Show whether they have churned in the past.
Output:
- customer_id
- customer_name
- total_tickets
- subscription_status
- churn_status
"""

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT st.ticket_id) AS total_tickets,
    s.subscription_status,
    CASE
        WHEN MAX(
            CASE
                WHEN ce.subscription_id IS NOT NULL THEN 1
                ELSE 0
            END
        ) = 1 THEN 'Churned'
        ELSE 'Not Churned'
    END AS churn_status

FROM customers c

JOIN customer_accounts ca
    ON c.customer_id = ca.customer_id

JOIN subscriptions s
    ON ca.account_id = s.account_id

JOIN support_tickets st
    ON c.customer_id = st.customer_id

LEFT JOIN churn_events ce
    ON s.subscription_id = ce.subscription_id

WHERE s.subscription_status = 'Active'

GROUP BY
    c.customer_id,
    c.customer_name,
    s.subscription_id,
    s.subscription_status

HAVING COUNT(DISTINCT st.ticket_id) >= 5

ORDER BY total_tickets DESC;

"""
Day 9 — Q3/5
Customer Revenue vs Subscription Cost Analysis

find customers whose total successful payment revenue is less than their total expected annual subscription charges.

Output columns:
1. customer_id
2. customer_name
3. total_monthly_charges
4. expected_annual_charges
5. total_successful_revenue
6. revenue_gap

"""
WITH SUBSCRIPTION_ANALYSIS AS
(
    SELECT
        CA.CUSTOMER_ID,
        SUM(S.MONTHLY_CHARGES) AS TOTAL_MONTHLY_CHARGES
    FROM CUSTOMER_ACCOUNTS CA
    JOIN SUBSCRIPTIONS S
        ON CA.ACCOUNT_ID = S.ACCOUNT_ID
    GROUP BY CA.CUSTOMER_ID
),

PAYMENT_ANALYSIS AS
(
    SELECT
        CA.CUSTOMER_ID,
        SUM(
            CASE
                WHEN P.PAYMENT_STATUS = 'Successful'
                THEN P.PAYMENT_AMOUNT
                ELSE 0
            END
        ) AS TOTAL_SUCCESSFUL_REVENUE
    FROM CUSTOMER_ACCOUNTS CA
    JOIN SUBSCRIPTIONS S
        ON CA.ACCOUNT_ID = S.ACCOUNT_ID
    JOIN PAYMENTS P
        ON S.SUBSCRIPTION_ID = P.SUBSCRIPTION_ID
    GROUP BY CA.CUSTOMER_ID
)

SELECT
    C.CUSTOMER_ID,
    C.CUSTOMER_NAME,
    SA.TOTAL_MONTHLY_CHARGES,
    SA.TOTAL_MONTHLY_CHARGES * 12 AS EXPECTED_ANNUAL_CHARGES,
    PA.TOTAL_SUCCESSFUL_REVENUE,
    (SA.TOTAL_MONTHLY_CHARGES * 12 - PA.TOTAL_SUCCESSFUL_REVENUE) AS REVENUE_GAP

FROM CUSTOMERS C

JOIN SUBSCRIPTION_ANALYSIS SA
    ON C.CUSTOMER_ID = SA.CUSTOMER_ID

JOIN PAYMENT_ANALYSIS PA
    ON C.CUSTOMER_ID = PA.CUSTOMER_ID

WHERE PA.TOTAL_SUCCESSFUL_REVENUE < SA.TOTAL_MONTHLY_CHARGES * 12

ORDER BY REVENUE_GAP DESC;

"""
Day 9 — Q4/5: Customer Retention Effectiveness Analysis
Business problem: Company jaana chahti hai ki retention offers accept karne wale customers kitne time tak active rahe.

Find the retention success percentage for each activity_type.

Output columns:
1. activity_type
2. total_customers
3. retained_customers
4. churned_customers
5. retention_success_rate

"""

select 
	activity_type ,
    count(distinct customer_id)  as total_customers,
    count(
		distinct case 
				when 
					retention_status != "Churned"
					then customer_id
					end
		) as retained_customers ,
    count(
		distinct case  
				when retention_status = "Churned"
				then customer_id
				end
    ) as churned_customers ,
    round(
        count(
		distinct case 
			when 
				retention_status != "Churned"
                then customer_id 
                end
    ) * 100 /  count(distinct customer_id) , 2
    ) as rentention_success_rate
from retention_activity
group by activity_type ;

"""
Day 9 — Q5/5: Latest Customer Subscription Analysis
Business problem: Company ko har customer ki latest subscription ka status aur plan identify karna hai.

Task: Har customer ki latest subscription record find karo.

Output columns:
1. customer_id
2. customer_name
3. subscription_id
4. plan_type
5. subscription_status
6. monthly_charges

"""

with subscription_analysis as 
	(
    select 
		c.customer_id ,
		c.customer_name,
		s.subscription_id,
        s.plan_type,
        s.subscription_status ,
        s.monthly_charges ,
        row_number() over(
        partition by c.customer_id order by s.start_date desc , subscription_id desc
        ) as  rn
        from customers c 
			join customer_accounts ca 
		on c.customer_id = ca.customer_id 
			join subscriptions s 
				on s.account_id = ca.account_id
        )
	select 
		customer_id,
        customer_name , 
        subscription_id ,
        plan_type,
        subscription_status,
        monthly_charges 
	from subscription_analysis 
		where rn = 1 ;


"""
Day 10 — Q1/5: Churned Customer Tenure Analysis
Business problem: Company jaana chahti hai ki customers average kitne din subscription use karne ke baad churn karte hain, 
aur kaunse plan ke customers sabse jaldi leave karte hain.

Task: Plan-wise churned subscriptions ka tenure calculate karo.

Output columns:
1. plan_type
2. total_churned_subscriptions
3. average_tenure_days
4. minimum_tenure_days
5. maximum_tenure_days

"""

SELECT
    s.plan_type,
    COUNT(DISTINCT ce.subscription_id) AS total_churned_subscriptions,
    MIN(DATEDIFF(ce.churn_date, s.start_date)) AS minimum_tenure_days,
    MAX(DATEDIFF(ce.churn_date, s.start_date)) AS maximum_tenure_days,
    ROUND(AVG(DATEDIFF(ce.churn_date, s.start_date)), 2) AS average_tenure_days

FROM subscriptions s

JOIN churn_events ce
    ON s.subscription_id = ce.subscription_id

GROUP BY s.plan_type

ORDER BY average_tenure_days ASC;

"""
Day 10 — Q2/5
Business Problem: Top Churn Reasons by Subscription Plan
Company management wants to understand why customers are leaving each subscription plan.

Your task: Find the top 3 churn reasons for each plan.

Expected output:
Column	Meaning
plan_type	Basic / Standard / Premium
leaving_reason	Reason for churn
churned_subscriptions	Number of churned subscriptions
reason_rank	Rank of each reason within its plan

"""

WITH churned_reason AS (
    SELECT
        s.plan_type,
        ce.leaving_reason,
        COUNT(DISTINCT ce.subscription_id) AS total_churned_subscriptions,
        DENSE_RANK() OVER (
            PARTITION BY s.plan_type
            ORDER BY COUNT(DISTINCT ce.subscription_id) DESC
        ) AS reason_rank
    FROM subscriptions s
    JOIN churn_events ce
        ON ce.subscription_id = s.subscription_id
    GROUP BY
        s.plan_type,
        ce.leaving_reason
)
SELECT
    plan_type,
    leaving_reason,
    total_churned_subscriptions,
    reason_rank
FROM churned_reason
WHERE reason_rank <= 3
ORDER BY plan_type, reason_rank ASC;

"""
🔥 Day 10 — Q3/5
Business Problem: Customer Revenue Segmentation
Company management wants to identify customers based on their total successful payment revenue.

Your task: Calculate each customer's lifetime successful revenue and classify them into three segments.
Revenue	Segment
0–10,000	Low Value
10,001–50,000	Medium Value
Above 50,000	High Value

Expected output:
- customer_id
- customer_name
- total_successful_revenue
- revenue_segment

"""
WITH customer_revenue_segment AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(
            CASE
                WHEN p.payment_status = 'Successful'
                THEN p.payment_amount
                ELSE 0
            END
        ) AS total_successful_revenue
    FROM customers c
    JOIN customer_accounts ca
        ON c.customer_id = ca.customer_id
    JOIN subscriptions s
        ON ca.account_id = s.account_id
    JOIN payments p
        ON s.subscription_id = p.subscription_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_successful_revenue,
    CASE
        WHEN total_successful_revenue <= 10000 THEN 'Low Value'
        WHEN total_successful_revenue <= 50000 THEN 'Medium Value'
        ELSE 'High Value'
    END AS revenue_segment
FROM customer_revenue_segment ORDER BY total_successful_revenue desc ;

"""
Day 10 — Q4/5
Business Problem: Monthly Customer Payment Consistency
Company management wants to identify customers who have made successful payments consistently over the last 6 months.

Your task: Find customer-wise monthly successful payment activity.

Expected output:
customer_id	
customer_name	
total_successful_payments	
active_payment_months   
"""

with monthly_payment_consistency as (
	select 
		c.customer_id,
        c.customer_name,
        sum(
			case 
				when p.payment_status = "Successful"
                then p.payment_amount 
                else 0 
			end 
        ) as total_successful_payments ,
        COUNT(DISTINCT
			CASE
				WHEN p.payment_status = 'Successful'
				THEN DATE_FORMAT(p.payment_date, '%Y-%m')
			END
		) AS active_payment_months 
	from customers c 
		join customer_accounts ca 
	on c.customer_id= ca.customer_id 
		join subscriptions s 
	on s.account_id = ca.account_id 
		join payments p 
	on p.subscription_id = s.subscription_id
    WHERE p.payment_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
  AND p.payment_date < CURDATE() + INTERVAL 1 DAY 
		group by c.customer_id , c.customer_name
        having  
        COUNT(DISTINCT
			CASE
				WHEN p.payment_status = 'Successful'
				THEN DATE_FORMAT(p.payment_date, '%Y-%m')
			END
		) >= 4 
) 
select * from monthly_payment_consistency  order by active_payment_months desc;



"""
Day 10 — Q5/5 (Final Question)
Business Problem: Customer Churn Risk Identification
Company management wants to identify customers who are showing signs of churn risk based on their payment behaviour.

Your task: Identify customers who meet BOTH conditions:
1. At least 3 failed payments in the last 6 months.
2. At least 2 successful payments in the last 6 months.
Expected output:
Column	Meaning
customer_id	Customer ID
customer_name	Customer name
failed_payments	Total failed transactions
successful_payments	Total successful transactions
risk_category	High Churn Risk

Conditions:
- Use customers, customer_accounts, subscriptions, payments.
- Consider only the last 6 months.
- Group results customer-wise.
- Show only customers meeting both conditions.

"""

with churn_risk_customers as (
	select 
		c.customer_id,
        c.customer_name,
        count(
			case 
				when p.payment_status = "Failed"
                then 1 
                end
        ) as total_failed_transactions,
		count(
			case
				when p.payment_status = "Successful"
                then 1 
                end 
        ) as total_successful_transactions
        from customers c 
			join customer_accounts ca 
		on c.customer_id = ca.customer_id
			join subscriptions s 
		on s.account_id = ca.account_id
			join payments  p 
		on p.subscription_id = s.subscription_id
         WHERE p.payment_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
  AND p.payment_date < CURDATE() + INTERVAL 1 DAY  
        group by c.customer_id , c.customer_name
        having 
			count((case when p.payment_status = "Failed" then 1 end)) >=3
        and
			count(case when p.payment_status = "Successful" then 1 end) >= 2 
)

SELECT
    customer_id,
    customer_name,
    total_failed_transactions,
    total_successful_transactions,
    'High Churn Risk' AS risk_category
FROM churn_risk_customers;
    ;