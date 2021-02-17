### Create Tables###
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50),
);


CREATE TABLE photos (
  id SERIAL PRIMARY KEY,
  url VARCHAR(200),
  user_id INTEGER REFERENCES users(id) #foreign key
);


### setting contraints ###
CREATE TABLE photos (
  id SERIAL PRIMARY KEY,
  url VARCHAR(200),
  user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE photos (
  id SERIAL PRIMARY KEY,
  url VARCHAR(200),
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE
);


###insert into users###
INSERT INTO
  users (username)
VALUES
  ('monahan93'),
  ('pferrer'),
  ('si93onis'),
  ('99stroman');

INSERT INTO
  photos (url, user_id)
VALUES
  ('http://one.jpg', 4);

INSERT INTO
  photos (url, user_id)
VALUES
  ('http://two.jpg', 1),
  ('http://25.jpg', 1),
  ('http://36.jpg', 1),
  ('http://754.jpg', 2),
  ('http://35.jpg', 3),
  ('http://256.jpg', 4);

  -- Data querying --
SELECT
  *
FROM
  photos
WHERE
  user_id = 4

### Join statements###
SELECT
  url,
  username
FROM
  photos
  JOIN users ON users.id = photos.user_id;


###Deleting a table###
DROP TABLE photos


#####JOINS EXAMPLES####
SELECT contents, username, photo_id
FROM COMMENTS
JOIN users ON users.id = comments.user_id

SELECT photos.id
FROM comments
JOIN photos ON photos.id = comments.photo_id


###renaming columns in similar columns
SELECT comments.id as comment_id, photos.id
FROM comments
JOIN photos ON photos.id = comments.photo_id

###renaming tables
SELECT comments.id as comment_id, p.id
FROM photos AS p
JOIN comments ON p.id = comments.photo_id


###different kind of joins###
INNER, LEFT, RIGHT, FULL

###WHERE with JOIN###
SELECT url, contents, comments.user_id
FROM comments
JOIN photos ON photos.id = comments.photo_id
WHERE comments.user_id = photos.user_id;


###THREE way JOIN####
SELECT url, contents, username
FROM comments
JOIN photos ON photos.id = comments.photo_id
JOIN users ON users.id = comments.user_id AND users.id = photos.user_id;

SELECT title, name, rating
FROM reviews
JOIN books ON books.id = reviews.book_id
JOIN authors ON authors.id = books.author_id AND authors.id = reviews.reviewer_id;

###Grouping and Aggregation###
SELECT user_id
FROM comments
GROUP BY user_id;

###Aggregate with groupby###
SELECT user_id, COUNT(*) as num_comments_created
FROM comments
GROUP BY user_id;

SELECT COUNT(*) FROM photos; #count all rows incase of null values in columns

###Having keyword###
#Find the number of comments for each photoswhere the photo_id is
#less than 3 and the photo has more than 2 comments
SELECT photo_id, COUNT(*)
FROM comments
WHERE photo_id < 3
GROUP BY photo_id
HAVING COUNT(*) > 2;

-- Find the users (ids) where the user has commented on the first 502 photos
-- and the user added more than or equal to 20 comments on those photos
SELECT user_id, COUNT(*)
FROM comments
WHERE photo_id < 50
GROUP BY user_id
HAVING COUNT(*) > 20;

-- print the number of manufacturers and total revenue (price * units_sold) for all
-- phones. Only print the manufacturers who have revenue greater than
-- 2,000,000 for all the phones they sold.
SELECT manufacturer, SUM(price*units_sold)
FROM phones
GROUP BY manufacturer
HAVING SUM(price*units_sold) > 2000000

-- Sorting
SELECT * 
FROM products
ORDER BY price;

-- Sorting by string
SELECT * 
FROM products
ORDER BY name;


-- Sorting by multiple columns
SELECT * 
FROM products
ORDER BY price, weight DESC;

-- Offset and Limit
SELECT *
FROM users
OFFSET 40; #Skip some number of rows and start at the offset

-- Limit
SELECT *
FROM products
ORDER BY price
LIMIT 5

-- Limits and Offsets for pagination
SELECT *
FROM products
ORDER BY price DESC
LIMIT 20
OFFSET 0 NEXT 20 NEXT 40 ... #not sql stmt


-- Unions
-- Find the 4 products with the highest price and the 4 products
-- with the highest price/weight ratio.
(SELECT *
FROM products
ORDER BY price DESC
LIMIT 4)
UNION
(SELECT *
FROM products
ORDER BY price/weight DESC
LIMIT 4);

-- UNION ALL - means dont remove duplicates
-- the results of the two queries in a union must have same columns
-- and the type must be the same

(SELECT *
FROM products
ORDER BY price DESC
LIMIT 4)
EXCEPT
(SELECT *
FROM products
ORDER BY price/weight DESC
LIMIT 4);


-- Subqueries
-- Merging one or more queries
-- List the name and price of all products that are more expensive than all products
-- in the 'Toys' department
SELECT name, price
FROM products
WHERE price > (
	SELECT MAX(price) FROM products WHERE department = 'Toys'
);

-- Only single values are allowed in a SELECT statement in a sub query
SELECT name, price, (
	SELECT MAX(price) FROM products
)
FROM products
WHERE price > 867

SELECT name, price, (
	SELECT price FROM products WHERE id=3
)
FROM products
WHERE price > 867

SELECT name, price, (price / (SELECT MAX(price) FROM phones)) AS price_ratio
FROM phones

-- Subqueries in FROM statements
-- must have an alias
SELECT
  name,
  price_weight_ratio
FROM
  (
    SELECT
      name, price / weight AS price_weight_ratio
    FROM
      products
  ) AS p
WHERE
  price_weight_ratio > 5;

SELECT *
FROM (SELECT MAX(price) FROM products) AS p;

-- Find the average number of orders for all users
SELECT
  AVG(p.order_count)
FROM
  (
    SELECT
      user_id,
      COUNT(*) AS order_count
    FROM
      orders
    GROUP BY
      user_id
  ) AS p;

-- Sub queries in JOIN clause
SELECT
  first_name
FROM
  users
  JOIN (
    SELECT
      user_id
    FROM
      orders
    WHERE
      product_id = 3
  ) AS o
  ON o.user_id = users.id

-- Sub queries in a where clause
-- show the id of orders that involve a product
-- with a price/weight ratio greater than 5
SELECT
  id
FROM
  orders
WHERE
  orders.product_id IN (
    SELECT
      id
    FROM
      products
    WHERE
      price / weight > 50
  );

-- Show the name of all products with a price 
-- greater than the average product price
SELECT name, price
FROM products
WHERE price > (
SELECT AVG(price) FROM products
)

-- show the name of all priducts tat are not in the same
-- department as products with a price less than 100
SELECT
  name,
  department
FROM
  products
WHERE
  department NOT IN (
    SELECT
      department
    FROM
      products
    WHERE
      price < 100
  );

-- show the name, department, and price of products
-- that are more expensive than all products in the 
-- industrial department
SELECT
  name,
  department,
  price
FROM
  products
WHERE
  price > ALL (
    SELECT
      price
    FROM
      products
    WHERE
      department = 'Industrial'
  );


-- Show the name of products that are more expensive than at least
-- one product in the 'Industrial' department
SELECT
  name,
  department,
  price
FROM
  products
WHERE
  price > SOME (
    SELECT
      price
    FROM
      products
    WHERE
      department = 'Industrial'
  );


-- Correlated subqueries
-- means we are refering to a row from the main query in a subquery
-- Show the name, department and price of the most 
-- expensive product in each department
SELECT name, department, price
FROM products AS p1
WHERE p1.price = (
	SELECT MAX(price)
  FROM products AS p2
  WHERE p1.department = p2.department
);

-- print the number of orders for each products
SELECT p1.name, (
	SELECT COUNT(*)
  FROM orders AS o1
  WHERE o1.product_id = p1.id
) AS num_orders
FROM products AS p1

-- FROM-less SELECTs
SELECT
    (SELECT MAX(price) FROM phones)  AS max_price,
    (SELECT MIN(price)  FROM phones) AS min_price,
    (SELECT AVG(price)  FROM phones) AS avg_price
;


-- DISTINCT
SELECT DISTINCT department FROM products;
SELECT COUNT(DISTINCT department) FROM products;
SELECT DISTINCT department, name
FROM products

-- Select greatest value out of a list of values
SELECT name, weight, GREATEST(30, 2* weight)
FROM products;

-- Least
SELECT name, price, GREATEST(400, 0.5*price)
FROM products;

-- Case
-- print each product and its price
-- Also print a description of the price
SELECT
  name,
  price,
  CASE
    WHEN price > 600 THEN 'High'
    WHEN price > 300 THEN 'Medium'
    ELSE 'Cheap'
  END
FROM products;

-- Update values in columns
UPDATE products
SET price = 9999
WHERE price IS NULL