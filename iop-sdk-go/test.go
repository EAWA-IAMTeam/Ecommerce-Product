// package main

// import (
// 	"database/sql"
// 	"encoding/json"
// 	"net/http"

// 	"github.com/labstack/echo/v4"
// 	_ "github.com/lib/pq"
// )

// // Define response structure
// type ProductResponse struct {
// 	Data struct {
// 		Products []Product `json:"products"`
// 	} `json:"data"`
// }

// type Product struct {
// 	Skus []Sku `json:"skus"`
// }

// type Sku struct {
// 	Status                    string               `json:"Status"`
// 	Quantity                  int                  `json:"quantity"`
// 	Images                    []string             `json:"Images"`
// 	Color                     string               `json:"Color,omitempty"`
// 	SellerSku                 string               `json:"SellerSku"`
// 	ShopSku                   string               `json:"ShopSku,omitempty"`
// 	Url                       string               `json:"Url"`
// 	SaleProp                  map[string]string    `json:"saleProp"`
// 	MultiWarehouseInventories []WarehouseInventory `json:"multiWarehouseInventories"`
// 	PackageWidth              string               `json:"package_width"`
// 	PackageHeight             string               `json:"package_height"`
// 	FblWarehouseInventories   []interface{}        `json:"fblWarehouseInventories"`
// 	SpecialPrice              float64              `json:"special_price"`
// 	Price                     float64              `json:"price"`
// 	ChannelInventories        []interface{}        `json:"channelInventories"`
// 	PackageLength             string               `json:"package_length"`
// 	Available                 int                  `json:"Available"`
// 	PackageWeight             string               `json:"package_weight"`
// 	SkuId                     int64                `json:"SkuId"`
// }

// type WarehouseInventory struct {
// 	OccupyQuantity   int    `json:"occupyQuantity"`
// 	Quantity         int    `json:"quantity"`
// 	TotalQuantity    int    `json:"totalQuantity"`
// 	WithholdQuantity int    `json:"withholdQuantity"`
// 	WarehouseCode    string `json:"warehouseCode"`
// 	SellableQuantity int    `json:"sellableQuantity"`
// }

// // Function to fetch ShopSkus from PostgreSQL
// func getBlockedShopSkus(db *sql.DB) (map[string]bool, error) {
// 	query := "SELECT sku FROM storeproduct"
// 	rows, err := db.Query(query)
// 	if err != nil {
// 		return nil, err
// 	}
// 	defer rows.Close()

// 	blockedSkus := make(map[string]bool)
// 	for rows.Next() {
// 		var sku string
// 		if err := rows.Scan(&sku); err != nil {
// 			return nil, err
// 		}
// 		blockedSkus[sku] = true
// 	}
// 	return blockedSkus, nil
// }

// // Function to remove ShopSku from JSON
// func filterShopSkus(getResult []byte, db *sql.DB) ([]byte, error) {
// 	blockedSkus, err := getBlockedShopSkus(db)
// 	if err != nil {
// 		return nil, err
// 	}

// 	// Parse JSON response
// 	var response ProductResponse
// 	if err := json.Unmarshal(getResult, &response); err != nil {
// 		return nil, err
// 	}

// 	// Remove ShopSku if it's in the database
// 	for i := range response.Data.Products {
// 		for j := range response.Data.Products[i].Skus {
// 			if blockedSkus[response.Data.Products[i].Skus[j].ShopSku] {
// 				response.Data.Products[i].Skus[j].ShopSku = ""
// 			}
// 		}
// 	}

// 	// Convert back to JSON
// 	return json.Marshal(response)
// }

// // Updated Echo handler function
// func getProducts(c echo.Context) error {
// 	// Execute API call
// 	getResult, err := client.Execute("/products/get", "GET", nil)
// 	if err != nil {
// 		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to fetch products: " + err.Error()})
// 	}

// 	// Connect to PostgreSQL
// 	connStr := "host=192.168.0.235 user=postgres password=postgres dbname=postgres sslmode=disable"
// 	db, err := sql.Open("postgres", connStr)
// 	if err != nil {
// 		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Database connection failed: " + err.Error()})
// 	}
// 	defer db.Close()

// 	// Filter ShopSku from JSON response
// 	filteredJSON, err := filterShopSkus(getResult, db)
// 	if err != nil {
// 		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to filter ShopSku: " + err.Error()})
// 	}

// 	// Send filtered response
// 	return c.JSONBlob(http.StatusOK, filteredJSON)
// }
