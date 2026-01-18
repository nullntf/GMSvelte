<script lang="ts">
	import favicon from '$lib/assets/favicon.svg';
	import { page } from '$app/stores';

	let { children, data } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<title>GMSvelte - Sistema de Gestión Multitienda</title>
</svelte:head>

{@render children()}
