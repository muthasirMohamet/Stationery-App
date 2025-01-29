const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');


// Set up Express app
const app = express();
const PORT = 3000;

// Middleware setup
app.use(cors());  // Allow cross-origin requests
app.use(bodyParser.json());

// Create MySQL connection
const db = mysql.createConnection({
    host: 'localhost',     // MySQL host
    user: 'root',          // MySQL username
    password: '123',       // MySQL password
    database: 'harsan_db'  // Database name
});

// Connect to the database
db.connect((err) => {
    if (err) {
        console.error('Database connection failed:', err);
        return;
    }
    console.log('Connected to MySQL database');
});

// Routes

// Create a new user
app.post('/users', (req, res) => {
  const { name, email, phoneNumber, role, password } = req.body;
  const userId = req.body.userId || 'unknown'; // Default user ID if not provided

  const query = `INSERT INTO users (name, email, phoneNumber, role, password) VALUES (?, ?, ?, ?, ?)`;

  db.query(query, [name, email, phoneNumber, role, hashedPassword], (err, result) => {
      if (err) {
          res.status(500).json({ message: 'Error creating user', error: err });
      } else {
          // Log the action
          logAudit(userId, 'insert', `Created new user: ${name}`, 'user', result.insertId);

          res.status(201).json({ message: 'User created successfully', userId: result.insertId });
      }
  });
});


// fetch all users
app.get('/users', (req, res) => {
  // Query the database to fetch all users
  // Replace 'users' with the actual table name in your database

  const query = `select * from users`;
  db.query(query, (err, results) => {
      if (err) {
          res.status(500).json({ message: 'Error fetching users', error: err });
      } else {
          res.status(200).json(results);
      }
  });
});

// Edit (Update) a user
app.put('/users/:id', (req, res) => {
  const userId = req.params.id; // ID of the user to be updated
  const { name, email, phoneNumber, role, password } = req.body;

  const query = `
      UPDATE users 
      SET 
          name = ?, 
          email = ?, 
          phoneNumber = ?, 
          role = ?, 
          password = ?
      WHERE id = ?
  `;

  const values = [name, email, phoneNumber, role, password, userId];

  db.query(query, values, (err, result) => {
      if (err) {
          res.status(500).json({ message: 'Error updating user', error: err });
      } else if (result.affectedRows === 0) {
          res.status(404).json({ message: 'User not found' });
      } else {
          // Log the action
          logAudit(userId, 'update', `Updated user: ${name}`, 'user', userId);

          res.status(200).json({ message: 'User updated successfully', affectedRows: result.affectedRows });
      }
  });
});


// Delete a user
app.delete('/users/:id', (req, res) => {
  const userId = req.params.id;

  const query = `DELETE FROM users WHERE id = ?`;

  db.query(query, [userId], (err, result) => {
      if (err) {
          res.status(500).json({ message: 'Error deleting user', error: err });
      } else {
          // Log the action
          logAudit(userId, 'delete', `Deleted user with ID: ${userId}`, 'user', userId);

          res.status(200).json({ message: 'User deleted successfully', affectedRows: result.affectedRows });
      }
  });
});

// Login route
app.post('/login', (req, res) => {
  const { email, password } = req.body;

  // Check if the user exists
  db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
    if (err) return res.status(500).send({ error: err });

    if (results.length === 0) {
      return res.status(400).send({ status: 'error', message: 'Invalid credentials' });
    }

    const user = results[0]; // Get the first user from results
    res.send({ status: 'success', user: user });
  });
});


// Add new product
app.post('/add-product', (req, res) => {
  const { name, price, quantity } = req.body;

  const query = 'INSERT INTO products (name, price, quantity) VALUES (?, ?, ?)';
  db.query(query, [name, price, quantity], (err, result) => {
    if (err) return res.status(500).send({ error: err });
    res.send({ status: 'success', message: 'Product added successfully' });
  });
});

// View all products
app.get('/products', (req, res) => {
  const query = 'SELECT * FROM products';
  db.query(query, (err, results) => {
    if (err) return res.status(500).send({ error: err });
    res.send({ status: 'success', products: results });
  });
});

// Edit product
app.put('/edit-product/:id', (req, res) => {
  const { id } = req.params;
  const { name, price, quantity } = req.body;

  const query = 'UPDATE products SET name = ?, price = ?, quantity = ? WHERE id = ?';
  db.query(query, [name, price, quantity, id], (err, result) => {
    if (err) return res.status(500).send({ error: err });
    res.send({ status: 'success', message: 'Product updated successfully' });
  });
});

// Delete product
app.delete('/delete-product/:id', (req, res) => {
  const { id } = req.params;

  const query = 'DELETE FROM products WHERE id = ?';
  db.query(query, [id], (err, result) => {
    if (err) return res.status(500).send({ error: err });
    res.send({ status: 'success', message: 'Product deleted successfully' });
  });
});


// API endpoint to fetch cart items for a specific user
app.get('/cart/:userId', (req, res) => {
  const userId = req.params.userId;
  
  // Query to get all products in the user's cart
  const query = `
    SELECT cart.cart_id, products.product_name, products.price, cart.quantity, 
           (products.price * cart.quantity) AS total_price
    FROM cart
    JOIN products ON cart.product_id = products.id
    WHERE cart.user_id = ?
  `;
  
  db.query(query, [userId], (err, results) => {
    if (err) {
      console.error('Error fetching cart items:', err);
      return res.status(500).send({ error: 'Error fetching cart items' });
    }
    res.send({ status: 'success', cart_items: results });
  });
});

// API to add a product to the cart
app.post('/cart', (req, res) => {
  const { user_id, product_id, quantity } = req.body;

  // Check if the product already exists in the user's cart
  const checkQuery = 'SELECT * FROM cart WHERE user_id = ? AND product_id = ?';
  db.query(checkQuery, [user_id, product_id], (err, results) => {
    if (err) {
      return res.status(500).send({ error: 'Error checking cart' });
    }

    if (results.length > 0) {
      // If the product exists, update the quantity
      const updateQuery = 'UPDATE cart SET quantity = quantity + ? WHERE user_id = ? AND product_id = ?';
      db.query(updateQuery, [quantity, user_id, product_id], (err) => {
        if (err) {
          return res.status(500).send({ error: 'Error updating cart' });
        }
        res.send({ status: 'success', message: 'Cart updated' });
      });
    } else {
      // If the product doesn't exist, add it to the cart
      const insertQuery = 'INSERT INTO cart (user_id, product_id, quantity) VALUES (?, ?, ?)';
      db.query(insertQuery, [user_id, product_id, quantity], (err) => {
        if (err) {
          return res.status(500).send({ error: 'Error adding to cart' });
        }
        res.send({ status: 'success', message: 'Product added to cart' });
      });
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
