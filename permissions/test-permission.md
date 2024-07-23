# How to test AWS permissions
1. Create a new IAM role in the AWS console
2. Create a new IAM policy in the AWS console using the statements in `policy.json` (replace `123456789012` with your account id)
3. Attach the policy to the role
4. Update role arn in `assume-role.sh` and run it if you're assuming role using role chaining. 
5. Run `install.sh` and `uninstall.sh` to deploy and destroy resources.
6. Add in actions missing into `policy.json` and run `update-policy.sh` to update the policy.
7. Repeat steps 4-6 until the policy is correct.
