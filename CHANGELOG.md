# Change Log


## 2.8.0

**Release date:** 2024-04-30

* Added support to enable OpenSearch for Confluence [#381](https://github.com/atlassian-labs/data-center-terraform/pull/381)
* Restore OpenSearch from snapshot [#384](https://github.com/atlassian-labs/data-center-terraform/pull/384)
* Improve dcapt-snapshots tests [#387](https://github.com/atlassian-labs/data-center-terraform/pull/387)

## 2.7.9

**Release date:** 2024-04-27

* Fix launch template error [#386](https://github.com/atlassian-labs/data-center-terraform/pull/386)

## 2.7.8

**Release date:** 2024-04-22

* Fix Bamboo e2e tests [#383](https://github.com/atlassian-labs/data-center-terraform/pull/383)

## 2.7.7

**Release date:** 2024-04-17

* Update RDS 14.x version [#382](https://github.com/atlassian-labs/data-center-terraform/pull/382)

## 2.7.6

**Release date:** 2024-03-28

* Fix pre-flight checks for JSM and Bamboo [#377](https://github.com/atlassian-labs/data-center-terraform/pull/377)

## 2.7.5

**Release date:** 2024-03-26

* Exit installation script if product version does not exist in snapshots.json [#374](https://github.com/atlassian-labs/data-center-terraform/pull/374)
* Add optional CrowdStrike installation to user data [#375](https://github.com/atlassian-labs/data-center-terraform/pull/375)

## 2.7.4

**Release date:** 2024-03-13

* Make jvm args configurable [#373](https://github.com/atlassian-labs/data-center-terraform/pull/373)
* Disable Atlassian analytics [#372](https://github.com/atlassian-labs/data-center-terraform/pull/372)

## 2.7.3

**Release date:** 2024-02-26

* Fix restore from a local home snapshot [#369](https://github.com/atlassian-labs/data-center-terraform/pull/369)

## 2.7.2

**Release date:** 2024-02-21

* Upgrade kube-prom-stack to 56.6.2 [#367](https://github.com/atlassian-labs/data-center-terraform/pull/367)
* Bump RDS minor version to 13.13 [#366](https://github.com/atlassian-labs/data-center-terraform/pull/366)
* Upgrade EKS to 1.29 [#365](https://github.com/atlassian-labs/data-center-terraform/pull/365)
* Exit 0 if force uninstall has been successful [#364](https://github.com/atlassian-labs/data-center-terraform/pull/364)
* Update collect_k8s_logs.sh with region for describe-auto-scaling-groups [#363](https://github.com/atlassian-labs/data-center-terraform/pull/363)
* Cleaned up Bamboo additional environment variable - ATL_BASE_URL [#362](https://github.com/atlassian-labs/data-center-terraform/pull/362)
* Install and log collection script improvements [#361](https://github.com/atlassian-labs/data-center-terraform/pull/361)

## 2.7.1

**Release date:** 2024-01-09

* Force delete environment if terraform destroy failed [#358](https://github.com/atlassian-labs/data-center-terraform/pull/358)
* sanitize product variable to get rid of Windows style line endings [#359](https://github.com/atlassian-labs/data-center-terraform/pull/359)
* always delete terraform state [#360](https://github.com/atlassian-labs/data-center-terraform/pull/360)

## 2.7.0

**Release date:** 2024-01-03

* Read snapshots from a JSON file [#341](https://github.com/atlassian-labs/data-center-terraform/pull/341)
* Create a test container to run Selenium/stress tests [#345](https://github.com/atlassian-labs/data-center-terraform/pull/345)
* Update security policy for the https listener in the Nginx LB [#346](https://github.com/atlassian-labs/data-center-terraform/pull/346)
* Run extensive license checks before starting Terraform [#349](https://github.com/atlassian-labs/data-center-terraform/pull/349)
* Optimize Terraform plan to decrease deployment time [#351](https://github.com/atlassian-labs/data-center-terraform/pull/351)
* Automatically clean up PVCs created from volume claim templates [#352](https://github.com/atlassian-labs/data-center-terraform/pull/352)
* Bump EKS version to 1.28 [#352](https://github.com/atlassian-labs/data-center-terraform/pull/352)
* Make it possible to restore local home PVs from snapshots [#355](https://github.com/atlassian-labs/data-center-terraform/pull/355)
* Optimize NFS server deployment to decrease infra creation time and flatten Terraform plan [#356](https://github.com/atlassian-labs/data-center-terraform/pull/356)


## 2.6.0

**Release date:** 2023-08-14

* Add go-to-sleep nodes and external dns [#333](https://github.com/atlassian-labs/data-center-terraform/pull/333)
* Fix Crowd dependency issues [#334](https://github.com/atlassian-labs/data-center-terraform/pull/334)
* Add EBS and RDS snapshots checks [#336](https://github.com/atlassian-labs/data-center-terraform/pull/336)
* Fix S3 and DynamoDB deletion [#338](https://github.com/atlassian-labs/data-center-terraform/pull/338)

## 2.5.0

**Release date:** 2023-06-13

* Add Prometheus monitoring stack [#320](https://github.com/atlassian-labs/data-center-terraform/pull/320)
* Use name prefix when creating launch template [#328](https://github.com/atlassian-labs/data-center-terraform/pull/328)
* Run terraform init when uninstalling infra [#330](https://github.com/atlassian-labs/data-center-terraform/pull/330)
* Dockerize install and uninstall [#322](https://github.com/atlassian-labs/data-center-terraform/pull/322)

## 2.4.0

**Release date:** 2023-04-04

* Support Crowd DB and EBS snapshot restoration [#317](https://github.com/atlassian-labs/data-center-terraform/pull/317)
* Update EKS output [#316](https://github.com/atlassian-labs/data-center-terraform/pull/316)
* Crowd Module added [#315](https://github.com/atlassian-labs/data-center-terraform/pull/315)
* Update EKS to 1.25 [#311](https://github.com/atlassian-labs/data-center-terraform/pull/311)

## 2.3.1

**Release date:** 2023-02-07

* Fix instance disk size override [#303](https://github.com/atlassian-labs/data-center-terraform/pull/303)
* Update nfs-server image tag to address performance/stability issues [#305](https://github.com/atlassian-labs/data-center-terraform/pull/305)
* Fix osquery installation and version upgrade [#304](https://github.com/atlassian-labs/data-center-terraform/pull/304)

## 2.3.0

**Release date:** 2023-01-13

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
