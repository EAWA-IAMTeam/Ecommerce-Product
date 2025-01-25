import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'MappedProductsPage.dart';

// TODO: add pages, setup database, add env variables for ip address

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link Product',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: LinkProductPage(),
    );
  }
}

class LinkProductPage extends StatefulWidget {
  @override
  _LinkProductPageState createState() => _LinkProductPageState();
}

class _LinkProductPageState extends State<LinkProductPage> {
  List<dynamic> sqlProducts = [];
  List<dynamic> platformProducts = [];
  dynamic selectedSQLProduct; // To store the whole SQL product object
  Set<dynamic> selectedPlatformProducts =
      {}; // To store the whole platform product objects

  Future<void> fetchSQLProducts() async {
    final response = await http.get(Uri.parse(
        'http://192.168.0.73:5000/api/stock_items/company/2')); //change according to server ip and port and endpoints

    if (response.statusCode == 200) {
      setState(() {
        sqlProducts = json.decode(response.body);
      });
    } else {
      print('Failed to load SQL products');
    }
  }

  Future<void> fetchPlatformProducts() async {
    final response = await http.get(Uri.parse(
        'http://192.168.0.73:7000/products')); //change according to server ip and port and endpoints

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        platformProducts = data['data']['products'];
      });
    } else {
      print('Failed to load platform products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Company ID: 10002',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20), // Add spacing below the text
            Expanded(
              child: Row(
                children: [
                  // SQL Products List
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'SQL Inventory',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: fetchSQLProducts,
                          child: Text('Fetch SQL Products'),
                        ),
                        Expanded(
                          child: sqlProducts.isEmpty
                              ? Center(child: Text('No Data'))
                              : ListView.builder(
                                  itemCount: sqlProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = sqlProducts[index];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedSQLProduct = sqlProducts[
                                              index]; // Store the entire product object
                                        });
                                      },
                                      child: Card(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Radio<dynamic>(
                                                value: sqlProducts[
                                                    index], // Set the product object as the value
                                                groupValue: selectedSQLProduct,
                                                onChanged: (dynamic value) {
                                                  setState(() {
                                                    selectedSQLProduct =
                                                        value; // Store the entire product object
                                                  });
                                                },
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        'Stock Code: ${product['stock_code']}'),
                                                    Text(
                                                        'Description: ${product['description']}'),
                                                    Text(
                                                        'Quantity: ${product['quantity']}'),
                                                    Text(
                                                        'Reserved Quantity: ${product['reserved_quantity']}'),
                                                    Text(
                                                        'Weight: ${product['weight']} kg'),
                                                    Text(
                                                        'Ref. Cost (MYR): ${product['ref_cost'].toStringAsFixed(2)}'),
                                                    // Optionally display more information:
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(),
                  // Platform Products List (unchanged)
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Platform Product',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: fetchPlatformProducts,
                          child: Text('Fetch Platform Products'),
                        ),
                        Expanded(
                          child: platformProducts.isEmpty
                              ? Center(child: Text('No Data'))
                              : ListView.builder(
                                  itemCount: platformProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = platformProducts[index];
                                    final skus =
                                        product['skus'] as List<dynamic>;

                                    // Safely get the short description
                                    final shortDescription =
                                        product['attributes']
                                            ['short_description'];
                                    final plainTextDescription =
                                        shortDescription != null
                                            ? html_parser
                                                    .parse(shortDescription)
                                                    .documentElement
                                                    ?.text
                                                    ?.trim() ??
                                                ''
                                            : 'No description available';

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (selectedPlatformProducts.contains(
                                              platformProducts[index])) {
                                            selectedPlatformProducts.remove(
                                                platformProducts[index]);
                                          } else {
                                            selectedPlatformProducts
                                                .add(platformProducts[index]);
                                          }
                                        });
                                      },
                                      child: Card(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Common attributes
                                              Row(
                                                children: [
                                                  Checkbox(
                                                    value:
                                                        selectedPlatformProducts
                                                            .contains(
                                                                platformProducts[
                                                                    index]),
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        if (value == true) {
                                                          selectedPlatformProducts
                                                              .add(
                                                                  platformProducts[
                                                                      index]);
                                                        } else {
                                                          selectedPlatformProducts
                                                              .remove(
                                                                  platformProducts[
                                                                      index]);
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            'Item ID: ${product['item_id']}'),
                                                        Text(
                                                            'Name: ${product['attributes']['name']}'),
                                                        Text(
                                                            'Short Description: \n$plainTextDescription'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8.0),

                                              // SKU-specific attributes
                                              ...skus.map((sku) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'SKU: ${sku['ShopSku']}'),
                                                      Text(
                                                          'Quantity: ${sku['quantity']}'),
                                                      Text(
                                                          'Status: ${sku['Status']}'),
                                                      Text(
                                                          'Price (MYR): ${sku['price'].toStringAsFixed(2)}'),
                                                      Text(
                                                          'Special Price (MYR): ${sku['special_price'].toStringAsFixed(2)}'),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (selectedSQLProduct != null) {
                  print("Selected SQL Product: ${selectedSQLProduct['id']}");

                  List<Map<String, dynamic>> products = selectedPlatformProducts
                      .expand((product) => product['skus'])
                      .map((sku) {
                    return {
                      'stock_item_id': selectedSQLProduct['id'],
                      'price': sku['price'],
                      'discounted_price': sku['special_price'],
                      'sku': sku['ShopSku'],
                      'currency': 'MYR', // change according to currency
                      'status': sku['Status'],
                    };
                  }).toList();

// Print the products list for checking
                  print('Products List:');
                  products.forEach((product) {
                    print(product);
                  });
                  Map<String, dynamic> requestBody = {
                    'store_id': 2, // Change according to store id
                    'products': products,
                  };

// Print the requestBody for checking
                  print('Request Body:');
                  print(requestBody);

                  // Call the API
                  try {
                    final response = await http.post(
                      Uri.parse('http://192.168.0.73:5000/api/products'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(requestBody),
                    );

                    if (response.statusCode == 201) {
                      print('Products inserted successfully');
                    } else {
                      print('Failed to insert products: ${response.body}');
                    }
                  } catch (e) {
                    print('Error making the API request: $e');
                  }
                } else {
                  print("No SQL product selected");
                }
              },
              child: Text('Map'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the mapped products page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MappedProductsPage(storeId: 2),
                  ),
                );
              },
              child: Text('View Mapped Products'),
            ),
          ],
        ),
      ),
    );
  }
}
