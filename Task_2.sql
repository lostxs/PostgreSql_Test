/* Задание 1. Выведите для каждого покупателя его адрес, город и страну проживания. */
SELECT
    c.first_name || ' ' || c.last_name AS "Покупатель",
    a.address AS "Адрес",
    ci.city AS "Город",
    co.country AS "Страна"
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

/* Задание 2. С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
•	Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300. Для решения используйте фильтрацию по сгруппированным строкам с функцией агрегации. 
•	Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, который работает в нём.  */
SELECT
    s.store_id AS "Идентификатор магазина",
    c.city AS "Город магазина",
    CONCAT(sm.first_name, ' ', sm.last_name) AS "Продавец",
    COUNT(*) AS "Количество покупателей"
FROM store s
JOIN customer cu ON s.store_id = cu.store_id
JOIN staff sm ON s.manager_staff_id = sm.staff_id
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
GROUP BY s.store_id, c.city, sm.first_name, sm.last_name
HAVING COUNT(*) > 300;

/* Задание 3. Выведите топ-5 покупателей, которые взяли в аренду за всё время наибольшее количество фильмов. */
SELECT
    c.first_name || ' ' || c.last_name AS "Покупатель",
    COUNT(r.rental_id) AS "Количество фильмов в аренде"
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY "Количество фильмов в аренде" DESC
LIMIT 5;

/* Задание 4. Посчитайте для каждого покупателя 4 аналитических показателя:
•	количество взятых в аренду фильмов;
•	общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
•	минимальное значение платежа за аренду фильма;
•	максимальное значение платежа за аренду фильма. */
SELECT
    c.first_name || ' ' || c.last_name AS "Покупатель",
    COUNT(r.rental_id) AS "Количество взятых в аренду фильмов",
    ROUND(SUM(p.amount)) AS "Общая стоимость платежей за аренду всех фильмов",
    MIN(p.amount) AS "Минимальное значение платежа за аренду фильма",
    MAX(p.amount) AS "Максимальное значение платежа за аренду фильма"
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id, c.first_name, c.last_name

/* Задание 5. Используя данные из таблицы городов, составьте одним запросом всевозможные пары городов так, чтобы в результате не было пар с одинаковыми названиями городов. Для решения необходимо использовать декартово произведение. */
SELECT
    c1.city AS "Город 1",
    c2.city AS "Город 2"
FROM city c1
CROSS JOIN city c2
WHERE c1.city_id < c2.city_id;

/* Задание 6. Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и дате возврата (поле return_date), вычислите для каждого покупателя среднее количество дней, за которые он возвращает фильмы. */
SELECT
    c.first_name || ' ' || c.last_name AS "Покупатель",
    AVG(EXTRACT(EPOCH FROM (return_date - rental_date)) / 86400) AS "Среднее количество дней возврата"
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

/* Задание 7. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время. */
SELECT
    f.title AS "Название фильма",
    COUNT(r.rental_id) AS "Количество аренд",
    SUM(p.amount) AS "Общая стоимость аренды"
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.film_id, f.title;

/* Задание 8. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые ни разу не брали в аренду. */
SELECT
    f.title AS "Название фильма"
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL;

/* Задание 9. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 7 300, то значение в колонке будет «Да», иначе должно быть значение «Нет». */
SELECT
    s.staff_id,
    s.first_name || ' ' || s.last_name AS "Продавец",
    COUNT(p.payment_id) AS "Количество продаж",
    CASE
        WHEN COUNT(p.payment_id) > 7300 THEN 'Да'
        ELSE 'Нет'
    END AS "Премия"
FROM staff s
LEFT JOIN payment p ON s.staff_id = p.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name;

