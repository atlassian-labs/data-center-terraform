# Limitations

## Products and Platforms

!!! info "Available Products and Platforms"

    Current project limitations listed below:

    * [AWS](https://aws.amazon.com/){.external} is the only supported cloud provider.
    * [Jira](https://confluence.atlassian.com/jirasoftware/jira-software-8-19-x-release-notes-1082526044.html){.external}, [Jira Service Management](https://confluence.atlassian.com/servicemanagement/jira-service-management-4-20-x-release-notes-1085202556.html), [Confluence](https://confluence.atlassian.com/doc/confluence-7-13-release-notes-1044114085.html){.external}, [Bitbucket](https://confluence.atlassian.com/bitbucketserver/bitbucket-data-center-and-server-7-17-release-notes-1086401305.html){.external}, [Bamboo](https://confluence.atlassian.com/bamboo/bamboo-8-1-release-notes-1103070461.html){.external} are the DC products supported by this project.
``

## Infrastructure limitations

### Cloud provider

Amazon Web Services (AWS) is the only supported cloud platform.

### Database

PostgreSQL is the defined database engine for the products and cannot be modified in the configuration. However, users can change the database [instance type](../userguide/configuration/CONFIGURATION.md#database-instance-class) and [storage size](../userguide/configuration/CONFIGURATION.md#database-allocated-storage).
