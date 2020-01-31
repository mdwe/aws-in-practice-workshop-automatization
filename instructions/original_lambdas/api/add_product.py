import json
import boto3
import uuid


class ProductHandler:
    def __init__(self, name: str, description: str):
        self.name = name
        self.description = description
        self.id = str(uuid.uuid1())

    def handler(self) -> dict:
        try:
            self.add_product()

            return {"statusCode": 200, "body": json.dumps(self.get_product())}
        except Exception:
            return {"statusCode": 500, "body": "Internal Server Error"}

    def add_product(self):
        try:
            dynamodb = boto3.client("dynamodb")

            product = {
                "id": {"S": self.id},
                "name": {"S": self.name},
                "description": {"S": self.description},
            }
            dynamodb.put_item(TableName="ProductCatalog", Item=product)
        except Exception as ex:
            print(ex)
            raise ex

    def get_product(self) -> dict:
        return {"id": self.id, "name": self.name, "description": self.description}


def validate_input(event: dict) -> bool:
    if "name" in event and "desc" in event:
        return True
    else:
        return False


def lambda_handler(event, context):
    payload = json.loads(event["body"])

    if validate_input(payload) is False:
        return {
            "statusCode": 400,
            "body": "Error in input, please verify payload body",
        }

    productHanlder = ProductHandler(payload["name"], payload["desc"])
    return productHanlder.handler()
