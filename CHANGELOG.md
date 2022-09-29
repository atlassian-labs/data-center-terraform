# Change Log

## 2.0.5

**Release date:** 2022-09-29

* Fixed EKS Cycle issue
* Introduced termination graceful period configuration for all products

## 2.0.4

**Release date:** 2022-08-18

* Fixed the setup-go github action

## 2.0.3

**Release date:** 2022-08-08

* Updated the default Helm chart version to 1.5.0 for Jira, Bitbucket, and Bamboo
* Introduced a configurable access restriction to the deployed applications
* Allowed nodes groups to spin up more than 1 node from start
* Allowed additional roles to access the EKS cluster

## 2.0.2

**Release date:** 2022-06-30

* Upgraded Helm chart version to 1.4.0
* Using v1beta1 apiVersion for client.authentication.k8s.io


## 2.0.1

**Release date:** 2022-05-18

* Improved Bitbucket e2e tests

## 2.0.0

**Release date:** 2022-05-17

* Added support for Jira Software, Jira Service Management, Confluence and Bitbucket
* AWS EBS and RDS snapshots can now be used for restoring datasets
* Changed shared home storage from EFS to NFS for all products
* Made product version configurable
* Added autoscaler to EKS cluster
* Upgraded Helm chart version to 1.3.0
* Improved documentation

**Note:** An upgrade from the pre 2.x version is not supported.

## 1.0.2

**Release date:** 2022-03-22

* Fixed provider versions


## 1.0.1

**Release date:** 2022-02-07

* Improved integration testing
* Added optional local Helm charts installation
* Updated the copyright info


## 1.0.0

**Release date:** 2022-01-31

* Improved documentation
* Changed the default values in the configuration template
* Resume the Bamboo server after installation
* Improved install and uninstall scripts
* Added optional configuration for Bamboo version and resources available to Bamboo DC and Bamboo agents
* Improved the end to end tests
* Changed the maximum length for environment name to 24 characters and restricted to lowercase 


## 0.0.2-beta

**Release date:** 2022-01-11

* Updated the Bamboo software and Bamboo agent Helm chart versions to 1.0.0 


## v0.0.1-beta

Initial release
