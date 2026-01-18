import dotenv from 'dotenv';
import { getPool } from '../src/lib/server/db.js';

// Load environment variables
dotenv.config();

async function testConnection() {
	try {
		console.log('🔍 Verificando variables de entorno...');
		console.log('MYSQL_HOST:', process.env.MYSQL_HOST);
		console.log('MYSQL_USER:', process.env.MYSQL_USER);
		console.log('MYSQL_DATABASE:', process.env.MYSQL_DATABASE);

		console.log('🔌 Intentando conectar a MySQL...');
		const pool = getPool();
		const [rows] = await pool.query('SELECT 1 as test');

		console.log('✅ Conexión exitosa a MySQL');
		console.log('Resultado del test:', rows);

		// Test adicional: verificar que podemos acceder a la base de datos
		const [dbCheck] = await pool.query('SELECT DATABASE() as current_db');
		console.log('📊 Base de datos actual:', dbCheck[0].current_db);

		process.exit(0);
	} catch (error) {
		console.error('❌ Error de conexión:', error.message);
		console.error('Stack:', error.stack);
		process.exit(1);
	}
}

testConnection();
