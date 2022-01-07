# This script will generate/override the `modules/tfstate/tfstate-locals.tf` and `terraform-backend.tf`

FORCE_FLAG=
while getopts f?c: name ; do
    case $name in
    c)  CONFIG_PATH="${OPTARG}";;   # Config file name to install - this overrides the default, 'config.tfvars'
    f)  FORCE_FLAG="true";;         # Force
    ?)  echo "Invalid arguments."; show_help; exit 1;;
    esac
done

if [ "${0##*/}" == "generate-variables.sh" ]; then
  # the script ran directly from terminal
   ROOT_PATH=$(cd $(dirname "${0}")/..; pwd)
 else
   # the script called by install.sh or uninstall.sh
  ROOT_PATH=$(cd $(dirname "${0}"); pwd)
fi
SCRIPT_PATH="${ROOT_PATH}/scripts"

source "${SCRIPT_PATH}/common.sh"

show_help() {
    log "The terraform config filename for infrastructure is missing." "ERROR"
    echo
    echo "Usage: generate-variables.sh -c <config_file> [-f]"
    exit 1
}

if [ $# -lt 1 ]; then
  show_help
fi
CONFIG_ABS_PATH="$(cd "$(dirname "${CONFIG_PATH}")"; pwd)/$(basename "${CONFIG_PATH}")"
if [ ! -f "${CONFIG_ABS_PATH}" ]; then
  log "Could not find config file '${CONFIG_PATH}'." "ERROR"
  show_help
fi

set_variables() {
  # extract S3 bucket, dynamodb, tags, and region from locals.tf
  ENVIRONMENT_NAME=$(grep 'environment_name' "${CONFIG_ABS_PATH}" | sed -nE 's/^.*"(.*)".*$/\1/p')
  REGION=$(grep 'region' "${CONFIG_ABS_PATH}" | sed -nE 's/^.*"(.*)".*$/\1/p')

  # Get the AWS account ID
  AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

  # Generates the unique s3 bucket and key names for the deployment for keeping the terraform state
  S3_BUCKET="atlassian-data-center-${REGION}-${AWS_ACCOUNT_ID}-tf-state"
  BUCKET_KEY="${ENVIRONMENT_NAME}"

  # Generates the unique dynamodb table names for the deployment lock ( convert all '-' to '_' )
  DYNAMODB_TABLE="atlassian_data_center_${REGION//-/_}_${AWS_ACCOUNT_ID}_tf_lock"

  BACKEND_TF="${ROOT_PATH}/terraform-backend.tf"
  TFSTATE_LOCALS="${ROOT_PATH}/modules/tfstate/tfstate-locals.tf"
  ASG_EC2_TAG_PATH="${ROOT_PATH}/modules/AWS/asg_ec2_tagging"
}

# Cleaning all the generated terraform state variable and backend file
cleanup_existing_files() {
  if [ -f "${BACKEND_TF}" ]; then
    # remove terraform generated files if the environment name or AWS Account ID or Region has changed
    set +e
    if ! grep -q "${S3_BUCKET}" "${BACKEND_TF}"  ; then
      EXISTING_S3_BUCKET=$(grep 'bucket' ${BACKEND_TF} | sed -nE 's/^.*"(.*)".*$/\1/p')
      log "We found this repo is using S3 backend '"${EXISTING_S3_BUCKET}"'."
      log "It means the repo was used to provision environments in different account or region."
      log "Terraform loses the existing S3 backend if you proceed with this configuration."
      log "As the result, you are not able to manage the previous environments anymore."
      if [ "${FORCE_FLAG}" == "true" ]; then
        log "Force flag was passed, continuing with the deployment." "WARN"
      else
        log "Before proceeding make sure you have cleaned up all environments that provisioned with this repo previously."
        echo
        read -p "Are you sure that you want to proceed(Yes/No)? " yn
        case $yn in
            Yes|yes ) log "Thank you. We have your confirmation to proceed.";;
            No|no|n|N ) log "Execution is cancelled by the user" "ERROR" ; exit;;
            * ) log "Please answer 'Yes' to confirm deleting the infrastructure." "ERROR" ; exit;;
        esac
      fi
    fi
    # If the environment is different from last run then we need to cleanup the terraform generated files
    if ! grep -q "${BUCKET_KEY}" "${BACKEND_TF}"  ; then
      CLEANUP_TERRAFORM_FILES="-t"
    fi
    set -e
  fi
  log "Cleaning all the generated variable files."
  sh "${SCRIPT_PATH}/cleanup.sh" -s -r "${ROOT_PATH}"
}

inject_variables_to_templates() {
  # Generate the terraform backend, where terraform store the state of the infrastructure
  log "Generating the terraform backend definition file 'terraform.backend.tf'."
  sed 's/<REGION>/'"${REGION}"'/g'  "${ROOT_PATH}/templates/terraform-backend.tf.tmpl" | \
  sed 's/<BUCKET_NAME>/'"${S3_BUCKET}"'/g' | \
  sed 's/<BUCKET_KEY>/'"${BUCKET_KEY}"'/g'  | \
  sed 's/<DYNAMODB_TABLE>/'"${DYNAMODB_TABLE}"'/g' \
    > "${BACKEND_TF}"

  # Generate the locals for terraform state
  log "Generating the terraform state local file 'modules/tfstate/tfstate-locals.tf'."
  sed 's/<REGION>/'"${REGION}"'/g'  "${ROOT_PATH}/templates/tfstate-locals.tf.tmpl" | \
  sed 's/<BUCKET_NAME>/'"${S3_BUCKET}"'/g' | \
  sed 's/<BUCKET_KEY>/'"${BUCKET_KEY}"'/g'  | \
  sed 's/<DYNAMODB_TABLE>/'"${DYNAMODB_TABLE}"'/g' \
    > "${TFSTATE_LOCALS}"
}

copy_injected_files() {
  # fetch the config files from root
  cp -fr "${ROOT_PATH}/variables.tf" "${ROOT_PATH}/modules/tfstate"
  cp -fr "${CONFIG_ABS_PATH}" "${ROOT_PATH}/modules/tfstate"

  # copy variable files for tagging module
  cp "${CONFIG_ABS_PATH}" "${ASG_EC2_TAG_PATH}"
  cp "${ROOT_PATH}/variables.tf" "${ASG_EC2_TAG_PATH}"
  cp "${TFSTATE_LOCALS}" "${ASG_EC2_TAG_PATH}"
}


set_variables
cleanup_existing_files
inject_variables_to_templates
copy_injected_files
