class Config {
  static const int storeId = 2;
  static String get sqlProductsUrl =>
      'http://192.168.0.73:5000/api/stock_items/company/$storeId';
  static const String platformProductsUrl =
      'http://192.168.0.240:7000/products';
  static const String mapProductsUrl = 'http://192.168.0.73:5000/api/products';
  static const String currency = 'MYR';
}
