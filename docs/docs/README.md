# Infrastructure for Atlassoan Data Center products on Kubernetes
[![Atlassian license](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square)](LICENSE) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)


Atlassian DC APP program provides App vendors in our ecosystem with ready-to-use environment setup tools. 
This project provides a tool to provision infrastructure for Atlassian DC helm chart products.
At this stage the scope is providing the infrastructure for Bamboo.  


## Usage

In order to use this project you need to have the following application installed on your local machine and an admin access to an AWS account:

* AWS CLI
* Kubernetes 
* helm
* Terraform

## Installation

1. Login with an admin access to an AWS account
2. Checkout out the project into your local
3. Open a terminal and change your current path to the root of the project
4. Run the following script to create the infrastructure:
```shell
./src/main/scripts/start-dc-terraform.sh
```


## Documentation
> TODO


## Feedback

If you find any issue, [raise a ticket](https://support.atlassian.com/contact/). If you have general feedback or question regarding the charts, use [Atlassian Community Kubernetes space](https://community.atlassian.com/t5/Atlassian-Data-Center-on/gh-p/DC_Kubernetes).
  

## Contributions

Contributions are welcome! [Find out how to contribute](CONTRIBUTING.md). 

## License

Copyright (c) [2021] Atlassian and others.
Apache 2.0 licensed, see [LICENSE](LICENSE) file.

<br/> 


[![With ❤️ from Atlassian](https://raw.githubusercontent.com/atlassian-internal/oss-assets/master/banner-cheers-light.png)](https://www.atlassian.com)
