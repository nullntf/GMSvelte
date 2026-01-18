-- Migration: 003_master_configuration_module
-- Created: 2025-01-18
-- Description: Módulo 2 - Configuración Maestra (stores, categories, products)

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
-- DATOS INICIALES - BODEGA PRINCIPAL
-- ============================================================================

INSERT INTO `stores` (`code`, `name`, `location`, `is_warehouse`, `is_active`, `created_by`, `created_at`, `updated_at`) VALUES
('BOD001', 'Bodega Central', 'Centro de Distribución Principal', 1, 1, 1, NOW(), NOW());

-- ============================================================================
-- DATOS INICIALES - TIENDAS DE EJEMPLO
-- ============================================================================

INSERT INTO `stores` (`code`, `name`, `location`, `is_warehouse`, `is_active`, `created_by`, `created_at`, `updated_at`) VALUES
('TIE001', 'Tienda Centro', 'Centro Histórico', 0, 1, 1, NOW(), NOW()),
('TIE002', 'Tienda Norte', 'Zona Norte', 0, 1, 1, NOW(), NOW()),
('TIE003', 'Tienda Sur', 'Zona Sur', 0, 1, 1, NOW(), NOW());

-- ============================================================================
-- DATOS INICIALES - CATEGORÍAS BASE
-- ============================================================================

INSERT INTO `categories` (`name`, `is_active`, `created_by`, `created_at`, `updated_at`) VALUES
('Alimentos', 1, 1, NOW(), NOW()),
('Bebidas', 1, 1, NOW(), NOW()),
('Limpieza', 1, 1, NOW(), NOW()),
('Electrónicos', 1, 1, NOW(), NOW()),
('Ropa', 1, 1, NOW(), NOW()),
('Otros', 1, 1, NOW(), NOW());

-- ============================================================================
-- DATOS INICIALES - PRODUCTOS DE EJEMPLO
-- ============================================================================

INSERT INTO `products` (`category_id`, `code`, `name`, `cost_price`, `sale_price`, `is_active`, `created_by`, `created_at`, `updated_at`) VALUES
-- Alimentos
(1, 'ALIM001', 'Arroz 1kg', 25.00, 35.00, 1, 1, NOW(), NOW()),
(1, 'ALIM002', 'Azúcar 1kg', 18.00, 25.00, 1, 1, NOW(), NOW()),
(1, 'ALIM003', 'Café 500g', 45.00, 65.00, 1, 1, NOW(), NOW()),

-- Bebidas
(2, 'BEB001', 'Agua Mineral 1L', 8.00, 12.00, 1, 1, NOW(), NOW()),
(2, 'BEB002', 'Refresco 2L', 15.00, 22.00, 1, 1, NOW(), NOW()),
(2, 'BEB003', 'Jugo Natural 500ml', 12.00, 18.00, 1, 1, NOW(), NOW()),

-- Limpieza
(3, 'LIM001', 'Detergente 1L', 28.00, 40.00, 1, 1, NOW(), NOW()),
(3, 'LIM002', 'Jabón en Polvo 1kg', 35.00, 50.00, 1, 1, NOW(), NOW()),
(3, 'LIM003', 'Desinfectante 500ml', 22.00, 32.00, 1, 1, NOW(), NOW()),

-- Electrónicos
(4, 'ELEC001', 'Cable USB 2m', 15.00, 25.00, 1, 1, NOW(), NOW()),
(4, 'ELEC002', 'Audífonos Básicos', 45.00, 80.00, 1, 1, NOW(), NOW()),
(4, 'ELEC003', 'Cargador Móvil', 35.00, 60.00, 1, 1, NOW(), NOW()),

-- Ropa
(5, 'ROP001', 'Camiseta Básica', 25.00, 45.00, 1, 1, NOW(), NOW()),
(5, 'ROP002', 'Pantalón Jeans', 80.00, 150.00, 1, 1, NOW(), NOW()),
(5, 'ROP003', 'Zapatos Deportivos', 120.00, 200.00, 1, 1, NOW(), NOW());

-- ============================================================================
-- FOREIGN KEYS
-- ============================================================================

ALTER TABLE `products`
  ADD CONSTRAINT `products_category_id_foreign`
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`);

-- ============================================================================
-- ACTUALIZAR USUARIOS PARA ASIGNAR TIENDAS A VENDEDORES
-- ============================================================================

-- Asignar tienda a vendedores (dejamos admin y bodega sin tienda asignada)
UPDATE `users`
SET `store_id` = (SELECT id FROM `stores` WHERE code = 'TIE001' LIMIT 1)
WHERE `role_id` = (SELECT id FROM `roles` WHERE name = 'vendedor' LIMIT 1);