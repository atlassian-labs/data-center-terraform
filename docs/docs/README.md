# Infrastructure for Atlassian Data Center products on Kubernetes
[![Atlassian license](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square)](LICENSE) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)


Atlassian DC APP program provides App vendors in our ecosystem with ready-to-use environment setup tools. 
This project provides a tool to provision infrastructure for Atlassian DC helm chart products.
At this stage the scope is providing the infrastructure for Bamboo.  


## Prerequisites

In order to deploy the infrastructure for Atlassian Data Center products on Kubernetes you need to have the 
following applications installed on your local machine:

* AWS CLI
* helm
* Terraform

See [prerequisites](userguide/PREREQUISITES.md) for details. 

## Installation
Before installing the infrastructure for Atlassian products please make sure you read the 
[prerequisites](userguide/PREREQUISITES.md) section and completed the [configuration](userguide/CONFIGURATION.md). 

After you have done the above steps you can [install](userguide/INSTALLATION.md) the Atlassian Data Center infrastructure 
for selected products. 

## Uninstall the products and infrastructure cleanup

To uninstall the products and clean up the infrastructure run the following command:
```shell 
./pkg/scripts/uninstall
```

This will remove the products and all Atlassian Data Center infrastructure including Terraform state in S3 bucket and 
dynamodb lock table created by install process. 

!!! tip "Do you want to keep the terraform state?"
    If you want to keep the terraform state files and dynamodb lock table then use the switch `-s`:
    ```shell 
    ./pkg/scripts/uninstall -s
    ```


## Feedback

If you find any issue, [raise a ticket](https://support.atlassian.com/contact/). If you have general feedback or question 
regarding the charts, use [Atlassian Community Kubernetes space](https://community.atlassian.com/t5/Atlassian-Data-Center-on/gh-p/DC_Kubernetes).
  

## Contributions

Contributions are welcome! [Find out how to contribute](CONTRIBUTING.md). 

## License

Copyright (c) [2021] Atlassian and others.
Apache 2.0 licensed, see [LICENSE](LICENSE) file.

<br/> 


[![With ❤️ from Atlassian](https://raw.githubusercontent.com/atlassian-internal/oss-assets/master/banner-cheers-light.png)](https://www.atlassian.com)
