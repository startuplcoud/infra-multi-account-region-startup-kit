# Setup CI/CD workflow pipeline with multiple AWS regions & accounts using Terragrunt & Terraform
[![Deploy Prod Infrastructure](https://github.com/startuplcoud/infra-multi-account-region-startup-kit/actions/workflows/production-terragrunt.yaml/badge.svg?branch=main)](https://github.com/startuplcoud/infra-multi-account-region-startup-kit/actions/workflows/production-terragrunt.yaml)
[![Terrascan Check](https://github.com/startuplcoud/infra-multi-account-region-startup-kit/actions/workflows/production-terrascan.yaml/badge.svg?branch=main)](https://github.com/startuplcoud/infra-multi-account-region-startup-kit/actions/workflows/production-terrascan.yaml)

Set up AWS infrastructure with terragrunt and terraform in multiple accounts and regions demo kit.  
Goals:
1.  Provisioning AWS infrastructure with terraform and terragrunt.
2.  Support AWS with multiple accounts and regions.
3.  Running the CI/CD workflow pipeline in parallel.
4.  GitHub OIDC provider with AWS IAM role (without setting up AWS credentials' key)
5.  Pattern: Separate terraform modules, keep the minimum AWS resources, and reduce duplicated codes. 

## AWS Services Architecture
This tutorial will show how to set up the AWS VPC and EC2 autoscaling group with the application load balancer and how to use the terraform & terragrunt to manage the AWS infrastructure.

### The Auto Scaling & ALB Architecture Diagram
![aws](images/aws.png)

### Terraform layout
Try to separate the resources and use separate directories for each component and application.   
Useful links about Google best practices for [terraform](https://cloud.google.com/docs/terraform/best-practices-for-terraform#minimize-resources).  
This tutorial separates the AWS resources into three modules, VPC & Auto Scaling & Application Load Balancer.
```
infra
└── module
    ├── alb # application load balancer module
    │   ├── loadbalancer.tf
    │   ├── security.tf
    │   └── vars.tf
    ├── autoscale # autoscaling module
    │   ├── autoscale.tf
    │   ├── config
    │   │   └── init-config.yaml
    │   ├── data.tf
    │   ├── security.tf
    │   └── vars.tf
    └── vpc # vpc module
        ├── data.tf
        ├── main.tf
        ├── outputs.tf
        └── vars.tf
```
### Terragrunt layout

```
.
├── common # common configuration and input variables
│ ├── alb.hcl
│ ├── autoscale.hcl
│ └── vpc.hcl
├── dev # development account id
│ └── us-east-1 # only provisioning resources in us-east-1
│     ├── env.yaml global configuration parameters
│     ├── alb
│     │ └── terragrunt.hcl
│     ├── autoscale
│     │ └── terragrunt.hcl
│     └── vpc
│       └── terragrunt.hcl
├── prod # production account id 
│ ├── cn-north-1 (AWS China region)
│ │ ├── env.yaml
│ │ ├── alb
│ │ │ └── terragrunt.hcl
│ │ ├── autoscale
│ │ │ └── terragrunt.hcl
│ │ └── vpc
│ │   └── terragrunt.hcl
│ └── cn-northwest-1
│     ├── env.yaml
│     ├── alb
│     │ └── terragrunt.hcl
│     ├── autoscale
│     │ └── terragrunt.hcl
│     └── vpc
│       └── terragrunt.hcl
└── terragrunt.hcl (Global terragrunt configuration)
```

### Global Variable and auto generate for the global providers.
In the `env.yaml`, for the different region and accounts
we need to set the AWS account id and region variables.
#### Global env.yaml
```
aws_region: us-east-1
account_id: xxxxxxxxx
```
#### terragrunt.hcl global provider
In the global terragrunt file, we can retrieve the `aws_region` and `account_id` in the `env.yaml`.
```hcl
locals {
  env_vars   = yamldecode(file("${find_in_parent_folders("env.yaml")}"))
  aws_region = local.env_vars["aws_region"]
  project    = local.env_vars["project"]
  account_id = local.env_vars["account_id"]
}
```
then, in the auto generate provider syntax, so it will generate the `providers.tf` in each terraform module,
the provider already strict the AWS region and account.
```hcl
generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  allowed_account_ids  = [ "${local.account_id}" ]
}
EOF
}
```

## Github OIDC with AWS IAM role.
Assume roles in AWS using an OpenID Connect identity provider.
In AWS, we can register GitHub as an Identity Provider, and then the JWT generated 
by GitHub is allowed to access AWS account.
![OIDC](images/github_oidc.png)

### Set up AWS IAM role & policies
#### Create OIDC Provider connection
In IAM → Identity providers → Add provider:

![identify](images/identity.png)

Provider URL: `https://token.actions.githubusercontent.com`  

Global Region:   
Audience: `sts.amazoneaws.com`    
China Region:   
Audience: 
`sts.cn-north-1.amazonaws.com.cn`(Beijing Region)           
`sts.cn-northwest-1.amazonaws.com.cn` (Ningxia Region)

#### Create AWS IAM role
Select Trust entity type, select the `Web identity`:
![role](images/role.png)
Add the `AdministratorAccess` permission
![role2](images/role2.png)

For policy also need to add the `"token.actions.githubusercontent.com:sub": "repo:{gituser}/{gitrepo}:ref:refs/heads/xxx"`,
`xxx` means the branch name.
this is used for to grant the boundary of git repository.
Global Region policy:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::xxxxxxxx:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                  "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                  "token.actions.githubusercontent.com:sub": ["repo:{gituser}/{gitrepo}:ref:refs/heads/xxx",
                                                              "repo:{gituser}/{gitrepo}:pull_request"]
                }
            }
        }
    ]
}
```
AWS China region policy
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws-cn:iam::xxxxxxxx:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                   "token.actions.githubusercontent.com:aud": ["sts.cn-north-1.amazonaws.com.cn","sts.cn-northwest-1.amazonaws.com.cn"],
                   "token.actions.githubusercontent.com:sub": ["repo:{gituser}/{gitrepo}:ref:refs/heads/xxx",
                                                               "repo:{gituser}/{gitrepo}:pull_request"]
                }
            }
        }
    ]
}
```

####  GitHub Actions OIDC Auth to assume AWS Role

```yaml
- name: GitHub OIDC Auth to assume AWS Role
  uses: aws-actions/configure-aws-credentials@v1
  with:
    role-to-assume: arn:aws:iam::xxxxxx:role/xxxxx
    role-session-name: github-action
    aws-region: us-east-1
```
after the actions execute, the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_SESSION_TOKEN` will automatically register in the global environment.

![github](images/github.png)


## Run CI/CD pipeline in parallel
This post will show how to use the `strategy.matrix` to significantly reduce the time on Github workflows.
`strategy.matrix` syntax allows creating multiple jobs by performing variable substitution in a single job definition.
Check the useful links for more details about the [github job matrix](https://docs.github.com/cn/actions/using-jobs/using-a-matrix-for-your-jobs).

```yaml
strategy:
  matrix:
    include:
      - env: dev
        aws-region: us-east-1
        aws-account-id: xxxxxxx
        aws-role: xxxxxx
        aws: aws
      - env: prod
        aws-region: cn-north-1
        aws-account-id: xxxxx
        aws-role: xxxx
        aws: aws-cn
      - env: prod
        aws-region: cn-northwest-1
        aws-account-id: xxxxx
        aws-role: xxxx
        aws: aws-cn
```
for parameters combinations will result in 3 jobs:
1. `{env: dev, aws-region: us-east-1, aws-account-id: xxxxx, aws-role: xxxx, aws: aws}`
2. `{env: prod, aws-region: cn-north-1, aws-account-id: xxxxx, aws-role: xxxx, aws: aws-cn}`
3. `{env: prod, aws-region: cn-northwest-1, aws-account-id: xxxxx, aws-role: xxxx, aws: aws-cn}`
then the job will dynamically fill the `matrix` values in the `with` sections.
```yaml
 steps:
  - name: Checkout repo
    uses: actions/checkout@v3
  - name: terragrunt packages
    uses: ./.github/action/terragrunt-action
    with:
      role-to-assume: arn:${{ matrix.aws }}:iam::${{ matrix.aws-account-id }}:role/${{ matrix.aws-role }}
      role-session-name: github-action
      aws-region: ${{ matrix.aws-region }}
      env: ${{ matrix.env }}
```

## Terragrunt best practices
### reduce duplicated code
 1. Using multiple `include` blocks to DRY common terragrunt configuration.
 2. Using deep merge to DRY nested attributes.
 3. Using expose includes to override common configuration variables.
 4. Reducing duplicated code blocks such as `inputs` or `dependency` for each terragrunt modules.
```hcl
include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/alb.hcl"
  expose = true
}
```
### apply one module
```shell
terragrunt run-all plan --terragrunt-include-dir $(directory)
```


## Security Tips 
### Encrypt terraform states in S3 bucket and Dynamodb
terragrunt encrypt the tfstate in the remote s3 bucket and Dynamodb.
```hcl
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.project}-terraform-state-${local.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "${local.project}-terraform-lock-table"
  }
}
```
### Encrypting using Vault

### Terraform code Vulnerability scan with GitHub Action

#### tfsec 

#### terrascan

#### checkov



## Cost Preview

Cost estimates for Terraform with Infracost https://www.infracost.io/.



