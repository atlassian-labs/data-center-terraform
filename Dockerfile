# Example docker command to run install script
# docker run --env-file aws_envs \
# -v "$PWD/.terraform:/data-center-terraform/.terraform" \
# -v "$PWD/logs:/data-center-terraform/logs" \
# -v "$PWD/config.tfvars:/data-center-terraform/config.tfvars" \
# -it atlassianlabs/terraform ./install.sh -c config.tfvars
#
# Example docker command to collect k8s logs
# docker run --env-file aws_envs \
# -v "$PWD/k8s_logs:/data-center-terraform/k8s_logs" \
# -v "$PWD/logs:/data-center-terraform/logs" \
# -it atlassianlabs/terraform ./scripts/collect_k8s_logs.sh atlas-cluster-name-cluster us-east-2 k8s_logs

# Example docker command to run uninstall script
# docker run --env-file aws_envs \
# -v "$PWD/.terraform:/data-center-terraform/.terraform" \
# -v "$PWD/logs:/data-center-terraform/logs" \
# -v "$PWD/config.tfvars:/data-center-terraform/config.tfvars" \
# -it atlassianlabs/terraform ./uninstall.sh -t -c config.tfvars

# In those example aws_envs should contain AWS variables needed for authorization without quotes like:
# AWS_ACCESS_KEY_ID=123dsa321asd
# AWS_SECRET_ACCESS_KEY=asd123asd123

ARG BASE_IMAGE=ubuntu:22.04
FROM $BASE_IMAGE

RUN apt-get update \
    && apt-get install -y gnupg software-properties-common curl unzip \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get update && apt-get install -y terraform jq

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

COPY . /data-center-terraform

WORKDIR /data-center-terraform
