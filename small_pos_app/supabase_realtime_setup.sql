-- Supabase Real-time Setup for Low Stock Notifications
-- Run this in your Supabase SQL Editor

-- Enable realtime for products table
ALTER PUBLICATION supabase_realtime ADD TABLE products;

-- Create a function to check and notify low stock products
CREATE OR REPLACE FUNCTION check_low_stock()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if stock is low after update
  IF NEW.stock_quantity IS NOT NULL AND NEW.low_stock_threshold IS NOT NULL THEN
    IF NEW.stock_quantity <= NEW.low_stock_threshold THEN
      -- This will trigger real-time event that app listens to
      -- The app will show notification when it receives this event
      PERFORM pg_notify('low_stock_alert', json_build_object(
        'product_id', NEW.id,
        'product_name', NEW.name,
        'stock_quantity', NEW.stock_quantity,
        'low_stock_threshold', NEW.low_stock_threshold
      )::text);
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to check low stock on product updates
DROP TRIGGER IF EXISTS trigger_check_low_stock ON products;
CREATE TRIGGER trigger_check_low_stock
  AFTER INSERT OR UPDATE OF stock_quantity, low_stock_threshold ON products
  FOR EACH ROW
  WHEN (NEW.stock_quantity IS NOT NULL AND NEW.low_stock_threshold IS NOT NULL)
  EXECUTE FUNCTION check_low_stock();

-- Create a view for low stock products (optional, for easy querying)
CREATE OR REPLACE VIEW low_stock_products AS
SELECT 
  id,
  name,
  sku,
  stock_quantity,
  low_stock_threshold,
  category,
  (stock_quantity - low_stock_threshold) as stock_deficit
FROM products
WHERE stock_quantity IS NOT NULL 
  AND low_stock_threshold IS NOT NULL
  AND stock_quantity <= low_stock_threshold;

-- Grant access to the view
GRANT SELECT ON low_stock_products TO authenticated;

-- Note: Real-time is automatically enabled for tables in Supabase
-- The app will listen to changes via the Supabase client

