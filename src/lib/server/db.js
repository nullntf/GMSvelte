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
			host: process.env.MYSQL_HOST || 'localhost',
			user: process.env.MYSQL_USER || 'root',
			password: process.env.MYSQL_PASSWORD || '',
			database: process.env.MYSQL_DATABASE || 'gmsveltedb',
			connectionLimit: 10,
			queueLimit: 0,
			multipleStatements: true // Permitir múltiples statements
		});
	}
	return pool;
}
