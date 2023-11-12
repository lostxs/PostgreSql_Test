--Задание 1. Выведите уникальные названия городов из таблицы городов
SELECT DISTINCT city_name
FROM city;

/* Задание 2. Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города, названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов. */
SELECT DISTINCT city
FROM city
WHERE city LIKE 'L%a' AND city NOT LIKE '% %';

/* Задание 3. Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно и стоимость которых превышает 1.00. Платежи нужно отсортировать по дате платежа. */
SELECT *
FROM payment
WHERE payment_date >= '2005-06-17' AND payment_date <= '2005-06-19' AND amount > 1.00
ORDER BY payment_date;

/* Задание 4. Выведите информацию о 10-ти последних платежах за прокат фильмов. */
SELECT *
FROM payment
ORDER BY payment_date DESC
LIMIT 10;

/* Задание 5. Выведите следующую информацию по покупателям:
•	Фамилия и имя (в одной колонке через пробел)
•	Электронная почта
•	Длину значения поля email
•	Дату последнего обновления записи о покупателе (без времени)

 Каждой колонке задайте наименование на русском языке.*/
SELECT
    CONCAT(first_name, ' ', last_name) AS "Фамилия и имя",
    email AS "Электронная почта",
    LENGTH(email) AS "Длина email",
    DATE(last_update) AS "Дата последнего обновления записи о покупателе"
FROM customer;

/* Задание 6. Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE. Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр. */
SELECT *
FROM customer
WHERE activebool = TRUE
AND (LOWER(first_name) = 'kelly' OR LOWER(first_name) = 'willie')
OR (LOWER(last_name) = 'kelly' OR LOWER(last_name) = 'willie');

/* Задание 7. Выведите одним запросом информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00. */
SELECT film.title, film.rating, film.rental_rate
FROM film
WHERE (film.rating = 'R' AND film.rental_rate >= 0.00 AND film.rental_rate <= 3.00)
OR (film.rating = 'PG-13' AND film.rental_rate >= 4.00);

/* Задание 8. Получите информацию о трёх фильмах с самым длинным описанием фильма. */
SELECT title, description, length(description) AS description_length
FROM film
ORDER BY description_length DESC
LIMIT 3;

/* Задание 9. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
•	в первой колонке должно быть значение, указанное до @,
•	во второй колонке должно быть значение, указанное после @. */
SELECT
    LEFT(email, POSITION('@' IN email) - 1) AS "Email до @",
    RIGHT(email, LENGTH(email) - POSITION('@' IN email)) AS "Email после @"
FROM customer;

/* Задание 10. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: первая буква должна быть заглавной, остальные строчными. */
SELECT
    INITCAP(LEFT(email, POSITION('@' IN email) - 1)) AS "Email до @",
    INITCAP(RIGHT(email, LENGTH(email) - POSITION('@' IN email))) AS "Email после @"
FROM customer;



