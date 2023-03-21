MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash

### OSQUERY INSTALLATION

sudo yum install -y yum-utils unzip jq
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

curl -L https://pkg.osquery.io/rpm/GPG | sudo tee /etc/pki/rpm-gpg/RPM-GPG-KEY-osquery
sudo yum-config-manager --add-repo https://pkg.osquery.io/rpm/osquery-s3-rpm.repo
sudo yum-config-manager --enable osquery-s3-rpm
sudo yum install -y osquery-${osquery_version}

cat <<'EOF' >> /etc/osquery/osquery.flags
--force=true
--host_identifier=hostname
--tls_hostname=${osquery_fleet_entrollment_host}
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
--logger_plugin=aws_kinesis
EOF

cat <<'EOF' >> /etc/sysconfig/osqueryd
OSQUERY_SERVICE=${env}
OSQUERY_SERVICE_ENV=ci
OSQUERY_ENV=${env}
EOF

aws --region ${osquery_secret_region} secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:${osquery_secret_region}:${account_id}:secret:${osquery_secret_name} | jq -r '.SecretString' > /etc/osquery/fleet.enrollment_secret

# osquery doesn't work with auditd service
service auditd stop
chkconfig auditd off

# Need to make sure osqueryd is started, and that it will automatically start on instance rebooting.
systemctl start osqueryd
systemctl enable osqueryd
systemctl status osqueryd.service

### /OSQUERY INSTALLATION

--==MYBOUNDARY==--
