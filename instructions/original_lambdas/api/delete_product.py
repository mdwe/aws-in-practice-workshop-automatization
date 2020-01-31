import boto3


class ProductHandler:
    def handler(self, id: str) -> dict:
        try:
            removed = self.remove_product(id)

            if removed is False:
                return {"statusCode": 404, "body": "Resource not found"}

            return {"statusCode": 200, "body": "Product has been deleted"}
        except Exception:
            return {"statusCode": 500, "body": "Internal Server Error"}

    def remove_product(self, id: str) -> bool:
        try:
            dynamodb = boto3.resource("dynamodb")
            table = dynamodb.Table("ProductCatalog")

            response = table.delete_item(Key={"id": id})

            return (
                response.get("ResponseMetadata", {}).get("HTTPStatusCode", False) == 200
            )
        except Exception as ex:
            print(ex)
            raise ex


def lambda_handler(event, context):
    productHanlder = ProductHandler()
    return productHanlder.handler(event["pathParameters"]["id"])
