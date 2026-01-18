-- Migration: 006_cash_register_module
-- Created: 2025-01-18
-- Description: Módulo 4 - Caja Registradora (por tienda)

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
-- DATOS INICIALES - CAJA REGISTRADORA POR TIENDA
-- ============================================================================

-- Crear caja registradora inicial para cada tienda (estado: cerrada)
INSERT INTO `cash_registers` (`store_id`, `opened_by`, `opened_at`, `opening_balance`, `status`, `notes`)
SELECT
  s.id as store_id,
  1 as opened_by, -- Admin
  DATE_SUB(NOW(), INTERVAL 1 DAY) as opened_at, -- Ayer
  500.00 as opening_balance, -- Balance inicial de $500
  'closed' as status,
  'Caja inicial de tienda' as notes
FROM stores s
WHERE s.is_warehouse = 0; -- Solo tiendas, no bodega

-- ============================================================================
-- FOREIGN KEYS
-- ============================================================================

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