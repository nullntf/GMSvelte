import { json, type RequestEvent } from '@sveltejs/kit';

export async function POST({ cookies }: RequestEvent) {
	// Limpiar cookie de autenticación
	cookies.set('auth_token', '', {
		path: '/',
		httpOnly: true,
		secure: false,
		maxAge: 0
	});

	return json({ success: true });
}
