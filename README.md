# Secure API Gateway using Cognito User Pool

### AWS CLI Command to generate token : 

```
aws cognito-idp admin-initiate-auth  --region <REGION> --user-pool-id <USER_POOL_ID>  --client-id <CLIENT_ID> --auth-flow ADMIN_NO_SRP_AUTH --auth-parameters USERNAME=<USERNAME>,PASSWORD=<PASSWORD>
```

### To export variable

```
export TF_VAR_username=test
export TF_VAR_password=your_password
```

### Other useful resources:
- [AWS CLI admin-initiate-auth command](https://docs.aws.amazon.com/cli/latest/reference/cognito-idp/admin-initiate-auth.html)
- [AWS initiate-auth](https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_InitiateAuth.html)
- [Managing user existence error responses](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pool-managing-errors.html)
- [Terraform - Cognito User Pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool)