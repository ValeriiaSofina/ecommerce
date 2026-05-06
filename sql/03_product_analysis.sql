-- Проект: Анализ интернет-магазина 
-- Блок: Анализ товаров

-- Количество продаж по товарам
with quantity_sale as
(
select product_id, SUM(quantity) as sale_amount
from order_items
join orders on orders.order_id=order_items.order_id
where status = 'completed'
group by product_id
),

--Общая выручка
total_revenue as
(
select SUM(revenue) as total_revenue
from orders
where status = 'completed'
), 

-- Общая выручка по каждому товару, доля товара в общей выручке
revenue_data as 
(
select order_items.product_id, sum(price*quantity) as product_revenue, 
sum(cost_price*quantity) as cost_product,	
round(sum(price*quantity)/total_revenue * 100, 2) as revenue_share
FROM order_items
JOIN orders ON orders.order_id = order_items.order_id
JOIN products on order_items.product_id = products.product_id
cross join total_revenue
where status = 'completed'
group by order_items.product_id, total_revenue
),

--Накопительная доля
share_data as
(select product_id, product_revenue,
(sum(product_revenue) over (order by product_revenue desc))/ total_revenue as cumulative_share  
 from revenue_data
 cross join total_revenue
)

-- Топ-10 товаров по количеству продаж
select * from quantity_sale
order by sale_amount desc
limit 10

--Топ-5 товаров по маржинальности
select product_id, product_revenue - cost_product as margin,
(product_revenue - cost_product)/product_revenue as margin_rate
from revenue_data
order by (product_revenue - cost_product)/product_revenue desc
limit 5

--Топ-10 товаров по выручке
select product_id, product_revenue
from revenue_data
order by product_revenue desc
limit 10

-- Средний чек по товару
SELECT product_id, AVG(price*quantity) as avg_bill
FROM order_items
JOIN orders on orders.order_id=order_items.order_id
WHERE status = 'completed'
GROUP BY product_id

-- ABC-анализ
select product_id, product_revenue, cumulative_share,
case when cumulative_share < 0.8 then 'A'
when cumulative_share >= 0.8 and cumulative_share < 0.95 then'B' 
else 'C' end as segment
from share_data
order by product_revenue desc