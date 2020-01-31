import json
import boto3


class ProductHandler:
    def handler(self) -> dict:
        try:
            products = self.get_products()

            return {"statusCode": 200, "body": json.dumps(products)}
        except Exception:
            return {"statusCode": 500, "body": "Internal Server Error"}

    def get_products(self) -> dict:
        try:
            dynamodb = boto3.resource("dynamodb")
            table = dynamodb.Table("ProductCatalog")

            response = table.scan()
            return response.get("Items", False)

        except Exception as ex:
            print(ex)
            raise ex


def lambda_handler(event, context):
    productHanlder = ProductHandler()
    return productHanlder.handler()
