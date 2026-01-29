-- POSTGRES DATABASE
-- can add indexes like on email to speed up queries
-- extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";  -- provides uuid_generate_v4()

-- Customers
CREATE TABLE IF NOT EXISTS customers (
    id UUID     PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(255) NOT NULL UNIQUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Addresses
CREATE TABLE IF NOT EXISTS addresses (
    id UUID             PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID    NOT NULL,
    street_number       INT NOT NULL,
    street_name         TEXT NOT NULL,
    postal_code         INT NOT NULL,
    city                TEXT NOT NULL,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    CONSTRAINT 
        fk_addresses_customer 
        FOREIGN KEY (customer_id)
        REFERENCES customers(id) ON DELETE CASCADE
);

-- Payment
CREATE TABLE IF NOT EXISTS payment_types (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(50) NOT NULL UNIQUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS payment_providers (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(100) NOT NULL UNIQUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS payment_methods (
    id UUID                 PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID        NOT NULL,
    type_id UUID            NOT NULL,
    provider_id UUID        NOT NULL,
    provider_reference_id   TEXT NOT NULL,
    expires_at              DATE,
    is_default              BOOLEAN DEFAULT FALSE,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    CONSTRAINT fk_payment_type FOREIGN KEY (type_id) REFERENCES payment_types(id) ON DELETE RESTRICT,
    CONSTRAINT fk_payment_provider FOREIGN KEY (provider_id) REFERENCES payment_providers(id) ON DELETE RESTRICT,
    CONSTRAINT unique_provider_reference UNIQUE (provider_id, provider_reference_id)
);

-- Product
CREATE TABLE IF NOT EXISTS product_categories (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(50) NOT NULL UNIQUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        TEXT NOT NULL,
    category_id UUID NOT NULL,
    price       NUMERIC(10,2) NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES product_categories(id) ON DELETE RESTRICT,
    CONSTRAINT unique_products_name_category UNIQUE (name, category_id)
);

-- Orders
CREATE TYPE order_status AS ENUM (
    'pending',
    'preparing',
    'transit',
    'delivered',
    'pickup'
);

CREATE TABLE IF NOT EXISTS orders (
    id UUID                 PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID        NOT NULL,
    address_id UUID         NOT NULL,
    payment_method_id UUID  NOT NULL,
    total_amount            NUMERIC(10,2) NOT NULL,
    status order_status     DEFAULT 'pending' NOT NULL,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
    CONSTRAINT fk_order_address FOREIGN KEY (address_id) REFERENCES addresses(id),
    CONSTRAINT fk_order_payment FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id)
);

CREATE TABLE IF NOT EXISTS order_items (
    id UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID   NOT NULL,
    product_id UUID NOT NULL,
    quantity        INT NOT NULL,
    unit_price      NUMERIC(10,2) NOT NULL,
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_order_item_product FOREIGN KEY (product_id) REFERENCES products(id)
);
