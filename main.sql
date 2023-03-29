
CREATE TABLE orders (
  order_id INT,
  order_date date,
  customer_id INT,
  amount REAL,
  order_type varchar(20),
  payment_id INT,
  CONSTRAINT FK_order_id 
  FOREIGN KEY (order_id) 
    REFERENCES order_details (order_id),
  CONSTRAINT FK_customer_id
  FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id),
  CONSTRAINT FK_payment_id
  FOREIGN KEY (payment_id)
    REFERENCES Payment(payment_id)
);

INSERT INTO orders VALUES
(1, '2022-12-01', 1, 430, 'dine-in', 101),
(2, '2022-12-01', 2, 100, 'dine-in', 102),
(3, '2022-12-01', 3, 300, 'dine-in', 103),
(4, '2022-12-02', 4, 290, 'dine-in', 104),
(5, '2022-12-02', 1, 500, 'delivery', 105),
(6, '2022-12-02', 5, 250, 'delivery', 106);

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  customer_firstname varchar(10),
  customer_lastname varchar(10),
  customer_phone varchar(10) UNIQUE
);

INSERT INTO customers VALUES
  (1, 'Jeff', 'Conor', 0624578906),
  (2, 'Jan', 'Johnson', 0687965432),
  (3, 'Mary', 'Tyler', 0675487643),
  (4, 'Oliver', 'Smith', 0656289654),
  (5, 'Ann', 'Jeff', 0698654120);

CREATE TABLE menu (
  menu_id INT PRIMARY KEY,
  menu_name varchar(100), 
  menu_type varchar(100),
  menu_price INT
);

INSERT INTO menu VALUES
  (1, 'Pesto Genovese', 'Pasta', 90),
  (2, 'Tomato Sauce', 'Pasta', 90),
  (3, 'Carbonara', 'Pasta', 90),
  (4, 'Marghaita', 'Pizza', 50),
  (5, 'Seafood', 'Pizza', 50),
  (6, 'Fungi', 'Pizza', 50),
  (7, 'Red Wine', 'Wine', 200),
  (8, 'White Wine', 'Wine', 200),
  (9, 'Sparkling Wine', 'Wine', 200);
  

CREATE TABLE order_details (
  order_line INT primary key,
  order_id INT,
  menu_id INT,
  unit_price INT,
  quantity INT
);

INSERT INTO order_details VALUES
  (1, 1, 1, 90, 2),
  (2, 1, 4, 50, 1),
  (3, 1, 7, 200, 1),
  (4, 2, 5, 50, 1),
  (5, 2, 6, 50, 1),
  (6, 3, 9, 200, 1),
  (7, 3, 6, 50, 1),
  (8, 3, 4, 50, 1),
  (9, 4, 2, 90, 1),
  (10, 4, 8, 200, 1),
  (11, 5, 8, 200, 1),
  (12, 5, 9, 200, 1),
  (13, 5, 5, 50, 1),
  (14, 5, 4, 50, 2),
  (15, 6, 5, 50, 2),
  (16, 6, 4, 50, 3);

CREATE TABLE Payment (
  payment_id INT primary key,
  order_id INT,
  customer_id INT,
  payment_type varchar(20),
  payment_date date,
  payment_time time,
  payment_amount INT  
);

INSERT INTO Payment VALUES
  (101, 1, 1, 'Debit', '2022-12-01', '13:00:05', 430),
  (102, 2, 2, 'Cash', '2022-12-01', '14:20:55', 100),
  (103, 3, 3, 'Cash', '2022-12-01', '14:25:20', 300),
  (104, 4, 4, 'Credit', '2022-12-02', '12:30:25', 290),
  (105, 5, 1, 'Cash', '2022-12-02', '12:45:59', 690),
  (106, 6, 5, 'Credit', '2022-12-02', '16:00:09', 250);

.mode markdown 
.header on
  
-- รายได้
SELECT 
  order_date,
  SUM(amount) AS total_amount
FROM orders
GROUP BY order_date;

-- ลูกค้าที่เกิดการซื้อซ้ำมากที่สุด
WITH sub AS (
   SELECT
  	customers.customer_id,
  	orders.customer_id AS oc,
    customers.customer_firstname || ' ' || customers.customer_lastname AS customer_name,
    orders.amount AS oa
  from orders
  join customers ON customers.customer_id = orders.customer_id
 )
SELECT 
    customer_name,
    SUM(oa) AS total_amount,
    count(oc) AS n_times  
FROM sub
 GROUP BY customer_name, oc
 ORDER BY total_amount DESC;
  
-- ประเภทอาหารที่ขายดีที่สุด / drill down เมนูอะไรบ้างในประเภทนั้น
SELECT 
	type,
  SUM(qua) AS total
FROM (
	SELECT 
		od.order_id,
        od.menu_id,
    	od.quantity AS qua,
    	menu.menu_type AS type
	FROM order_details AS od
	JOIN menu ON menu.menu_id = od.menu_id
) as sub1
group by type
order By total DESC;

SELECT 
    type,
    name_food,
    SUM(qua) AS total_pizza
FROM (
	SELECT 
		od.order_id,
    od.menu_id,
  	menu.menu_name AS name_food,
    od.quantity AS qua,
    menu.menu_type AS type
	FROM order_details AS od
	JOIN menu ON menu.menu_id = od.menu_id
  WHERE type = 'Pizza'
) as sub2
group by name_food
ORDER By total_pizza DESC;

-- ลูกค้าสั่งแบบไหนมากที่สุด
SELECT 
  order_type,
  COUNT(*) AS n_type
FROM orders
GROUP BY order_type
ORDER BY n_type DESC;