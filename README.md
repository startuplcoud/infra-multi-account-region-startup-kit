# Setup multiple AWS regions & accounts with terragrunt & terraform and github actions CI/CD workflow

Goals:
1.  Provide terraform code structure and 

Set up AWS infrastructure with terragrunt and terraform in multiple accounts and regions startup kit.

1. grant the permission for the OICD provider for github actions


AWS Achitecture

![aws](images/aws.png)


### Terraform layout
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
    └── vpc # vpc
        ├── data.tf
        ├── main.tf
        ├── outputs.tf
        └── vars.tf
```
### Terragrunt layout
```
.
├── common # common configuration for each region modules
│ ├── alb.hcl
│ ├── autoscale.hcl
│ └── vpc.hcl
├── dev # aws dev environment global
│ └── us-east-1
│     ├── alb
│     │ └── terragrunt.hcl
│     ├── autoscale
│     │ └── terragrunt.hcl
│     ├── env.yaml
│     └── vpc
│         └── terragrunt.hcl
├── prod # aws prod environment account China region
│ ├── cn-north-1
│ │ ├── env.yaml
│ │ └── vpc
│ │     ├── alb
│ │     │ └── terragrunt.hcl
│ │     ├── autoscale
│ │     │ └── terragrunt.hcl
│ │     └── vpc
│ │         └── terragrunt.hcl
│ └── cn-northwest-1
│     ├── env.yaml
│     └── vpc
│         ├── alb
│         │ └── terragrunt.hcl
│         ├── autoscale
│         │ └── terragrunt.hcl
│         └── vpc
│             └── terragrunt.hcl
└── terragrunt.hcl
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

#### Github action with the AWS credential

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

### multiple accounts & regions
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

### Terragrunt tips
#### reusable 

#### apply one module
```shell
terragrunt run-all plan --terragrunt-include-dir $(directory)
```
 

