MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash


### OSQUERY INSTALLATION

# This script is taken from https://hello.atlassian.net/wiki/spaces/SECURITY/pages/380804774/Osquery+AWS+Server+Deployment+Guide

sudo yum install -y yum-utils unzip jq
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

curl -L https://pkg.osquery.io/rpm/GPG | sudo tee /etc/pki/rpm-gpg/RPM-GPG-KEY-osquery
sudo yum-config-manager --add-repo https://pkg.osquery.io/rpm/osquery-s3-rpm.repo
sudo yum-config-manager --enable osquery-s3-rpm
sudo yum install -y osquery-${osquery_version}

# https://hello.atlassian.net/wiki/spaces/OBSERVABILITY/pages/140624694/Logging+pipeline+-+Sending+logs+to+Splunk#Kinesis-Stream-Details

cat <<'EOF' >> /etc/osquery/osquery.flags
--force=true
--host_identifier=hostname
--tls_hostname=fleet-server.services.atlassian.com
--config_plugin=tls
--config_tls_refresh=300
--enroll_tls_endpoint=/api/v1/osquery/enroll
--config_tls_endpoint=/api/v1/osquery/config
--enroll_secret_path=/etc/osquery/fleet.enrollment_secret
--logger_min_status=2
--aws_kinesis_stream=prod-logs
--aws_sts_arn_role=${aws_sts_arn_role}
--aws_region=${aws_sts_region}
--aws_sts_region=${aws_sts_region}
--aws_sts_session_name=osquery
--disable_audit=false
--disable_events=false
--audit_allow_config
--verbose
--tls_dump
--logger_plugin=aws_kinesis
EOF

# OSQUERY_SERVICE is set to https://microscope.prod.atl-paas.net/services/${env}
# It has to be created if it does not exist
cat <<'EOF' >> /etc/sysconfig/osqueryd
OSQUERY_SERVICE=${env}
OSQUERY_SERVICE_ENV=ci
OSQUERY_ENV=${env}
EOF

/usr/local/bin/aws --region ${osquery_secret_region} secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:${osquery_secret_region}:${account_id}:secret:${osquery_secret_name} | jq -r '.SecretString' > /etc/osquery/fleet.enrollment_secret

# osquery doesn't work with auditd service
service auditd stop
chkconfig auditd off

# Need to make sure osqueryd is started, and that it will automatically start on instance rebooting.
systemctl start osqueryd
systemctl enable osqueryd
systemctl status osqueryd.service

echo "Begin checking Fleet server availability"
curl -v https://fleet-server.services.atlassian.com/api/v1/osquery/enroll
echo "End checking fleet server availability"

### /OSQUERY INSTALLATION

--==MYBOUNDARY==--
