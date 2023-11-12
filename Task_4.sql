/* Задание 1. Напишите SQL-запрос, который выводит всю информацию о фильмах со специальным атрибутом (поле special_features) равным “Behind the Scenes”. */

SELECT
    film_id,
    title AS "Название фильма",
    description AS "Описание",
    release_year AS "Год выпуска",
    language_id AS "ID языка",
    original_language_id AS "ID оригинального языка",
    rental_duration AS "Длительность аренды (в днях)",
    rental_rate AS "Стоимость аренды",
    length AS "Продолжительность (в минутах)",
    replacement_cost AS "Стоимость замены",
    rating AS "Рейтинг",
    last_update AS "Последнее обновление",
    special_features AS "Специальные атрибуты",
    fulltext AS "Полный текст"
FROM film
WHERE 'Behind the Scenes' = ALL(special_features);

/* Задание 2. Напишите ещё 2 варианта поиска фильмов с атрибутом “Behind the Scenes”, используя другие функции или операторы языка SQL для поиска значения в массиве */
SELECT
    film_id,
    title AS "Название фильма",
    description AS "Описание",
    release_year AS "Год выпуска",
    language_id AS "ID языка",
    original_language_id AS "ID оригинального языка",
    rental_duration AS "Длительность аренды (в днях)",
    rental_rate AS "Стоимость аренды",
    length AS "Продолжительность (в минутах)",
    replacement_cost AS "Стоимость замены",
    rating AS "Рейтинг",
    last_update AS "Последнее обновление",
    special_features AS "Специальные атрибуты",
    fulltext AS "Полный текст"
FROM film
WHERE 'Behind the Scenes' = ANY(special_features);

SELECT
    film_id,
    title AS "Название фильма",
    description AS "Описание",
    release_year AS "Год выпуска",
    language_id AS "ID языка",
    original_language_id AS "ID оригинального языка",
    rental_duration AS "Длительность аренды (в днях)",
    rental_rate AS "Стоимость аренды",
    length AS "Продолжительность (в минутах)",
    replacement_cost AS "Стоимость замены",
    rating AS "Рейтинг",
    last_update AS "Последнее обновление",
    special_features AS "Специальные атрибуты",
    fulltext AS "Полный текст"
FROM film
WHERE ARRAY['Behind the Scenes'] <@ special_features;

/* Задание 3. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в CTE. */
WITH FilmsWithSpecialAttribute AS (
    SELECT
        film_id
    FROM film
    WHERE 'Behind the Scenes' = ALL(special_features)
)

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS "Покупатель",
    COUNT(r.rental_id) AS "Количество фильмов 'Behind the Scenes' в аренде"
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
WHERE i.film_id IN (SELECT film_id FROM FilmsWithSpecialAttribute)
GROUP BY c.customer_id
ORDER BY "Количество фильмов 'Behind the Scenes' в аренде" DESC;

/* Задание 4. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в подзапрос, который необходимо использовать для решения задания. */
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS "Покупатель",
    (
        SELECT COUNT(*)
        FROM rental r
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id
        WHERE c.customer_id = r.customer_id
        AND 'Behind the Scenes' = ALL(f.special_features)
    ) AS "Количество фильмов 'Behind the Scenes' в аренде"
FROM customer c
ORDER BY "Количество фильмов 'Behind the Scenes' в аренде" DESC;

/* Задание 5. Создайте материализованное представление с запросом из предыдущего задания и напишите запрос для обновления материализованного представления. */
CREATE MATERIALIZED VIEW customer_rental_counts AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS "Покупатель",
    (
        SELECT COUNT(*)
        FROM rental r
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id
        WHERE c.customer_id = r.customer_id
        AND 'Behind the Scenes' = ALL(f.special_features)
    ) AS "Количество фильмов 'Behind the Scenes' в аренде"
FROM customer c;

REFRESH MATERIALIZED VIEW customer_rental_counts;

SELECT * FROM customer_rental_counts;

/* Задание 6. С помощью explain analyze проведите анализ скорости выполнения запросов из предыдущих заданий и ответьте на вопросы:
с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания, поиск значения в массиве происходит быстрее;
какой вариант вычислений работает быстрее: с использованием CTE или с использованием подзапроса. 

Оператор "ALL" работает быстрее среднее время выполнения запроса 100 msec, в то время как остальные операторы имели среднее выполнение запроса 150 msec.
Вариант  CTE работает быстрее среднее время выполнения 100 msec, с использованием подзапроса среднее время выполнения 1 sec. */

/* Задание 7. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже. */
WITH RankedSales AS (
    SELECT
        s.staff_id,
        p.payment_id,
        p.payment_date,
        ROW_NUMBER() OVER (PARTITION BY s.staff_id ORDER BY p.payment_date) AS row_num
    FROM staff s
    LEFT JOIN payment p ON s.staff_id = p.staff_id
)
SELECT
    s.staff_id,
    s.first_name AS first_name,
    s.last_name AS last_name,
    s.email AS email,
    r.payment_id AS first_payment_id,
    r.payment_date AS first_payment_date
FROM staff s
LEFT JOIN RankedSales r ON s.staff_id = r.staff_id
WHERE r.row_num = 1;

/* Задание 8. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
•	день, в который арендовали больше всего фильмов (в формате год-месяц-день);
•	количество фильмов, взятых в аренду в этот день;
•	день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
•	сумму продажи в этот день. */
WITH RentalStats AS (
    SELECT
        s.store_id,
        DATE_TRUNC('day', r.rental_date) AS rental_day,
        COUNT(r.rental_id) AS rental_count
    FROM rental r
    JOIN staff s ON r.staff_id = s.staff_id
    GROUP BY s.store_id, DATE_TRUNC('day', r.rental_date)
),
SalesStats AS (
    SELECT
        s.store_id,
        DATE_TRUNC('day', p.payment_date) AS sale_day,
        SUM(p.amount) AS sale_amount
    FROM payment p
    JOIN staff s ON p.staff_id = s.staff_id
    GROUP BY s.store_id, DATE_TRUNC('day', p.payment_date)
),
MaxRentals AS (
    SELECT
        store_id,
        rental_day,
        rental_count,
        RANK() OVER (PARTITION BY store_id ORDER BY rental_count DESC) AS rent_rank
    FROM RentalStats
),
MinSales AS (
    SELECT
        store_id,
        sale_day,
        sale_amount,
        RANK() OVER (PARTITION BY store_id ORDER BY sale_amount) AS sale_rank
    FROM SalesStats
)
SELECT
    rs.store_id,
    TO_CHAR(rs.rental_day, 'YYYY-MM-DD') AS max_rental_day,
    rs.rental_count AS max_rental_count,
    TO_CHAR(ms.sale_day, 'YYYY-MM-DD') AS min_sale_day,
    ms.sale_amount AS min_sale_amount
FROM MaxRentals rs
JOIN MinSales ms ON rs.store_id = ms.store_id
WHERE rs.rent_rank = 1 AND ms.sale_rank = 1;



