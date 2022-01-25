# Prerequisites

Before installing the infrastructure for Atlassian Data Center products, make sure that you meet the following requirements and that your local environment is configured with all the necessary tools.

## Environment setup

Its advised that the tooling below is installed to your development environment. An understanding of these tools and their associated concepts is also advisable.

1. [Terraform](#terraform) 
2. [Helm v3.3 or later](#helm)
3. [AWS CLI](#aws-cli)
4. [Kubectl](#kubectl) (optional)
5. [Kubernetes cluster monitoring tools](#kubernetes-cluster-monitoring-tools) (optional)

### :material-terraform: Terraform

Terraform is an open-source infrastructure as code tool that provides a consistent CLI workflow to create and manage the infrastructure of cloud environments. 

This project uses Terraform to create and manage the Atlassian Data Center infrastructure on AWS for use with supported Data Center products. 

!!! warning "Supported Products and Platforms"  

    * [AWS](https://aws.amazon.com/){.external} is the only supported cloud provider.
    * [Bamboo DC](https://confluence.atlassian.com/bamboo/bamboo-8-1-release-notes-1103070461.html){.external} is the only supported DC product

    Support for additional Cloud providers and DC products will be made available in future.

1. Check if Terraform is already installed by running the following command:
   ```shell
   terraform version
   ```
2. If Terraform is not installed, install it by following the [official instructions](https://learn.hashicorp.com/tutorials/terraform/install-cli){.external}.

### :material-package: Helm

Atlassian supports Helm Charts for some of its [Data Center products](https://atlassian.github.io/data-center-helm-charts/){.external}, including Bamboo. This project uses Helm charts to package Bamboo Data Center as a turnkey solution for your cloud infrastructure.

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

### :material-tools: Kubectl

Kubectl is a command line tool lets you control Kubernetes clusters. 

1. Check if kubectl is already installed by running the following command:
    ```shell
    kubectl version
    ```
2. If not installed this can be done by following the [official instructions](https://kubernetes.io/docs/tasks/tools/){.external}.

### :material-kubernetes: Kubernetes cluster monitoring tools

Kubernetes monitoring and issue diagnosis can be facilitated with a monitoring tool like one of those listed below. Installation and usage of one is not a requirement for deployments with this project but can certainly be of help when problems arise.

!!! Tip "Kubernetes monitoring tools"

    * [Prometheus](https://github.com/prometheus/prometheus){.external}
    * [Grafana](https://github.com/grafana/grafana){.external}
    * [Weave Scope](https://github.com/weaveworks/scope){.external}
    

 