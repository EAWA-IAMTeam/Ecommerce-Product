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

stockItem_data = [
    {"id": 1, "company_id": 10002, "stock_code": "laptop/lenovo", "stock_control": True, "ref_cost": 99.99, "weight": 11.1, "height": 11.1, "width": 11.1, "length": 11.1, "variation1": "variation1", "variation2": "variation2", "reserved_quantity": 10, "quantity": 100, "created_at": "2025-01-23 10:00:00", "updated_at": "2025-01-23 10:00:00", "platform": "Lazada", "description": "Next-gen gaming console", "status": True},
    {"id": 2, "company_id": 10002, "stock_code": "tablet/samsung", "stock_control": True, "ref_cost": 199.99, "weight": 0.5, "height": 7.8, "width": 5.5, "length": 0.3, "variation1": "color", "variation2": "storage", "reserved_quantity": 5, "quantity": 50, "created_at": "2025-01-23 10:10:00", "updated_at": "2025-01-23 10:10:00", "platform": "Shopee", "description": "Portable tablet for work and play", "status": True},
    {"id": 3, "company_id": 10002, "stock_code": "phone/apple", "stock_control": True, "ref_cost": 899.99, "weight": 0.3, "height": 6.2, "width": 2.8, "length": 0.3, "variation1": "color", "variation2": "model", "reserved_quantity": 2, "quantity": 30, "created_at": "2025-01-23 10:20:00", "updated_at": "2025-01-23 10:20:00", "platform": "TikTok", "description": "Latest Apple smartphone", "status": True},
    {"id": 4, "company_id": 3, "stock_code": "tv/samsung", "stock_control": True, "ref_cost": 499.99, "weight": 5.5, "height": 42, "width": 60, "length": 3, "variation1": "size", "variation2": "resolution", "reserved_quantity": 8, "quantity": 40, "created_at": "2025-01-23 10:30:00", "updated_at": "2025-01-23 10:30:00", "platform": "Lazada", "description": "Ultra HD Smart TV", "status": True},
    {"id": 5, "company_id": 3, "stock_code": "headphones/bose", "stock_control": True, "ref_cost": 299.99, "weight": 0.5, "height": 7.5, "width": 7.5, "length": 2.5, "variation1": "color", "variation2": "type", "reserved_quantity": 3, "quantity": 25, "created_at": "2025-01-23 10:40:00", "updated_at": "2025-01-23 10:40:00", "platform": "Shopee", "description": "Noise-cancelling headphones", "status": True},
    {"id": 6, "company_id": 10002, "stock_code": "smartwatch/apple", "stock_control": True, "ref_cost": 199.99, "weight": 0.2, "height": 4.5, "width": 4.5, "length": 0.5, "variation1": "band", "variation2": "color", "reserved_quantity": 4, "quantity": 20, "created_at": "2025-01-23 10:50:00", "updated_at": "2025-01-23 10:50:00", "platform": "TikTok", "description": "Smartwatch with health tracking", "status": True},
    {"id": 7, "company_id": 1, "stock_code": "keyboard/logitech", "stock_control": True, "ref_cost": 79.99, "weight": 1.0, "height": 4.5, "width": 17, "length": 0.8, "variation1": "layout", "variation2": "color", "reserved_quantity": 1, "quantity": 15, "created_at": "2025-01-23 11:00:00", "updated_at": "2025-01-23 11:00:00", "platform": "Lazada", "description": "Mechanical keyboard", "status": True},
    {"id": 8, "company_id": 1, "stock_code": "mouse/razer", "stock_control": True, "ref_cost": 49.99, "weight": 0.3, "height": 4.0, "width": 6.0, "length": 1.5, "variation1": "color", "variation2": "type", "reserved_quantity": 0, "quantity": 12, "created_at": "2025-01-23 11:10:00", "updated_at": "2025-01-23 11:10:00", "platform": "Shopee", "description": "High-precision gaming mouse", "status": True},
    {"id": 9, "company_id": 10002, "stock_code": "monitor/dell", "stock_control": True, "ref_cost": 219.99, "weight": 3.5, "height": 16, "width": 24, "length": 5, "variation1": "size", "variation2": "resolution", "reserved_quantity": 6, "quantity": 18, "created_at": "2025-01-23 11:20:00", "updated_at": "2025-01-23 11:20:00", "platform": "TikTok", "description": "Full HD Monitor", "status": True},
    {"id": 10, "company_id": 1, "stock_code": "speakers/jbl", "stock_control": True, "ref_cost": 129.99, "weight": 1.2, "height": 7, "width": 7, "length": 7, "variation1": "color", "variation2": "type", "reserved_quantity": 4, "quantity": 22, "created_at": "2025-01-23 11:30:00", "updated_at": "2025-01-23 11:30:00", "platform": "Lazada", "description": "Portable Bluetooth speakers", "status": True}
]

app = Flask(__name__)
CORS(app)

@app.route('/api/stock_items/company/<int:company_id>', methods=['GET'])
def stock_items_by_company(company_id):
    # Filter stock items based on company_id
    filtered_stock_items = [item for item in stockItem_data if item['company_id'] == company_id]
    if filtered_stock_items:
        return jsonify(filtered_stock_items), 200
    else:
        return jsonify({'error': 'Stock items not found for the given company_id'}), 404

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
