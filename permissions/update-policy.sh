#!/usr/bin/env bash

# This script is used for updating a policy with a new version. It'll try creating a new version first,
# if failed due to the policy version limit, it'll delete the old versions and retry creating the new version.
#
# Pass in the policy_arn and policy_document_path as arguments to the script
# Usage: ./update-policy.sh arn:aws:iam::accountId:policy/policyName ./policy.json

# Check if two arguments are passed
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <policy_arn> <policy_document_path>"
  exit 1
fi

policy_arn="$1"
policy_document_path="$2"

# Attempt to create a new policy version and capture the output and error
output=$(aws iam create-policy-version \
    --policy-arn "$policy_arn" \
    --policy-document file://"$policy_document_path" --set-as-default 2>&1)
exit_status=$?

# Check the exit status
if [ $exit_status -eq 0 ]; then
  echo "Policy version created successfully"
else
  # Check if the output contains the specific error message
  if echo "$output" | grep -q "A managed policy can have up to 5 versions."; then
    echo "Policy version number exceeded 5"

    # List all policy versions
    versions=$(aws iam list-policy-versions --policy-arn "$policy_arn" | jq -r '.Versions[] | select(.IsDefaultVersion == false) | .VersionId')

    # Loop through the versions and delete them
    for version in $versions; do
      aws iam delete-policy-version --policy-arn "$policy_arn" --version-id "$version"
      echo "Deleted policy version $version"
    done

    # Retry creating the policy version
    retry_output=$(aws iam create-policy-version \
        --policy-arn "$policy_arn" \
        --policy-document file://"$policy_document_path" --set-as-default 2>&1)
    retry_exit_status=$?
    if [ $retry_exit_status -eq 0 ]; then
      echo "Policy version created successfully after deletion"
    else
      echo "Failed to create policy version after deletion: $retry_output"
      exit 1
    fi
  else
    echo "An unexpected error occurred: $output"
    exit 1
  fi
fi