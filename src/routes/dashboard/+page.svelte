<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { DashboardStats } from '$lib/types';

	let stats: DashboardStats = $state({
		total_stores: 0,
		total_products: 0,
		total_inventory_value: 0,
		total_sales_today: 0,
		low_stock_alerts: 0
	});

	let loading = $state(true);

	onMount(async () => {
		// Verificar autenticación
		if (!$page.data?.user) {
			goto('/login');
			return;
		}

		// Cargar estadísticas del dashboard
		await loadDashboardStats();
	});

	async function loadDashboardStats() {
		try {
			const response = await fetch('/api/dashboard/stats');
			if (response.ok) {
				stats = await response.json();
			}
		} catch (error) {
			console.error('Error loading dashboard stats:', error);
		} finally {
			loading = false;
		}
	}

	async function logout() {
		await fetch('/api/auth/logout', { method: 'POST' });
		goto('/login');
	}

	function hasPermission(permission: string): boolean {
		return $page.data?.user?.permissions?.includes(permission) ?? false;
	}

	function canAccessModule(module: string): boolean {
		const user = $page.data?.user;
		if (!user) return false;

		// Admin tiene acceso a todo
		if (user.role === 'admin') return true;

		// Verificar permisos específicos del módulo
		switch (module) {
			case 'inventory':
				return hasPermission('inventory.view');
			case 'sales':
				return hasPermission('sales.view') || hasPermission('sales.create');
			case 'users':
				return hasPermission('users.view');
			case 'reports':
				return hasPermission('reports.view');
			default:
				return false;
		}
	}
</script>

<main class="min-h-screen bg-gray-50">
	<!-- Header -->
	<header class="bg-white shadow-sm border-b">
		<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
			<div class="flex justify-between items-center py-4">
				<div class="flex items-center">
					<h1 class="text-2xl font-bold text-gray-900">GMSvelte</h1>
					<span class="ml-4 text-sm text-gray-500">Dashboard</span>
				</div>

				<div class="flex items-center space-x-4">
					{#if $page.data?.user}
						<span class="text-sm text-gray-700">
							{$page.data.user.name} ({$page.data.user.role})
						</span>
						<button
							on:click={logout}
							class="bg-red-600 text-white px-3 py-1 rounded text-sm hover:bg-red-700 transition-colors"
						>
							Cerrar Sesión
						</button>
					{/if}
				</div>
			</div>
		</div>
	</header>

	<!-- Dashboard Content -->
	<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
		{#if loading}
			<div class="flex justify-center items-center h-64">
				<div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
			</div>
		{:else}
			<!-- Welcome Section -->
			<div class="mb-8">
				<h2 class="text-3xl font-bold text-gray-900 mb-2">
					¡Bienvenido, {$page.data?.user?.name}!
				</h2>
				<p class="text-gray-600">
					Sistema de Gestión Multitienda - Rol: {$page.data?.user?.role}
				</p>
			</div>

			<!-- Stats Cards -->
			<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
				<div class="bg-white rounded-lg shadow p-6">
					<div class="flex items-center">
						<div class="p-2 bg-blue-500 rounded-lg">
							<svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"
								></path>
							</svg>
						</div>
						<div class="ml-4">
							<p class="text-sm font-medium text-gray-600">Total Tiendas</p>
							<p class="text-2xl font-bold text-gray-900">{stats.total_stores}</p>
						</div>
					</div>
				</div>

				<div class="bg-white rounded-lg shadow p-6">
					<div class="flex items-center">
						<div class="p-2 bg-green-500 rounded-lg">
							<svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
								></path>
							</svg>
						</div>
						<div class="ml-4">
							<p class="text-sm font-medium text-gray-600">Total Productos</p>
							<p class="text-2xl font-bold text-gray-900">{stats.total_products}</p>
						</div>
					</div>
				</div>

				<div class="bg-white rounded-lg shadow p-6">
					<div class="flex items-center">
						<div class="p-2 bg-yellow-500 rounded-lg">
							<svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"
								></path>
							</svg>
						</div>
						<div class="ml-4">
							<p class="text-sm font-medium text-gray-600">Valor Inventario</p>
							<p class="text-2xl font-bold text-gray-900">
								${stats.total_inventory_value.toLocaleString()}
							</p>
						</div>
					</div>
				</div>

				<div class="bg-white rounded-lg shadow p-6">
					<div class="flex items-center">
						<div class="p-2 bg-red-500 rounded-lg">
							<svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"
								></path>
							</svg>
						</div>
						<div class="ml-4">
							<p class="text-sm font-medium text-gray-600">Alertas Stock Bajo</p>
							<p class="text-2xl font-bold text-gray-900">{stats.low_stock_alerts}</p>
						</div>
					</div>
				</div>
			</div>

			<!-- Quick Actions -->
			<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
				{#if canAccessModule('inventory')}
					<div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow">
						<div class="flex items-center mb-4">
							<div class="p-2 bg-blue-100 rounded-lg">
								<svg
									class="w-6 h-6 text-blue-600"
									fill="none"
									stroke="currentColor"
									viewBox="0 0 24 24"
								>
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										stroke-width="2"
										d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
									></path>
								</svg>
							</div>
							<h3 class="ml-3 text-lg font-medium text-gray-900">Inventario</h3>
						</div>
						<p class="text-gray-600 mb-4">Gestionar productos, stock y movimientos</p>
						<a href="/inventory" class="text-blue-600 hover:text-blue-800 font-medium">
							Ver Inventario →
						</a>
					</div>
				{/if}

				{#if canAccessModule('sales')}
					<div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow">
						<div class="flex items-center mb-4">
							<div class="p-2 bg-green-100 rounded-lg">
								<svg
									class="w-6 h-6 text-green-600"
									fill="none"
									stroke="currentColor"
									viewBox="0 0 24 24"
								>
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										stroke-width="2"
										d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"
									></path>
								</svg>
							</div>
							<h3 class="ml-3 text-lg font-medium text-gray-900">Ventas</h3>
						</div>
						<p class="text-gray-600 mb-4">Registrar ventas y gestionar transacciones</p>
						<a href="/sales" class="text-green-600 hover:text-green-800 font-medium">
							Gestionar Ventas →
						</a>
					</div>
				{/if}

				{#if canAccessModule('users')}
					<div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow">
						<div class="flex items-center mb-4">
							<div class="p-2 bg-purple-100 rounded-lg">
								<svg
									class="w-6 h-6 text-purple-600"
									fill="none"
									stroke="currentColor"
									viewBox="0 0 24 24"
								>
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										stroke-width="2"
										d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"
									></path>
								</svg>
							</div>
							<h3 class="ml-3 text-lg font-medium text-gray-900">Usuarios</h3>
						</div>
						<p class="text-gray-600 mb-4">Gestionar usuarios y permisos del sistema</p>
						<a href="/users" class="text-purple-600 hover:text-purple-800 font-medium">
							Gestionar Usuarios →
						</a>
					</div>
				{/if}

				{#if canAccessModule('reports')}
					<div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow">
						<div class="flex items-center mb-4">
							<div class="p-2 bg-orange-100 rounded-lg">
								<svg
									class="w-6 h-6 text-orange-600"
									fill="none"
									stroke="currentColor"
									viewBox="0 0 24 24"
								>
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										stroke-width="2"
										d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
									></path>
								</svg>
							</div>
							<h3 class="ml-3 text-lg font-medium text-gray-900">Reportes</h3>
						</div>
						<p class="text-gray-600 mb-4">Ver reportes y análisis del negocio</p>
						<a href="/reports" class="text-orange-600 hover:text-orange-800 font-medium">
							Ver Reportes →
						</a>
					</div>
				{/if}

				<!-- Additional modules based on permissions -->
				{#if hasPermission('cash_registers.open')}
					<div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow">
						<div class="flex items-center mb-4">
							<div class="p-2 bg-cyan-100 rounded-lg">
								<svg
									class="w-6 h-6 text-cyan-600"
									fill="none"
									stroke="currentColor"
									viewBox="0 0 24 24"
								>
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										stroke-width="2"
										d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"
									></path>
								</svg>
							</div>
							<h3 class="ml-3 text-lg font-medium text-gray-900">Cajas Registradoras</h3>
						</div>
						<p class="text-gray-600 mb-4">Control de efectivo y cierre de cajas</p>
						<a href="/cash-registers" class="text-cyan-600 hover:text-cyan-800 font-medium">
							Gestionar Cajas →
						</a>
					</div>
				{/if}
			</div>
		{/if}
	</div>
</main>
