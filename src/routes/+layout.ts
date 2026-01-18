export const load = ({ locals }: any) => {
	return {
		user: locals.user || null
	};
};
