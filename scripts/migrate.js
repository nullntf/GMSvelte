import dotenv from 'dotenv';
import { getPool } from '../src/lib/server/db.js';
import fs from 'fs';
import path from 'path';

// Load environment variables
dotenv.config();

const migrationsDir = './migrations';

async function runMigrations() {
	try {
		const pool = getPool();

		// Crear tabla de migraciones si no existe
		await pool.query(`
      CREATE TABLE IF NOT EXISTS migrations (
        id VARCHAR(255) PRIMARY KEY,
        executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

		console.log('📋 Sistema de migraciones inicializado');

		// Leer archivos de migración
		if (!fs.existsSync(migrationsDir)) {
			fs.mkdirSync(migrationsDir);
			console.log('📁 Directorio migrations creado');
			return;
		}

		const files = fs
			.readdirSync(migrationsDir)
			.filter((f) => f.endsWith('.sql'))
			.sort();

		if (files.length === 0) {
			console.log('📭 No hay archivos de migración pendientes');
			return;
		}

		console.log(`🔍 Encontrados ${files.length} archivos de migración`);

		for (const file of files) {
			const migrationId = path.parse(file).name;

			// Verificar si ya se ejecutó
			const [existing] = await pool.query('SELECT id FROM migrations WHERE id = ?', [migrationId]);

			if (existing.length === 0) {
				console.log(`⚡ Ejecutando migración: ${file}`);

				const sqlPath = path.join(migrationsDir, file);
				const sql = fs.readFileSync(sqlPath, 'utf8');

				// Verificar si contiene triggers (necesitan ejecución individual)
				if (sql.includes('CREATE TRIGGER')) {
					// Ejecutar statements individuales para triggers
					const statements = sql
						.split(';')
						.map((stmt) => stmt.trim())
						.filter((stmt) => stmt.length > 0 && !stmt.startsWith('--'));

					for (const statement of statements) {
						if (statement.trim()) {
							await pool.query(statement);
						}
					}
				} else {
					// Ejecutar SQL completo para statements normales
					await pool.query(sql);
				}

				// Registrar como ejecutada
				await pool.query('INSERT INTO migrations (id) VALUES (?)', [migrationId]);

				console.log(`✅ Migración completada: ${file}`);
			} else {
				console.log(`⏭️  Migración ya ejecutada: ${file}`);
			}
		}

		console.log('🎉 Todas las migraciones ejecutadas exitosamente');
	} catch (error) {
		console.error('❌ Error en migraciones:', error.message);
		console.error('Stack:', error.stack);
		process.exit(1);
	}
}

runMigrations();
