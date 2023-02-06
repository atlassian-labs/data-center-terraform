# Change Log

## 2.3.1

**Release date:** 2022-02-07

* Fix instance disk size override [#303](https://github.com/atlassian-labs/data-center-terraform/pull/303)
* Update nfs-server image tag to address performance/stability issues [#305](https://github.com/atlassian-labs/data-center-terraform/pull/305)
* Fix osquery installation and version upgrade [#304](https://github.com/atlassian-labs/data-center-terraform/pull/304)

## 2.3.0

**Release date:** 2022-01-13

* Read engine_version from snapshot. Support Postgres 14 [#297](https://github.com/atlassian-labs/data-center-terraform/pull/297)

## 2.2.4

**Release date:** 2022-12-30

* Add NAT EIP to whitelisted CIDRs in Nginx svc [#298](https://github.com/atlassian-labs/data-center-terraform/pull/298)

## 2.2.3

**Release date:** 2022-12-15

* Fix uninstall script [#294](https://github.com/atlassian-labs/data-center-terraform/pull/294)

## 2.2.2

**Release date:** 2022-12-14

* Make skipping refresh optional on destroy [#293](https://github.com/atlassian-labs/data-center-terraform/pull/293)

## 2.2.1

**Release date:** 2022-12-02

* Fix terraform destroy [#489](https://github.com/atlassian/data-center-helm-charts/pull/489)

## 2.2.0

**Release date:** 2022-12-01

* Update EKS version to 1.24 [#288](https://github.com/atlassian-labs/data-center-terraform/pull/288)
* Add Elasticsearch e2e tests [#287](https://github.com/atlassian-labs/data-center-terraform/pull/287)
* Fix use of local Helm chart for all products [#284](https://github.com/atlassian-labs/data-center-terraform/pull/284)
* Fix resources termination order to avoid pods stuck in Terminating [#282](https://github.com/atlassian-labs/data-center-terraform/pull/282)
* Update EKS Terraform module to 18.20.2 [#277](https://github.com/atlassian-labs/data-center-terraform/pull/277)
* Disable automatic DB updates during maintenance window [#276](https://github.com/atlassian-labs/data-center-terraform/pull/276)

## 2.1.1

**Release date:** 2022-11-01

* PV binding are now bidirectional
* Update and/or pin some dependency versions

## 2.1.0

**Release date:** 2022-10-24

* Introduced configuration for Synchrony instance for Confluence.
* Improved stability by adding product termination grace period 
* Introduced option for enabling osquery on EC2 worker nodes
* Added an option to disable 443 port for nginx ingress

## 2.0.6

**Release date:** 2022-10-05

* Fixed end-to-end test by skipping resuming Bamboo server if it's already running.
* Added script to collecting k8s logs and events to help debugging 
* Default version of confluence Helm chart is updated to 1.5.1

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
