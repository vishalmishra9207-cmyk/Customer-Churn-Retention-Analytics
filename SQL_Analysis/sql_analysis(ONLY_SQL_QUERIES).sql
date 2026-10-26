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