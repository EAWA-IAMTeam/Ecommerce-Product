import psycopg2
from psycopg2 import OperationalError
import datetime

def get_products(store_id = "2"):
    try:
        # Connect to your postgres DB
        connection = psycopg2.connect(
            host="192.168.0.235",  # change according to database ip address
            port="5432",
            database="postgres",  # Replace with your database name
            user="postgres",
            password="postgres"
        )
        
        # Create a cursor object
        cursor = connection.cursor()

        # Write the SQL query to select data from stockitem where company_id = 2
        query = """
            SELECT id, price, discounted_price, sku, currency, status
            FROM storeproduct
            WHERE store_id = """ + store_id + ";"    
            
        # Execute the query
        cursor.execute(query)

        # Fetch all results
        store_product = cursor.fetchall()

        # Prepare the result in the format of the sample data
        storeproduct_data = []
        for product in store_product:
            storeproduct_data.append({
                "id": product[0],
                "price": product[1],
                "discounted_price": product[2],
                "sku": product[3],
                "currency": product[4],
                "status": product[5]
            })

        # Print the results
        print("Store Product for Store ID = " + store_id + " is retrieved successfully")
        
        # Close the cursor and connection
        cursor.close()
        connection.close()
        
        # Return the results as a list of dictionaries
        return storeproduct_data

    except OperationalError as e:
        print(f"Error connecting to PostgreSQL: {e}")

# def insert_product(store_id, stock_item_id, price, discounted_price, sku, currency, status):
#     try:
#         # Connect to your postgres DB
#         connection = psycopg2.connect(
#             host="192.168.0.235",  # Change according to database IP address
#             port="5432",
#             database="postgres",  # Replace with your database name
#             user="postgres",
#             password="postgres"
#         )
        
#         # Create a cursor object
#         cursor = connection.cursor()

#         # Write the SQL query to insert data into the storeproduct table
#         query = """
#             INSERT INTO storeproduct (store_id, stock_item_id, price, discounted_price, created_at, updated_at, sku, currency, status)
#             VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);
#         """

#         # Data to be inserted
#         values = (
#             store_id,
#             stock_item_id,
#             price,
#             discounted_price,
#             'NOW()',  # Use current timestamp for created_at
#             'NOW()',  # Use current timestamp for updated_at
#             sku,
#             currency,
#             status
#         )

#         # Execute the query with values
#         cursor.execute(query, values)

#         # Commit the transaction
#         connection.commit()

#         print("Product inserted successfully into storeproduct table.")

#         # Close the cursor and connection
#         cursor.close()
#         connection.close()

#     except OperationalError as e:
#         print(f"Error connecting to PostgreSQL: {e}")
#     except Exception as e:
#         print(f"Error: {e}")

def insert_product(store_id, products):
    try:
        # Connect to your postgres DB
        with psycopg2.connect(
            host="192.168.0.235",  # Change according to database IP address
            port="5432",
            database="postgres",  # Replace with your database name
            user="postgres",
            password="postgres"
        ) as connection:
            with connection.cursor() as cursor:
                # Write the SQL query to insert data into the storeproduct table
                query = """
                    INSERT INTO storeproduct (store_id, stock_item_id, price, discounted_price, created_at, updated_at, sku, currency, status)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);
                """
                
                # Get the current timestamp
                current_timestamp = datetime.datetime.now()

                # Prepare data for insertion
                values = [
                    (
                        store_id,
                        product['stock_item_id'],
                        product['price'],
                        product['discounted_price'],
                        current_timestamp,  # Use current timestamp for created_at
                        current_timestamp,  # Use current timestamp for updated_at
                        product['sku'],
                        product['currency'],
                        product['status']
                    )
                    for product in products
                ]

                # Execute the query with multiple values
                cursor.executemany(query, values)

                # Commit the transaction
                connection.commit()

                print(f"{len(products)} products inserted successfully into storeproduct table.")
                return True
    except OperationalError as e:
        print(f"Error connecting to PostgreSQL: {e}")
    except Exception as e:
        print(f"Error: {e}")
    return False

# Example usage: Insert a product
# insert_product(
#     store_id=2,
#     stock_item_id = 9,
#     price=100.0,
#     discounted_price=80.0,
#     sku="SKU12345",
#     currency="USD",
#     status="available"
# )

# Call the function to insert products
# get_products()

store_id = 2
products = [
    {
        "stock_item_id": 1,
        "price": 19.99,
        "discounted_price": 14.99,
        "sku": "SKU101",
        "currency": "USD",
        "status": "active"
    },
    {
        "stock_item_id": 2,
        "price": 29.99,
        "discounted_price": 19.99,
        "sku": "SKU102",
        "currency": "USD",
        "status": "active"
    }
]

# Call the insert_product function to insert the products
insert_product(store_id, products)