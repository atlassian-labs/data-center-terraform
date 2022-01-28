# Prerequisites

Before installing the infrastructure for Atlassian Data Center products, make sure that you meet the following requirements and that your local environment is configured with all the necessary tools.

## Requirements

In order to deploy Atlassian’s Data Center infrastructure to Amazon Web Services (AWS), the following are required:

1. An understanding of [Kubernetes](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/){.external} and [Helm](https://helm.sh/){.external} concepts.
2. An understanding of [Terraform](https://www.terraform.io/){.external}.
3. An AWS account with admin access. 

## Environment setup

Before creating the infrastructure, make sure that your development environment is configured with the following tools:

1. [Terraform](#terraform) 
2. [Helm v3.3 or later](#helm)
3. [AWS CLI](#aws-cli)
4. [Kubernetes cluster monitoring tools](#kubernetes-cluster-monitoring-tools) (optional)

### :material-terraform: Terraform

Terraform is an open-source infrastructure as code tool that provides a consistent CLI workflow to create and manage the infrastructure of cloud environments. 

This project uses Terraform to create and manage the Atlassian Data Center infrastructure on AWS for use with supported Data Center products. 

!!! info "Currently, not all Data Center products are supported." 
    At this stage, Bamboo Data Center is the only supported product. 

1. Check if Terraform is already installed by running the following command:
   ```shell
   terraform version
   ```
2. If Terraform is not installed, install it by following the [official instructions](https://learn.hashicorp.com/tutorials/terraform/install-cli).

### :material-package: Helm

Atlassian supports Helm Charts for some of its [Data Center products](https://atlassian.github.io/data-center-helm-charts/), including Bamboo. This project uses Helm charts to package Bamboo Data Center as a turnkey solution for your cloud infrastructure.

Before using this project, make sure that Helm v3.3 or later is installed on your machine. 

1. Check if Helm v3.3 or later is already installed by running the following command:

   ```shell
   helm version --short
   ```

2. If Helm is not installed or you're running a version lower than 3.3, install Helm by following the [official instructions](https://helm.sh/docs/intro/install/){.external}.

### :material-aws: AWS CLI

You need to have the AWS CLI tool installed on your local machine before creating the Kubernetes infrastructure. We recommend using AWS CLI version 2.

1. Check if AWS CLI version 2 is already installed by running the following command:
    ```shell
    aws --version
    ```
2. If the AWS CLI is not installed or you're running version 1, install AWS CLI version 2 by following the [official instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html){.external}.

### :material-kubernetes: Kubernetes cluster monitoring tools

This step is not mandatory in order to use Terraform for Atlassian Data Center products, but we recommend installing tools such as [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl){.external} to be able monitor 
and diagnose the resources in the Kubernetes cluster. 

!!! Tip "Other Kubernetes cluster monitoring tools"
    Alternatively, you can use other open-source Kubernetes cluster monitoring monitoring tools, such as [Prometheus](https://github.com/prometheus/prometheus){.external} [Grafana](https://github.com/grafana/grafana){.external}, or [Weave Scope](https://github.com/weaveworks/scope){.external}.
    

 