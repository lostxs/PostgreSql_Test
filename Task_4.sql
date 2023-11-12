/* ������� 1. �������� SQL-������, ������� ������� ��� ���������� � ������� �� ����������� ��������� (���� special_features) ������ �Behind the Scenes�. */

SELECT
    film_id,
    title AS "�������� ������",
    description AS "��������",
    release_year AS "��� �������",
    language_id AS "ID �����",
    original_language_id AS "ID ������������� �����",
    rental_duration AS "������������ ������ (� ����)",
    rental_rate AS "��������� ������",
    length AS "����������������� (� �������)",
    replacement_cost AS "��������� ������",
    rating AS "�������",
    last_update AS "��������� ����������",
    special_features AS "����������� ��������",
    fulltext AS "������ �����"
FROM film
WHERE 'Behind the Scenes' = ALL(special_features);

/* ������� 2. �������� ��� 2 �������� ������ ������� � ��������� �Behind the Scenes�, ��������� ������ ������� ��� ��������� ����� SQL ��� ������ �������� � ������� */
SELECT
    film_id,
    title AS "�������� ������",
    description AS "��������",
    release_year AS "��� �������",
    language_id AS "ID �����",
    original_language_id AS "ID ������������� �����",
    rental_duration AS "������������ ������ (� ����)",
    rental_rate AS "��������� ������",
    length AS "����������������� (� �������)",
    replacement_cost AS "��������� ������",
    rating AS "�������",
    last_update AS "��������� ����������",
    special_features AS "����������� ��������",
    fulltext AS "������ �����"
FROM film
WHERE 'Behind the Scenes' = ANY(special_features);

SELECT
    film_id,
    title AS "�������� ������",
    description AS "��������",
    release_year AS "��� �������",
    language_id AS "ID �����",
    original_language_id AS "ID ������������� �����",
    rental_duration AS "������������ ������ (� ����)",
    rental_rate AS "��������� ������",
    length AS "����������������� (� �������)",
    replacement_cost AS "��������� ������",
    rating AS "�������",
    last_update AS "��������� ����������",
    special_features AS "����������� ��������",
    fulltext AS "������ �����"
FROM film
WHERE ARRAY['Behind the Scenes'] <@ special_features;

/* ������� 3. ��� ������� ���������� ����������, ������� �� ���� � ������ ������� �� ����������� ��������� �Behind the Scenes�.
������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, ���������� � CTE. */
WITH FilmsWithSpecialAttribute AS (
    SELECT
        film_id
    FROM film
    WHERE 'Behind the Scenes' = ALL(special_features)
)

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS "����������",
    COUNT(r.rental_id) AS "���������� ������� 'Behind the Scenes' � ������"
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
WHERE i.film_id IN (SELECT film_id FROM FilmsWithSpecialAttribute)
GROUP BY c.customer_id
ORDER BY "���������� ������� 'Behind the Scenes' � ������" DESC;

/* ������� 4. ��� ������� ���������� ����������, ������� �� ���� � ������ ������� �� ����������� ��������� �Behind the Scenes�.
������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, ���������� � ���������, ������� ���������� ������������ ��� ������� �������. */
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS "����������",
    (
        SELECT COUNT(*)
        FROM rental r
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id
        WHERE c.customer_id = r.customer_id
        AND 'Behind the Scenes' = ALL(f.special_features)
    ) AS "���������� ������� 'Behind the Scenes' � ������"
FROM customer c
ORDER BY "���������� ������� 'Behind the Scenes' � ������" DESC;

/* ������� 5. �������� ����������������� ������������� � �������� �� ����������� ������� � �������� ������ ��� ���������� ������������������ �������������. */
CREATE MATERIALIZED VIEW customer_rental_counts AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS "����������",
    (
        SELECT COUNT(*)
        FROM rental r
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id
        WHERE c.customer_id = r.customer_id
        AND 'Behind the Scenes' = ALL(f.special_features)
    ) AS "���������� ������� 'Behind the Scenes' � ������"
FROM customer c;

REFRESH MATERIALIZED VIEW customer_rental_counts;

SELECT * FROM customer_rental_counts;

/* ������� 6. � ������� explain analyze ��������� ������ �������� ���������� �������� �� ���������� ������� � �������� �� �������:
� ����� ���������� ��� �������� ����� SQL, ������������� ��� ���������� ��������� �������, ����� �������� � ������� ���������� �������;
����� ������� ���������� �������� �������: � �������������� CTE ��� � �������������� ����������. 

�������� "ALL" �������� ������� ������� ����� ���������� ������� 100 msec, � �� ����� ��� ��������� ��������� ����� ������� ���������� ������� 150 msec.
�������  CTE �������� ������� ������� ����� ���������� 100 msec, � �������������� ���������� ������� ����� ���������� 1 sec. */

/* ������� 7. ��������� ������� �������, �������� ��� ������� ���������� �������� � ������ ��� �������. */
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

/* ������� 8. ��� ������� �������� ���������� � �������� ����� SQL-�������� ��������� ������������� ����������:
�	����, � ������� ���������� ������ ����� ������� (� ������� ���-�����-����);
�	���������� �������, ������ � ������ � ���� ����;
�	����, � ������� ������� ������� �� ���������� ����� (� ������� ���-�����-����);
�	����� ������� � ���� ����. */
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



