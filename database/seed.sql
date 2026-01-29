-- =========================
-- Customers
-- =========================
INSERT INTO customers (first_name, last_name, email)
VALUES
('Alice', 'Martin', 'alice.martin@example.com'),
('Bob', 'Dupont', 'bob.dupont@example.com'),
('Charlie', 'Durand', 'charlie.durand@example.com')
ON CONFLICT (email) DO NOTHING;

-- =========================
-- Addresses
-- =========================
INSERT INTO addresses (customer_id, street_number, street_name, postal_code, city)
SELECT id, 12, 'Rue de Paris', 75001, 'Paris' FROM customers WHERE first_name = 'Alice'
ON CONFLICT DO NOTHING;

INSERT INTO addresses (customer_id, street_number, street_name, postal_code, city)
SELECT id, 5, 'Avenue de Lyon', 69001, 'Lyon' FROM customers WHERE first_name = 'Bob'
ON CONFLICT DO NOTHING;

INSERT INTO addresses (customer_id, street_number, street_name, postal_code, city)
SELECT id, 8, 'Boulevard Saint-Germain', 75005, 'Paris' FROM customers WHERE first_name = 'Charlie'
ON CONFLICT DO NOTHING;

-- =========================
-- Payment Types
-- =========================
INSERT INTO payment_types (name)
VALUES ('Credit Card'), ('PayPal')
ON CONFLICT (name) DO NOTHING;

-- =========================
-- Payment Providers
-- =========================
INSERT INTO payment_providers (name)
VALUES ('Visa'), ('MasterCard'), ('Stripe')
ON CONFLICT (name) DO NOTHING;

-- =========================
-- Payment Methods
-- =========================
INSERT INTO payment_methods (customer_id, type_id, provider_id, provider_reference_id, is_default)
SELECT c.id, pt.id, pp.id, 'REF123', TRUE
FROM customers c
JOIN payment_types pt ON pt.name = 'Credit Card'
JOIN payment_providers pp ON pp.name = 'Visa'
WHERE c.first_name = 'Alice'
ON CONFLICT DO NOTHING;

INSERT INTO payment_methods (customer_id, type_id, provider_id, provider_reference_id, is_default)
SELECT c.id, pt.id, pp.id, 'REF456', TRUE
FROM customers c
JOIN payment_types pt ON pt.name = 'PayPal'
JOIN payment_providers pp ON pp.name = 'Stripe'
WHERE c.first_name = 'Bob'
ON CONFLICT DO NOTHING;

-- =========================
-- Product Categories
-- =========================
INSERT INTO product_categories (name)
VALUES ('Pizza'), ('Pasta'), ('Dessert')
ON CONFLICT (name) DO NOTHING;

-- =========================
-- Products
-- =========================
INSERT INTO products (name, category_id, price)
SELECT 'Margherita', id, 8.50 FROM product_categories WHERE name = 'Pizza'
ON CONFLICT DO NOTHING;

INSERT INTO products (name, category_id, price)
SELECT 'Pepperoni', id, 9.50 FROM product_categories WHERE name = 'Pizza'
ON CONFLICT DO NOTHING;

INSERT INTO products (name, category_id, price)
SELECT 'Spaghetti Carbonara', id, 12.00 FROM product_categories WHERE name = 'Pasta'
ON CONFLICT DO NOTHING;

-- =========================
-- Orders and Order Items using CTEs
-- =========================
WITH new_order AS (
    INSERT INTO orders (customer_id, address_id, payment_method_id, total_amount, status)
    SELECT c.id, a.id, pm.id, 0, 'pending'
    FROM customers c
    JOIN addresses a ON a.customer_id = c.id
    JOIN payment_methods pm ON pm.customer_id = c.id
    WHERE c.first_name = 'Alice'
    RETURNING id, customer_id
),
insert_items AS (
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    SELECT o.id, p.id, 2, p.price
    FROM new_order o
    JOIN products p ON p.name = 'Margherita'
    RETURNING order_id
)
UPDATE orders o
SET total_amount = (
    SELECT SUM(quantity * unit_price)
    FROM order_items
    WHERE order_id = o.id
)
WHERE o.id IN (SELECT order_id FROM insert_items);

-- Repeat CTE for Bob
WITH new_order AS (
    INSERT INTO orders (customer_id, address_id, payment_method_id, total_amount, status)
    SELECT c.id, a.id, pm.id, 0, 'pending'
    FROM customers c
    JOIN addresses a ON a.customer_id = c.id
    JOIN payment_methods pm ON pm.customer_id = c.id
    WHERE c.first_name = 'Bob'
    RETURNING id, customer_id
),
insert_items AS (
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    SELECT o.id, p.id, 1, p.price
    FROM new_order o
    JOIN products p ON p.name = 'Spaghetti Carbonara'
    RETURNING order_id
)

UPDATE orders o
SET total_amount = (
    SELECT SUM(quantity * unit_price)
    FROM order_items
    WHERE order_id = o.id
)
WHERE o.id IN (SELECT order_id FROM order_items);

