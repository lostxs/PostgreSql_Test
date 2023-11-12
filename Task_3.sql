/* Çàäàíèå 1. Ñäåëàéòå çàïðîñ ê òàáëèöå payment è ñ ïîìîùüþ îêîííûõ ôóíêöèé äîáàâüòå âû÷èñëÿåìûå êîëîíêè ñîãëàñíî óñëîâèÿì:
•	Ïðîíóìåðóéòå âñå ïëàòåæè îò 1 äî N ïî äàòå
•	Ïðîíóìåðóéòå ïëàòåæè äëÿ êàæäîãî ïîêóïàòåëÿ, ñîðòèðîâêà ïëàòåæåé äîëæíà áûòü ïî äàòå
•	Ïîñ÷èòàéòå íàðàñòàþùèì èòîãîì ñóììó âñåõ ïëàòåæåé äëÿ êàæäîãî ïîêóïàòåëÿ, ñîðòèðîâêà äîëæíà áûòü ñïåðâà ïî äàòå ïëàòåæà, à çàòåì ïî ñóììå ïëàòåæà îò íàèìåíüøåé ê áîëüøåé
•	Ïðîíóìåðóéòå ïëàòåæè äëÿ êàæäîãî ïîêóïàòåëÿ ïî ñòîèìîñòè ïëàòåæà îò íàèáîëüøèõ ê ìåíüøèì òàê, ÷òîáû ïëàòåæè ñ îäèíàêîâûì çíà÷åíèåì èìåëè îäèíàêîâîå çíà÷åíèå íîìåðà. */
SELECT
    payment_id,
    payment_date,
    ROW_NUMBER() OVER (ORDER BY payment_date) AS "Íîìåð ïî äàòå"
FROM payment
ORDER BY payment_date;

SELECT
    payment_id,
    customer_id,
    payment_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS "Íîìåð ïî äàòå äëÿ ïîêóïàòåëÿ"
FROM payment
ORDER BY customer_id, payment_date;

SELECT
    payment_id,
    customer_id,
    payment_date,
    amount,
    SUM(amount) OVER (PARTITION BY customer_id ORDER BY payment_date, amount) AS "Íàðàñòàþùèé èòîã"
FROM payment
ORDER BY customer_id, payment_date;

SELECT
    payment_id,
    customer_id,
    payment_date,
    amount,
    DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY amount DESC) AS "Íîìåð ïî ñòîèìîñòè"
FROM payment
ORDER BY customer_id, amount DESC;

/* Çàäàíèå 2. Ñ ïîìîùüþ îêîííîé ôóíêöèè âûâåäèòå äëÿ êàæäîãî ïîêóïàòåëÿ ñòîèìîñòü ïëàòåæà è ñòîèìîñòü ïëàòåæà èç ïðåäûäóùåé ñòðîêè ñî çíà÷åíèåì ïî óìîë÷àíèþ 0.0 ñ ñîðòèðîâêîé ïî äàòå. */
SELECT
    customer_id,
    payment_id,
    payment_date,
    amount,
    COALESCE(LAG(amount, 1, 0.0) OVER (PARTITION BY customer_id ORDER BY payment_date), 0.0) AS "Ïðåäûäóùàÿ ñòîèìîñòü"
FROM payment
ORDER BY customer_id, payment_date;

/* Çàäàíèå 3. Ñ ïîìîùüþ îêîííîé ôóíêöèè îïðåäåëèòå, íà ñêîëüêî êàæäûé ñëåäóþùèé ïëàòåæ ïîêóïàòåëÿ áîëüøå èëè ìåíüøå òåêóùåãî */
SELECT
    customer_id,
    payment_id,
    payment_date,
    amount,
    LEAD(amount, 1, 0.0) OVER (PARTITION BY customer_id ORDER BY payment_date) - amount AS "Ðàçíèöà ñî ñëåäóþùèì ïëàòåæîì"
FROM payment
ORDER BY customer_id, payment_date;

/* Çàäàíèå 4. Ñ ïîìîùüþ îêîííîé ôóíêöèè äëÿ êàæäîãî ïîêóïàòåëÿ âûâåäèòå äàííûå î åãî ïîñëåäíåé îïëàòå àðåíäû. */
WITH LastPayment AS (
    SELECT
        customer_id,
        payment_id,
        payment_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date DESC) AS "Ðàíã"
    FROM payment
)
SELECT
    lp.customer_id,
    lp.payment_id,
    lp.payment_date AS "Äàòà ïîñëåäíåé îïëàòû",
    p.amount AS "Ñóììà ïîñëåäíåé îïëàòû"
FROM LastPayment lp
JOIN payment p ON lp.payment_id = p.payment_id
WHERE lp."Ðàíã" = 1;

/* Çàäàíèå 5. Ñ ïîìîùüþ îêîííîé ôóíêöèè âûâåäèòå äëÿ êàæäîãî ñîòðóäíèêà ñóììó ïðîäàæ çà àâãóñò 2005 ãîäà ñ íàðàñòàþùèì èòîãîì ïî êàæäîìó ñîòðóäíèêó è ïî êàæäîé äàòå ïðîäàæè (áåç ó÷¸òà âðåìåíè) ñ ñîðòèðîâêîé ïî äàòå. */
WITH SalesInAugust AS (
    SELECT
        s.staff_id,
        p.payment_date::date AS "Äàòà ïðîäàæè",
        SUM(p.amount) OVER (PARTITION BY s.staff_id ORDER BY p.payment_date::date) AS "Ñóììà ïðîäàæè",
        RANK() OVER (PARTITION BY s.staff_id ORDER BY p.payment_date::date) AS "Ðåéòèíã ïðîäàæ"
    FROM staff s
    JOIN payment p ON s.staff_id = p.staff_id
    WHERE EXTRACT(YEAR FROM p.payment_date) = 2005 AND EXTRACT(MONTH FROM p.payment_date) = 8
)
SELECT
    staff_id,
    "Äàòà ïðîäàæè",
    "Ñóììà ïðîäàæè",
    "Ðåéòèíã ïðîäàæ"
FROM SalesInAugust
ORDER BY staff_id, "Äàòà ïðîäàæè";

/* Çàäàíèå 6. 20 àâãóñòà 2005 ãîäà â ìàãàçèíàõ ïðîõîäèëà àêöèÿ: ïîêóïàòåëü êàæäîãî ñîòîãî ïëàòåæà ïîëó÷àë äîïîëíèòåëüíóþ ñêèäêó íà ñëåäóþùóþ àðåíäó. Ñ ïîìîùüþ îêîííîé ôóíêöèè âûâåäèòå âñåõ ïîêóïàòåëåé, êîòîðûå â äåíü ïðîâåäåíèÿ àêöèè ïîëó÷èëè ñêèäêó. */
WITH DiscountPayments AS (
    SELECT
        p.customer_id,
        p.payment_date::date AS "Äàòà ïëàòåæà",
        ROW_NUMBER() OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) 
    FROM payment p
    WHERE p.payment_date::date = '2005-08-20'
)
SELECT DISTINCT
    customer_id,
    "Äàòà ïëàòåæà"
FROM DiscountPayments
WHERE "customer_id" % 100 = 0;

/* Çàäàíèå 7. Äëÿ êàæäîé ñòðàíû îïðåäåëèòå è âûâåäèòå îäíèì SQL-çàïðîñîì ïîêóïàòåëåé, êîòîðûå ïîïàäàþò ïîä óñëîâèÿ:
•	ïîêóïàòåëü, àðåíäîâàâøèé íàèáîëüøåå êîëè÷åñòâî ôèëüìîâ;
•	ïîêóïàòåëü, àðåíäîâàâøèé ôèëüìîâ íà ñàìóþ áîëüøóþ ñóììó;
•	ïîêóïàòåëü, êîòîðûé ïîñëåäíèì àðåíäîâàë ôèëüì. */
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
    cr.rentals_count AS "Êîëè÷åñòâî àðåíäîâàííûõ ôèëüìîâ",
    cr.total_payment AS "Îáùàÿ ñóììà îïëàòû",
    cr.last_rental_date AS "Äàòà ïîñëåäíåé àðåíäû"
FROM CustomerRanking cr
WHERE cr.rental_rank = 1
   OR cr.payment_rank = 1
   OR cr.last_rental_rank = 1;
