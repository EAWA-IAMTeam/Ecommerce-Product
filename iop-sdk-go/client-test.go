package main

import (
	"context"
	"encoding/json"
	"fmt"
	"iop-go-sdk/iop"
	"log"
	"net/http"

	"github.com/jackc/pgx/v5"
	"github.com/labstack/echo/v4"
)

// Database connection settings
const (
	host     = "192.168.0.235"
	port     = "5432"
	dbname   = "postgres"
	user     = "postgres"
	password = "postgres"
)

// Define product structure
type Product struct {
    ItemID     int      `json:"item_id"`
    Status     string      `json:"status"`
    Images     []string `json:"images"` // List of product images
    Skus       []Sku    `json:"skus"`
    Attributes struct {
        Name string `json:"name"`
		Description     string      `json:"description"`
    } `json:"attributes"`
}

type Sku struct {
	ShopSku      string  `json:"ShopSku"`
 	Images     []string  `json:"Images"` // List of SKU images
	Quantity     int     `json:"quantity"`
	Price        float64 `json:"price"`
	SpecialPrice float64 `json:"special_price"`
}

type ApiResponse struct {
	Code string `json:"code"`
	Data struct {
		Products []Product `json:"products"`
	} `json:"data"`
}

// Declare global client
var client *iop.IopClient

func init() {
	appKey := "131165"
	appSecret := "0XTLuKkYYtdMhahQn8fQxehaXXSJOv5x"

	clientOptions := iop.ClientOptions{
		APIKey:    appKey,
		APISecret: appSecret,
		Region:    "MY",
	}

	client = iop.NewClient(&clientOptions)
	client.SetAccessToken("50000001c15clcgXddQ4nzUdiEt1974f9d1GYDRz9hYmQxcLoWqmqyaeubxzvXOK")
}

// Function to fetch SKUs to remove from the database
func getStoreSkus(storeID string) (map[string]bool, error) {
	// Database connection string
	connStr := fmt.Sprintf("host=%s port=%s dbname=%s user=%s password=%s sslmode=disable",
		host, port, dbname, user, password)

	// Open database connection
	conn, err := pgx.Connect(context.Background(), connStr)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %v", err)
	}
	defer conn.Close(context.Background())

	// Query to get SKUs based on store_id
	query := "SELECT sku FROM storeproduct WHERE store_id = $1"
	rows, err := conn.Query(context.Background(), query, storeID)
	if err != nil {
		return nil, fmt.Errorf("failed to query database: %v", err)
	}
	defer rows.Close()

	// Map to store SKUs to remove
	skus := make(map[string]bool)

	// Read data from query result
	for rows.Next() {
		var sku string
		if err := rows.Scan(&sku); err != nil {
			return nil, fmt.Errorf("failed to scan row: %v", err)
		}
		skus[sku] = true
	}

	// Check for errors in iteration
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating rows: %v", err)
	}

	return skus, nil
}

// API handler to get products
func getFilteredProducts(c echo.Context) error {
	// Get store_id from query parameters
	storeID := c.QueryParam("store_id")
	if storeID == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "store_id is required"})
	}

	// Fetch SKUs to remove from database
	skusToRemove, err := getStoreSkus(storeID)
	if err != nil {
		log.Println("Error fetching SKUs: ", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to retrieve SKU list"})
	}

	// Call the API
	resp, err := client.Execute("/products/get", "GET", nil)
	if err != nil {
		log.Println("Error making API call: ", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to fetch products"})
	}

	// Convert response to JSON
	responseBytes, err := json.Marshal(resp)
	if err != nil {
		log.Println("Error converting response to JSON: ", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to process response"})
	}

	// Decode response into ApiResponse struct
	var apiResponse ApiResponse
	err = json.Unmarshal(responseBytes, &apiResponse)
	if err != nil {
		log.Println("Error decoding response: ", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to parse response"})
	}

	// Lists for filtered products
	var unmappedProducts []Product // Products with at least one unremoved SKU
	var mappedProducts []Product // Products with at least one removed SKU

	for _, product := range apiResponse.Data.Products {
		var remainingSkus []Sku // SKUs that are **not** removed
		var removedSkus []Sku   // SKUs that are **removed**

		for _, sku := range product.Skus {
			if skusToRemove[sku.ShopSku] {
				removedSkus = append(removedSkus, sku) // Add to removed list
			} else {
				remainingSkus = append(remainingSkus, sku) // Keep in updated list
			}
		}

		// If some SKUs are removed but some remain, add to both lists
		if len(remainingSkus) > 0 {
			updatedProduct := product
			updatedProduct.Skus = remainingSkus
			unmappedProducts = append(unmappedProducts, updatedProduct)
		}

		if len(removedSkus) > 0 {
			removedProduct := product
			removedProduct.Skus = removedSkus
			mappedProducts = append(mappedProducts, removedProduct)
		}
	}

	// Return JSON response
	return c.JSON(http.StatusOK, map[string]interface{}{
		"unmapped_products": unmappedProducts,
		"mapped_products": mappedProducts,
	})
}

func main() {
	e := echo.New()

	// Define API routes
	e.GET("/products", getFilteredProducts)

	// Start server
	port := "7000"
	address := "192.168.0.73:" + port
	fmt.Println("Server running on", address)
	e.Logger.Fatal(e.Start(address))
}
