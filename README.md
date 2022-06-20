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
Do **NOT** set any variables such `.tfvars` in terraform module.

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

#### global parameters for different region
```
aws_region: us-east-1
account_id: xxxxxxxxx
```

#### terragrunt.hcl global provider
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

## Github OIDC to authenticate with  AWS IAM role. 
1.  grant the permission for the OICD provider for github actions
![github](images/github.png)


### Setup AWS IAM role 
#### Setup AWS Identifier providers
![identify](images/identity.png)

Global Region:   
Provider URL: `https://token.actions.githubusercontent.com`  
Audience: `sts.amazoneaws.com`

China Region:  
Provider URL: `https://token.actions.githubusercontent.com`  
Audience: `sts.cn-north-1.amazonaws.com.cn`(Beijing Region) `sts.cn-northwest-1.amazonaws.com.cn` (Ningxia Region)

IAM role
Select Trust entity type
![role](images/role.png)
Add permission
![role2](images/role2.png)
AWS Global policy
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
                  "token.actions.githubusercontent.com:sub": "repo:{gituser}/{gitrepo}:ref:refs/heads/xxx"
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
                   "token.actions.githubusercontent.com:sub": "repo:{gituser}/{gitrepo}:ref:refs/heads/xxx"
                }
            }
        }
    ]
}
```

###  GitHub OIDC Auth to assume AWS Role

```yaml
- name: GitHub OIDC Auth to assume AWS Role
  uses: aws-actions/configure-aws-credentials@v1
  with:
    role-to-assume: arn:aws:iam::xxxxxx:role/xxxxx
    role-session-name: github-action
    aws-region: us-east-1
```


### Run CI/CD pipeline in parallel
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


### Terragrunt tips
#### reusable 

#### apply one module
```shell
terragrunt run-all plan --terragrunt-include-dir $(directory)
```
 

