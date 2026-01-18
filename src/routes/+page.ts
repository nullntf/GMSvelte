import { redirect } from '@sveltejs/kit';

export const load = ({ locals }: any) => {
	// Si el usuario está autenticado, redirigir al dashboard
	if (locals.user) {
		throw redirect(302, '/dashboard');
	}

	// Si no está autenticado, redirigir al login
	throw redirect(302, '/login');
};
