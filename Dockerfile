# Example docker command to run install script executed from root dir of the repository
# docker run --env-file aws_envs -v "$PWD:/data-center-terraform/" -it localtfdocker ./install.sh -f -c dcapt.tfvars
# In this example aws_envs should contains AWS variables needed for authorization like:
# AWS_SECRET_ACCESS_KEY="asd123asd123"
# AWS_ACCESS_KEY_ID="123dsa321asd"

FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y gnupg software-properties-common curl unzip \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get update && apt-get install -y terraform

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

WORKDIR /data-center-terraform
