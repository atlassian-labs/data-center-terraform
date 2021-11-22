# Limitations 

## Product limitations
At this time **Bamboo Data Center** is the only supported product by **Terraform** deployment. 
We have a plan to support more [Atlassian Data Center products](https://atlassian.github.io/data-center-helm-charts/) in the future. 

## Infrastructure limitations

### Cloud Provider
AWS Cloud provider is the only supported platform. 

### Database 
Postgres is the defined database engine for the products and cannot be modified in the configuration. 
However, use can change the database [instance type](../userguide/CONFIGURATION.md#database-instance-class) and [storage size](../userguide/CONFIGURATION.md#database-allocated-storage). 