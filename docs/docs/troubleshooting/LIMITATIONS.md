# Limitations

!!! warning "Supported Products and Platforms"
    **This project is still under development and is not officially supported.**

    Current project limitations listed below:

    * [AWS](https://aws.amazon.com/){.external} is the only supported cloud provider.
    * [Bamboo DC](https://confluence.atlassian.com/bamboo/bamboo-8-1-release-notes-1103070461.html){.external} is the only DC product supported by this project.

    Support for additional Cloud providers and DC products will be made available in future.

## Product limitations

At this time, Bamboo Data Center is the only product with support for Terraform deployment. 
We're planning to add support for more [Atlassian Data Center products](https://atlassian.github.io/data-center-helm-charts/) in the future. 

## Infrastructure limitations

### Cloud provider

Amazon Web Services (AWS) is the only supported cloud platform.

### Database

PostgreSQL is the defined database engine for the products and cannot be modified in the configuration. However, users can change the database [instance type](../userguide/CONFIGURATION.md#database-instance-class) and [storage size](../userguide/CONFIGURATION.md#database-allocated-storage).

### Scaling EKS

You cannot change the number of the EKS cluster nodes (`desired_capacity`) and node type (`instance_types`) after provisioning the environment.

### Scaling DC product

Follow the official documentation on [Product Scaling](https://atlassian.github.io/data-center-helm-charts/userguide/resource_management/RESOURCE_SCALING/#product-scaling) for more details.