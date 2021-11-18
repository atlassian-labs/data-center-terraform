# Limitations 

## Product limitations
We officially support a range of [Atlassian Data Center products in Kubernetes](https://atlassian.github.io/data-center-helm-charts/). 
However, at this time **Bamboo Data Center** is the only supported product by Terraform deployment. 
We have a plan to add more Data Center products in the future. 

## Infrastructure limitations

### Cloud Provider
AWS Cloud provider is the only supported platform. 

### Kubernetes Cluster Size
The number of nodes in the Kubernetes cluster can be up to 10 nodes. Number of nodes cannot be less than 1.
Cluster instance type is configurable and can be changed by the user based on the environment requirement. 

### Database 
Postgres is the defined database engine for the products and cannot be modified in the configuration. 
However, use can change the database instance type and storage size. 