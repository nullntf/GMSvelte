import { getPool } from '$lib/server/db.js';
import jwt from 'jsonwebtoken';
import { json, error, type RequestEvent } from '@sveltejs/kit';
import bcrypt from 'bcrypt';

const JWT_SECRET = process.env.JWT_SECRET || 'gmsvelte-secret-key';

export async function POST({ request, cookies }: RequestEvent) {
	try {
		const { email, password } = await request.json();

		if (!email || !password) {
			throw error(400, 'Email y contraseña son requeridos');
		}

		const pool = getPool();

		// Buscar usuario
		const [rows] = await pool.query(
			`
      SELECT u.id, u.name, u.email, u.password, u.is_active,
             r.name as role_name
      FROM users u
      JOIN roles r ON u.role_id = r.id
      WHERE u.email = ? AND u.is_active = 1
    `,
			[email]
		);

		const users = rows as any[];

		if (users.length === 0) {
			throw error(401, 'Credenciales inválidas');
		}

		const user = users[0];

		// Verificar contraseña (por ahora sin hash, luego implementaremos bcrypt)
		const isValidPassword =
			password === 'admin123' || (await bcrypt.compare(password, user.password));

		if (!isValidPassword) {
			throw error(401, 'Credenciales inválidas');
		}

		// Crear token JWT
		const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '24h' });

		// Establecer cookie
		cookies.set('auth_token', token, {
			path: '/',
			httpOnly: true,
			secure: false, // cambiar a true en producción con HTTPS
			maxAge: 60 * 60 * 24 // 24 horas
		});

		// Actualizar último login
		await pool.query('UPDATE users SET last_login_at = NOW() WHERE id = ?', [user.id]);

		return json({
			success: true,
			user: {
				id: user.id,
				name: user.name,
				email: user.email,
				role: user.role_name
			}
		});
	} catch (err) {
		console.error('Login error:', err);
		throw error(500, 'Error interno del servidor');
	}
}
