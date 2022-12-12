# Troubleshooting tips

This guide contains general tips on how to investigate an application deployment that doesn't work correctly.

??? tip "How do I uninstall an environment using a different Terraform configuration file?"

    **Symptom**

    If you try to uninstall an environment by using a different configuration file than the one you used to install it or by using a different version of the code, you may encounter some issues during uninstallation. In most cases, Terraform reports that the resource cannot be removed because it's in use.

    **Solution**

    Identify the resource and delete it manually from the AWS console, and then restart the uninstallation process. Make sure to always use the same configuration file that was used to install the environment.



??? tip "How do I deal with persistent volumes that do not get removed as part of the Terraform uninstallation?"
    **Symptom**

    Uninstall fails to remove the persistent volume.
    ```shell
    Error: Persistent volume atlassian-dc-share-home-pv still exists (Bound)

    Error: context deadline exceeded

    Error: Persistent volume claim atlassian-dc-share-home-pvc still exists with
    ```
    **Solution**

    If a pod termination stalls, it will block pvc and pv deletion.
    To fix this problem we need to terminate product pod first and run uninstall command again.
    ```shell
    kubectl delete pod <stalled-pod> -n atlassian --force
    ```
    To see the stalled pod name you can run the following command:
    ```shell
    kubectl get pods -n atlassian
    ```

??? tip "How do I deal with suspended AWS Auto Scaling Groups during Terraform uninstallation?"

    **Symptom**

    If for any reason Auto Scaling Group gets suspended, AWS does not allow Terraform to delete the node group. In cases like this the uninstall process gets interrupted with the following error:

    ```shell
    Error: error waiting for EKS Node Group (atlas-<environment_name>-cluster:appNode) to delete: unexpected state 'DELETE_FAILED', wanted target ''. last error: 2 errors occurred:
        * i-06a4b4afc9e7a76b0: NodeCreationFailure: Instances failed to join the kubernetes cluster
        * eks-appNode-3ebedddc-2d97-ff10-6c23-4900d1d79599: AutoScalingGroupInvalidConfiguration: Couldn't terminate instances in ASG as Terminate process is suspended
    ```

    **Solution**

    Delete the reported Auto Scaling Group in AWS console and run uninstall command again.

??? tip "How do I deal with Terraform AWS authentication issues during installation?"

    **Symptom**

    The following error is thrown:

    ```shell
    An error occurred (ExpiredToken) when calling the GetCallerIdentity operation: The security token included in the request is expired
    ```

    **Solution**

    Terraform cannot deploy resources to AWS if your security token has expired. Renew your token and retry.

??? tip "How do I deal with Terraform state lock acquisition errors?"

    If user interrupts the installation or uninstallation process, Terraform won't be able to unlock resources. In this case, Terraform is unable to acquire state lock in the next attempt.

    **Symptom**

    The following error is thrown:

    ```shell
    Acquiring state lock. This may take a few moments...

     Error: Error acquiring the state lock

     Error message: ConditionalCheckFailedException: The conditional request failed
     Lock Info:
       ID:        26f7b9a8-1bef-0674-669b-1d60800dea4d
       Path:      atlassian-data-center-terraform-state-xxxxxxxxxx/bamboo-xxxxxxxxxx/terraform.tfstate
       Operation: OperationTypeApply
       Who:       xxxxxxxxxx@C02CK0JYMD6V
       Version:   1.0.9
       Created:   2021-11-04 00:50:34.736134 +0000 UTC
       Info:
    ```

    **Solution**

    Forcibly unlock the state by running the following command:

    ```shell
    terraform force-unlock <ID>
    ```

    Where `<ID>` is the value that appears in the error message.

    There are two Terraform locks; one for the infrastructure and another for Terraform state. If you are still experiencing lock issues, change the directory to `./modules/tfstate` and retry the same command.

??? tip "How do I deal with state data in S3 that does not have the expected content?"

    If Terraform state is locked and users forcefully unlock it using `terraform force-unlock <id>`, it may not get a chance to update the Digest value in DynamoDB. This prevents Terraform from reading the state data.       

    **Symptom**

    The following error is thrown:

    ```shell
    Error refreshing state: state data in S3 does not have the expected content.

    This may be caused by unusually long delays in S3 processing a previous state
    update.  Please wait for a minute or two and try again. If this problem
    persists, and neither S3 nor DynamoDB are experiencing an outage, you may need
    to manually verify the remote state and update the Digest value stored in the
    DynamoDB table to the following value: 531ca9bce76bbe0262f610cfc27bbf0b
    ```

    **Solution**

    1. Open DynamoDB page in AWS console and find the table named `atlassian_data_center_<region>_<aws_account_id>_tf_lock` in the same region as the cluster.

    2. Click on `Explore Table Items` and find the LockID named `<table_name>/<environment_name>/terraform.tfstate-md5`.

    3. Click on the item and replace the `Digest` value with the given value in the error message.

??? tip "How do I deal with pre-existing state in multiple environment?"

    If you start installing a new environment while you already have an active environment installed before, you should *NOT* use the pre-existing state.

    The same scenario when you want to uninstall a non-active environment.     

    !!! help "What is active environment?"
         Active environment is the latest environment you installed or uninstalled.

    !!! tip "Tip"
        Answer '**NO**' when you get a similar message during installation or uninstallation:
        ```shellscript
        Do you want to copy existing state to the new backend? Pre-existing state was found while migrating
        the previous "s3" backend to the newly configured "s3" backend. An existing non-empty state already
        exists in the new backend. The two states have been saved to temporary files that will be removed
        after responding to this query.

        Do you want to overwrite the state in the new backend with the previous state? Enter "yes" to copy
        and "no" to start with the existing state in the newly configured "s3" backend.

        Enter a value:
        ```

    **Symptom**

    Installation or uninstallation break after you chose to use pre-existing state.


    **Solution**

    1. Clean up the project before proceed. In root directory of the project run:
    ```shell
    ./scripts/cleanup.sh -s -t -x -r .
    terraform init -var-file=<config file>
    ```
    3. Then re-run the install/uninstall script.


??? tip "How do I deal with `Module not installed` error during uninstallation?"

    There are some Terraform specific modules that are required when performing an uninstall. These modules are generated by Terraform during the install process and are stored in the `.terraform` folder. If Terraform cannot find these modules, then it won't be able perform an uninstall of the infrastructure.

    **Symptom**

    ```shell
    Error: Module not installed

      on main.tf line 7:
       7: module "tfstate-bucket" {

    This module is not yet installed. Run "terraform init" to install all modules required by this configuration.
    ```


    **Solution**

    1. In the root directory of the project run:
    ```shell
    ./scripts/cleanup.sh -s -t -x -r .
    cd modules/tfstate
    terraform init -var-file=<config file>
    ```
    2. Go back to the root of the project and re-run the `uninstall.sh` script.


??? tip "How to deal with `getting credentials: exec: executable aws failed with exit code 2` error?"

    **Symptom**

    After performing an `install.sh` the following error is encountered:

    ```shell
    Error: Post "https://0839E580E6ADB7B784AECE0E152D8AF2.gr7.eu-west-1.eks.amazonaws.com/api/v1/namespaces": getting credentials: exec: executable aws failed with exit code 2

    with module.base-infrastructure.kubernetes_namespace.products,
    on modules/common/main.tf line 39, in resource "kubernetes_namespace" "products":
    39: resource "kubernetes_namespace" "products" {
    ```

    **Solution**

    Ensure you are using a version of the [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) that is at least >= `2` The version can be checked by running:

    ```shell
    aws --version
    ```


??? tip "How to `ssh` to application nodes?"

    Sometimes you need to ssh to the application nodes. This can be done by running:

    ```shell
    kubectl exec -it <pod-name> -n atlassian -- /bin/bash
    ```

    where `<pod-name>` is the name of the application pod you want to ssh such as `bitbucket-0` or `jira-1`. To get the pod names you can run:

    ```shell
    kubectl get pods -n atlassian
    ```

??? tip "How to access to the application log files?"

    A simple way to access to the application log content is running the following command:

    ```shell
    kubectl logs <pod-name> -n atlassian
    ```

    where `<pod-name>` is the name of the application pod you want to see the log such as `bitbucket-0` or `jira-1`. To get the pod names you can run:

    ```shell
    kubectl get pods -n atlassian
    ```

    However, another approach to see the full log files produced by the application would be to `ssh` to the application pod and access directly the log folder.

    ```shell  
    kubectl exec -it <pod-name> -n atlassian -- /bin/bash
    cd /var/atlassian/<application>/logs
    ```

    where `<application>` is the name of the application such as `confluence`, `bamboo`, `bitbucket`, or `jira`.

    Note that for some applications log foler is `/var/atlassian/<application>/log` and for others is `/var/atlassian/<application>/logs`.

    If you need to copy the log files to a local machine, you can use the following command:

    ```shell
    kubectl cp atlassian/<pod-name>:/var/atlassian/<application>/logs/<log_files> <local-path>
    ```

??? tip "How to deal with persistent volume claim destroy failed error?"

    The PVC cannot be destroyed when bound to a pod. Overcome this by scaling down to `0` pods first before deleting PVC.

    `helm upgrade PRODUCT atlassian-data-center/PRODUCT --set replicaCount=0 --reuse-values -n atlassian`

??? tip "How to manually clean up resources when uninstall has failed?"

    Sometimes Terraform is unable to destroy resources for various reasons. This normally happens at EKS level.
    One quick solution is to manually delete the EKS cluster, and re-run uninstall, so that Terraform will pick up from there.

    To delete EKS cluster, go to AWS console > EKS service > the cluster you're deploying.
    You'll need to go to 'Configuration' tab > 'Compute' tab > click into node group.
    Then in node group screen > Details > click into Autoscaling group.
    It'll then direct you to EC2 > Auto Scaling Group screen with the ASG selected > 'Delete' the chosen ASG.
    Wait for the ASG to be deleted, then go back to EKS cluster > Delete.

??? tip "How to deal with `This object does not have an attribute named` error when running uninstall.sh"

    It is possible that if the installation has failed, the uninstall script will return an error like:

    ```
    module.base-infrastructure.module.eks.aws_autoscaling_group_tag.this["Name"]: Refreshing state... [id=eks-appNode-t3_xlarge-50c26268-ea57-5aee-4523-68f33af7dd71,Name]
    Error: Unsupported attribute
    on dc-infrastructure.tf line 142, in module "confluence":
    142: ingress = module.base-infrastructure.ingress
    ├────────────────
    │ module.base-infrastructure is object with 5 attributes
    This object does not have an attribute named "ingress".
    Error: Unsupported attribute
    ```
    This happens because some of the modules failed to be installed. To fix the error, run the uninstall script with `-s` argument.
    This will add `-refresh=false` to terraform destroy command.

??? tip "How to deal with `Error: Kubernetes cluster unreachable: the server has asked for the client to provide credentials` error"

    It is possible that you see such an error when running uninstall script with `-s` argument. If it's not possible to destroy infrastructure without it, delete the offending module from tfstate, for example:

    ```
    terraform state rm module.base-infrastructure.module.eks.helm_release.cluster-autoscaler
    ```

    Once done, re-run the uninstall script.


??? tip "How to deal with EIP AddressLimitExceeded error"

    If you encounter the below error during installation stage, it means VPC is successfully created, but no Elastic IP addresses available.

    ```shell
    Error: Error creating EIP: AddressLimitExceeded: The maximum number of addresses has been reached.
	status code: 400, request id: 0061b744-ced3-4d0e-9905-503c85013bcc

    with module.base-infrastructure.module.vpc.module.vpc.aws_eip.nat[0],
    on .terraform/modules/base-infrastructure.vpc.vpc/main.tf line 1078, in resource "aws_eip" "nat":
    1078: resource "aws_eip" "nat" {
    ```

    It happens when an old VPC was deleted but associated Elastic IPs were not released. Refer to AWS documentation on
    [how to release an Elastic IP address](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-eips.html#release-eip){.external}.  

    Another option is to [increase the Elastic UP address limit](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html#using-instance-addressing-limit){.external}.
??? tip "How to deal with Nginx Ingress Helm deployment error"

    If you encounter the below error when providing 25+ cidrs in `whitelist_cidr` variable, it may be caused by the service controller being unable to create a Load Balancer due to exceeding the inbound rules quota in a security group:

    ```
    module.base-infrastructure.module.ingress.helm_release.ingress: Still creating... [5m50s elapsed]
    Warning: Helm release "ingress-nginx" was created but has a failed status. Use the `helm` command to investigate the error, correct it, then run Terraform again.
    ```
    To check if it's really the case, login to the cluster and run:

    ```
    kubectl describe ingress-nginx-controller -n ingress-nginx
    ```
    to find the following error in Events section:

    ```
    Warning  SyncLoadBalancerFailed  112s  service-controller  Error syncing load balancer: failed to ensure load balancer: error authorizing security group ingress: "RulesPerSecurityGroupLimitExceeded: The maximum number of rules per security group has been reached.\n\tstatus code: 400, request id: 7de945ea-0571-48cd-99a1-c2ca528ad412"
    ```

    The service controller creates several inbound rules for ports 80 and 443 for each source cidr, and as a result the quota is reached if there are 25+ cidrs in `whitelist_cidr` list.

    To mitigate the problem you may either file a ticket with AWS to [increase the quota of inbound rules in a security group](https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html#vpc-limits-security-groups) (60 by default) or set `enable_https_ingress` to false in `config.tfvars` if you don't need https ingresses. Port 443 will be removed from Nginx service, and as a result fewer inbound rules are created in the security group.

    With an increased inbound rules quota or `enable_https_ingress` set to false (or both), it is recommended to delete Nginx Helm chart before re-running `install.sh`:

    ```
    helm delete ingress-nginx -n ingress-nginx
    ```
