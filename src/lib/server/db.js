import mysql from 'mysql2/promise';

/** @type {import('mysql2/promise').Pool | null} */
let pool = null;

/**
 * Singleton connection pool for MySQL
 * @returns {import('mysql2/promise').Pool}
 */
export function getPool() {
	if (!pool) {
		pool = mysql.createPool({
			host: '127.0.0.1', // Usar IP explícita para evitar socket issues
			port: 3306, // Puerto TCP explícito
			user: 'root',
			password: '5378',
			database: 'gmsveltedb',
			connectionLimit: 10,
			queueLimit: 0,
			multipleStatements: true // Permitir múltiples statements
		});
	}
	return pool;
}
