# Limitations

!!! warning "Supported Products and Platforms"
    **This project is designed for Atlassian vendors to run DCAPT performance toolkit and is not officially supported.**

    Current project limitations listed below:

    * [AWS](https://aws.amazon.com/){.external} is the only supported cloud provider.
    * [Bamboo](https://confluence.atlassian.com/bamboo/bamboo-8-1-release-notes-1103070461.html){.external}, [Confluence](https://confluence.atlassian.com/doc/confluence-7-13-release-notes-1044114085.html){.external}, and [Jira](https://confluence.atlassian.com/jirasoftware/jira-software-8-19-x-release-notes-1082526044.html){.external} are the DC products supported by this project.

    Support for additional DC products will be made available in future.

## Product limitations

At this time, Bamboo Data Center is the only product with support for Terraform deployment. 
We're planning to add support for more [Atlassian Data Center products](https://atlassian.github.io/data-center-helm-charts/) in the future. 

## Infrastructure limitations

### Cloud provider

Amazon Web Services (AWS) is the only supported cloud platform.

### Database

PostgreSQL is the defined database engine for the products and cannot be modified in the configuration. However, users can change the database [instance type](../userguide/configuration/CONFIGURATION.md#database-instance-class) and [storage size](../userguide/configuration/CONFIGURATION.md#database-allocated-storage).
