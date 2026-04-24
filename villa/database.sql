-- Database untuk Aplikasi Villa Management
CREATE DATABASE IF NOT EXISTS villa_management;
USE villa_management;

-- Tabel Users
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    role ENUM('admin', 'user') DEFAULT 'user',
    profile_image VARCHAR(255),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Categories
CREATE TABLE IF NOT EXISTS categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    category_type ENUM('villa', 'furniture') NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Villas
CREATE TABLE IF NOT EXISTS villas (
    villa_id INT AUTO_INCREMENT PRIMARY KEY,
    villa_name VARCHAR(150) NOT NULL,
    category_id INT,
    description TEXT,
    location VARCHAR(255),
    address TEXT,
    bedrooms INT,
    bathrooms INT,
    area_sqm DECIMAL(10,2),
    price_sale DECIMAL(15,2),
    price_rent_daily DECIMAL(12,2),
    price_rent_monthly DECIMAL(12,2),
    status ENUM('available', 'sold', 'rented', 'unavailable') DEFAULT 'available',
    images TEXT,
    amenities TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (created_by) REFERENCES users(user_id)
);

-- Tabel Furniture
CREATE TABLE IF NOT EXISTS furniture (
    furniture_id INT AUTO_INCREMENT PRIMARY KEY,
    furniture_name VARCHAR(150) NOT NULL,
    category_id INT,
    description TEXT,
    price DECIMAL(12,2) NOT NULL,
    stock INT DEFAULT 0,
    images TEXT,
    condition_type ENUM('new', 'used', 'refurbished') DEFAULT 'new',
    material VARCHAR(100),
    dimensions VARCHAR(100),
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (created_by) REFERENCES users(user_id)
);

-- Tabel Villa Rentals
CREATE TABLE IF NOT EXISTS villa_rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    villa_id INT NOT NULL,
    user_id INT NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    total_days INT NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    payment_status ENUM('pending', 'partial', 'paid', 'cancelled') DEFAULT 'pending',
    booking_status ENUM('pending', 'confirmed', 'checked_in', 'checked_out', 'cancelled') DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (villa_id) REFERENCES villas(villa_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Tabel Villa Sales
CREATE TABLE IF NOT EXISTS villa_sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    villa_id INT NOT NULL,
    buyer_id INT NOT NULL,
    sale_price DECIMAL(15,2) NOT NULL,
    payment_status ENUM('pending', 'dp_paid', 'paid') DEFAULT 'pending',
    down_payment DECIMAL(15,2),
    remaining_payment DECIMAL(15,2),
    sale_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (villa_id) REFERENCES villas(villa_id),
    FOREIGN KEY (buyer_id) REFERENCES users(user_id)
);

-- Tabel Orders (untuk furniture)
CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    payment_status ENUM('pending', 'paid', 'cancelled') DEFAULT 'pending',
    delivery_status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    shipping_address TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Tabel Order Items
CREATE TABLE IF NOT EXISTS order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    furniture_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (furniture_id) REFERENCES furniture(furniture_id)
);

-- Tabel Transactions (untuk POS)
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_number VARCHAR(50) UNIQUE NOT NULL,
    transaction_type ENUM('sale', 'rental', 'furniture') NOT NULL,
    reference_id INT,
    user_id INT NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    payment_method ENUM('cash', 'transfer', 'card', 'other') DEFAULT 'cash',
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_by INT,
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (processed_by) REFERENCES users(user_id)
);

-- Tabel Payments
CREATE TABLE IF NOT EXISTS payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    payment_method ENUM('cash', 'transfer', 'card', 'other') NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_proof VARCHAR(255),
    notes TEXT,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);

-- Insert default admin user (password: admin123)
INSERT INTO users (username, password, full_name, email, role) VALUES
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrator', 'admin@villamanagement.com', 'admin');

-- Insert sample categories
INSERT INTO categories (category_name, category_type, description) VALUES
('Villa Mewah', 'villa', 'Villa dengan fasilitas mewah dan lengkap'),
('Villa Budget', 'villa', 'Villa dengan harga terjangkau'),
('Villa Pantai', 'villa', 'Villa di lokasi dekat pantai'),
('Sofa & Kursi', 'furniture', 'Berbagai jenis sofa dan kursi'),
('Tempat Tidur', 'furniture', 'Bed dan perlengkapan tidur'),
('Meja', 'furniture', 'Meja makan, meja kerja, dan lainnya'),
('Lemari', 'furniture', 'Lemari pakaian dan penyimpanan'),
('Dekorasi', 'furniture', 'Aksesoris dan dekorasi rumah');
