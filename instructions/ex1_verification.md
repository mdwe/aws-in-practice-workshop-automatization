# Exercise 1 - Verification steps - manual approach

1. Go to `API Gateway` in AWS Console, and download from the tab `Stages / Export` JSON file for **Swagger and Postman**

2. Import JSON file with API details into *Postman* application

3. Try to execute API methods for the resource **product**:

    * Create new product with `POST` method from *product* resource, with the body:

        ```
        {
            "name": "Apple iPhone 11",
            "desc": "The iPhone 11 is a smartphone designed, developed, and marketed by Apple Inc. It is the thirteenth generation lower-priced iPhone, succeeding the iPhone XR."
        }
        ```
    
    * Call `GET` methods to list all products, the result should be similar like: 

        ```
        [
            {
                "description": "The iPhone 11 is a smartphone designed, developed, and marketed by Apple Inc. It is the thirteenth generation lower-priced iPhone, succeeding the iPhone XR.",
                "id": "fd85eb65-74e4-11ea-8eee-55b226ef39ee",
                "name": "Apple iPhone 11"
            }
        ]
        ```

    * Update created product item with new data:

        ```
        {
            "name": "Apple iPhone 11 Pro",
            "desc": "The iPhone 11 Pro is a smartphone designed, developed, and marketed by Apple Inc. It is the thirteenth generation lower-priced iPhone, succeeding the iPhone XS Max."
        }
        ```
        
        And the response should have HTTP code `200` and be like:

        ```
        {
            "description": "The iPhone 11 Pro is a smartphone designed, developed, and marketed by Apple Inc. It is the thirteenth generation lower-priced iPhone, succeeding the iPhone XS Max.",
            "id": "fd85eb65-74e4-11ea-8eee-55b226ef39ee",
            "name": "Apple iPhone 11 Pro"
        }
        ```

    