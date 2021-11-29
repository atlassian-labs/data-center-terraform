# Prerequisites 
## Requirements 

In order to deploy Atlassian’s Data Center infrastructure, the following are required:

1. An understanding of [Kubernetes](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/){.external} and [Helm](https://helm.sh/){.external} concepts.
2. An understanding of [Terraform](https://www.terraform.io/){.external}.
3. An AWS account with admin access. 

## Environment setup 

Before installing you need to make sure your environment has the necessary tools::

1. [Install Terraform](#terraform) 
2. [Install helm v3.3 or later](#helm)
3. [Install AWS CLI](#aws-cli)
4. [Kubernetes tools](#kubernetes-tools) (optional)


### :material-terraform: Terraform
Terraform is an open source infrastructure as code that provides a consistent CLI workflow to create and manage 
infrastructures on the cloud environment. We use terraform in this project to create and manage Atlassian Data Center 
infrastructure on AWS cloud to be used with the supported Data Center products. 

!!! warning "Currently, not all Data Center products are supported." 
    At this stage **Bamboo** is the only supported product.  

Please make sure to install the latest version of [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli){.external} 

### :material-package: Helm 
Atlassian supports Helm Charts for some of [Data Center products](https://atlassian.github.io/data-center-helm-charts/) 
including Bamboo. This project uses terraform to provision the infrastructure for Atlassian products and uses the 
Helm charts to install them as a turnkey solution. 

Before using this project make sure you have Helm v3.3 or later installed on your machine. 

!!! help "How to confirm your Helm version?"
    Use the following command to see the installed Helm version on your local:
    
    ```
    helm version --short
    ```

If you have not installed Helm on your local environment, or the installed version is lower than `v3.3` then you 
need to [install Helm](https://helm.sh/docs/intro/install/){.external}.

### :material-aws: AWS CLI
You need to have the AWS CLI tool installed on your local machine before installing the infrastructure. We recommend 
having version 2 of `aws-cli`. 

```
aws --version
```

If you still have no AWS CLI installed on your local environment please
 [install it](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html){.external} before 
 proceeding to the next step.  


### :material-kubernetes: Kubernetes tools
This step is not mandatory in order to use Terraform for Atlassian Data Center products, but we recommend you to have
some useful tools such as [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/){.external} to be able monitor 
and diagnose the resources in the Kubernetes cluster. 

!!! Tip "Other useful tools"
    There are many Kubernetes open source monitoring tools such as 
    [Prometheus](https://github.com/prometheus/prometheus){.external}, 
    [Grafana](https://github.com/grafana/grafana){.external}, 
    [Weave Scope](https://github.com/weaveworks/scope){.external}, and many  other tools that could be useful.  
    

 