const express = require('express');
const { Pool, types } = require('pg');
types.setTypeParser(1700, (val) => (val == null ? null : parseFloat(val)));
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json({ limit: '10mb' }));
app.use(cors());

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:postgres@db:5432/shiftly',
  ssl: process.env.DATABASE_URL && !process.env.DATABASE_URL.includes('localhost') && !process.env.DATABASE_URL.includes('db:')
    ? { rejectUnauthorized: false }
    : false
});

// Automatically runs database migrations, creates missing tables, indexes, and columns.
const ensureSchema = async () => {
  try {
    // 1. Create Users table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          name VARCHAR(100) NOT NULL,
          email VARCHAR(100) UNIQUE NOT NULL,
          password VARCHAR(255) NOT NULL,
          birth_date DATE,
          automatic_expense_enabled BOOLEAN DEFAULT FALSE,
          automatic_income_enabled BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // 2. Create Job Types table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS job_types (
          id VARCHAR(50) NOT NULL,
          user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          name VARCHAR(100) NOT NULL,
          hourly_rate DECIMAL(10, 2) DEFAULT 0,
          wage_history JSONB,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id, user_id)
      )
    `);

    // 3. Create Default Automatic Items table (dedicated table for user fixed expenses & incomes)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS default_automatic_items (
          id VARCHAR(100) NOT NULL,
          user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          description TEXT NOT NULL,
          amount DECIMAL(10, 2) NOT NULL,
          is_income BOOLEAN DEFAULT FALSE,
          is_enabled BOOLEAN DEFAULT TRUE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id, user_id)
      )
    `);

    // 4. Create Shifts table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS shifts (
          id UUID PRIMARY KEY,
          user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          job_type_id VARCHAR(50),
          date DATE NOT NULL,
          start_time TIMESTAMP NOT NULL,
          end_time TIMESTAMP NOT NULL,
          tips DECIMAL(10, 2) DEFAULT 0,
          break_type VARCHAR(20) DEFAULT 'none',
          unpaid_break_minutes DECIMAL(10, 2) DEFAULT 0,
          hourly_rate DECIMAL(10, 2),
          automatic_expenses JSONB,
          automatic_incomes JSONB,
          description TEXT,
          total_pay DECIMAL(10, 2),
          wage_segments JSONB,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    await pool.query('ALTER TABLE shifts ADD COLUMN IF NOT EXISTS wage_segments JSONB');

    // 5. Create Financial Transactions table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS financial_transactions (
          id UUID PRIMARY KEY,
          user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          date DATE NOT NULL,
          description TEXT NOT NULL,
          amount DECIMAL(10, 2) NOT NULL,
          is_income BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Performance Indexes
    await pool.query('CREATE INDEX IF NOT EXISTS idx_shifts_user_date ON shifts(user_id, date DESC)');
    await pool.query('CREATE INDEX IF NOT EXISTS idx_job_types_user ON job_types(user_id)');
    await pool.query('CREATE INDEX IF NOT EXISTS idx_financial_trans_user_date ON financial_transactions(user_id, date DESC)');
    await pool.query('CREATE INDEX IF NOT EXISTS idx_default_auto_items_user ON default_automatic_items(user_id)');

    console.log('Database schema & indexes ensured successfully.');
  } catch (err) {
    console.error('Error ensuring schema:', err);
  }
};

// Root route
app.get('/', (req, res) => {
  res.send('Shiftly Backend is running successfully!');
});

app.get('/api', (req, res) => {
  res.json({ message: 'Shiftly API is active' });
});

const JWT_SECRET = process.env.JWT_SECRET || 'your_super_secret_key';

// Middleware to verify JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.sendStatus(401);

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// Register Route
app.post('/api/auth/register', async (req, res) => {
  const { name, email, password, birthDate, birth_date, automaticExpenseEnabled, automaticIncomeEnabled } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const bDate = birthDate || birth_date;
    const parsedBirthDate = bDate ? new Date(bDate).toISOString().split('T')[0] : null;
    const result = await pool.query(
      `INSERT INTO users (name, email, password, birth_date, automatic_expense_enabled, automatic_income_enabled)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, name, email, birth_date, created_at, automatic_expense_enabled, automatic_income_enabled`,
      [name, email, hashedPassword, parsedBirthDate, automaticExpenseEnabled || false, automaticIncomeEnabled || false]
    );

    const user = result.rows[0];
    const token = jwt.sign({ userId: user.id }, JWT_SECRET);

    res.status(201).json({ user, token });
  } catch (err) {
    console.error(err);
    if (err.code === '23505' || (err.message && (err.message.includes('unique') || err.message.includes('already exists')))) {
      return res.status(400).json({ error: 'Email already exists' });
    }
    res.status(500).json({ error: 'User registration failed' });
  }
});

// Login Route
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    const user = result.rows[0];

    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign({ userId: user.id }, JWT_SECRET);
    res.json({
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        birth_date: user.birth_date,
        created_at: user.created_at,
        automatic_expense_enabled: user.automatic_expense_enabled,
        automatic_income_enabled: user.automatic_income_enabled
      },
      token
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Login failed' });
  }
});

// Get User Profile Route
app.get('/api/auth/profile', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name, email, birth_date, created_at, automatic_expense_enabled, automatic_income_enabled FROM users WHERE id = $1',
      [req.user.userId]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

// Update User Profile
app.put('/api/auth/profile', authenticateToken, async (req, res) => {
  const { name, email, birthDate, birth_date, automaticExpenseEnabled, automaticIncomeEnabled } = req.body;
  try {
    const bDate = birthDate !== undefined ? birthDate : birth_date;
    const parsedBirthDate = bDate !== undefined ? (bDate ? new Date(bDate).toISOString().split('T')[0] : null) : undefined;

    let query, params;
    if (parsedBirthDate !== undefined) {
      query = `UPDATE users SET
               name = $1, email = $2, birth_date = $3,
               automatic_expense_enabled = COALESCE($4, automatic_expense_enabled),
               automatic_income_enabled = COALESCE($5, automatic_income_enabled)
               WHERE id = $6
               RETURNING id, name, email, birth_date, created_at, automatic_expense_enabled, automatic_income_enabled`;
      params = [name, email, parsedBirthDate, automaticExpenseEnabled, automaticIncomeEnabled, req.user.userId];
    } else {
      query = `UPDATE users SET
               name = $1, email = $2,
               automatic_expense_enabled = COALESCE($3, automatic_expense_enabled),
               automatic_income_enabled = COALESCE($4, automatic_income_enabled)
               WHERE id = $5
               RETURNING id, name, email, birth_date, created_at, automatic_expense_enabled, automatic_income_enabled`;
      params = [name, email, automaticExpenseEnabled, automaticIncomeEnabled, req.user.userId];
    }
    const result = await pool.query(query, params);
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

// Dedicated Update User Settings Route
app.put('/api/auth/settings', authenticateToken, async (req, res) => {
  const { automaticExpenseEnabled, automaticIncomeEnabled } = req.body;
  try {
    const result = await pool.query(
      `UPDATE users SET
       automatic_expense_enabled = CASE WHEN $1::boolean IS NOT NULL THEN $1 ELSE automatic_expense_enabled END,
       automatic_income_enabled = CASE WHEN $2::boolean IS NOT NULL THEN $2 ELSE automatic_income_enabled END
       WHERE id = $3
       RETURNING id, name, email, birth_date, created_at, automatic_expense_enabled, automatic_income_enabled`,
      [automaticExpenseEnabled !== undefined ? automaticExpenseEnabled : null, automaticIncomeEnabled !== undefined ? automaticIncomeEnabled : null, req.user.userId]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update settings' });
  }
});

// Health check
app.get('/health', (req, res) => res.send('OK'));

// --- Job Type Routes ---

app.get('/api/job-types', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM job_types WHERE user_id = $1', [req.user.userId]);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch job types' });
  }
});

app.post('/api/job-types', authenticateToken, async (req, res) => {
  const { id, name, hourly_rate, wage_history } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO job_types (id, user_id, name, hourly_rate, wage_history)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (id, user_id) DO UPDATE SET
       name = EXCLUDED.name,
       hourly_rate = EXCLUDED.hourly_rate,
       wage_history = EXCLUDED.wage_history
       RETURNING *`,
      [id, req.user.userId, name, hourly_rate, wage_history ? JSON.stringify(wage_history) : null]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to save job type' });
  }
});

// Batch upsert job types
app.post('/api/job-types/batch', authenticateToken, async (req, res) => {
  const { items } = req.body;
  if (!Array.isArray(items) || items.length === 0) {
    return res.json({ status: 'ok', count: 0 });
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    for (const item of items) {
      await client.query(
        `INSERT INTO job_types (id, user_id, name, hourly_rate, wage_history)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (id, user_id) DO UPDATE SET
         name = EXCLUDED.name,
         hourly_rate = EXCLUDED.hourly_rate,
         wage_history = EXCLUDED.wage_history`,
        [item.id, req.user.userId, item.name, item.hourly_rate, item.wage_history ? JSON.stringify(item.wage_history) : null]
      );
    }
    await client.query('COMMIT');
    res.json({ status: 'ok', count: items.length });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Batch job-types upsert error:', err);
    res.status(500).json({ error: 'Batch job-types save failed' });
  } finally {
    client.release();
  }
});

app.delete('/api/job-types/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM job_types WHERE id = $1 AND user_id = $2', [req.params.id, req.user.userId]);
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete job type' });
  }
});

// --- Shift Routes ---

app.get('/api/shifts', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM shifts WHERE user_id = $1 ORDER BY start_time DESC',
      [req.user.userId]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch shifts' });
  }
});

// Single shift upsert
app.post('/api/shifts', authenticateToken, async (req, res) => {
  const {
    id, job_type_id, date, start_time, end_time, tips,
    break_type, unpaid_break_minutes, hourly_rate,
    automatic_expenses, automatic_incomes, description, total_pay,
    wage_segments, wageSegments
  } = req.body;
  try {
    const autoExpJson = automatic_expenses && automatic_expenses.length > 0 ? JSON.stringify(automatic_expenses) : null;
    const autoIncJson = automatic_incomes && automatic_incomes.length > 0 ? JSON.stringify(automatic_incomes) : null;
    const segments = wage_segments || wageSegments;
    const wageSegJson = segments && segments.length > 0 ? JSON.stringify(segments) : null;

    const result = await pool.query(
      `INSERT INTO shifts (id, user_id, job_type_id, date, start_time, end_time, tips, break_type, unpaid_break_minutes, hourly_rate, automatic_expenses, automatic_incomes, description, total_pay, wage_segments)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11::jsonb, $12::jsonb, $13, $14, $15::jsonb)
       ON CONFLICT (id) DO UPDATE SET
       job_type_id = EXCLUDED.job_type_id,
       date = EXCLUDED.date,
       start_time = EXCLUDED.start_time,
       end_time = EXCLUDED.end_time,
       tips = EXCLUDED.tips,
       break_type = EXCLUDED.break_type,
       unpaid_break_minutes = EXCLUDED.unpaid_break_minutes,
       hourly_rate = EXCLUDED.hourly_rate,
       automatic_expenses = EXCLUDED.automatic_expenses,
       automatic_incomes = EXCLUDED.automatic_incomes,
       description = EXCLUDED.description,
       total_pay = EXCLUDED.total_pay,
       wage_segments = EXCLUDED.wage_segments
       RETURNING *`,
      [id, req.user.userId, job_type_id, date, start_time, end_time, tips, break_type, unpaid_break_minutes, hourly_rate, autoExpJson, autoIncJson, description, total_pay, wageSegJson]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to save shift' });
  }
});

// Batch upsert shifts
app.post('/api/shifts/batch', authenticateToken, async (req, res) => {
  const { items } = req.body;
  if (!Array.isArray(items) || items.length === 0) {
    return res.json({ status: 'ok', count: 0 });
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    for (const item of items) {
      const autoExpJson = item.automatic_expenses && item.automatic_expenses.length > 0 ? JSON.stringify(item.automatic_expenses) : null;
      const autoIncJson = item.automatic_incomes && item.automatic_incomes.length > 0 ? JSON.stringify(item.automatic_incomes) : null;
      const segments = item.wage_segments || item.wageSegments;
      const wageSegJson = segments && segments.length > 0 ? JSON.stringify(segments) : null;

      await client.query(
        `INSERT INTO shifts (id, user_id, job_type_id, date, start_time, end_time, tips, break_type, unpaid_break_minutes, hourly_rate, automatic_expenses, automatic_incomes, description, total_pay, wage_segments)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11::jsonb, $12::jsonb, $13, $14, $15::jsonb)
         ON CONFLICT (id) DO UPDATE SET
         job_type_id = EXCLUDED.job_type_id,
         date = EXCLUDED.date,
         start_time = EXCLUDED.start_time,
         end_time = EXCLUDED.end_time,
         tips = EXCLUDED.tips,
         break_type = EXCLUDED.break_type,
         unpaid_break_minutes = EXCLUDED.unpaid_break_minutes,
         hourly_rate = EXCLUDED.hourly_rate,
         automatic_expenses = EXCLUDED.automatic_expenses,
         automatic_incomes = EXCLUDED.automatic_incomes,
         description = EXCLUDED.description,
         total_pay = EXCLUDED.total_pay,
         wage_segments = EXCLUDED.wage_segments`,
        [
          item.id, req.user.userId, item.job_type_id, item.date,
          item.start_time, item.end_time, item.tips || 0,
          item.break_type, item.unpaid_break_minutes || 0,
          item.hourly_rate || 0, autoExpJson, autoIncJson, item.description, item.total_pay || 0, wageSegJson
        ]
      );
    }
    await client.query('COMMIT');
    res.json({ status: 'ok', count: items.length });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Batch shift upsert error:', err);
    res.status(500).json({ error: 'Batch shift save failed' });
  } finally {
    client.release();
  }
});

app.delete('/api/shifts/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM shifts WHERE id = $1 AND user_id = $2', [req.params.id, req.user.userId]);
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete shift' });
  }
});

// --- Financial Transactions Routes (Expenses & Special Incomes Unified Table) ---

app.get('/api/expenses', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM financial_transactions WHERE user_id = $1 ORDER BY date DESC', [req.user.userId]);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch financial transactions' });
  }
});

app.post('/api/expenses', authenticateToken, async (req, res) => {
  const { id, date, description, amount, is_income } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO financial_transactions (id, user_id, date, description, amount, is_income)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (id) DO UPDATE SET
       date = EXCLUDED.date,
       description = EXCLUDED.description,
       amount = EXCLUDED.amount,
       is_income = EXCLUDED.is_income
       RETURNING *`,
      [id, req.user.userId, date, description, amount, is_income || false]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to save financial transaction' });
  }
});

// Batch upsert financial transactions
app.post('/api/expenses/batch', authenticateToken, async (req, res) => {
  const { items } = req.body;
  if (!Array.isArray(items) || items.length === 0) {
    return res.json({ status: 'ok', count: 0 });
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    for (const item of items) {
      await client.query(
        `INSERT INTO financial_transactions (id, user_id, date, description, amount, is_income)
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (id) DO UPDATE SET
         date = EXCLUDED.date,
         description = EXCLUDED.description,
         amount = EXCLUDED.amount,
         is_income = EXCLUDED.is_income`,
        [item.id, req.user.userId, item.date, item.description, item.amount, item.is_income || false]
      );
    }
    await client.query('COMMIT');
    res.json({ status: 'ok', count: items.length });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Batch financial transactions upsert error:', err);
    res.status(500).json({ error: 'Batch financial transactions save failed' });
  } finally {
    client.release();
  }
});

app.delete('/api/expenses/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM financial_transactions WHERE id = $1 AND user_id = $2', [req.params.id, req.user.userId]);
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete financial transaction' });
  }
});

// --- Default Automatic Items Routes (Dedicated Table for User Fixed Expenses & Incomes) ---

app.get('/api/automatic-items', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM default_automatic_items WHERE user_id = $1 ORDER BY created_at ASC', [req.user.userId]);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch default automatic items' });
  }
});

app.post('/api/automatic-items/batch', authenticateToken, async (req, res) => {
  const { items } = req.body;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query('DELETE FROM default_automatic_items WHERE user_id = $1', [req.user.userId]);
    if (Array.isArray(items) && items.length > 0) {
      for (const item of items) {
        await client.query(
          `INSERT INTO default_automatic_items (id, user_id, description, amount, is_income, is_enabled)
           VALUES ($1, $2, $3, $4, $5, $6)`,
          [item.id || item.description, req.user.userId, item.description, item.amount, item.is_income || false, item.is_enabled !== undefined ? item.is_enabled : true]
        );
      }
    }
    await client.query('COMMIT');
    res.json({ status: 'ok', count: items ? items.length : 0 });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Batch automatic items error:', err);
    res.status(500).json({ error: 'Failed to save default automatic items' });
  } finally {
    client.release();
  }
});

app.delete('/api/automatic-items/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM default_automatic_items WHERE id = $1 AND user_id = $2', [req.params.id, req.user.userId]);
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete default automatic item' });
  }
});

// Delete account
app.delete('/api/auth/profile', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM users WHERE id = $1', [req.user.userId]);
    res.sendStatus(204);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete account' });
  }
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection:', reason);
});
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
});

const PORT = process.env.PORT || 3000;
ensureSchema()
  .then(() => app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`)))
  .catch((error) => {
    console.error('Failed to apply database schema updates:', error);
    process.exit(1);
  });
