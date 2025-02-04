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
	"github.com/labstack/echo/v4/middleware"
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
	Images     []string `json:"images"` // List of product images
	Skus       []Sku    `json:"skus"`
	Attributes struct {
		Name string `json:"name"`
	} `json:"attributes"`
}

type Sku struct {
	ShopSku      string   `json:"ShopSku"`
	Images       []string `json:"Images"` // List of SKU images
	Quantity     int      `json:"quantity"`
	Price        float64  `json:"price"`
	SpecialPrice float64  `json:"special_price"`
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
func getSkusToRemove(storeID string) (map[string]bool, error) {
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
	skusToRemove := make(map[string]bool)

	// Read data from query result
	for rows.Next() {
		var sku string
		if err := rows.Scan(&sku); err != nil {
			return nil, fmt.Errorf("failed to scan row: %v", err)
		}
		skusToRemove[sku] = true
	}

	// Check for errors in iteration
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating rows: %v", err)
	}

	return skusToRemove, nil
}

// API handler to get products
func getFilteredProducts(c echo.Context) error {
	// Get store_id from query parameters
	storeID := c.QueryParam("store_id")
	if storeID == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "store_id is required"})
	}

	// Fetch SKUs to remove from database
	skusToRemove, err := getSkusToRemove(storeID)
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
	var updatedProducts []Product // Products with at least one unremoved SKU
	var removedProducts []Product // Products with at least one removed SKU

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
			updatedProducts = append(updatedProducts, updatedProduct)
		}

		if len(removedSkus) > 0 {
			removedProduct := product
			removedProduct.Skus = removedSkus
			removedProducts = append(removedProducts, removedProduct)
		}
	}

	// Return JSON response
	return c.JSON(http.StatusOK, map[string]interface{}{
		"updated_products": updatedProducts,
		"removed_products": removedProducts,
	})
}

// func CORSMiddleware(next echo.HandlerFunc) echo.HandlerFunc {
// 	return func(c echo.Context) error {
// 		c.Response().Header().Set("Access-Control-Allow-Origin", "*")
// 		c.Response().Header().Set("Access-Control-Allow-Credentials", "true")
// 		c.Response().Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
// 		c.Response().Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT")

// 		if c.Request().Method == http.MethodOptions {
// 			return c.NoContent(http.StatusNoContent)
// 		}

// 		return next(c)
// 	}
// }

func main() {
	e := echo.New()

	// Apply built-in CORS middleware
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins:     []string{"*"}, // Change "*" to specific frontend URLs if needed
		AllowMethods:     []string{echo.GET, echo.POST, echo.PUT, echo.DELETE, echo.OPTIONS},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"},
		AllowCredentials: true,
	}))

	// Define API routes
	e.GET("/products", getFilteredProducts)

	// Start server
	port := "7000"
	address := "192.168.0.240:" + port
	fmt.Println("Server running on", address)
	e.Logger.Fatal(e.Start(address))
}
