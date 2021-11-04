# Troubleshooting tips

This guide contains general tips on how to investigate an application deployment that doesn't work correctly.


## How to unlock terraform
If user interrupt execution og install or uninstall actions, the terraform lock the resources but never get a chance to
 unlock them. In this case in next attempt you may see the following error:
 

```
Acquiring state lock. This may take a few moments...
╷
│ Error: Error acquiring the state lock
│
│ Error message: ConditionalCheckFailedException: The conditional request failed
│ Lock Info:
│   ID:        26f7b9a8-4bef-0674-669b-1d90800dea4d
│   Path:      atlassian-data-center-terraform-state-887764444972/test-bamboo-887764444972/terraform.tfstate
│   Operation: OperationTypeApply
│   Who:       nghazalibeiklar@C02CK0JYMD6V
│   Version:   1.0.9
│   Created:   2021-11-04 00:50:34.736134 +0000 UTC
│   Info:
│
│
│ Terraform acquires a state lock to protect the state from being written
│ by multiple users at the same time. Please resolve the issue above and try
│ again. For most commands, you can disable locking with the "-lock=false"
│ flag, but this is not recommended.
╵
```

To fix this you need to unlock state first by running the following command 
(replace ID with the value from the error message):

```shell 
terraform force-unlock <ID>
```

!!! hint "After running the unlock command still you see the error?"
    There are two terraform locks, one for infrastructure and another for terraform state. If running the following 
    command from repo folder does not unlock the resources, then change the current path to `./pkg/tfstate` and retry
     the same command.  