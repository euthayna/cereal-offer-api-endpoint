## Cereal Offer API Endpoint
The Cereal Offer API Endpoint is a simple Rails application that serves as an API endpoint for managing offers related to cereals. It provides a convenient way to calculate the discount prices for a given cart object through a RESTful API.

### Installation and Setup
To set up the Cereal Offer API locally, follow these steps:

- Clone this repository to your local machine.
- Install Ruby (_version 2.7.2_) and Rails (_version 6.1.4_) if you haven't already.
- Install the required dependencies by running `bundle install` in the project root directory.
- Start the Rails server with the command `rails server`.
- The API endpoint will be accessible at http://localhost:3000/cart.

### Features
Create Cereal Offers: Users can create new cereal offers by sending a _POST request_ to the `/cart` API endpoint. Each line items includes details such as the `name`, `price`, and `collection`. 

#### Accepted Input
```JSON
{
  "cart": {
    "reference": "2d832fe0-6c96-4515-9be7-4c00983539c1",
    "lineItems": [
      { "name": "Peanut Butter", "price": "39.0", "collection": "BEST-SELLERS" },
      { "name": "Banana Cake", "price": "34.99", "collection": "DEFAULT" },
      { "name": "Cocoa", "price": "34.99", "collection": "KETO" },
      { "name": "Fruity", "price": "32", "collection": "DEFAULT" }
    ]
  }
}
```
#### Expected Output
```JSON
{
    "cart": {
        "reference": "2d832fe0-6c96-4515-9be7-4c00983539c1",
        "lineItems": [
            {
                "name": "Peanut Butter",
                "price": "39.0",
                "collection": "BEST-SELLERS",
                "discounted_price": 35.1
            },
            {
                "name": "Banana Cake",
                "price": "34.99",
                "collection": "DEFAULT",
                "discounted_price": 31.49
            },
            {
                "name": "Cocoa",
                "price": "34.99",
                "collection": "KETO",
                "discounted_price": 34.99
            },
            {
                "name": "Fruity",
                "price": "32",
                "collection": "DEFAULT",
                "discounted_price": 28.8
            }
        ],
        "totalPrice": 130.38
    }
}
```

### API Endpoints
The following API endpoints are available in the Cereal Offer API:

- `POST /cart` - Returns a new JSON with all input data plus:
    - `discounted_price`: add the _discounted_price_ key in each item.
    - `totalPrice`: sum of items discounted prices and return as the `cart` total price.

### Authentication and Authorization
This version of the Cereal Offer API Endpoint does not include any authentication or authorization mechanisms.
