--������� 1. �������� ���������� �������� ������� �� ������� �������
SELECT DISTINCT city_name
FROM city;

/* ������� 2. ����������� ������ �� ����������� �������, ����� ������ ������� ������ �� ������, �������� ������� ���������� �� �L� � ������������� �� �a�, � �������� �� �������� ��������. */
SELECT DISTINCT city
FROM city
WHERE city LIKE 'L%a' AND city NOT LIKE '% %';

/* ������� 3. �������� �� ������� �������� �� ������ ������� ���������� �� ��������, ������� ����������� � ���������� � 17 ���� 2005 ���� �� 19 ���� 2005 ���� ������������ � ��������� ������� ��������� 1.00. ������� ����� ������������� �� ���� �������. */
SELECT *
FROM payment
WHERE payment_date >= '2005-06-17' AND payment_date <= '2005-06-19' AND amount > 1.00
ORDER BY payment_date;

/* ������� 4. �������� ���������� � 10-�� ��������� �������� �� ������ �������. */
SELECT *
FROM payment
ORDER BY payment_date DESC
LIMIT 10;

/* ������� 5. �������� ��������� ���������� �� �����������:
�	������� � ��� (� ����� ������� ����� ������)
�	����������� �����
�	����� �������� ���� email
�	���� ���������� ���������� ������ � ���������� (��� �������)

 ������ ������� ������� ������������ �� ������� �����.*/
SELECT
    CONCAT(first_name, ' ', last_name) AS "������� � ���",
    email AS "����������� �����",
    LENGTH(email) AS "����� email",
    DATE(last_update) AS "���� ���������� ���������� ������ � ����������"
FROM customer;

/* ������� 6. �������� ����� �������� ������ �������� �����������, ����� ������� KELLY ��� WILLIE. ��� ����� � ������� � ����� �� �������� �������� ������ ���� ���������� � ������ �������. */
SELECT *
FROM customer
WHERE activebool = TRUE
AND (LOWER(first_name) = 'kelly' OR LOWER(first_name) = 'willie')
OR (LOWER(last_name) = 'kelly' OR LOWER(last_name) = 'willie');

/* ������� 7. �������� ����� �������� ���������� � �������, � ������� ������� �R� � ��������� ������ ������� �� 0.00 �� 3.00 ������������, � ����� ������ c ��������� �PG-13� � ���������� ������ ������ ��� ������ 4.00. */
SELECT film.title, film.rating, film.rental_rate
FROM film
WHERE (film.rating = 'R' AND film.rental_rate >= 0.00 AND film.rental_rate <= 3.00)
OR (film.rating = 'PG-13' AND film.rental_rate >= 4.00);

/* ������� 8. �������� ���������� � ��� ������� � ����� ������� ��������� ������. */
SELECT title, description, length(description) AS description_length
FROM film
ORDER BY description_length DESC
LIMIT 3;

/* ������� 9. �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������:
�	� ������ ������� ������ ���� ��������, ��������� �� @,
�	�� ������ ������� ������ ���� ��������, ��������� ����� @. */
SELECT
    LEFT(email, POSITION('@' IN email) - 1) AS "Email �� @",
    RIGHT(email, LENGTH(email) - POSITION('@' IN email)) AS "Email ����� @"
FROM customer;

/* ������� 10. ����������� ������ �� ����������� �������, �������������� �������� � ����� ��������: ������ ����� ������ ���� ���������, ��������� ���������. */
SELECT
    INITCAP(LEFT(email, POSITION('@' IN email) - 1)) AS "Email �� @",
    INITCAP(RIGHT(email, LENGTH(email) - POSITION('@' IN email))) AS "Email ����� @"
FROM customer;



