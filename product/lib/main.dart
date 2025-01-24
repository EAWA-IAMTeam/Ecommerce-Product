import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

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
  int? selectedSQLProductIndex; // To allow only one SQL product selection
  Set<int> selectedPlatformProductIndices =
      {}; // To track selected platform products

  Future<void> fetchSQLProducts() async {
    final response = await http.get(
        Uri.parse('http://192.168.0.73:5000/api/stock_items/company/10002'));

    if (response.statusCode == 200) {
      setState(() {
        sqlProducts = json.decode(response.body);
      });
    } else {
      print('Failed to load SQL products');
    }
  }

  Future<void> fetchPlatformProducts() async {
    final response =
        await http.get(Uri.parse('http://192.168.0.73:7000/products'));

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
                                          selectedSQLProductIndex = index;
                                        });
                                      },
                                      child: Card(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Radio<int>(
                                                value: index,
                                                groupValue:
                                                    selectedSQLProductIndex,
                                                onChanged: (int? value) {
                                                  setState(() {
                                                    selectedSQLProductIndex =
                                                        value;
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
                                                        'Ref. Cost (MYR): ${product['ref_cost']}'),
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
                                    final sku =
                                        skus.isNotEmpty ? skus[0] : null;

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
                                          if (selectedPlatformProductIndices
                                              .contains(index)) {
                                            selectedPlatformProductIndices
                                                .remove(index);
                                          } else {
                                            selectedPlatformProductIndices
                                                .add(index);
                                          }
                                        });
                                      },
                                      child: Card(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                value:
                                                    selectedPlatformProductIndices
                                                        .contains(index),
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    if (value == true) {
                                                      selectedPlatformProductIndices
                                                          .add(index);
                                                    } else {
                                                      selectedPlatformProductIndices
                                                          .remove(index);
                                                    }
                                                  });
                                                },
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        'Item ID: ${product['item_id']}'),
                                                    Text(
                                                        'Name: ${product['attributes']['name']}'),
                                                    Text(
                                                        'Short Description: \n$plainTextDescription'),
                                                    if (sku != null) ...[
                                                      Text(
                                                          'Quantity: ${sku['quantity']}'),
                                                      Text(
                                                          'Price (MYR): ${sku['price']}'),
                                                    ],
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
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Print the ID of the selected SQL product
                if (selectedSQLProductIndex != null) {
                  final selectedSQLProduct =
                      sqlProducts[selectedSQLProductIndex!];
                  print("Selected SQL Product ID: ${selectedSQLProduct['id']}");
                } else {
                  print("No SQL product selected");
                }

                // Print the IDs of the selected platform products
                if (selectedPlatformProductIndices.isNotEmpty) {
                  selectedPlatformProductIndices.forEach((index) {
                    final selectedPlatformProduct = platformProducts[index];
                    print(
                        "Selected Platform Product ID: ${selectedPlatformProduct['item_id']}");
                  });
                } else {
                  print("No platform products selected");
                }
              },
              child: Text('Map'),
            ),
          ],
        ),
      ),
    );
  }
}
