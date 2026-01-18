-- Migration: 009_views_for_reports
-- Created: 2025-01-18
-- Description: Vistas para reportes y dashboards

-- ============================================================================
-- VISTAS PARA REPORTES Y CONSULTAS
-- ============================================================================

-- Vista: Inventario consolidado con valores
CREATE OR REPLACE VIEW v_inventory_overview AS
SELECT
  i.id,
  s.id AS store_id,
  s.code AS store_code,
  s.name AS store_name,
  s.is_warehouse,
  p.id AS product_id,
  p.code AS product_code,
  p.name AS product_name,
  c.name AS category_name,
  i.stock,
  i.min_stock,
  p.cost_price,
  p.sale_price,
  (i.stock * p.cost_price) AS inventory_value_cost,
  (i.stock * p.sale_price) AS inventory_value_sale,
  (i.stock * (p.sale_price - p.cost_price)) AS potential_profit,
  CASE
    WHEN i.stock <= i.min_stock THEN 'low'
    WHEN i.stock > i.min_stock THEN 'normal'
  END AS stock_status
FROM inventory i
INNER JOIN stores s ON i.store_id = s.id
INNER JOIN products p ON i.product_id = p.id
INNER JOIN categories c ON p.category_id = c.id
WHERE s.is_active = 1 AND p.is_active = 1;

-- Vista: Estado de cajas por tienda
CREATE OR REPLACE VIEW v_cash_register_status AS
SELECT
  cr.id,
  cr.store_id,
  s.name AS store_name,
  u_open.name AS opened_by,
  cr.opened_at,
  cr.opening_balance,
  u_close.name AS closed_by,
  cr.closed_at,
  cr.closing_balance,
  cr.expected_balance,
  cr.difference,
  cr.status,
  TIMESTAMPDIFF(HOUR, cr.opened_at, COALESCE(cr.closed_at, NOW())) AS hours_open
FROM cash_registers cr
INNER JOIN stores s ON cr.store_id = s.id
INNER JOIN users u_open ON cr.opened_by = u_open.id
LEFT JOIN users u_close ON cr.closed_by = u_close.id;

-- Vista: Resumen de ventas por tienda
CREATE OR REPLACE VIEW v_sales_summary AS
SELECT
  s.store_id,
  st.name AS store_name,
  DATE(s.created_at) AS sale_date,
  COUNT(CASE WHEN s.status = 'completed' THEN s.id END) AS total_sales,
  COUNT(CASE WHEN s.status = 'cancelled' THEN s.id END) AS total_cancelled,
  SUM(CASE WHEN s.status = 'completed' THEN s.total ELSE 0 END) AS total_revenue,
  SUM(CASE WHEN s.status = 'cancelled' THEN s.total ELSE 0 END) AS total_cancelled_amount
FROM sales s
INNER JOIN stores st ON s.store_id = st.id
GROUP BY s.store_id, st.name, DATE(s.created_at);

-- Vista: Datos financieros consolidados (para dashboard admin)
CREATE OR REPLACE VIEW v_financial_dashboard AS
SELECT
  s.id AS store_id,
  s.name AS store_name,
  DATE(COALESCE(sal.created_at, exp.created_at)) AS transaction_date,
  COALESCE(SUM(CASE WHEN sal.status = 'completed' THEN sal.total END), 0) AS daily_sales,
  COALESCE(SUM(CASE WHEN exp.status = 'active' THEN exp.total_amount END), 0) AS daily_expenses,
  COALESCE(SUM(CASE WHEN sal.status = 'completed' THEN sal.total END), 0) -
  COALESCE(SUM(CASE WHEN exp.status = 'active' THEN exp.total_amount END), 0) AS daily_net
FROM stores s
LEFT JOIN sales sal ON s.id = sal.store_id
LEFT JOIN expenses exp ON s.id = exp.store_id AND DATE(exp.expense_date) = DATE(sal.created_at)
WHERE s.is_active = 1 AND s.is_warehouse = 0
GROUP BY s.id, s.name, DATE(COALESCE(sal.created_at, exp.created_at));