-- Migration: 004_inventory_management_module
-- Created: 2025-01-18
-- Description: Módulo 3 - Gestión de Inventario (inventory, movements, transfers)

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
-- DATOS INICIALES - INVENTARIO EN BODEGA
-- ============================================================================

-- Insertar inventario inicial en bodega (100 unidades de cada producto)
INSERT INTO `inventory` (`store_id`, `product_id`, `stock`, `min_stock`, `created_by`, `created_at`, `updated_at`)
SELECT
  (SELECT id FROM stores WHERE is_warehouse = 1 LIMIT 1) as store_id,
  p.id as product_id,
  100 as stock,
  10 as min_stock,
  1 as created_by,
  NOW() as created_at,
  NOW() as updated_at
FROM products p;

-- Registrar movimientos de entrada inicial
INSERT INTO `inventory_movements` (
  `store_id`, `product_id`, `movement_type`, `quantity`,
  `previous_stock`, `new_stock`, `reference_type`, `notes`, `created_by`
)
SELECT
  (SELECT id FROM stores WHERE is_warehouse = 1 LIMIT 1) as store_id,
  p.id as product_id,
  'entry' as movement_type,
  100 as quantity,
  0 as previous_stock,
  100 as new_stock,
  'initial_stock' as reference_type,
  'Inventario inicial de bodega' as notes,
  1 as created_by
FROM products p;

-- ============================================================================
-- DATOS INICIALES - INVENTARIO EN TIENDAS (STOCK MÍNIMO)
-- ============================================================================

-- Insertar inventario inicial en tiendas (5 unidades de cada producto como stock base)
INSERT INTO `inventory` (`store_id`, `product_id`, `stock`, `min_stock`, `created_by`, `created_at`, `updated_at`)
SELECT
  s.id as store_id,
  p.id as product_id,
  5 as stock,
  2 as min_stock,
  1 as created_by,
  NOW() as created_at,
  NOW() as updated_at
FROM stores s
CROSS JOIN products p
WHERE s.is_warehouse = 0;

-- Registrar movimientos de entrada inicial en tiendas
INSERT INTO `inventory_movements` (
  `store_id`, `product_id`, `movement_type`, `quantity`,
  `previous_stock`, `new_stock`, `reference_type`, `notes`, `created_by`
)
SELECT
  s.id as store_id,
  p.id as product_id,
  'entry' as movement_type,
  5 as quantity,
  0 as previous_stock,
  5 as new_stock,
  'initial_stock' as reference_type,
  'Stock inicial de tienda' as notes,
  1 as created_by
FROM stores s
CROSS JOIN products p
WHERE s.is_warehouse = 0;

-- ============================================================================
-- FOREIGN KEYS
-- ============================================================================

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

-- ============================================================================
-- NOTA: Los triggers se implementarán en una migración separada
-- ============================================================================
-- Los triggers requieren ejecución individual por limitaciones del driver MySQL2
-- Se crearán en la migración 005_triggers_setup.sql