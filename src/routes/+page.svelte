<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';

	onMount(() => {
		// Redirigir basado en el estado de autenticación
		if ($page.data?.user) {
			// Usuario autenticado → dashboard
			goto('/dashboard');
		} else {
			// Usuario no autenticado → login
			goto('/login');
		}
	});
</script>

<main
	class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4"
>
	<div class="max-w-md w-full bg-white rounded-lg shadow-lg p-8">
		<div class="text-center">
			<div
				class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"
			></div>
			<h2 class="text-xl font-semibold text-gray-900 mb-2">GMSvelte</h2>
			<p class="text-gray-600">Redirigiendo...</p>
		</div>
	</div>
</main>
