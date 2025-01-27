package main

import (
	"iop-go-sdk/iop"
	"log"
	"net/http"

	"github.com/labstack/echo/v4"
)

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

func CORSMiddleware(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		c.Response().Header().Set("Access-Control-Allow-Origin", "*")
		c.Response().Header().Set("Access-Control-Allow-Credentials", "true")
		c.Response().Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Response().Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT")

		if c.Request().Method == http.MethodOptions {
			return c.NoContent(http.StatusNoContent)
		}

		return next(c)
	}
}

func getProducts(c echo.Context) error {
	// client.AddAPIParam("limit", "10")
	// client.AddAPIParam("offset", "0")

	getResult, err := client.Execute("/products/get", "GET", nil)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to fetch products: " + err.Error()})
	}

	return c.JSON(http.StatusOK, getResult)
}

func main() {
	e := echo.New()

	// Apply the CORS middleware
	e.Use(CORSMiddleware)

	e.GET("/products", getProducts)

	// Replace "0.0.0.0" with your machine's local IP address
	serverAddress := "192.168.0.240:7000" // change according to your ip address and port

	log.Printf("Server running on http://%s", serverAddress)
	if err := e.Start(serverAddress); err != nil {
		log.Fatal("Failed to run server: ", err)
	}
}
