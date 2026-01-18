-- ============================================================================
-- SISTEMA PUNTO DE VENTA MULTITIENDA
-- Arquitectura: Bodega Central → Tiendas Independientes
-- ============================================================================

-- ============================================================================
-- MÓDULO 1: SEGURIDAD Y AUTENTICACIÓN
-- ============================================================================

-- Tabla: roles
CREATE TABLE `roles` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT 'admin, bodega, vendedor',
  `display_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: permissions
CREATE TABLE `permissions` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'users.create, products.edit, etc',
  `display_name` varchar(150) NOT NULL,
  `module` varchar(50) DEFAULT NULL COMMENT 'users, products, sales, etc',
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permissions_name_unique` (`name`),
  KEY `permissions_module_index` (`module`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: role_permission
CREATE TABLE `role_permission` (
  `role_id` bigint(20) UNSIGNED NOT NULL,
  `permission_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`role_id`, `permission_id`),
  KEY `role_permission_permission_id_foreign` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: users
CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `role_id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Solo para vendedores',
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_login_at` timestamp NULL DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_role_id_index` (`role_id`),
  KEY `users_store_id_index` (`store_id`),
  KEY `users_is_active_index` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- MÓDULO 2: CONFIGURACIÓN MAESTRA
-- ============================================================================

-- Tabla: stores
CREATE TABLE `stores` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL COMMENT 'Código único de tienda',
  `name` varchar(100) NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `is_warehouse` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=Bodega principal, 0=Tienda',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stores_code_unique` (`code`),
  KEY `stores_is_warehouse_index` (`is_warehouse`),
  KEY `stores_is_active_index` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: categories
CREATE TABLE `categories` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `categories_is_active_index` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: products
CREATE TABLE `products` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(50) NOT NULL COMMENT 'SKU/Código de producto',
  `name` varchar(200) NOT NULL,
  `cost_price` decimal(10,2) NOT NULL COMMENT 'Precio de costo',
  `sale_price` decimal(10,2) NOT NULL COMMENT 'Precio de venta',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_code_unique` (`code`),
  KEY `products_category_id_index` (`category_id`),
  KEY `products_is_active_index` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- MÓDULO 3: GESTIÓN DE INVENTARIO (CLAVE DEL SISTEMA)
-- ============================================================================

-- Tabla: inventory (Inventario unificado: bodega + tiendas)
CREATE TABLE `inventory` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `store_id` bigint(20) UNSIGNED NOT NULL COMMENT 'Incluye bodega y tiendas',
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0 COMMENT 'Stock actual',
  `min_stock` int(11) NOT NULL DEFAULT 0 COMMENT 'Stock mínimo de alerta',
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_store_product` (`store_id`, `product_id`),
  KEY `inventory_stock_index` (`stock`),
  KEY `inventory_product_id_index` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: inventory_movements (Trazabilidad completa de movimientos)
CREATE TABLE `inventory_movements` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `movement_type` enum('entry','exit','transfer_out','transfer_in','sale','sale_return','adjustment') NOT NULL,
  `quantity` int(11) NOT NULL COMMENT 'Positivo para entrada, negativo para salida',
  `previous_stock` int(11) NOT NULL COMMENT 'Stock antes del movimiento',
  `new_stock` int(11) NOT NULL COMMENT 'Stock después del movimiento',
  `reference_type` varchar(50) DEFAULT NULL COMMENT 'sales, transfers, adjustments',
  `reference_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'ID de la tabla de referencia',
  `notes` text DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `inventory_movements_store_product_index` (`store_id`, `product_id`),
  KEY `inventory_movements_type_index` (`movement_type`),
  KEY `inventory_movements_reference_index` (`reference_type`, `reference_id`),
  KEY `inventory_movements_created_at_index` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: transfers (Transferencias bodega → tiendas o entre tiendas)
CREATE TABLE `transfers` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `transfer_number` varchar(50) NOT NULL,
  `from_store_id` bigint(20) UNSIGNED NOT NULL,
  `to_store_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('pending','completed','cancelled') NOT NULL DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `cancelled_by` bigint(20) UNSIGNED DEFAULT NULL,
  `cancellation_reason` text DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transfers_number_unique` (`transfer_number`),
  KEY `transfers_from_store_index` (`from_store_id`),
  KEY `transfers_to_store_index` (`to_store_id`),
  KEY `transfers_status_index` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: transfer_items (Detalle de productos en transferencias)
CREATE TABLE `transfer_items` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `transfer_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `transfer_items_transfer_id_index` (`transfer_id`),
  KEY `transfer_items_product_id_index` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- MÓDULO 4: CAJA REGISTRADORA (POR TIENDA)
-- ============================================================================

-- Tabla: cash_registers
CREATE TABLE `cash_registers` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `opened_by` bigint(20) UNSIGNED NOT NULL,
  `opened_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `opening_balance` decimal(10,2) NOT NULL DEFAULT 0.00,
  `closed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT NULL,
  `closing_balance` decimal(10,2) DEFAULT NULL COMMENT 'Efectivo contado físicamente',
  `expected_balance` decimal(10,2) DEFAULT NULL COMMENT 'Calculado automáticamente',
  `difference` decimal(10,2) DEFAULT NULL COMMENT 'closing_balance - expected_balance',
  `status` enum('open','closed') NOT NULL DEFAULT 'open',
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cash_registers_store_id_index` (`store_id`),
  KEY `cash_registers_status_index` (`status`),
  KEY `cash_registers_opened_at_index` (`opened_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: cash_movements (Movimientos de efectivo en caja)
CREATE TABLE `cash_movements` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `cash_register_id` bigint(20) UNSIGNED NOT NULL,
  `type` enum('deposit','withdrawal') NOT NULL COMMENT 'Ingreso o retiro de efectivo',
  `amount` decimal(10,2) NOT NULL,
  `reason` text NOT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `cash_movements_cash_register_id_index` (`cash_register_id`),
  KEY `cash_movements_type_index` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- MÓDULO 5: VENTAS (POR TIENDA)
-- ============================================================================

-- Tabla: sales
CREATE TABLE `sales` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `sale_number` varchar(50) NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `cash_register_id` bigint(20) UNSIGNED NOT NULL,
  `seller_id` bigint(20) UNSIGNED NOT NULL COMMENT 'Usuario vendedor',
  `subtotal` decimal(10,2) NOT NULL,
  `tax` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total` decimal(10,2) NOT NULL,
  `payment_method` enum('cash','card','transfer','mixed') NOT NULL,
  `status` enum('completed','cancelled') NOT NULL DEFAULT 'completed',
  `cancelled_by` bigint(20) UNSIGNED DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `cancellation_reason` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sales_sale_number_unique` (`sale_number`),
  KEY `sales_store_id_index` (`store_id`),
  KEY `sales_cash_register_id_index` (`cash_register_id`),
  KEY `sales_seller_id_index` (`seller_id`),
  KEY `sales_status_index` (`status`),
  KEY `sales_created_at_index` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: sale_items
CREATE TABLE `sale_items` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `sale_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `sale_items_sale_id_index` (`sale_id`),
  KEY `sale_items_product_id_index` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: sale_returns (Devoluciones completas o parciales)
CREATE TABLE `sale_returns` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `return_number` varchar(50) NOT NULL,
  `sale_id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `total_returned` decimal(10,2) NOT NULL,
  `return_type` enum('full','partial') NOT NULL,
  `reason` text NOT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sale_returns_number_unique` (`return_number`),
  KEY `sale_returns_sale_id_index` (`sale_id`),
  KEY `sale_returns_store_id_index` (`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: sale_return_items
CREATE TABLE `sale_return_items` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `sale_return_id` bigint(20) UNSIGNED NOT NULL,
  `sale_item_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `quantity_returned` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `sale_return_items_return_id_index` (`sale_return_id`),
  KEY `sale_return_items_sale_item_id_index` (`sale_item_id`),
  KEY `sale_return_items_product_id_index` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- MÓDULO 6: GASTOS (POR TIENDA)
-- ============================================================================

-- Tabla: expenses
CREATE TABLE `expenses` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `expense_number` varchar(50) NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `category` varchar(100) NOT NULL COMMENT 'Servicios, Suministros, etc',
  `description` text NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `expense_date` date NOT NULL,
  `status` enum('active','cancelled') NOT NULL DEFAULT 'active',
  `cancelled_by` bigint(20) UNSIGNED DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `cancellation_reason` text DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `expenses_number_unique` (`expense_number`),
  KEY `expenses_store_id_index` (`store_id`),
  KEY `expenses_status_index` (`status`),
  KEY `expenses_date_index` (`expense_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- VISTAS PARA REPORTES Y CONSULTAS
-- ============================================================================

-- Vista: Inventario consolidado con valores
CREATE OR REPLACE VIEW `v_inventory_overview` AS
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
CREATE OR REPLACE VIEW `v_cash_register_status` AS
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
CREATE OR REPLACE VIEW `v_sales_summary` AS
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
CREATE OR REPLACE VIEW `v_financial_dashboard` AS
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


-- ============================================================================
-- RESTRICCIONES DE INTEGRIDAD REFERENCIAL
-- ============================================================================

-- Role & Permissions
ALTER TABLE `role_permission`
  ADD CONSTRAINT `role_permission_role_id_foreign` 
    FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `role_permission_permission_id_foreign` 
    FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE;

-- Users
ALTER TABLE `users`
  ADD CONSTRAINT `users_role_id_foreign` 
    FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  ADD CONSTRAINT `users_store_id_foreign` 
    FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE SET NULL;

-- Products
ALTER TABLE `products`
  ADD CONSTRAINT `products_category_id_foreign` 
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`);

-- Inventory
ALTER TABLE `inventory`
  ADD CONSTRAINT `inventory_store_id_foreign` 
    FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`),
  ADD CONSTRAINT `inventory_product_id_foreign` 
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

ALTER TABLE `inventory_movements`
  ADD CONSTRAINT `inventory_movements_store_id_foreign` 
    FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`),
  ADD CONSTRAINT `inventory_movements_product_id_foreign` 
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  ADD CONSTRAINT `inventory_movements_created_by_foreign` 
    FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

-- Transfers
ALTER TABLE `transfers`
  ADD CONSTRAINT `transfers_from_store_id_foreign` 
    FOREIGN KEY (`from_store_id`) REFERENCES `stores` (`id`),
  ADD CONSTRAINT `transfers_to_store_id_foreign` 
    FOREIGN KEY (`to_store_id`) REFERENCES `stores` (`id`),
  ADD CONSTRAINT `transfers_created_by_foreign` 
    FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

ALTER TABLE `transfer_items`
  ADD CONSTRAINT `transfer_items_transfer_id_foreign` 
    FOREIGN KEY (`transfer_id`) REFERENCES `transfers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `transfer_items_product_id_foreign` 
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

-- Cash Registers
ALTER TABLE `cash_registers`
  ADD CONSTRAINT `cash_registers_store_id_foreign` 
    FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`),
  ADD CONSTRAINT `cash_registers_opened_by_foreign` 
    FOREIGN KEY (`opened_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `cash_registers_closed_by_foreign` 
    FOREIGN KEY (`closed_by`) REFERENCES `users` (`id`);

ALTER TABLE `cash_movements`
  ADD CONSTRAINT `cash_movements_cash_register_id_foreign` 
    FOREIGN KEY (`cash_register_id`) REFERENCES `cash_registers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cash_movements_created_by_foreign` 
    FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

-- Sales
ALTER TABLE `sales`
  ADD CONSTRAINT `sales_store_id_foreign` 
    FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`),
  ADD CONSTRAINT `sales_cash_register_id_foreign` 
    FOREIGN KEY (`cash_register_id`) REFERENCES `cash_registers` (`id`),
  ADD CONSTRAINT `sales_seller_id_foreign` 
    FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `sales_cancelled_by_foreign` 
    FOREIGN KEY (`cancelled_by`) REFERENCES `users` (`id`);

ALTER TABLE `sale_items`
  ADD CONSTRAINT `sale_items_sale_id_foreign` 
    FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `sale_items_product_id_foreign` 
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

ALTER TABLE `sale_returns`
  ADD CONSTRAINT `sale_returns_sale_id_foreign` 
    FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`),
  ADD CONSTRAINT `sale_returns_store_id_foreign` 
    FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`),
  ADD CONSTRAINT `sale_returns_created_by_foreign` 
    FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

ALTER TABLE `sale_return_items`
  ADD CONSTRAINT `sale_return_items_return_id_foreign` 
    FOREIGN KEY (`sale_return_id`) REFERENCES `sale_returns` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `sale_return_items_sale_item_id_foreign` 
    FOREIGN KEY (`sale_item_id`) REFERENCES `sale_items` (`id`),
  ADD CONSTRAINT `sale_return_items_product_id_foreign` 
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

-- Expenses
ALTER TABLE `expenses`
  ADD CONSTRAINT `expenses_store_id_foreign` 
    FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`),
  ADD CONSTRAINT `expenses_created_by_foreign` 
    FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `expenses_cancelled_by_foreign` 
    FOREIGN KEY (`cancelled_by`) REFERENCES `users` (`id`);


-- ============================================================================
-- MÓDULO 7: AUDITORÍA DEL SISTEMA
-- ============================================================================

-- Tabla: audit_log (Registro de cambios en datos críticos)
CREATE TABLE `audit_log` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `table_name` varchar(100) NOT NULL,
  `record_id` bigint(20) UNSIGNED NOT NULL,
  `action` enum('INSERT','UPDATE','DELETE') NOT NULL,
  `old_values` json DEFAULT NULL,
  `new_values` json DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `audit_log_table_record_index` (`table_name`, `record_id`),
  KEY `audit_log_action_index` (`action`),
  KEY `audit_log_user_id_index` (`user_id`),
  KEY `audit_log_created_at_index` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- TRIGGERS PARA AUTOMATIZACIÓN
-- ============================================================================

-- ========================================
-- TRIGGERS: INVENTARIO
-- ========================================

-- Trigger: Registrar movimiento al actualizar stock manualmente
DELIMITER $
CREATE TRIGGER after_inventory_update
AFTER UPDATE ON inventory
FOR EACH ROW
BEGIN
  IF NEW.stock != OLD.stock THEN
    INSERT INTO inventory_movements (
      store_id, product_id, movement_type, quantity, 
      previous_stock, new_stock, reference_type, notes, created_by
    ) VALUES (
      NEW.store_id, NEW.product_id, 'adjustment', 
      NEW.stock - OLD.stock, OLD.stock, NEW.stock, 
      'manual_adjustment', 'Manual stock adjustment', NEW.updated_by
    );
  END IF;
END$
DELIMITER ;

-- ========================================
-- TRIGGERS: TRANSFERENCIAS
-- ========================================

-- Trigger: Actualizar inventario al completar transferencia
DELIMITER $
CREATE TRIGGER after_transfer_complete
AFTER UPDATE ON transfers
FOR EACH ROW
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_product_id BIGINT;
  DECLARE v_quantity INT;
  DECLARE v_prev_stock_from INT;
  DECLARE v_prev_stock_to INT;
  
  DECLARE cur CURSOR FOR 
    SELECT product_id, quantity FROM transfer_items WHERE transfer_id = NEW.id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  
  IF NEW.status = 'completed' AND OLD.status = 'pending' THEN
    OPEN cur;
    
    transfer_loop: LOOP
      FETCH cur INTO v_product_id, v_quantity;
      IF done THEN
        LEAVE transfer_loop;
      END IF;
      
      -- Obtener stock previo origen
      SELECT stock INTO v_prev_stock_from FROM inventory 
      WHERE store_id = NEW.from_store_id AND product_id = v_product_id;
      
      -- Obtener stock previo destino
      SELECT stock INTO v_prev_stock_to FROM inventory 
      WHERE store_id = NEW.to_store_id AND product_id = v_product_id;
      
      -- Actualizar stock origen
      UPDATE inventory 
      SET stock = stock - v_quantity, updated_at = NOW()
      WHERE store_id = NEW.from_store_id AND product_id = v_product_id;
      
      -- Registrar movimiento salida
      INSERT INTO inventory_movements (
        store_id, product_id, movement_type, quantity, 
        previous_stock, new_stock, reference_type, reference_id, created_by
      ) VALUES (
        NEW.from_store_id, v_product_id, 'transfer_out', -v_quantity,
        v_prev_stock_from, v_prev_stock_from - v_quantity, 
        'transfers', NEW.id, NEW.created_by
      );
      
      -- Actualizar stock destino (crear si no existe)
      INSERT INTO inventory (store_id, product_id, stock, created_by, created_at, updated_at)
      VALUES (NEW.to_store_id, v_product_id, v_quantity, NEW.created_by, NOW(), NOW())
      ON DUPLICATE KEY UPDATE 
        stock = stock + v_quantity, 
        updated_at = NOW();
      
      -- Registrar movimiento entrada
      INSERT INTO inventory_movements (
        store_id, product_id, movement_type, quantity, 
        previous_stock, new_stock, reference_type, reference_id, created_by
      ) VALUES (
        NEW.to_store_id, v_product_id, 'transfer_in', v_quantity,
        COALESCE(v_prev_stock_to, 0), COALESCE(v_prev_stock_to, 0) + v_quantity, 
        'transfers', NEW.id, NEW.created_by
      );
      
    END LOOP;
    
    CLOSE cur;
  END IF;
END$
DELIMITER ;

-- ========================================
-- TRIGGERS: VENTAS
-- ========================================

-- Trigger: Actualizar stock y registrar movimiento al crear venta
DELIMITER $
CREATE TRIGGER after_sale_item_insert
AFTER INSERT ON sale_items
FOR EACH ROW
BEGIN
  DECLARE v_store_id BIGINT;
  DECLARE v_prev_stock INT;
  DECLARE v_seller_id BIGINT;
  
  SELECT store_id, seller_id INTO v_store_id, v_seller_id 
  FROM sales WHERE id = NEW.sale_id;
  
  SELECT stock INTO v_prev_stock FROM inventory 
  WHERE store_id = v_store_id AND product_id = NEW.product_id;
  
  -- Actualizar stock
  UPDATE inventory 
  SET stock = stock - NEW.quantity, updated_at = NOW()
  WHERE store_id = v_store_id AND product_id = NEW.product_id;
  
  -- Registrar movimiento
  INSERT INTO inventory_movements (
    store_id, product_id, movement_type, quantity, 
    previous_stock, new_stock, reference_type, reference_id, created_by
  ) VALUES (
    v_store_id, NEW.product_id, 'sale', -NEW.quantity,
    v_prev_stock, v_prev_stock - NEW.quantity, 
    'sales', NEW.sale_id, v_seller_id
  );
END$
DELIMITER ;

-- Trigger: Devolver stock al cancelar venta
DELIMITER $
CREATE TRIGGER after_sale_cancel
AFTER UPDATE ON sales
FOR EACH ROW
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_product_id BIGINT;
  DECLARE v_quantity INT;
  DECLARE v_prev_stock INT;
  
  DECLARE cur CURSOR FOR 
    SELECT product_id, quantity FROM sale_items WHERE sale_id = NEW.id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  
  IF NEW.status = 'cancelled' AND OLD.status = 'completed' THEN
    OPEN cur;
    
    cancel_loop: LOOP
      FETCH cur INTO v_product_id, v_quantity;
      IF done THEN
        LEAVE cancel_loop;
      END IF;
      
      SELECT stock INTO v_prev_stock FROM inventory 
      WHERE store_id = NEW.store_id AND product_id = v_product_id;
      
      -- Devolver stock
      UPDATE inventory 
      SET stock = stock + v_quantity, updated_at = NOW()
      WHERE store_id = NEW.store_id AND product_id = v_product_id;
      
      -- Registrar movimiento
      INSERT INTO inventory_movements (
        store_id, product_id, movement_type, quantity, 
        previous_stock, new_stock, reference_type, reference_id, 
        notes, created_by
      ) VALUES (
        NEW.store_id, v_product_id, 'adjustment', v_quantity,
        v_prev_stock, v_prev_stock + v_quantity, 
        'sales', NEW.id, 
        CONCAT('Sale cancelled: ', NEW.cancellation_reason), 
        NEW.cancelled_by
      );
      
    END LOOP;
    
    CLOSE cur;
  END IF;
END$
DELIMITER ;

-- ========================================
-- TRIGGERS: DEVOLUCIONES
-- ========================================

-- Trigger: Devolver stock al registrar devolución
DELIMITER $
CREATE TRIGGER after_sale_return_item_insert
AFTER INSERT ON sale_return_items
FOR EACH ROW
BEGIN
  DECLARE v_store_id BIGINT;
  DECLARE v_prev_stock INT;
  DECLARE v_return_id BIGINT;
  
  SELECT store_id INTO v_store_id FROM sale_returns WHERE id = NEW.sale_return_id;
  
  SELECT stock INTO v_prev_stock FROM inventory 
  WHERE store_id = v_store_id AND product_id = NEW.product_id;
  
  -- Devolver stock
  UPDATE inventory 
  SET stock = stock + NEW.quantity_returned, updated_at = NOW()
  WHERE store_id = v_store_id AND product_id = NEW.product_id;
  
  -- Registrar movimiento
  INSERT INTO inventory_movements (
    store_id, product_id, movement_type, quantity, 
    previous_stock, new_stock, reference_type, reference_id, created_by
  ) 
  SELECT 
    v_store_id, NEW.product_id, 'sale_return', NEW.quantity_returned,
    v_prev_stock, v_prev_stock + NEW.quantity_returned, 
    'sale_returns', NEW.sale_return_id, sr.created_by
  FROM sale_returns sr
  WHERE sr.id = NEW.sale_return_id;
END$
DELIMITER ;

-- ========================================
-- TRIGGERS: AUDITORÍA
-- ========================================

-- Trigger: Auditar cambios en usuarios
DELIMITER $
CREATE TRIGGER after_user_update
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, user_id)
  VALUES (
    'users', NEW.id, 'UPDATE',
    JSON_OBJECT(
      'name', OLD.name, 'email', OLD.email, 'role_id', OLD.role_id, 
      'store_id', OLD.store_id, 'is_active', OLD.is_active
    ),
    JSON_OBJECT(
      'name', NEW.name, 'email', NEW.email, 'role_id', NEW.role_id, 
      'store_id', NEW.store_id, 'is_active', NEW.is_active
    ),
    NEW.updated_by
  );
END$
DELIMITER ;

-- Trigger: Auditar cambios en productos
DELIMITER $
CREATE TRIGGER after_product_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, user_id)
  VALUES (
    'products', NEW.id, 'UPDATE',
    JSON_OBJECT(
      'code', OLD.code, 'name', OLD.name, 'cost_price', OLD.cost_price,
      'sale_price', OLD.sale_price, 'is_active', OLD.is_active
    ),
    JSON_OBJECT(
      'code', NEW.code, 'name', NEW.name, 'cost_price', NEW.cost_price,
      'sale_price', NEW.sale_price, 'is_active', NEW.is_active
    ),
    NEW.updated_by
  );
END$
DELIMITER ;

-- Trigger: Auditar cambios en cajas registradoras
DELIMITER $
CREATE TRIGGER after_cash_register_update
AFTER UPDATE ON cash_registers
FOR EACH ROW
BEGIN
  IF NEW.status = 'closed' AND OLD.status = 'open' THEN
    INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, user_id)
    VALUES (
      'cash_registers', NEW.id, 'UPDATE',
      JSON_OBJECT('status', OLD.status, 'opening_balance', OLD.opening_balance),
      JSON_OBJECT(
        'status', NEW.status, 'closing_balance', NEW.closing_balance,
        'expected_balance', NEW.expected_balance, 'difference', NEW.difference
      ),
      NEW.closed_by
    );
  END IF;
END$
DELIMITER ;


-- ============================================================================
-- PROCEDIMIENTOS ALMACENADOS
-- ============================================================================

-- ========================================
-- PROCEDIMIENTO: Cerrar Caja
-- ========================================
DELIMITER $
CREATE PROCEDURE sp_close_cash_register(
  IN p_cash_register_id BIGINT,
  IN p_closing_balance DECIMAL(10,2),
  IN p_closed_by BIGINT,
  IN p_notes TEXT,
  OUT p_success BOOLEAN,
  OUT p_message VARCHAR(255)
)
BEGIN
  DECLARE v_opening_balance DECIMAL(10,2);
  DECLARE v_total_sales DECIMAL(10,2);
  DECLARE v_total_deposits DECIMAL(10,2);
  DECLARE v_total_withdrawals DECIMAL(10,2);
  DECLARE v_expected_balance DECIMAL(10,2);
  DECLARE v_difference DECIMAL(10,2);
  DECLARE v_status VARCHAR(20);
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET p_success = FALSE;
    SET p_message = 'Error al cerrar la caja';
  END;
  
  START TRANSACTION;
  
  -- Verificar estado de la caja
  SELECT status, opening_balance INTO v_status, v_opening_balance
  FROM cash_registers WHERE id = p_cash_register_id;
  
  IF v_status != 'open' THEN
    SET p_success = FALSE;
    SET p_message = 'La caja ya está cerrada';
    ROLLBACK;
  ELSE
    -- Calcular ventas en efectivo
    SELECT COALESCE(SUM(total), 0) INTO v_total_sales
    FROM sales
    WHERE cash_register_id = p_cash_register_id
      AND status = 'completed'
      AND payment_method IN ('cash', 'mixed');
    
    -- Calcular depósitos
    SELECT COALESCE(SUM(amount), 0) INTO v_total_deposits
    FROM cash_movements
    WHERE cash_register_id = p_cash_register_id
      AND type = 'deposit';
    
    -- Calcular retiros
    SELECT COALESCE(SUM(amount), 0) INTO v_total_withdrawals
    FROM cash_movements
    WHERE cash_register_id = p_cash_register_id
      AND type = 'withdrawal';
    
    -- Calcular balance esperado
    SET v_expected_balance = v_opening_balance + v_total_sales + v_total_deposits - v_total_withdrawals;
    SET v_difference = p_closing_balance - v_expected_balance;
    
    -- Actualizar caja
    UPDATE cash_registers
    SET status = 'closed',
        closed_by = p_closed_by,
        closed_at = NOW(),
        closing_balance = p_closing_balance,
        expected_balance = v_expected_balance,
        difference = v_difference,
        notes = p_notes
    WHERE id = p_cash_register_id;
    
    SET p_success = TRUE;
    SET p_message = CONCAT('Caja cerrada. Diferencia: , v_difference);
    
    COMMIT;
  END IF;
END$
DELIMITER ;

-- ========================================
-- PROCEDIMIENTO: Procesar Devolución
-- ========================================
DELIMITER $
CREATE PROCEDURE sp_process_sale_return(
  IN p_sale_id BIGINT,
  IN p_return_type ENUM('full', 'partial'),
  IN p_reason TEXT,
  IN p_items JSON, -- [{"sale_item_id": 1, "quantity": 2}, ...]
  IN p_created_by BIGINT,
  OUT p_return_id BIGINT,
  OUT p_success BOOLEAN,
  OUT p_message VARCHAR(255)
)
BEGIN
  DECLARE v_return_number VARCHAR(50);
  DECLARE v_store_id BIGINT;
  DECLARE v_total_returned DECIMAL(10,2) DEFAULT 0;
  DECLARE v_item_count INT;
  DECLARE v_index INT DEFAULT 0;
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET p_success = FALSE;
    SET p_message = 'Error al procesar la devolución';
  END;
  
  START TRANSACTION;
  
  -- Obtener store_id de la venta
  SELECT store_id INTO v_store_id FROM sales WHERE id = p_sale_id;
  
  -- Generar número de devolución
  SET v_return_number = CONCAT('DEV', LPAD(
    (SELECT COALESCE(MAX(id), 0) + 1 FROM sale_returns), 8, '0'
  ));
  
  -- Crear registro de devolución
  INSERT INTO sale_returns (
    return_number, sale_id, store_id, total_returned, 
    return_type, reason, created_by, created_at
  ) VALUES (
    v_return_number, p_sale_id, v_store_id, 0, 
    p_return_type, p_reason, p_created_by, NOW()
  );
  
  SET p_return_id = LAST_INSERT_ID();
  
  -- Procesar cada item
  SET v_item_count = JSON_LENGTH(p_items);
  
  WHILE v_index < v_item_count DO
    SET @sale_item_id = JSON_EXTRACT(p_items, CONCAT('$[', v_index, '].sale_item_id'));
    SET @quantity = JSON_EXTRACT(p_items, CONCAT('$[', v_index, '].quantity'));
    
    -- Obtener datos del item original
    SELECT product_id, unit_price, @quantity * unit_price
    INTO @product_id, @unit_price, @subtotal
    FROM sale_items WHERE id = @sale_item_id;
    
    -- Crear item de devolución
    INSERT INTO sale_return_items (
      sale_return_id, sale_item_id, product_id, 
      quantity_returned, unit_price, subtotal, created_at
    ) VALUES (
      p_return_id, @sale_item_id, @product_id, 
      @quantity, @unit_price, @subtotal, NOW()
    );
    
    SET v_total_returned = v_total_returned + @subtotal;
    SET v_index = v_index + 1;
  END WHILE;
  
  -- Actualizar total de devolución
  UPDATE sale_returns 
  SET total_returned = v_total_returned 
  WHERE id = p_return_id;
  
  SET p_success = TRUE;
  SET p_message = CONCAT('Devolución procesada: ', v_return_number);
  
  COMMIT;
END$
DELIMITER ;

-- ========================================
-- PROCEDIMIENTO: Calcular Margen de Ganancia
-- ========================================
DELIMITER $
CREATE PROCEDURE sp_calculate_profit_margin(
  IN p_store_id BIGINT,
  IN p_date_from DATE,
  IN p_date_to DATE,
  OUT p_total_sales DECIMAL(10,2),
  OUT p_total_cost DECIMAL(10,2),
  OUT p_gross_profit DECIMAL(10,2),
  OUT p_profit_margin DECIMAL(5,2)
)
BEGIN
  -- Calcular ventas totales
  SELECT COALESCE(SUM(total), 0) INTO p_total_sales
  FROM sales
  WHERE store_id = p_store_id
    AND status = 'completed'
    AND DATE(created_at) BETWEEN p_date_from AND p_date_to;
  
  -- Calcular costo total
  SELECT COALESCE(SUM(si.quantity * p.cost_price), 0) INTO p_total_cost
  FROM sale_items si
  INNER JOIN sales s ON si.sale_id = s.id
  INNER JOIN products p ON si.product_id = p.id
  WHERE s.store_id = p_store_id
    AND s.status = 'completed'
    AND DATE(s.created_at) BETWEEN p_date_from AND p_date_to;
  
  -- Calcular ganancia bruta
  SET p_gross_profit = p_total_sales - p_total_cost;
  
  -- Calcular margen de ganancia
  IF p_total_sales > 0 THEN
    SET p_profit_margin = (p_gross_profit / p_total_sales) * 100;
  ELSE
    SET p_profit_margin = 0;
  END IF;
END$
DELIMITER ;

-- ========================================
-- PROCEDIMIENTO: Reporte Financiero Dashboard
-- ========================================
DELIMITER $
CREATE PROCEDURE sp_dashboard_financial_report(
  IN p_date_from DATE,
  IN p_date_to DATE,
  IN p_store_id BIGINT -- NULL para todas las tiendas
)
BEGIN
  SELECT 
    s.id AS store_id,
    s.name AS store_name,
    -- Ventas
    COUNT(DISTINCT CASE WHEN sal.status = 'completed' THEN sal.id END) AS total_sales,
    COALESCE(SUM(CASE WHEN sal.status = 'completed' THEN sal.total END), 0) AS total_revenue,
    -- Gastos
    COUNT(DISTINCT CASE WHEN exp.status = 'active' THEN exp.id END) AS total_expenses_count,
    COALESCE(SUM(CASE WHEN exp.status = 'active' THEN exp.total_amount END), 0) AS total_expenses,
    -- Neto
    COALESCE(SUM(CASE WHEN sal.status = 'completed' THEN sal.total END), 0) - 
    COALESCE(SUM(CASE WHEN exp.status = 'active' THEN exp.total_amount END), 0) AS net_income,
    -- Inventario
    (SELECT COALESCE(SUM(stock * cost_price), 0) 
     FROM inventory i 
     INNER JOIN products p ON i.product_id = p.id 
     WHERE i.store_id = s.id) AS inventory_value
  FROM stores s
  LEFT JOIN sales sal ON s.id = sal.store_id 
    AND DATE(sal.created_at) BETWEEN p_date_from AND p_date_to
  LEFT JOIN expenses exp ON s.id = exp.store_id 
    AND exp.expense_date BETWEEN p_date_from AND p_date_to
  WHERE s.is_active = 1 
    AND s.is_warehouse = 0
    AND (p_store_id IS NULL OR s.id = p_store_id)
  GROUP BY s.id, s.name
  ORDER BY total_revenue DESC;
END$
DELIMITER ;

-- ========================================
-- PROCEDIMIENTO: Alertas de Stock Bajo
-- ========================================
DELIMITER $
CREATE PROCEDURE sp_low_stock_alerts(
  IN p_store_id BIGINT -- NULL para todas las tiendas
)
BEGIN
  SELECT 
    s.id AS store_id,
    s.name AS store_name,
    p.id AS product_id,
    p.code AS product_code,
    p.name AS product_name,
    c.name AS category_name,
    i.stock AS current_stock,
    i.min_stock AS minimum_stock,
    i.min_stock - i.stock AS units_needed,
    p.cost_price,
    (i.min_stock - i.stock) * p.cost_price AS restock_cost
  FROM inventory i
  INNER JOIN stores s ON i.store_id = s.id
  INNER JOIN products p ON i.product_id = p.id
  INNER JOIN categories c ON p.category_id = c.id
  WHERE i.stock <= i.min_stock
    AND s.is_active = 1
    AND p.is_active = 1
    AND (p_store_id IS NULL OR s.id = p_store_id)
  ORDER BY s.name, (i.min_stock - i.stock) DESC;
END$
DELIMITER ;


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


-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================