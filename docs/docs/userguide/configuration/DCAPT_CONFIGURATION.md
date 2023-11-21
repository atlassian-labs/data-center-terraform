# DCAPT Configuration

Besides deploying Atlassian DC products, it is possible to spin up a testing environment to run [Data Center App Performance Toolkit tests](https://github.com/atlassian/dc-app-performance-toolkit/tree/master).

## Create DCAPT Test Deployment

Create an additional deployment for DCAPT Jmeter and Selenium test environment:

```shell
start_test_deployment = true
```

## Configure DCAPT Test Deployment

The default values works well with a typical DCAPT test, however, if you need to allocate more resources to the test container,
use the following variables to override the defaults:

### Configure CPU
```shell
test_deployment_cpu_request = "1"

test_deployment_cpu_limit = "4"
```

### Configure Memory

```shell
test_deployment_mem_request = "4Gi"

test_deployment_mem_limit = "6Gi"

```

### Configure Image and Tag

The container starts in a privileged mode to be able to run docker-in-docker. If you need to change the image repository
or tag, use the following variables:

```shell
test_deployment_image_repo = "docker"

test_deployment_image_tag = "24.0.7-dind"
```