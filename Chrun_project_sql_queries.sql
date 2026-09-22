Select * from Customers;

-- 1. What's our overall churn rate.
Select 
round(avg(churn * 100),2) as overall_churn_rate
From Customers;

-- 2. Which region churns the most.
Select 
region,
round(avg(churn * 100),2) as Churn_rate,
count(*) 
from Customers
group by region
order by Churn_rate desc;

-- 3. Does contract type (monthly vs yearly) impact churn.
Select 
Contract_type,
round(avg(churn * 100),2) as Impact,
count(*) 
from Customers
group by Contract_type
order by Impact desc;

-- 4. Is there a satisfaction score threshold where churn spikes.
Select 
satisfaction_score,
count(*),
round(avg(churn * 100),2) as churn_spikes
from Customers
group by satisfaction_score
order by churn_spikes desc;

-- 5.Does a high-risk flag accurately predict a higher churn rate.

Select 
high_risk,
count(*),
round(avg(churn * 100),2) as churn_rate
from Customers
group by high_risk
order by churn_rate desc;

-- 6-- .Do inactive customers (no login in 30+ days) churn more.
Select 
risk_by_login,
count(*),
round(avg(churn * 100),2) as C_percentage_rate
from Customers
group by risk_by_login
order by C_percentage_rate desc;

-- Q7. How much monthly recurring revenue is at risk from churned customers
Select 
round(sum(monthly_charges),2) as Lost_Churn
from Customers
where churn = 1;
 
-- 8.Who are our highest-value customers at Risk.
Select customer_id, region, subscription_type,
monthly_charges, total_charges, last_login_days_ago,
rank() over (order by total_charges desc) as Top_10_Customers
FROM customers
WHERE last_login_days_ago > 30
ORDER BY total_charges DESC
LIMIT 10;

-- 9. Does discount usage actually reduce churn.
Select 
discount_used,
count(*) as numbers,
round(avg(churn * 100),2) as churn_rate
from Customers
group by discount_used;

-- 10.churned customers show lower product engagement (total_watch_time)?
Select 
churn,
round(avg(total_watch_time),2) as avg_watch_time
from Customers
group by churn;


