/* ������� 1. �������� ������ � ������� payment � � ������� ������� ������� �������� ����������� ������� �������� ��������:
�	������������ ��� ������� �� 1 �� N �� ����
�	������������ ������� ��� ������� ����������, ���������� �������� ������ ���� �� ����
�	���������� ����������� ������ ����� ���� �������� ��� ������� ����������, ���������� ������ ���� ������ �� ���� �������, � ����� �� ����� ������� �� ���������� � �������
�	������������ ������� ��� ������� ���������� �� ��������� ������� �� ���������� � ������� ���, ����� ������� � ���������� ��������� ����� ���������� �������� ������. */
SELECT
    payment_id,
    payment_date,
    ROW_NUMBER() OVER (ORDER BY payment_date) AS "����� �� ����"
FROM payment
ORDER BY payment_date;

SELECT
    payment_id,
    customer_id,
    payment_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS "����� �� ���� ��� ����������"
FROM payment
ORDER BY customer_id, payment_date;

SELECT
    payment_id,
    customer_id,
    payment_date,
    amount,
    SUM(amount) OVER (PARTITION BY customer_id ORDER BY payment_date, amount) AS "����������� ����"
FROM payment
ORDER BY customer_id, payment_date;

SELECT
    payment_id,
    customer_id,
    payment_date,
    amount,
    DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY amount DESC) AS "����� �� ���������"
FROM payment
ORDER BY customer_id, amount DESC;

/* ������� 2. � ������� ������� ������� �������� ��� ������� ���������� ��������� ������� � ��������� ������� �� ���������� ������ �� ��������� �� ��������� 0.0 � ����������� �� ����. */
SELECT
    customer_id,
    payment_id,
    payment_date,
    amount,
    COALESCE(LAG(amount, 1, 0.0) OVER (PARTITION BY customer_id ORDER BY payment_date), 0.0) AS "���������� ���������"
FROM payment
ORDER BY customer_id, payment_date;

/* ������� 3. � ������� ������� ������� ����������, �� ������� ������ ��������� ������ ���������� ������ ��� ������ �������� */
SELECT
    customer_id,
    payment_id,
    payment_date,
    amount,
    LEAD(amount, 1, 0.0) OVER (PARTITION BY customer_id ORDER BY payment_date) - amount AS "������� �� ��������� ��������"
FROM payment
ORDER BY customer_id, payment_date;

/* ������� 4. � ������� ������� ������� ��� ������� ���������� �������� ������ � ��� ��������� ������ ������. */
WITH LastPayment AS (
    SELECT
        customer_id,
        payment_id,
        payment_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date DESC) AS "����"
    FROM payment
)
SELECT
    lp.customer_id,
    lp.payment_id,
    lp.payment_date AS "���� ��������� ������",
    p.amount AS "����� ��������� ������"
FROM LastPayment lp
JOIN payment p ON lp.payment_id = p.payment_id
WHERE lp."����" = 1;

/* ������� 5. � ������� ������� ������� �������� ��� ������� ���������� ����� ������ �� ������ 2005 ���� � ����������� ������ �� ������� ���������� � �� ������ ���� ������� (��� ����� �������) � ����������� �� ����. */
WITH SalesInAugust AS (
    SELECT
        s.staff_id,
        p.payment_date::date AS "���� �������",
        SUM(p.amount) OVER (PARTITION BY s.staff_id ORDER BY p.payment_date::date) AS "����� �������",
        RANK() OVER (PARTITION BY s.staff_id ORDER BY p.payment_date::date) AS "������� ������"
    FROM staff s
    JOIN payment p ON s.staff_id = p.staff_id
    WHERE EXTRACT(YEAR FROM p.payment_date) = 2005 AND EXTRACT(MONTH FROM p.payment_date) = 8
)
SELECT
    staff_id,
    "���� �������",
    "����� �������",
    "������� ������"
FROM SalesInAugust
ORDER BY staff_id, "���� �������";

/* ������� 6. 20 ������� 2005 ���� � ��������� ��������� �����: ���������� ������� ������ ������� ������� �������������� ������ �� ��������� ������. � ������� ������� ������� �������� ���� �����������, ������� � ���� ���������� ����� �������� ������. */
WITH DiscountPayments AS (
    SELECT
        p.customer_id,
        p.payment_date::date AS "���� �������",
        ROW_NUMBER() OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) 
    FROM payment p
    WHERE p.payment_date::date = '2005-08-20'
)
SELECT DISTINCT
    customer_id,
    "���� �������"
FROM DiscountPayments
WHERE "customer_id" % 100 = 0;

/* ������� 7. ��� ������ ������ ���������� � �������� ����� SQL-�������� �����������, ������� �������� ��� �������:
�	����������, ������������ ���������� ���������� �������;
�	����������, ������������ ������� �� ����� ������� �����;
�	����������, ������� ��������� ��������� �����. */
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
    cr.rentals_count AS "���������� ������������ �������",
    cr.total_payment AS "����� ����� ������",
    cr.last_rental_date AS "���� ��������� ������"
FROM CustomerRanking cr
WHERE cr.rental_rank = 1
   OR cr.payment_rank = 1
   OR cr.last_rental_rank = 1;
