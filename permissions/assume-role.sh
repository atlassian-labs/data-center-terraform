#!/usr/bin/env bash

# This script is useful when you want to do role chaining.
# Make sure you've already authenticated into AWS CLI before running this script.
# Replace accountId and roleName with the actual values.
# Run this script by executing `source assume-role.sh` in the terminal, otherwise change won't be propagated to the parent shell.

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

ROLE_DATA=$(aws sts assume-role --role-arn arn:aws:iam::accountId:role/roleName --role-session-name terraform-policy)

export AWS_ACCESS_KEY_ID=$(echo $ROLE_DATA | jq ".Credentials.AccessKeyId" | sed 's/"//g')
export AWS_SECRET_ACCESS_KEY=$(echo $ROLE_DATA | jq ".Credentials.SecretAccessKey" | sed 's/"//g')
export AWS_SESSION_TOKEN=$(echo $ROLE_DATA | jq ".Credentials.SessionToken" | sed 's/"//g')

ASSUMED_ROLE=$(aws sts get-caller-identity | jq ".Arn" | sed 's/"//g')
echo "You're assumed role ${ASSUMED_ROLE}"
