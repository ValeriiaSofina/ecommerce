-- Проект: Анализ интернет-магазина 
-- Блок: Анализ поведения пользователей

-- Сегментация пользователей (Новые vs повторные)

With users_data as
(
	SELECT user_id, COUNT(*) as order_count from orders
	WHERE status = 'completed'
	GROUP BY user_id)

SELECT COUNT (case 
			  when order_count = 1 then 1 end) as new_users,
       COUNT (case 
			  when order_count > 1 then 1 end) as repeat_users	  
FROM users_data

--Среднее количество заказов на пользователя
SELECT AVG(order_count) as avg_count_orders
FROM users_data

-- Частота покупок по месяцам
SELECT 
DATE_TRUNC('month', order_date) AS month,
COUNT(*)::numeric / COUNT(DISTINCT user_id) as purchase_frequency
FROM orders
WHERE status = 'completed'
GROUP BY month
ORDER BY month

-- Сегментация по количеству заказов 
--(пользователи с 1 заказом, с 2-4 заказами, с 5+ заказами, средний чек и выручка в каждой группе)
With users_data as
(
SELECT user_id, COUNT(*) as order_count, sum(revenue) as sum_revenue,
	CASE when COUNT(*) = 1 then '1 order'
	when COUNT(*) BETWEEN 2 AND 4 then '2-4 orders'
	when COUNT(*) > 4 then '5+ order'
	end as segment
from orders
WHERE status = 'completed'
GROUP BY user_id)
SELECT segment, count (*) as users_count, SUM (sum_revenue) as sum_revenue, SUM (sum_revenue)::numeric/ Sum (order_count) as avg_bill
from users_data
group by segment
order by segment

-- retention по месяцам
with first_orders as
(
	select user_id, DATE_TRUNC('month', MIN(order_date)) as cohort_month from orders
	where status = 'completed'
	group by user_id
),

orders_clean as (
	SELECT user_id, DATE_TRUNC('month', order_date) as order_month
	from orders
	where status = 'completed'	
),

cohort_data AS (
    SELECT o.user_id, f.cohort_month, o.order_month
    FROM orders_clean o
    JOIN first_orders f 
    ON o.user_id = f.user_id
),

cohort_size AS (
    SELECT cohort_month, COUNT(user_id) AS cohort_users
    FROM first_orders
    GROUP BY cohort_month
)

SELECT c.cohort_month, c.order_month, COUNT(DISTINCT c.user_id) AS active_users, cs.cohort_users, COUNT(DISTINCT c.user_id)::float / cs.cohort_users AS retention_rate
FROM cohort_data c
JOIN cohort_size cs ON c.cohort_month = cs.cohort_month
GROUP BY 
    c.cohort_month,
    c.order_month,
    cs.cohort_users
ORDER BY 
    c.cohort_month,
    c.order_month;






