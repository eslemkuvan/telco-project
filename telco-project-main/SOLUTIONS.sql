
/* =========================================================
   1. Tariff-Based Customer Queries
   ========================================================= */

/*
This query lists all customers who are subscribed to the 'Kobiye Destek' tariff.
I joined the CUSTOMERS and TARIFFS tables using TARIFF_ID.
This allows filtering by tariff name and displaying customer details.
*/

SELECT
    c.CUSTOMER_ID,
    c.NAME,
    c.CITY,
    c.SIGNUP_DATE,
    t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.CUSTOMER_ID;


/*
This query finds the newest customers who subscribed to the 'Kobiye Destek' tariff.
I used MAX(SIGNUP_DATE) to find the latest signup date.
This ensures that all customers with the most recent date are included.
*/

SELECT
    c.CUSTOMER_ID,
    c.NAME,
    c.CITY,
    c.SIGNUP_DATE,
    t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
  AND c.SIGNUP_DATE = (
      SELECT MAX(c2.SIGNUP_DATE)
      FROM CUSTOMERS c2
      JOIN TARIFFS t2
          ON c2.TARIFF_ID = t2.TARIFF_ID
      WHERE t2.NAME = 'Kobiye Destek'
  );
/* =========================================================
  2. Tariff Distribution
   ========================================================= */

/*
This query shows how customers are distributed across tariffs.
I grouped the data by tariff name and counted customers in each group.
This helps understand which tariff is more popular.
*/
SELECT
    t.NAME AS TARIFF_NAME,
    COUNT(*) AS CUSTOMER_COUNT
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.NAME
ORDER BY CUSTOMER_COUNT DESC;


/* =========================================================
   3. Customer Signup Analysis
   ========================================================= */

/*
This query identifies the earliest customers to sign up in the system.
I used MIN(SIGNUP_DATE) because customer IDs do not necessarily reflect the signup order.
The query returns all customers who have the earliest signup date.
*/

SELECT
    CUSTOMER_ID,
    NAME,
    CITY,
    SIGNUP_DATE,
    TARIFF_ID
FROM CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM CUSTOMERS
)
ORDER BY CUSTOMER_ID;

/*
This query shows the city distribution of the earliest customers.
I grouped the earliest customers by city and counted how many belong to each city.
This helps analyze where the first customers are located.
*/

SELECT
    CITY,
    COUNT(*) AS TOTAL_COUNT
FROM CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM CUSTOMERS
)
GROUP BY CITY
ORDER BY TOTAL_COUNT DESC, CITY;


/* =========================================================
   4. Missing Monthly Records
   ========================================================= */

/*
This query identifies customers whose monthly records are missing.
I used a LEFT JOIN from CUSTOMERS to MONTHLY_STATS because every customer is expected to have a monthly record.
If a customer has no matching row in MONTHLY_STATS, the monthly record is missing, so ms.CUSTOMER_ID becomes NULL.
*/
SELECT
    c.CUSTOMER_ID
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.CUSTOMER_ID IS NULL
ORDER BY c.CUSTOMER_ID;

/*
This query shows the city distribution of customers whose monthly records are missing.
I again used a LEFT JOIN to detect customers without a matching monthly record.
Then I grouped those customers by city and counted how many missing records belong to each city.
*/
SELECT
    c.CITY,
    COUNT(*) AS TOTAL_COUNT
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.CUSTOMER_ID IS NULL
GROUP BY c.CITY
ORDER BY TOTAL_COUNT DESC, c.CITY;

/* =========================================================
   5. Usage Analysis
   ========================================================= */

/*
This query finds customers who have used at least 75 percent of their data limit.
I joined CUSTOMERS, TARIFFS, and MONTHLY_STATS because usage and limits are stored in different tables.
I filtered the customers whose data usage is greater than or equal to 75 percent of their data limit.
*/

SELECT
    c.CUSTOMER_ID,
    c.NAME,
    c.CITY,
    t.NAME AS TARIFF_NAME,
    ms.DATA_USAGE,
    t.DATA_LIMIT
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE t.DATA_LIMIT > 0
  AND ms.DATA_USAGE >= t.DATA_LIMIT * 0.75
ORDER BY c.CUSTOMER_ID;

/*
This query identifies customers who have exhausted all of their package limits.
I compared data, minute, and SMS usage values with their corresponding limits.
Only customers who meet all three conditions are included in the result.
*/
/*The query returned no rows, which indicates that no customer in the dataset consumed all three limits completely at the same time.
*/
SELECT
    c.CUSTOMER_ID,
    c.NAME,
    c.CITY,
    t.NAME AS TARIFF_NAME,
    ms.DATA_USAGE,
    t.DATA_LIMIT,
    ms.MINUTE_USAGE,
    t.MINUTE_LIMIT,
    ms.SMS_USAGE,
    t.SMS_LIMIT
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE t.DATA_LIMIT > 0
  AND t.MINUTE_LIMIT > 0
  AND t.SMS_LIMIT > 0
  AND ms.DATA_USAGE   >= t.DATA_LIMIT
  AND ms.MINUTE_USAGE >= t.MINUTE_LIMIT
  AND ms.SMS_USAGE    >= t.SMS_LIMIT
ORDER BY c.CUSTOMER_ID;


/* =========================================================
   6. Payment Analysis
   ========================================================= */

/*
This query finds customers who have unpaid fees.
I joined the customer, tariff, and monthly statistics tables to combine customer details, tariff information, and payment status.
Then I filtered the rows where PAYMENT_STATUS is equal to 'UNPAID'.
*/
SELECT
    c.CUSTOMER_ID,
    c.NAME,
    c.CITY,
    t.NAME AS TARIFF_NAME,
    t.MONTHLY_FEE,
    ms.PAYMENT_STATUS
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.PAYMENT_STATUS = 'UNPAID'
ORDER BY c.CUSTOMER_ID;

/*
This query shows the distribution of all payment statuses across different tariffs.
I grouped the records by tariff name and payment status.
This helps analyze how payment behavior changes between tariffs.
*/
SELECT
    t.NAME AS TARIFF_NAME,
    ms.PAYMENT_STATUS,
    COUNT(*) AS TOTAL_COUNT
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
GROUP BY t.NAME, ms.PAYMENT_STATUS
