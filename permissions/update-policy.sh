#!/usr/bin/env bash

# This script is used for updating a policy with a new version
# It'll try creating a new version first, it failed due to the policy version limit, it'll delete the old versions and retry creating the new version
# Update policy_arn and policy_document_path with the actual values
policy_arn="arn:aws:iam::accountId:policy/policyName"
policy_document_path="./policy.json"

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
    fi
  else
    echo "An unexpected error occurred: $output"
  fi
fi