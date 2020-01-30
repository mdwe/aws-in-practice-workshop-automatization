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

    8. Download and install Terraform - `https://www.terraform.io/downloads.html`



## Tools 

- **aws-cli** - The AWS Command Line Interface (AWS CLI) is an open source tool that enables you to interact with AWS services using commands in your command-line shell. [Read more](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
- **awsume** - Awsume is a convenient way to manage session tokens and assume role credentials. [Read more](https://awsu.me)
- **terraform** - Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions. [Read more](https://www.terraform.io/intro/index.html)