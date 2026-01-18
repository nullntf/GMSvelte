-- Migration: 007_sales_module
-- Created: 2025-01-18
-- Description: Módulo 5 - Sistema de Ventas (por tienda)

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
-- DATOS INICIALES - VENTAS DE EJEMPLO
-- ============================================================================

-- Insertar algunas ventas de ejemplo para demostrar funcionalidad
-- Venta 1: Tienda Centro - Efectivo
INSERT INTO `sales` (
  `sale_number`, `store_id`, `cash_register_id`, `seller_id`,
  `subtotal`, `tax`, `discount`, `total`, `payment_method`, `status`, `created_at`
) VALUES (
  'VTA001001', 2, 1, 2,  -- Tienda Centro, Caja 1, Vendedor Juan
  85.00, 0.00, 5.00, 80.00, 'cash', 'completed', DATE_SUB(NOW(), INTERVAL 2 HOUR)
);

SET @sale_id_1 = LAST_INSERT_ID();

-- Items de la venta 1
INSERT INTO `sale_items` (`sale_id`, `product_id`, `quantity`, `unit_price`, `subtotal`) VALUES
(@sale_id_1, 1, 2, 35.00, 70.00),  -- 2 × Arroz 1kg = $70
(@sale_id_1, 8, 1, 25.00, 25.00);  -- 1 × Cable USB = $25
                                        -- Subtotal: $95, Descuento: $5, Total: $90? Wait, let me fix this
-- Wait, let me correct the sale total
UPDATE `sales` SET `total` = 90.00 WHERE `id` = @sale_id_1;

-- Venta 2: Tienda Norte - Tarjeta
INSERT INTO `sales` (
  `sale_number`, `store_id`, `cash_register_id`, `seller_id`,
  `subtotal`, `tax`, `discount`, `total`, `payment_method`, `status`, `created_at`
) VALUES (
  'VTA002001', 3, 2, 2,  -- Tienda Norte, Caja 2, Vendedor Juan (simulando multi-tienda)
  120.00, 0.00, 0.00, 120.00, 'card', 'completed', DATE_SUB(NOW(), INTERVAL 1 HOUR)
);

SET @sale_id_2 = LAST_INSERT_ID();

-- Items de la venta 2
INSERT INTO `sale_items` (`sale_id`, `product_id`, `quantity`, `unit_price`, `subtotal`) VALUES
(@sale_id_2, 12, 1, 80.00, 80.00),   -- 1 × Pantalón Jeans = $80
(@sale_id_2, 11, 1, 40.00, 40.00);   -- 1 × Zapatos Deportivos = $40

-- Venta 3: Tienda Sur - Mixta (parcialmente cancelada)
INSERT INTO `sales` (
  `sale_number`, `store_id`, `cash_register_id`, `seller_id`,
  `subtotal`, `tax`, `discount`, `total`, `payment_method`, `status`, `created_at`,
  `cancelled_by`, `cancelled_at`, `cancellation_reason`
) VALUES (
  'VTA003001', 4, 3, 2,  -- Tienda Sur, Caja 3, Vendedor Juan
  45.00, 0.00, 0.00, 45.00, 'mixed', 'cancelled', DATE_SUB(NOW(), INTERVAL 30 MINUTE),
  1, NOW(), 'Cliente cambió de opinión'
);

SET @sale_id_3 = LAST_INSERT_ID();

-- Items de la venta 3 (cancelada)
INSERT INTO `sale_items` (`sale_id`, `product_id`, `quantity`, `unit_price`, `subtotal`) VALUES
(@sale_id_3, 4, 1, 12.00, 12.00),   -- 1 × Agua Mineral = $12
(@sale_id_3, 6, 1, 32.00, 32.00);   -- 1 × Desinfectante = $32

-- ============================================================================
-- REGISTRAR MOVIMIENTOS DE INVENTARIO PARA LAS VENTAS
-- ============================================================================

-- Movimientos para venta 1 (completada)
INSERT INTO `inventory_movements` (
  `store_id`, `product_id`, `movement_type`, `quantity`,
  `previous_stock`, `new_stock`, `reference_type`, `reference_id`, `created_by`
) VALUES
(2, 1, 'sale', -2, 5, 3, 'sales', @sale_id_1, 2),  -- Arroz: 5→3
(2, 8, 'sale', -1, 5, 4, 'sales', @sale_id_1, 2);  -- Cable USB: 5→4

-- Movimientos para venta 2 (completada)
INSERT INTO `inventory_movements` (
  `store_id`, `product_id`, `movement_type`, `quantity`,
  `previous_stock`, `new_stock`, `reference_type`, `reference_id`, `created_by`
) VALUES
(3, 12, 'sale', -1, 5, 4, 'sales', @sale_id_2, 2),  -- Pantalón: 5→4
(3, 11, 'sale', -1, 5, 4, 'sales', @sale_id_2, 2);  -- Zapatos: 5→4

-- Nota: No registramos movimientos para venta 3 porque fue cancelada

-- ============================================================================
-- FOREIGN KEYS
-- ============================================================================

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