import { getPool } from '$lib/server/db.js';
import { json, error } from '@sveltejs/kit';

export async function GET() {
	try {
		const pool = getPool();

		// Obtener estadísticas del dashboard
		const [rows] = await pool.query(`
      SELECT
        (SELECT COUNT(*) FROM stores WHERE is_active = 1) as total_stores,
        (SELECT COUNT(*) FROM products WHERE is_active = 1) as total_products,
        (SELECT COALESCE(SUM(stock * cost_price), 0) FROM inventory i JOIN products p ON i.product_id = p.id WHERE p.is_active = 1) as total_inventory_value,
        (SELECT COALESCE(SUM(total), 0) FROM sales WHERE status = 'completed' AND DATE(created_at) = CURDATE()) as total_sales_today,
        (SELECT COUNT(*) FROM inventory i JOIN products p ON i.product_id = p.id WHERE i.stock <= i.min_stock AND p.is_active = 1) as low_stock_alerts
    `);

		const dashboardStats = (rows as any[])[0];

		return json({
			total_stores: Number(dashboardStats.total_stores || 0),
			total_products: Number(dashboardStats.total_products || 0),
			total_inventory_value: Number(dashboardStats.total_inventory_value || 0),
			total_sales_today: Number(dashboardStats.total_sales_today || 0),
			low_stock_alerts: Number(dashboardStats.low_stock_alerts || 0)
		});
	} catch (err) {
		console.error('Dashboard stats error:', err);
		throw error(500, 'Error al cargar estadísticas del dashboard');
	}
}
