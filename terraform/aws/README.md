# Deploy to AWS

## Set up cluster

```bash
terraform plan -var 'aws_access_key={{ACCESS_KEY}}' -var 'aws_secret_key={{SECRET_KEY}}'
terraform apply -var 'aws_access_key={{ACCESS_KEY}}' -var 'aws_secret_key={{SECRET_KEY}}'
```

## Tear down cluster

```bash
terraform destroy -var 'aws_access_key={{ACCESS_KEY}}' -var 'aws_secret_key={{SECRET_KEY}}'
```

## Notes

- Needs the `eksctl` utility, see https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
- EKS requires that VPC subnets be set up in at least 2 availability zones
