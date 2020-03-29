## Requirements 

1. Python 3.8
2. AWS Account with active FreeTier plan

## Installation and local environment configuration 

1. Install aws-cli 

    pip install awscli --upgrade --user

2. Install awsume 

    pip install awsume --upgrade --user

3. Configure access to AWS account on local environment 

    1. Login to AWS account in Console 
    2. Go to "My Security Credentials" page
    3. Create new Access Key and save key file 
    4. Create credentails file `~/.aws/credentials`:

            [default]
            aws_access_key_id=$key
            aws_secret_access_key=$secret

    5. Create configuration file `~/.aws/config`:

            [default]
            region=eu-central-1

    6. Create session with awsume - execute command:

            awsume
    
    7. Validate session information:

            aws sts get-caller-identity

        Expected result:

            {
                "UserId": "192XXXXXX",
                "Account": "1926XXXXXX",
                "Arn": "arn:aws:iam::1926XXXXXX:root"
            }
    
    
    ### Project additional tools

    1. Install project requirements:

        ```
        pip install -r requirements.txt
        ```

    2. Install pre-commit hooks

        ```
        pre-commit install
        ```

        You can run pre-commmit manually: 

        ```
        pre-commit run --all-files
        ```
4. Download and install Terraform - `https://www.terraform.io/downloads.html`, verify version of application with command ( > 0.12.10):

    ```
    terraform -v
    ```



## Tools 

1. **aws-cli** - The AWS Command Line Interface (AWS CLI) is an open source tool that enables you to interact with AWS services using commands in your command-line shell. [Read more](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

2. **awsume** - Awsume is a convenient way to manage session tokens and assume role credentials. [Read more](https://awsu.me)

3. **terraform** - Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions. [Read more](https://www.terraform.io/intro/index.html)

### Python tools

1. **flake8** - is a Python library that wraps PyFlakes, pycodestyle and Ned Batchelder's McCabe script. It is a great toolkit for checking your codebase against coding style (PEP8), programming errors (like “library imported but unused" and “Undefined name") and to check cyclomatic complexity. [Read more](https://simpleisbetterthancomplex.com/packages/2016/08/05/flake8.html)

2. **black** - is a Python code formatter. By using it, you agree to cede control over minutiae of hand-formatting. In return, Black gives you speed, determinism, and freedom from pycodestyle nagging about formatting. You will save time and mental energy for more important matters.
Blackened code looks the same regardless of the project you're reading. Formatting becomes transparent after a while and you can focus on the content instead.
Black makes code review faster by producing the smallest diffs possible. [Read more](https://pypi.org/project/black/)