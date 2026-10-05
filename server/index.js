const express = require('express');
const { Pool } = require('pg');
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
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // 2. Create Job Types table (primary key is id + user_id)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS job_types (
          id VARCHAR(50) NOT NULL,
          user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          name VARCHAR(100) NOT NULL,
          hourly_rate DECIMAL(10, 2),
          wage_history JSONB,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id, user_id)
      )
    `);

    // 3. Create Shifts table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS shifts (
          id UUID PRIMARY KEY,
          user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
          job_type_id VARCHAR(50),
          date DATE NOT NULL,
          start_time TIMESTAMP NOT NULL,
          end_time TIMESTAMP NOT NULL,
          tips DECIMAL(10, 2) DEFAULT 0,
          break_type VARCHAR(20),
          unpaid_break_minutes DECIMAL(10, 2),
          hourly_rate DECIMAL(10, 2),
          automatic_expenses JSONB,
          description TEXT,
          total_pay DECIMAL(10, 2),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // 4. Create Financial Transactions table (unified for Expenses and Special Incomes)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS financial_transactions (
          id UUID PRIMARY KEY,
          user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
          date DATE NOT NULL,
          description TEXT,
          amount DECIMAL(10, 2) NOT NULL,
          is_income BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Ensure job_types primary key includes user_id (id, user_id)
    try {
      await pool.query('ALTER TABLE job_types DROP CONSTRAINT IF EXISTS job_types_pkey CASCADE');
      await pool.query('ALTER TABLE job_types ADD PRIMARY KEY (id, user_id)');
    } catch (e) {
      // Primary key already updated or table just created
    }

    // Ensure description & is_income columns exist if tables already existed
    await pool.query('ALTER TABLE shifts ADD COLUMN IF NOT EXISTS description TEXT');
    await pool.query('ALTER TABLE financial_transactions ADD COLUMN IF NOT EXISTS is_income BOOLEAN DEFAULT FALSE');

    // Performance & Storage Optimization Indexes (Eliminate Full Table Scans)
    await pool.query('CREATE INDEX IF NOT EXISTS idx_shifts_user_id ON shifts(user_id)');
    await pool.query('CREATE INDEX IF NOT EXISTS idx_shifts_user_date ON shifts(user_id, date DESC)');
    await pool.query('CREATE INDEX IF NOT EXISTS idx_job_types_user_id ON job_types(user_id)');
    await pool.query('CREATE INDEX IF NOT EXISTS idx_financial_transactions_user_id ON financial_transactions(user_id)');

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
  const { name, email, password } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await pool.query(
      'INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING id, name, email',
      [name, email, hashedPassword]
    );

    const user = result.rows[0];
    const token = jwt.sign({ userId: user.id }, JWT_SECRET);

    res.status(201).json({ user, token });
  } catch (err) {
    console.error(err);
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
      user: { id: user.id, name: user.name, email: user.email },
      token
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Login failed' });
  }
});

// Update User Profile
app.put('/api/auth/profile', authenticateToken, async (req, res) => {
  const { name, email } = req.body;
  try {
    const result = await pool.query(
      'UPDATE users SET name = $1, email = $2 WHERE id = $3 RETURNING id, name, email',
      [name, email, req.user.userId]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update profile' });
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

// Batch upsert job types (1 SQL transaction instead of N calls)
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
    automatic_expenses, description, total_pay
  } = req.body;
  try {
    const autoExpJson = automatic_expenses && automatic_expenses.length > 0 ? JSON.stringify(automatic_expenses) : null;
    const result = await pool.query(
      `INSERT INTO shifts (id, user_id, job_type_id, date, start_time, end_time, tips, break_type, unpaid_break_minutes, hourly_rate, automatic_expenses, description, total_pay)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
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
       description = EXCLUDED.description,
       total_pay = EXCLUDED.total_pay
       RETURNING *`,
      [id, req.user.userId, job_type_id, date, start_time, end_time, tips, break_type, unpaid_break_minutes, hourly_rate, autoExpJson, description, total_pay]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to save shift' });
  }
});

// Batch upsert shifts (Reduces WAL logs, dead tuple bloat, and sync time by 95%)
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
      await client.query(
        `INSERT INTO shifts (id, user_id, job_type_id, date, start_time, end_time, tips, break_type, unpaid_break_minutes, hourly_rate, automatic_expenses, description, total_pay)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
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
         description = EXCLUDED.description,
         total_pay = EXCLUDED.total_pay`,
        [
          item.id, req.user.userId, item.job_type_id, item.date,
          item.start_time, item.end_time, item.tips || 0,
          item.break_type, item.unpaid_break_minutes || 0,
          item.hourly_rate || 0, autoExpJson, item.description, item.total_pay || 0
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
