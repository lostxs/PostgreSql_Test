/* Задание 1. Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
•	Пронумеруйте все платежи от 1 до N по дате
•	Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
•	Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
•	Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера. */
SELECT
    payment_id,
    payment_date,
    ROW_NUMBER() OVER (ORDER BY payment_date) AS "Номер по дате"
FROM payment
ORDER BY payment_date;

SELECT
    payment_id,
    customer_id,
    payment_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS "Номер по дате для покупателя"
FROM payment
ORDER BY customer_id, payment_date;

SELECT
    payment_id,
    customer_id,
    payment_date,
    amount,
    SUM(amount) OVER (PARTITION BY customer_id ORDER BY payment_date, amount) AS "Нарастающий итог"
FROM payment
ORDER BY customer_id, payment_date;

SELECT
    payment_id,
    customer_id,
    payment_date,
    amount,
    DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY amount DESC) AS "Номер по стоимости"
FROM payment
ORDER BY customer_id, amount DESC;

/* Задание 2. С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате. */
SELECT
    customer_id,
    payment_id,
    payment_date,
    amount,
    COALESCE(LAG(amount, 1, 0.0) OVER (PARTITION BY customer_id ORDER BY payment_date), 0.0) AS "Предыдущая стоимость"
FROM payment
ORDER BY customer_id, payment_date;

/* Задание 3. С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего */
SELECT
    customer_id,
    payment_id,
    payment_date,
    amount,
    LEAD(amount, 1, 0.0) OVER (PARTITION BY customer_id ORDER BY payment_date) - amount AS "Разница со следующим платежом"
FROM payment
ORDER BY customer_id, payment_date;

/* Задание 4. С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды. */
WITH LastPayment AS (
    SELECT
        customer_id,
        payment_id,
        payment_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date DESC) AS "Ранг"
    FROM payment
)
SELECT
    lp.customer_id,
    lp.payment_id,
    lp.payment_date AS "Дата последней оплаты",
    p.amount AS "Сумма последней оплаты"
FROM LastPayment lp
JOIN payment p ON lp.payment_id = p.payment_id
WHERE lp."Ранг" = 1;

/* Задание 5. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате. */
WITH SalesInAugust AS (
    SELECT
        s.staff_id,
        p.payment_date::date AS "Дата продажи",
        SUM(p.amount) OVER (PARTITION BY s.staff_id ORDER BY p.payment_date::date) AS "Сумма продажи",
        RANK() OVER (PARTITION BY s.staff_id ORDER BY p.payment_date::date) AS "Рейтинг продаж"
    FROM staff s
    JOIN payment p ON s.staff_id = p.staff_id
    WHERE EXTRACT(YEAR FROM p.payment_date) = 2005 AND EXTRACT(MONTH FROM p.payment_date) = 8
)
SELECT
    staff_id,
    "Дата продажи",
    "Сумма продажи",
    "Рейтинг продаж"
FROM SalesInAugust
ORDER BY staff_id, "Дата продажи";

/* Задание 6. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку. */
WITH DiscountPayments AS (
    SELECT
        p.customer_id,
        p.payment_date::date AS "Дата платежа",
        ROW_NUMBER() OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) 
    FROM payment p
    WHERE p.payment_date::date = '2005-08-20'
)
SELECT DISTINCT
    customer_id,
    "Дата платежа"
FROM DiscountPayments
WHERE "customer_id" % 100 = 0;

/* Задание 7. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
•	покупатель, арендовавший наибольшее количество фильмов;
•	покупатель, арендовавший фильмов на самую большую сумму;
•	покупатель, который последним арендовал фильм. */
WITH CustomerRanking AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        co.country,
        COUNT(DISTINCT r.rental_id) AS rentals_count,
        SUM(p.amount) AS total_payment,
        MAX(r.rental_date) AS last_rental_date,
        ROW_NUMBER() OVER (PARTITION BY co.country ORDER BY COUNT(DISTINCT r.rental_id) DESC) AS rental_rank,
        ROW_NUMBER() OVER (PARTITION BY co.country ORDER BY SUM(p.amount) DESC) AS payment_rank,
        ROW_NUMBER() OVER (PARTITION BY co.country ORDER BY MAX(r.rental_date) DESC) AS last_rental_rank
    FROM customer c
    LEFT JOIN rental r ON c.customer_id = r.customer_id
    LEFT JOIN payment p ON r.rental_id = p.rental_id
    LEFT JOIN address a ON c.address_id = a.address_id
    LEFT JOIN city ci ON a.city_id = ci.city_id
    LEFT JOIN country co ON ci.country_id = co.country_id
    GROUP BY c.customer_id, c.first_name, c.last_name, co.country
)
SELECT
    cr.first_name,
    cr.last_name,
    cr.country,
    cr.rentals_count AS "Количество арендованных фильмов",
    cr.total_payment AS "Общая сумма оплаты",
    cr.last_rental_date AS "Дата последней аренды"
FROM CustomerRanking cr
WHERE cr.rental_rank = 1
   OR cr.payment_rank = 1
   OR cr.last_rental_rank = 1;
