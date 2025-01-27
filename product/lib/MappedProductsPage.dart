import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MappedProductsPage extends StatefulWidget {
  final int storeId; // Pass storeId as parameter to the page

  MappedProductsPage({required this.storeId});

  @override
  _MappedProductsPageState createState() => _MappedProductsPageState();
}

class _MappedProductsPageState extends State<MappedProductsPage> {
  late Future<List<Map<String, dynamic>>> mappedProducts;

  @override
  void initState() {
    super.initState();
    // Fetch products when the widget is initialized
    mappedProducts = fetchProducts(widget.storeId);
  }

  Future<List<Map<String, dynamic>>> fetchProducts(int storeId) async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.0.73:5000/api/products?store_id=$storeId'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((product) {
          return {
            'id': product['id'],
            'price': product['price'],
            'discounted_price': product['discounted_price'],
            'sku': product['sku'],
            'currency': product['currency'],
            'status': product['status'],
            'stock_item_id': product['stock_item_id'],
          };
        }).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapped Products'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: mappedProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No mapped products found'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      'Product ID: ${product['id']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: ${product['price']} MYR'),
                        Text(
                            'Discounted Price: ${product['discounted_price']} MYR'),
                        Text('SKU: ${product['sku']}'),
                        Text('Currency: ${product['currency']}'),
                        Text('Status: ${product['status']}'),
                        Text('Stock Item ID: ${product['stock_item_id']}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
