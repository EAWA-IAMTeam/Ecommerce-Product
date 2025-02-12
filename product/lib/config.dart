class Config {
  static const String storeId = '2';
  static String get sqlProductsUrl =>
      'http://192.168.0.196:8100/stock_items/company/$storeId';
  static const String platformProductsUrl =
      'http://192.168.0.196:8100/lazada/$storeId';
  static const String mapProductsUrl = 'http://192.168.0.196:8100/products';
  static const String currency = 'MYR';
  static const String apiBaseUrl = 'http://192.168.0.196:8100';
}
