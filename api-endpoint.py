import logging
from flask import Flask, jsonify, request, abort
from flask_cors import CORS
from argparse import ArgumentParser

# Configure logging
logging.basicConfig(level=logging.DEBUG)

# Hardcoded product data
products_data = [
    {"id": 1, "name": "Smartphone", "description": "Latest model smartphone with advanced features", "platform": "Shopee", "stock": 100, "sku": "SM12345", "currency": "USD", "price": 799.99, "status": "available", "created_at": "2025-01-23 10:00:00", "updated_at": "2025-01-23 10:00:00"},
    {"id": 2, "name": "Laptop", "description": "High-performance laptop for professionals", "platform": "Shopee", "stock": 50, "sku": "LP67890", "currency": "USD", "price": 1200.00, "status": "available", "created_at": "2025-01-23 10:00:00", "updated_at": "2025-01-23 10:00:00"},
    {"id": 3, "name": "Tablet", "description": "Portable tablet with a sleek design", "platform": "Shopee", "stock": 75, "sku": "TB11223", "currency": "USD", "price": 499.99, "status": "available", "created_at": "2025-01-23 10:00:00", "updated_at": "2025-01-23 10:00:00"},
    {"id": 4, "name": "Smartwatch", "description": "Stylish smartwatch with health tracking features", "platform": "Lazada", "stock": 200, "sku": "SW33445", "currency": "USD", "price": 199.99, "status": "available", "created_at": "2025-01-23 10:00:00", "updated_at": "2025-01-23 10:00:00"},
    {"id": 5, "name": "Headphones", "description": "Noise-cancelling over-ear headphones", "platform": "Lazada", "stock": 150, "sku": "HP55667", "currency": "USD", "price": 149.99, "status": "available", "created_at": "2025-01-23 10:00:00", "updated_at": "2025-01-23 10:00:00"},
    {"id": 6, "name": "Camera", "description": "DSLR camera for professional photography", "platform": "Lazada", "stock": 30, "sku": "CM77889", "currency": "USD", "price": 999.99, "status": "available", "created_at": "2025-01-23 10:00:00", "updated_at": "2025-01-23 10:00:00"},
    {"id": 7, "name": "Gaming Console", "description": "Next-gen gaming console", "platform": "Tiktok", "stock": 40, "sku": "GC99001", "currency": "USD", "price": 499.99, "status": "available", "created_at": "2025-01-23 10:00:00", "updated_at": "2025-01-23 10:00:00"},
    {"id": 8, "name": "Printer", "description": "All-in-one wireless printer", "platform": "Tiktok", "stock": 60, "sku": "PR22334", "currency": "USD", "price": 199.99, "status": "available", "created_at": "2025-01-23 10:00:00", "updated_at": "2025-01-23 10:00:00"},
    {"id": 9, "name": "Monitor", "description": "Ultra-wide 4K monitor", "platform": "Tiktok", "stock": 25, "sku": "MN44556", "currency": "USD", "price": 349.99, "status": "available", "created_at": "2025-01-23 10:00:00", "updated_at": "2025-01-23 10:00:00"}
]

app = Flask(__name__)
CORS(app)

# Helper function to fetch product by ID
def get_product_by_id(product_id):
    return next((product for product in products_data if product["id"] == product_id), None)

@app.route('/api/products', methods=['GET'])
def products():
    return jsonify(products_data), 200

@app.route('/api/products/<int:product_id>', methods=['GET'])
def product(product_id):
    product = get_product_by_id(product_id)
    if product:
        return jsonify(product), 200
    else:
        return jsonify({'error': 'Product not found'}), 404

@app.route('/api/shopee_auth', methods=['POST'])
def shopeeAuth():
    if not request.json:
        logging.debug('Invalid request: No JSON body provided.')
        abort(400)  # Use 400 for bad requests

    # Check required parameters
    required_params = ['sign', 'partner_id', 'timestamp', 'code']
    for param in required_params:
        if param not in request.json:
            logging.debug(f"Missing required parameter: {param}")
            abort(400)

    # Check shop_id or main_account_id
    if 'shop_id' not in request.json and 'main_account_id' not in request.json:
        logging.debug("Missing either 'shop_id' or 'main_account_id'.")
        abort(400)

    response = {
        'id': "1",
        'request_id': "12345",
        'error': "none",
        'refresh_token': "refresh_token_abc123",
        'access_token': "access_token_xyz789",
        'expire_in': "3600",
        'message': "Success",
    }

    if 'main_account_id' in request.json:
        response.update({
            'merchant_id_list': ["merchant_1", "merchant_2"],
            'shop_id_list': ["shop_1", "shop_2"]
        })

    return jsonify(response), 201

if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('-p', '--port', default=5000, type=int, help='port to listen on')
    args = parser.parse_args()
    port = args.port

    app.run(debug=True, host='0.0.0.0', port=port)
