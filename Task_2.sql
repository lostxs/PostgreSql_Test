/* ������� 1. �������� ��� ������� ���������� ��� �����, ����� � ������ ����������. */
SELECT
    c.first_name || ' ' || c.last_name AS "����������",
    a.address AS "�����",
    ci.city AS "�����",
    co.country AS "������"
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

/* ������� 2. � ������� SQL-������� ���������� ��� ������� �������� ���������� ��� �����������.
�	����������� ������ � �������� ������ �� ��������, � ������� ���������� ����������� ������ 300. ��� ������� ����������� ���������� �� ��������������� ������� � �������� ���������. 
�	����������� ������, ������� � ���� ���������� � ������ ��������, ������� � ����� ��������, ������� �������� � ��.  */
SELECT
    s.store_id AS "������������� ��������",
    c.city AS "����� ��������",
    CONCAT(sm.first_name, ' ', sm.last_name) AS "��������",
    COUNT(*) AS "���������� �����������"
FROM store s
JOIN customer cu ON s.store_id = cu.store_id
JOIN staff sm ON s.manager_staff_id = sm.staff_id
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
GROUP BY s.store_id, c.city, sm.first_name, sm.last_name
HAVING COUNT(*) > 300;

/* ������� 3. �������� ���-5 �����������, ������� ����� � ������ �� �� ����� ���������� ���������� �������. */
SELECT
    c.first_name || ' ' || c.last_name AS "����������",
    COUNT(r.rental_id) AS "���������� ������� � ������"
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY "���������� ������� � ������" DESC
LIMIT 5;

/* ������� 4. ���������� ��� ������� ���������� 4 ������������� ����������:
�	���������� ������ � ������ �������;
�	����� ��������� �������� �� ������ ���� ������� (�������� ��������� �� ������ �����);
�	����������� �������� ������� �� ������ ������;
�	������������ �������� ������� �� ������ ������. */
SELECT
    c.first_name || ' ' || c.last_name AS "����������",
    COUNT(r.rental_id) AS "���������� ������ � ������ �������",
    ROUND(SUM(p.amount)) AS "����� ��������� �������� �� ������ ���� �������",
    MIN(p.amount) AS "����������� �������� ������� �� ������ ������",
    MAX(p.amount) AS "������������ �������� ������� �� ������ ������"
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id, c.first_name, c.last_name

/* ������� 5. ��������� ������ �� ������� �������, ��������� ����� �������� ������������ ���� ������� ���, ����� � ���������� �� ���� ��� � ����������� ���������� �������. ��� ������� ���������� ������������ ��������� ������������. */
SELECT
    c1.city AS "����� 1",
    c2.city AS "����� 2"
FROM city c1
CROSS JOIN city c2
WHERE c1.city_id < c2.city_id;

/* ������� 6. ��������� ������ �� ������� rental � ���� ������ ������ � ������ (���� rental_date) � ���� �������� (���� return_date), ��������� ��� ������� ���������� ������� ���������� ����, �� ������� �� ���������� ������. */
SELECT
    c.first_name || ' ' || c.last_name AS "����������",
    AVG(EXTRACT(EPOCH FROM (return_date - rental_date)) / 86400) AS "������� ���������� ���� ��������"
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

/* ������� 7. ���������� ��� ������� ������, ������� ��� ��� ����� � ������, � ����� ����� ��������� ������ ������ �� �� �����. */
SELECT
    f.title AS "�������� ������",
    COUNT(r.rental_id) AS "���������� �����",
    SUM(p.amount) AS "����� ��������� ������"
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.film_id, f.title;

/* ������� 8. ����������� ������ �� ����������� ������� � �������� � ������� ���� ������, ������� �� ���� �� ����� � ������. */
SELECT
    f.title AS "�������� ������"
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL;

/* ������� 9. ���������� ���������� ������, ����������� ������ ���������. �������� ����������� ������� ��������. ���� ���������� ������ ��������� 7 300, �� �������� � ������� ����� ���, ����� ������ ���� �������� ����. */
SELECT
    s.staff_id,
    s.first_name || ' ' || s.last_name AS "��������",
    COUNT(p.payment_id) AS "���������� ������",
    CASE
        WHEN COUNT(p.payment_id) > 7300 THEN '��'
        ELSE '���'
    END AS "������"
FROM staff s
LEFT JOIN payment p ON s.staff_id = p.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name;

