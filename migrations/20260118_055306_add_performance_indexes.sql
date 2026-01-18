-- Migration: 010_performance_indexes
-- Created: 2025-01-18
-- Description: Índices adicionales para optimización de rendimiento

-- ============================================================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- ============================================================================

-- Índices compuestos para consultas frecuentes
CREATE INDEX idx_sales_store_date_status ON sales(store_id, created_at, status);
CREATE INDEX idx_sales_cash_register_status ON sales(cash_register_id, status);
CREATE INDEX idx_inventory_movements_store_date ON inventory_movements(store_id, created_at);
CREATE INDEX idx_expenses_store_date_status ON expenses(store_id, expense_date, status);

-- Índices para búsquedas de texto
CREATE FULLTEXT INDEX idx_products_search ON products(code, name);
CREATE FULLTEXT INDEX idx_users_search ON users(name, email);

-- Índices para reportes financieros
CREATE INDEX idx_sale_items_product_sale ON sale_items(product_id, sale_id);
CREATE INDEX idx_transfers_stores_status ON transfers(from_store_id, to_store_id, status);