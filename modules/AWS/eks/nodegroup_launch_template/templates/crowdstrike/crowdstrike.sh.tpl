--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash

### CROWDSTRIKE INSTALLATION

sudo yum install -y yum-utils unzip jq
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# fetch falcon sensor rpm
aws s3 cp s3://trust-shared-agents/crowdstrike/amazon/falcon-sensor-${falcon_sensor_version}.amzn2.x86_64.rpm .

# install falcon sensor
sudo yum install ./falcon-sensor-${falcon_sensor_version}.amzn2.x86_64.rpm -y

# fetch a secret with cid and token
crowdstrike_cid_and_token=$(aws secretsmanager get-secret-value \
        --region "${aws_region}" \
        --secret-id "arn:aws:secretsmanager:${aws_region}:${crowdstrike_aws_account_id}:secret:shared/${crowdstrike_secret_name}" \
        --query SecretString \
        --output text \
        2>&1)

crowdstrike_cid=$(echo "${crowdstrike_cid_and_token}" | jq -r '.cid')
crowdstrike_token=$(echo "${crowdstrike_cid_and_token}" | jq -r '.token')

# register agent to CrowdStrike console
agent_tags="non-micros,non-micros/dev,non-micros/dev/dcapt"
sudo /opt/CrowdStrike/falconctl -s -f --tags="$${agent_tags}" --cid="$${crowdstrike_cid}" --provisioning-token="$${crowdstrike_token}"

sudo systemctl start falcon-sensor.service
sudo systemctl enable falcon-sensor.service

# verify crowdstrike is running 
sudo yum list installed | grep falcon-sensor
sudo systemctl is-active falcon-sensor
sudo systemctl is-enabled falcon-sensor

sudo lsmod | grep falcon
ps -ef | grep falcon-sensor
sudo netstat -tapn | grep falcon

### END CROWDSTRIKE INSTALLATION