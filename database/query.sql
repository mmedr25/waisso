-- query to update address
UPDATE addresses
SET
    street_number = $1,
    street_name   = $2,
    postal_code   = $3,
    city          = $4,
    updated_at    = CURRENT_TIMESTAMP
WHERE id = $5
  AND customer_id = $6;


-- query to get the average spendings in a city
SELECT AVG(o.total_amount) AS montant_moyen_achats
FROM orders o
JOIN addresses a ON o.address_id = a.id
WHERE a.city = $1;