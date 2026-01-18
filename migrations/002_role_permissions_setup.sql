-- Migration: 002_role_permissions_setup
-- Created: 2025-01-17
-- Description: Configuración de permisos por rol

-- Tabla: role_permission
CREATE TABLE `role_permission` (
  `role_id` bigint(20) UNSIGNED NOT NULL,
  `permission_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`role_id`, `permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- ASIGNACIÓN DE PERMISOS POR ROL
-- ============================================================================

-- Admin: TODOS los permisos
INSERT INTO `role_permission` (`role_id`, `permission_id`, `created_at`)
SELECT r.id, p.id, NOW()
FROM `roles` r CROSS JOIN `permissions` p
WHERE r.name = 'admin';

-- Bodega: permisos específicos para gestión
INSERT INTO `role_permission` (`role_id`, `permission_id`, `created_at`)
SELECT r.id, p.id, NOW()
FROM `roles` r, `permissions` p
WHERE r.name = 'bodega'
  AND p.name IN ('products.view', 'sales.view');

-- Vendedor: permisos limitados para tienda
INSERT INTO `role_permission` (`role_id`, `permission_id`, `created_at`)
SELECT r.id, p.id, NOW()
FROM `roles` r, `permissions` p
WHERE r.name = 'vendedor'
  AND p.name IN ('sales.view', 'sales.create', 'products.view');

-- ============================================================================
-- FOREIGN KEYS
-- ============================================================================

ALTER TABLE `role_permission`
  ADD CONSTRAINT `role_permission_role_id_foreign`
    FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `role_permission_permission_id_foreign`
    FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE;

ALTER TABLE `users`
  ADD CONSTRAINT `users_role_id_foreign`
    FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`);