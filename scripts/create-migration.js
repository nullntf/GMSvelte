#!/usr/bin/env node

import fs from 'fs';
import path from 'path';

const migrationsDir = './migrations';

function createMigration(name) {
	// Crear directorio si no existe
	if (!fs.existsSync(migrationsDir)) {
		fs.mkdirSync(migrationsDir);
		console.log('📁 Directorio migrations creado');
	}

	// Generar timestamp y nombre del archivo
	const timestamp = new Date().toISOString().slice(0, 19).replace(/[-:]/g, '').replace('T', '_');
	const fileName = `${timestamp}_${name}.sql`;
	const filePath = path.join(migrationsDir, fileName);

	// Crear archivo con template básico
	const template = `-- Migration: ${name}
-- Created: ${new Date().toISOString()}

-- Add your SQL statements here

`;

	fs.writeFileSync(filePath, template);

	console.log(`✅ Migración creada: ${fileName}`);
	console.log(`📝 Edita el archivo: ${filePath}`);
}

// Obtener nombre de la migración desde argumentos
const migrationName = process.argv[2];

if (!migrationName) {
	console.error('❌ Debes proporcionar un nombre para la migración');
	console.log('Uso: npm run db:create <migration_name>');
	console.log('Ejemplo: npm run db:create add_users_table');
	process.exit(1);
}

createMigration(migrationName);
