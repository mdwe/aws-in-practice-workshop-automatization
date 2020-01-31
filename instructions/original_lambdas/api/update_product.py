import json
import boto3


class ProductHandler:
    def handler(self, id: str, obj: dict) -> dict:
        try:
            product = self.update_product(id, obj)

            if product is False:
                return {"statusCode": 404, "body": "Resource not found"}

            return {"statusCode": 200, "body": json.dumps(product)}
        except Exception:
            return {"statusCode": 500, "body": "Internal Server Error"}

    def update_product(self, id: str, obj: dict):
        try:
            dynamodb = boto3.resource("dynamodb")
            table = dynamodb.Table("ProductCatalog")

            response = table.get_item(Key={"id": id})
            product = response.get("Item", False)

            if product:
                if obj.get("name", False):
                    product["name"] = obj.get("name")
                if obj.get("desc", False):
                    product["description"] = obj.get("desc")

                table.put_item(Item=product)
                return product
            return False

        except Exception as ex:
            print(ex)
            raise ex


def lambda_handler(event, context):
    print(event)

    productHanlder = ProductHandler()
    return productHanlder.handler(
        event["pathParameters"]["id"], json.loads(event["body"])
    )
