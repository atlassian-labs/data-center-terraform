# Limitations

Because the project is still under active development, it comes with certain limitations.

## Product limitations

At this time, Bamboo Data Center is the only product with support for Terraform deployment. 
We're planning to add support for more [Atlassian Data Center products](https://atlassian.github.io/data-center-helm-charts/) in the future. 

## Infrastructure limitations

### Cloud provider

Amazon Web Services (AWS) is the only supported cloud platform.

### Database

PostgreSQL is the defined database engine for the products and cannot be modified in the configuration. However, users can change the database [instance type](../userguide/CONFIGURATION.md#database-instance-class) and [storage size](../userguide/CONFIGURATION.md#database-allocated-storage).