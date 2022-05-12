# Limitations

## Products and Platforms

!!! info "Available Products and Platforms"

    Current project limitations listed below:

    * [AWS](https://aws.amazon.com/){.external} is the only supported cloud provider.
    * [Jira](https://confluence.atlassian.com/jirasoftware/jira-software-8-19-x-release-notes-1082526044.html){.external}, [Jira Service Management](https://confluence.atlassian.com/servicemanagement/jira-service-management-4-20-x-release-notes-1085202556.html), [Confluence](https://confluence.atlassian.com/doc/confluence-7-13-release-notes-1044114085.html){.external}, [Bitbucket](https://confluence.atlassian.com/bitbucketserver/bitbucket-data-center-and-server-7-17-release-notes-1086401305.html){.external}, [Bamboo](https://confluence.atlassian.com/bamboo/bamboo-8-1-release-notes-1103070461.html){.external} are the DC products supported by this project.

### Bitbucket scaling up issue with NFS

There is an intermittent issue where scaling the Bitbucket cluster up resulted in new pods not being able to aquire a lock on shared home. 

Log file: 
    
```
bitbucket have write permission on that directory? Is file locking enabled for the filesystem?
java.io.IOException: No locks available
at java.base/sun.nio.ch.FileDispatcherImpl.lock0(Native Method)
at java.base/sun.nio.ch.FileDispatcherImpl.lock(FileDispatcherImpl.java:96)
at java.base/sun.nio.ch.FileChannelImpl.tryLock(FileChannelImpl.java:1161)
at com.atlassian.stash.internal.home.HomeLock.acquireLock(HomeLock.java:112)
at com.atlassian.stash.internal.home.HomeLock.lock(HomeLock.java:98)
at com.atlassian.stash.internal.home.HomeLockAcquirer.lock(HomeLockAcquirer.java:58)
at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
at org.springframework.context.support.AbstractApplicationContext.finishBeanFactoryInitialization(AbstractApplicationContext.java:918)
at org.springframework.context.support.AbstractApplicationContext.refresh(AbstractApplicationContext.java:583)
at javax.servlet.GenericServlet.init(GenericServlet.java:158)
at java.base/java.lang.Thread.run(Thread.java:829)
... 37 frames trimmed
2022-03-22 05:38:46,125 WARN  [spring-startup]  o.s.w.c.s.XmlWebApplicationContext Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'crowdAliasDao': Unsatisfied dependency expressed through method 'setSessionFactory' parameter 0; nested exception is org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'sharedHomeLockAcquirer' defined in class path resource [stash-context.xml]: Invocation of init method failed; nested exception is com.atlassian.stash.internal.home.HomeLockFailedException: Unable to create and acquire shared lock file '/var/atlassian/application-data/shared-home/.lock' for Bitbucket shared home directory '/var/atlassian/application-data/shared-home'.

Please ensure that the user running Bitbucket has permission to write to this directory and that file locking is enabled for your network file system.

If this is already the case, please check the logs for more information.
2022-03-22 05:38:46,136 INFO  [spring-startup]  c.a.s.internal.home.HomeLockAcquirer Releasing lock on /var/atlassian/application-data/bitbucket
```

This only been occasionally observed to happen when scaling pods from 1 to 2. 
If you pre-seed Bitbucket instance and set bitbucket_replica_count to 2 from the beginning, no issue will occur. 

Workaround will be to kill both Bitbucket pod and NFS pod, and wait for them to be up again.

```
kubectl delete pod bitbucket-0 -n atlassian
kubectl delete pod bitbucket-nfs-server-0 -n atlassian
```

## Infrastructure limitations

### Cloud provider

Amazon Web Services (AWS) is the only supported cloud platform.

### Database

PostgreSQL is the defined database engine for the products and cannot be modified in the configuration. However, users can change the database [instance type](../userguide/configuration/CONFIGURATION.md#database-instance-class) and [storage size](../userguide/configuration/CONFIGURATION.md#database-allocated-storage).

### Domain
Stick to either domain or no domain for the whole deployment. Switching between domain and no domain is not supported.

## Deployment limitations
