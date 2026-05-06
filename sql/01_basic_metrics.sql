-- Проект: Анализ интернет-магазина
-- Блок: Базовые метрики

with users_data as
(
SELECT COUNT(*) as total_users
from users),

orders_data as
(
SELECT COUNT(*) as total_orders
from orders
),

revenue_data as
(
SELECT 
	COUNT(*) as total_completed_orders,
	SUM(revenue) as total_revenue 
	from orders 
WHERE status = 'completed')

SELECT 
total_users, -- Общее количество пользователей
total_orders, -- Общее количество заказов 
total_completed_orders, -- Количество выполненных заказов
total_revenue, -- Общая выручка по выполненным заказам
total_revenue:: numeric / total_completed_orders as average_bill, -- Средний чек
total_revenue:: numeric / total_users as arpu --ARPU (средняя выручка на пользователя)
from revenue_data
cross join users_data
cross join orders_data






