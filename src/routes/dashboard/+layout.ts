import { redirect } from '@sveltejs/kit';

export const load = ({ locals }: any) => {
	// Verificar si el usuario está autenticado
	if (!locals.user) {
		throw redirect(302, '/login');
	}

	return {
		user: locals.user
	};
};
