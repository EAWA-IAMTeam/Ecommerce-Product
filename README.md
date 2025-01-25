> [!NOTE]  
> Go SDK for Lazada Open API might use new app secret and access token if expired
> For the response of lazada products, one product might have one or many skus, need to handle it properly during mapping and writing into database

# Product and API Integration

This project consists of multiple components, including a Go SDK that integrates with Lazada, a Flask-based Python API that serves various endpoints for fetching SQL Account Stock Items by Company, and a Flutter application that interacts with the API to display data, including stock items from SQL accounts and Lazada products for mapping purposes.

### Components

1. **iop-sdk-go**:

   - A Go SDK that integrates with Lazada's API to retrieve product data.
   - Provides functionality to interact with Lazada's product API endpoints.

2. **api-endpoint.py**:

   - A Python script that utilizes Flask to expose the following API endpoints:
     - **Get stock items by company ID from SQL Account in the Database**
     - **Shopee access token API** for authentication.
     - **Insert products after mapping** according to store id
     - **Retrieve products that have done mapping** according to store id

3. **Flutter Application**:
   - A Flutter app that consumes the API to display Lazada products and stock items from SQL accounts for mapping purposes.
     ![Product Mapping Interface](/img/mapping-with-data.png)
     ![Mapped Products Interface](/img/mapped-product.png)

### API Endpoints

#### 1. **Get Stock Items by Company ID**

- **Endpoint**: `http://192.168.0.73:5000/api/stock_items/company/<company_id>`
- **Method**: `GET`
- **Description**: Retrieves stock items based on the company ID from the SQL-based accounting system.
- **Parameters**:
  - `company_id` (path parameter): The ID of the company for which stock items are being retrieved.

#### 2. **Lazada Get Product API**

- **Endpoint**: `http://192.168.0.73:7000/products`
- **Method**: `GET`
- **Description**: Retrieves a list of products from Lazada.

#### 3. **Shopee Access Token API**

- **Endpoint**: `http://192.168.0.73:5000/api/shopee_auth`
- **Method**: `POST`
- **Description**: Authenticates and retrieves an access token from Shopee.

##### Required Parameters:

To authenticate with Shopee, you can use either the **shop ID** or **main account ID**, along with the necessary authentication parameters. Refer to the image below for the full list of required parameters.

- **Option 1: Authenticate Using `shop_id`**:
  Provide the following parameters in the request body:

  - `shop_id`: Your shop ID.
  - `sign`: The signature generated for authentication.
  - `partner_id`: The partner ID assigned to your application.
  - `timestamp`: The timestamp of the request.
  - `code`: The authorization code.

- **Option 2: Authenticate Using `main_account_id`**:
  Provide the following parameters in the request body:

  - `main_account_id`: Your main account ID.
  - `sign`: The signature generated for authentication.
  - `partner_id`: The partner ID assigned to your application.
  - `timestamp`: The timestamp of the request.
  - `code`: The authorization code.

  ![Shopee Auth Params](/img/shopee-auth-params.png)

#### 4. **Insert Products API**

- **Endpoint**: `http://192.168.0.73:5000/api/products`
- **Method**: `GET`
- **Description**: Insert Products that have done mapping

#### 5. **Get Products API**

- **Endpoint**: `http://192.168.0.73:5000/api/products`
- **Method**: `POST`
- **Description**: Select Products that have done mapping by store
