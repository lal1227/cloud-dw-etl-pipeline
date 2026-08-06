-- PL/SQL-style stored procedures that clean, deduplicate, and load staged
-- sales rows into the final warehouse fact table.

CREATE OR REPLACE PROCEDURE transform_and_load_sales_fact()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Remove exact duplicate rows that may have landed in staging.
    DELETE FROM staging.sales_raw a
    USING staging.sales_raw b
    WHERE a.order_id = b.order_id
      AND a.ctid < b.ctid;

    -- Upsert cleaned rows into the warehouse fact table.
    INSERT INTO warehouse.sales_fact (
        order_id, order_date, region, product, quantity, unit_price, total_revenue
    )
    SELECT
        order_id,
        order_date,
        region,
        product,
        COALESCE(quantity, 0) AS quantity,
        COALESCE(unit_price, 0) AS unit_price,
        COALESCE(quantity, 0) * COALESCE(unit_price, 0) AS total_revenue
    FROM staging.sales_raw
    ON CONFLICT (order_id) DO UPDATE
    SET
        order_date = EXCLUDED.order_date,
        region = EXCLUDED.region,
        product = EXCLUDED.product,
        quantity = EXCLUDED.quantity,
        unit_price = EXCLUDED.unit_price,
        total_revenue = EXCLUDED.total_revenue;

    RAISE NOTICE 'Sales fact table refreshed successfully.';
END;
$$;
