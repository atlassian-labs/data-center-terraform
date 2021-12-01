# Infrastructure for Atlassian Data Center products on Kubernetes
[![Atlassian license](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square)](https://github.com/atlassian-labs/data-center-terraform/blob/main/LICENSE) 
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/atlassian-labs/data-center-terraform/blob/main/CONTRIBUTING.md)

!!! warning "This project is still under development and is not officially supported."

[Atlassian DC Apps program](https://developer.atlassian.com/platform/marketplace/dc-apps-submitting-your-app/#step-2--test-your-app-s-performance-at-scale)
provides App vendors in Atlassian ecosystem with tools to setup ready-to-use environment. 
This project provides a tool to provision infrastructure for Atlassian DC helm chart products.
At this stage the scope is providing the infrastructure for Bamboo DC.


## Prerequisites

In order to deploy the infrastructure for Atlassian Data Center products on Kubernetes you need to have the 
following applications installed on your local machine:

* AWS CLI
* helm
* Terraform

See [prerequisites](userguide/PREREQUISITES.md) for details. 

## Installation
Before installing the infrastructure for Atlassian products, please make sure you read the 
[prerequisites](userguide/PREREQUISITES.md) section and completed the [configuration](userguide/CONFIGURATION.md). 

After you have done the above steps you can [install](userguide/INSTALLATION.md) the Atlassian Data Center infrastructure 
for selected products. 

## Uninstall the products and infrastructure 

In installation process, Terraform created all required resources on AWS environment in order to provide the infrastructure to handle Atlassian Data Center products. 
If you want to uninstall all products and cleanup the infrastructure see [cleanup page](userguide/CLEANUP.md).


## Feedback

If you find any issue, [raise a ticket](https://github.com/atlassian-labs/data-center-terraform/issues). If you have general feedback or question 
regarding the project, use [Atlassian Community Kubernetes space](https://community.atlassian.com/t5/Atlassian-Data-Center-on/gh-p/DC_Kubernetes).
  

## Contributions

Contributions are welcome! [Find out how to contribute](https://github.com/atlassian-labs/data-center-terraform/blob/main/CONTRIBUTING.md). 

## License

Copyright (c) [2021] Atlassian and others.
Apache 2.0 licensed, see [LICENSE](https://github.com/atlassian-labs/data-center-terraform/blob/main/LICENSE) file.

<br/> 


[![With ❤️ from Atlassian](https://raw.githubusercontent.com/atlassian-internal/oss-assets/master/banner-cheers-light.png)](https://www.atlassian.com)
