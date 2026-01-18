# AI Agent Instructions for GMSvelte Development

## 📋 Project Overview
This is a **monolithic SvelteKit application** for multi-store management (inventory, sales, stock, cash registers, expenses). Built for efficiency and minimal resource consumption on Railway.

## 🎯 Core Development Principles

### Architecture Rules
- ✅ **Monolithic architecture** - Everything in one SvelteKit project
- ✅ **No REST API** - Use SvelteKit's built-in `+page.server.js` and form actions
- ✅ **Server-side rendering (SSR)** - Default SvelteKit behavior
- ✅ **Progressive enhancement** - Forms work without JavaScript
- ❌ **NO separate API layer** - Direct database access in server files
- ❌ **NO client-side data fetching** - Use `load` functions instead
- ❌ **NO external API calls** unless absolutely necessary

### File Structure Convention
```
src/routes/
  productos/
    +page.svelte          # UI component
    +page.server.js       # Server logic (load + actions)
  ventas/
    +page.svelte
    +page.server.js
```

**NEVER create:**
- `src/routes/api/` folders
- Separate API endpoints
- Client-side fetch() calls to `/api/*`

---

## 🔥 CRITICAL PERFORMANCE OPTIMIZATIONS

### 1. Connection Pooling (MANDATORY)
**ALWAYS use a singleton connection pool. NEVER create new connections in routes.**

**✅ CORRECT Pattern:**
```javascript
// src/lib/server/db.js
import mysql from 'mysql2/promise';

let pool;

export function getPool() {
  if (!pool) {
    pool = mysql.createPool({
      host: process.env.MYSQL_HOST,
      user: process.env.MYSQL_USER,
      password: process.env.MYSQL_PASSWORD,
      database: process.env.MYSQL_DATABASE,
      waitForConnections: true,
      connectionLimit: 10,
      idleTimeoutMillis: 30000,
      queueLimit: 0
    });
  }
  return pool;
}

// Usage in routes:
// +page.server.js
import { getPool } from '$lib/server/db';

export async function load() {
  const pool = getPool(); // Reuses existing pool
  const [rows] = await pool.query('SELECT * FROM productos LIMIT 50');
  return { productos: rows };
}
```

**❌ WRONG - NEVER DO THIS:**
```javascript
// Creating new connection on every request
export async function load() {
  const pool = mysql.createPool({...}); // ❌ Memory leak!
  // ...
}
```

### 2. Database Indexes (MANDATORY)
**ALWAYS create indexes for columns used in WHERE, JOIN, ORDER BY clauses.**

```sql
-- For productos table
CREATE INDEX idx_productos_tienda ON productos(tienda_id);
CREATE INDEX idx_productos_nombre ON productos(nombre);

-- For ventas table
CREATE INDEX idx_ventas_fecha ON ventas(fecha);
CREATE INDEX idx_ventas_tienda ON ventas(tienda_id);
CREATE INDEX idx_ventas_usuario ON ventas(usuario_id);

-- For stock table
CREATE INDEX idx_stock_producto ON stock(producto_id);
CREATE INDEX idx_stock_tienda ON stock(tienda_id);

-- Composite indexes for common queries
CREATE INDEX idx_ventas_tienda_fecha ON ventas(tienda_id, fecha);
```

**When creating new tables, ALWAYS suggest appropriate indexes.**

### 3. Pagination (MANDATORY)
**NEVER load all records. ALWAYS use LIMIT and OFFSET.**

**✅ CORRECT:**
```javascript
export async function load({ url }) {
  const page = parseInt(url.searchParams.get('page') || '1');
  const limit = 50;
  const offset = (page - 1) * limit;
  
  const pool = getPool();
  const [rows] = await pool.query(
    'SELECT * FROM productos LIMIT ? OFFSET ?',
    [limit, offset]
  );
  
  return { productos: rows, page };
}
```

**❌ WRONG:**
```javascript
const [rows] = await pool.query('SELECT * FROM productos'); // ❌ Can load 10k+ records
```

### 4. Avoid N+1 Queries (MANDATORY)
**ALWAYS use JOINs instead of loops with queries.**

**✅ CORRECT - Single query with JOIN:**
```javascript
export async function load() {
  const pool = getPool();
  const [rows] = await pool.query(`
    SELECT 
      v.*,
      p.nombre as producto_nombre,
      p.precio as producto_precio,
      u.nombre as usuario_nombre
    FROM ventas v
    LEFT JOIN productos p ON p.id = v.producto_id
    LEFT JOIN usuarios u ON u.id = v.usuario_id
    LIMIT 100
  `);
  
  return { ventas: rows };
}
```

**❌ WRONG - N+1 problem:**
```javascript
const [ventas] = await pool.query('SELECT * FROM ventas LIMIT 100');

for (let venta of ventas) {
  // ❌ 100+ additional queries!
  const [producto] = await pool.query('SELECT * FROM productos WHERE id = ?', [venta.producto_id]);
  venta.producto = producto[0];
}
```

### 5. Compression (MANDATORY)
**ALWAYS enable precompress in adapter configuration.**

```javascript
// svelte.config.js
import adapter from '@sveltejs/adapter-node';

const config = {
  kit: {
    adapter: adapter({
      precompress: true  // ✅ Enables gzip/brotli compression
    })
  }
};

export default config;
```

---

## 🚫 NEVER DO THIS

### ❌ Avoid These Patterns:
1. **SELECT * without LIMIT**
   ```javascript
   // ❌ WRONG
   SELECT * FROM ventas;
   
   // ✅ CORRECT
   SELECT * FROM ventas WHERE fecha >= ? LIMIT 100;
   ```

2. **Creating API endpoints**
   ```javascript
   // ❌ WRONG - Don't create this file
   src/routes/api/productos/+server.js
   
   // ✅ CORRECT - Use this instead
   src/routes/productos/+page.server.js
   ```

3. **Client-side data fetching**
   ```svelte
   <!-- ❌ WRONG -->
   <script>
     onMount(async () => {
       const res = await fetch('/api/productos');
       productos = await res.json();
     });
   </script>
   
   <!-- ✅ CORRECT -->
   <script>
     export let data; // Comes from +page.server.js load()
     const { productos } = data;
   </script>
   ```

4. **Storing files in database**
   ```javascript
   // ❌ WRONG - Don't store binary data
   await pool.query('INSERT INTO productos (imagen) VALUES (?)', [imageBuffer]);
   
   // ✅ CORRECT - Store URLs only
   await pool.query('INSERT INTO productos (imagen_url) VALUES (?)', [cloudinaryUrl]);
   ```

5. **Using SELECT * for specific fields**
   ```javascript
   // ❌ WRONG
   const [rows] = await pool.query('SELECT * FROM productos');
   
   // ✅ CORRECT - Only select needed columns
   const [rows] = await pool.query('SELECT id, nombre, precio, stock FROM productos');
   ```

---

## 📚 Svelte MCP Tools Usage

### Available MCP Tools:

#### 1. list-sections
Use this FIRST to discover all available documentation sections. Returns a structured list with titles, use_cases, and paths.
When asked about Svelte or SvelteKit topics, ALWAYS use this tool at the start of the chat to find relevant sections.

#### 2. get-documentation
Retrieves full documentation content for specific sections. Accepts single or multiple sections.
After calling the list-sections tool, you MUST analyze the returned documentation sections (especially the use_cases field) and then use the get-documentation tool to fetch ALL documentation sections that are relevant for the user's task.

#### 3. svelte-autofixer
Analyzes Svelte code and returns issues and suggestions.
You MUST use this tool whenever writing Svelte code before sending it to the user. Keep calling it until no issues or suggestions are returned.

#### 4. playground-link
Generates a Svelte Playground link with the provided code.
After completing the code, ask the user if they want a playground link. Only call this tool after user confirmation and NEVER if code was written to files in their project.

---

## 🎨 Code Style Guidelines

### Svelte 5 Syntax (MANDATORY)
**ALWAYS use Svelte 5 runes. NEVER use Svelte 4 syntax.**

**✅ CORRECT - Svelte 5:**
```svelte
<script>
  let count = $state(0);
  let doubled = $derived(count * 2);
  
  $effect(() => {
    console.log('Count changed:', count);
  });
</script>
```

**❌ WRONG - Svelte 4 (deprecated):**
```svelte
<script>
  let count = 0;
  $: doubled = count * 2;  // ❌ Old syntax
</script>
```

### Form Actions Pattern
**ALWAYS use SvelteKit form actions for mutations.**

```javascript
// +page.server.js
import { getPool } from '$lib/server/db';
import { fail } from '@sveltejs/kit';
import { productoSchema } from '$lib/server/schemas';

export const actions = {
  crear: async ({ request }) => {
    const data = await request.formData();
    
    // Validate with Zod
    const result = productoSchema.safeParse({
      nombre: data.get('nombre'),
      precio: parseFloat(data.get('precio')),
      stock: parseInt(data.get('stock'))
    });
    
    if (!result.success) {
      return fail(400, { errors: result.error.flatten() });
    }
    
    const pool = getPool();
    await pool.query(
      'INSERT INTO productos (nombre, precio, stock) VALUES (?, ?, ?)',
      [result.data.nombre, result.data.precio, result.data.stock]
    );
    
    return { success: true };
  }
};
```

```svelte
<!-- +page.svelte -->
<script>
  export let form;
</script>

<form method="POST" action="?/crear">
  <input name="nombre" required />
  <input name="precio" type="number" step="0.01" required />
  <input name="stock" type="number" required />
  <button>Crear Producto</button>
</form>

{#if form?.success}
  <p>✅ Producto creado exitosamente</p>
{/if}

{#if form?.errors}
  <p>❌ {form.errors}</p>
{/if}
```

### Validation with Zod (MANDATORY)
**ALWAYS validate user input with Zod schemas.**

```javascript
// src/lib/server/schemas.js
import { z } from 'zod';

export const productoSchema = z.object({
  nombre: z.string().min(1, 'El nombre es requerido').max(100),
  precio: z.number().positive('El precio debe ser positivo'),
  stock: z.number().int().min(0, 'El stock no puede ser negativo'),
  tienda_id: z.string().uuid('ID de tienda inválido')
});

export const ventaSchema = z.object({
  productos: z.array(z.object({
    id: z.string(),
    cantidad: z.number().int().positive(),
    precio: z.number().positive()
  })).min(1, 'Debe incluir al menos un producto'),
  metodo_pago: z.enum(['efectivo', 'tarjeta', 'transferencia']),
  total: z.number().positive()
});
```

---

## 🎯 Development Workflow

### When Creating New Features:

1. **Create route structure**
   ```
   src/routes/nueva-feature/
     +page.svelte
     +page.server.js
   ```

2. **Define Zod schema** in `src/lib/server/schemas.js`

3. **Create database queries** using the connection pool

4. **Add necessary indexes** to MySQL tables

5. **Implement pagination** if displaying lists

6. **Use JOINs** if data from multiple tables is needed

7. **Add form actions** for mutations

8. **Run svelte-autofixer** before finalizing code

### Before Every Response:
- ✅ Check if connection pool is used
- ✅ Verify indexes exist for query columns
- ✅ Confirm pagination is implemented
- ✅ Ensure no N+1 queries
- ✅ Validate Svelte 5 syntax is used
- ✅ Run svelte-autofixer on Svelte code

---

## 📊 Performance Targets

**Expected metrics on Railway:**
- RAM usage: 256-384MB
- CPU idle: 5-10%
- CPU active: 15-30%
- Network egress: <500MB/month
- Cost: $5-7/month

**If exceeding these targets, investigate:**
1. Connection pool leaks
2. Missing indexes
3. Queries without LIMIT
4. N+1 query problems
5. Large payloads being sent

---

## 🔒 Security Guidelines

1. **NEVER expose database credentials in code**
   - Always use `process.env.*`
   - Load from `.env` file with dotenv

2. **ALWAYS validate user input with Zod**
   - Before any database operations
   - Return clear error messages

3. **Use parameterized queries**
   ```javascript
   // ✅ CORRECT
   await pool.query('SELECT * FROM users WHERE id = ?', [userId]);
   
   // ❌ WRONG - SQL injection risk
   await pool.query(`SELECT * FROM users WHERE id = ${userId}`);
   ```

4. **Sanitize user-generated content**
   - Especially for display in HTML
   - Use Svelte's automatic escaping

---

## 📝 Summary Checklist

Before submitting any code, verify:

- [ ] Connection pool singleton is used
- [ ] Database indexes are created/mentioned
- [ ] Pagination is implemented (LIMIT/OFFSET)
- [ ] No N+1 queries (using JOINs)
- [ ] Compression enabled in adapter
- [ ] Svelte 5 syntax (runes) used
- [ ] Zod validation for all inputs
- [ ] No REST API endpoints created
- [ ] Form actions used for mutations
- [ ] svelte-autofixer run on all Svelte code
- [ ] No SELECT * without specific need
- [ ] Parameterized queries for security

---

**Remember: This is a monolithic application optimized for minimal resource usage. Every optimization matters for keeping Railway costs under $7/month.**
