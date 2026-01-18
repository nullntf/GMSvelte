import type { Handle } from '@sveltejs/kit';
import { getPool } from '$lib/server/db.js';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'gmsvelte-secret-key';

export const handle: Handle = async ({ event, resolve }) => {
	// Obtener token de cookies
	const token = event.cookies.get('auth_token');

	if (token) {
		try {
			// Verificar token
			const decoded = jwt.verify(token, JWT_SECRET) as { userId: number };

			// Obtener datos completos del usuario desde BD
			const pool = getPool();
			const [rows] = await pool.query(
				`
        SELECT u.id, u.name, u.email, r.name as role_name,
               GROUP_CONCAT(p.name) as permissions
        FROM users u
        JOIN roles r ON u.role_id = r.id
        LEFT JOIN role_permission rp ON r.id = rp.role_id
        LEFT JOIN permissions p ON rp.permission_id = p.id
        WHERE u.id = ? AND u.is_active = 1
        GROUP BY u.id, u.name, u.email, r.name
      `,
				[decoded.userId]
			);

			const users = rows as any[];

			if (users.length > 0) {
				const user = users[0];
				event.locals.user = {
					id: user.id,
					name: user.name,
					email: user.email,
					role: user.role_name,
					permissions: user.permissions ? user.permissions.split(',') : []
				};
			}
		} catch (error) {
			// Token inválido, limpiar cookie
			event.cookies.set('auth_token', '', { maxAge: 0, path: '/' });
		}
	}

	return resolve(event);
};
