// Types for GMSvelte application
export interface User {
	id: number;
	name: string;
	email: string;
	role: string;
	permissions: string[];
}

export interface Store {
	id: number;
	code: string;
	name: string;
	location?: string;
	is_warehouse: boolean;
	is_active: boolean;
}

export interface Product {
	id: number;
	code: string;
	name: string;
	cost_price: number;
	sale_price: number;
	category_id: number;
	is_active: boolean;
}

export interface InventoryItem {
	store_id: number;
	product_id: number;
	stock: number;
	min_stock: number;
}

export interface Sale {
	id: number;
	sale_number: string;
	total: number;
	status: 'completed' | 'cancelled';
	created_at: string;
}

export interface DashboardStats {
	total_stores: number;
	total_products: number;
	total_inventory_value: number;
	total_sales_today: number;
	low_stock_alerts: number;
}
