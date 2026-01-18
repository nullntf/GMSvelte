-- Migration: 008_expenses_module
-- Created: 2025-01-18
-- Description: Módulo 6 - Gastos (por tienda)

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
-- DATOS INICIALES - GASTOS DE EJEMPLO
-- ============================================================================

-- Gastos de Tienda Centro
INSERT INTO `expenses` (
  `expense_number`, `store_id`, `category`, `description`, `total_amount`,
  `expense_date`, `status`, `created_by`, `created_at`, `updated_at`
) VALUES
('GAS001001', 2, 'Servicios', 'Pago de luz mensual', 250.00, DATE_SUB(CURDATE(), INTERVAL 15 DAY), 'active', 1, NOW(), NOW()),
('GAS001002', 2, 'Suministros', 'Compra de bolsas plásticas', 45.00, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'active', 1, NOW(), NOW()),
('GAS001003', 2, 'Mantenimiento', 'Reparación de refrigerador', 180.00, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'active', 1, NOW(), NOW());

-- Gastos de Tienda Norte
INSERT INTO `expenses` (
  `expense_number`, `store_id`, `category`, `description`, `total_amount`,
  `expense_date`, `status`, `created_by`, `created_at`, `updated_at`
) VALUES
('GAS002001', 3, 'Servicios', 'Internet mensual', 120.00, DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'active', 1, NOW(), NOW()),
('GAS002002', 3, 'Suministros', 'Limpieza de vidrios', 85.00, DATE_SUB(CURDATE(), INTERVAL 8 DAY), 'active', 1, NOW(), NOW());

-- Gastos de Tienda Sur
INSERT INTO `expenses` (
  `expense_number`, `store_id`, `category`, `description`, `total_amount`,
  `expense_date`, `status`, `created_by`, `created_at`, `updated_at`
) VALUES
('GAS003001', 4, 'Servicios', 'Agua potable', 95.00, DATE_SUB(CURDATE(), INTERVAL 20 DAY), 'active', 1, NOW(), NOW()),
('GAS003002', 4, 'Mantenimiento', 'Cambio de cerradura', 65.00, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'active', 1, NOW(), NOW());

-- Gasto cancelado de ejemplo
INSERT INTO `expenses` (
  `expense_number`, `store_id`, `category`, `description`, `total_amount`,
  `expense_date`, `status`, `cancelled_by`, `cancelled_at`, `cancellation_reason`,
  `created_by`, `created_at`, `updated_at`
) VALUES
('GAS001004', 2, 'Suministros', 'Compra de carteles publicitarios', 150.00,
 DATE_SUB(CURDATE(), INTERVAL 7 DAY), 'cancelled', 1, NOW(), 'Presupuesto insuficiente',
 1, DATE_SUB(NOW(), INTERVAL 8 DAY), NOW());

-- ============================================================================
-- FOREIGN KEYS
-- ============================================================================

ALTER TABLE `expenses`
  ADD CONSTRAINT `expenses_store_id_foreign`
    FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`),
  ADD CONSTRAINT `expenses_created_by_foreign`
    FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `expenses_cancelled_by_foreign`
    FOREIGN KEY (`cancelled_by`) REFERENCES `users` (`id`);