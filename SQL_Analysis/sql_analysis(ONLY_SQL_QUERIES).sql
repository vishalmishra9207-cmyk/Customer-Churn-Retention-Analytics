use churn_retention_analytics;

select gender ,  count(*)  as total_customer 
    from customers group by gender order by total_customer desc;
    
select subscription_status , count(*) as total_subscriptions 
	from subscriptions where subscription_status not  in ("Active" , "Terminated")
    group by subscription_status  order by subscription_status desc;
    
select 
	plan_type ,
    round(avg(monthly_charges) , 2)  as average_monthly_charges
from subscriptions 
	group by plan_type 
    order by average_monthly_charges desc;

select 
	ticket_status,
    count(*) as total_tickets 
from support_tickets
	group by ticket_status
	having count(*) > 1000
    order by total_tickets desc ;
    
    
select
    customer_id , 
    count(*) as total_tickets
from support_tickets
    group by customer_id 
    having count(*) > 5
    order by total_tickets desc;
    
select 	
	count(*) as total_subscriptions ,
    case 
    when subscription_status = "Active" then "Active"
    else "Inactive" 
    end as subscription_category
from subscriptions group by subscription_category  order by total_subscriptions desc;

select * from subscriptions ;

select
	payment_mode ,
    sum(case when payment_status = "Successful" then 1 else 0 end) as successful_payment ,
    sum(case when payment_status = "Failed" then 1 else 0 end) as failed_payment
from payments
group by payment_mode order by successful_payment;


select
	plan_type ,
    round(avg(monthly_charges) ,2) as average_monthly_charges,
    case 
		when avg(monthly_charges) < 500 then "Low" 
        when avg(monthly_charges) < 1000 then "Medium" 
        else "High" 
        end as price_category
from subscriptions group by plan_type order by average_monthly_charges desc;


select * from payments;


select 
	date_format(payment_date , "%Y-%m") as payment_month ,
    count(transaction_id) as total_payment ,
    round(sum(payment_amount),2) as total_payment_amount
from payments 
	group by date_format(payment_date , "%Y-%m") 
    order by payment_month desc;
    
    
select 
	date_format(payment_date , "%Y-%m") as payment_month ,
    count(case when payment_status = "Successful" then 1 end) as successfull_payments,
    round(sum(case when payment_status = "Successful" then payment_amount else 0 end),2) as successfull_payment_amount
from payments 
	group by date_format(payment_date ,"%Y-%m")
    order by payment_month desc;

select 
    payment_mode,
    count(case when payment_status = "Failed" then 1 end ) as total_failed_payment ,
    round(sum(case when payment_status = "Failed" then payment_amount else 0 end),2) as failed_payment_amount
from payments 
	group by payment_mode
    order by total_failed_payment desc;
    
select 
	subscription_id ,
    count(*) as total_transactions ,
    count(case 
		when 
			payment_status = "Successful" 
				then 1 end)
			as successful_transactions,
    round(
    sum(case 
			when 
				payment_status = "Successful" 
				then payment_amount else 0 end) , 2) as successful_amount 
from payments 
	group by subscription_id ;
    
    
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


select 
	s.plan_type ,
    count(*) as total_subscriptions,
    count(ce.subscription_id) as churned_customers ,
    round (count(ce.subscription_id) * 100 / count(*) , 2) as churn_percentage
from subscriptions s
left join churn_events ce
	on s.subscription_id = ce.subscription_id
group by s.plan_type;

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
    
SELECT
    ce.leaving_reason AS churn_reason,
    COUNT(*) AS total_churned_customers,
    ROUND(AVG(s.monthly_charges), 2) AS average_monthly_charges
FROM subscriptions s
JOIN churn_events ce
    ON s.subscription_id = ce.subscription_id
GROUP BY ce.leaving_reason
ORDER BY total_churned_customers DESC;


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

select 
    c.customer_id ,
    c.customer_name ,
    s.monthly_charges ,
    ce.leaving_reason
from customers c 
    join customer_accounts a 
on c.customer_id = a.customer_id
    join subscriptions s 
on a.account_id = s.account_id 
    join churn_events ce 
on s.subscription_id = ce.subscription_id 
where  s.monthly_charges > 1000;

select 
	s.plan_type ,
    count( ce.subscription_id) as churned_subscriptions ,
    sum(s.monthly_charges) as total_lost_monthly_revenue 
from subscriptions s 
	join churn_events ce 
on s.subscription_id = ce.subscription_id 
group by s.plan_type
ORDER BY total_lost_monthly_revenue DESC;

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
        END ;
        
        
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