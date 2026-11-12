const mysql = require('mysql2/promise');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
require('dotenv').config(); // Fallback se executado de pastas diferentes

const dbPassword = (process.env.DB_PASSWORD === 'AcademiaApp' || !process.env.DB_PASSWORD) 
    ? 'AcademiaApp#2026' 
    : process.env.DB_PASSWORD;

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USER || 'academia_app',
    password: dbPassword,
    database: process.env.DB_NAME || 'academia_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    decimalNumbers: true
});

module.exports = pool;
