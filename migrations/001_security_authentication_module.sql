-- Migration: 001_security_authentication_module
-- Created: 2025-01-17
-- Description: Módulo 1 - Seguridad y Autenticación (version simplificada)

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
  UNIQUE KEY `permissions_name_unique` (`name`)
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
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- DATOS INICIALES - ROLES BASE
-- ============================================================================

INSERT INTO `roles` (`name`, `display_name`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
('admin', 'Administrador', 'Control total del sistema', 1, NOW(), NOW()),
('bodega', 'Personal de Bodega', 'Gestión de inventario central', 1, NOW(), NOW()),
('vendedor', 'Vendedor', 'Operaciones en tienda específica', 1, NOW(), NOW());

-- ============================================================================
-- DATOS INICIALES - PERMISOS BASE
-- ============================================================================

INSERT INTO `permissions` (`name`, `display_name`, `module`, `description`, `created_at`, `updated_at`) VALUES
('users.view', 'Ver Usuarios', 'users', 'Permite ver lista de usuarios', NOW(), NOW()),
('users.create', 'Crear Usuarios', 'users', 'Permite crear nuevos usuarios', NOW(), NOW()),
('products.view', 'Ver Productos', 'products', 'Permite ver catálogo de productos', NOW(), NOW()),
('sales.view', 'Ver Ventas', 'sales', 'Permite ver historial de ventas', NOW(), NOW()),
('sales.create', 'Crear Ventas', 'sales', 'Permite registrar nuevas ventas', NOW(), NOW());

-- ============================================================================
-- USUARIO ADMINISTRADOR INICIAL
-- ============================================================================

INSERT INTO `users` (`role_id`, `name`, `email`, `password`, `is_active`, `email_verified_at`, `created_at`, `updated_at`) VALUES
(1, 'Administrador Sistema', 'admin@gmsvelte.com', '$2b$10$dummy.hash.for.testing.purposes.only', 1, NOW(), NOW(), NOW());