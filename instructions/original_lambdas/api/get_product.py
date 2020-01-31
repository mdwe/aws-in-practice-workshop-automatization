import json
import boto3


class ProductHandler:
    def handler(self, id: str) -> dict:
        try:
            product = self.get_product(id)

            if product is False:
                return {"statusCode": 404, "body": "Resource not found"}

            return {"statusCode": 200, "body": json.dumps(product)}
        except Exception:
            return {"statusCode": 500, "body": "Internal Server Error"}

    def get_product(self, id: str) -> dict:
        try:
            dynamodb = boto3.resource("dynamodb")
            table = dynamodb.Table("ProductCatalog")

            response = table.get_item(Key={"id": id})

            return response.get("Item", False)
        except Exception as ex:
            print(ex)
            raise Exception


def lambda_handler(event, context):
    productHanlder = ProductHandler()
    return productHanlder.handler(event["pathParameters"]["id"])
