#!/usr/bin/env bash
# Prints message to stdout
# params: $1 - message, $2 - log level
log(){
  if [ "$#" -eq 0 ]; then
    echo "Usage: log <message>"
    return 1
  elif [ "$#" -eq 2 ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") [$2] $1"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"
  fi
}

# Fetch the value of the requested variable defined in Terraform config file
# params: $1 - variable name, $2 - config file full path
get_variable(){
  if [ "$#" -eq 2 ]; then
    local variable_name=${1}
    local config_file=${2}
    if [ ! -f "${config_file}" ]; then
      log "File ${config_file} does not exist." "ERROR"
      return 1
    fi
    local VALUE=$(grep -o '^[^#]*' "${config_file}" | grep "${variable_name}" | sed 's/ //g' | grep "${variable_name}=\"" | sed -nE 's/^.*"(.*)".*$/\1/p')
    if [ ! $(echo "${VALUE}" | wc -l) -eq 1 ];then
      log "ERROR - '${variable_name}' is re-defined in '${config_file}'" "ERROR";
      return 1;
    fi
    echo "${VALUE}"
    return 0
  fi
  echo "Usage: get_variable <variable name> <config file>"
  return 1
}

# Fetch the expected product from the list of products defined in 'products' variable in given Terraform config file
# returns null if the product is not found
# params: $1 - expected product , $2 - config file full path
get_product(){
  if [ "$#" -eq 2 ]; then
    local expected_product=${1}
    local config_file=${2}
    if [ ! -f "${config_file}" ]; then
      log "File ${config_file} does not exist." "ERROR"
      return 1
    fi
    local VALUE=$(grep -o '^[^#]*' "${config_file}" | grep "products" | sed 's/ //g' | grep "products=")
    if [ ! $(echo "${VALUE}" | wc -l) -eq 1 ];then
      log "ERROR - 'products' is re-defined in '${config_file}'" "ERROR";
      return 1;
    fi
    products="${VALUE#*=}"
    if [[ "${products}" == *"${expected_product}"* ]]; then
      echo $expected_product
    fi
    return 0
  fi
  echo "Usage: get_products <expected product> <config file>"
  return 1
}

# Delete the load balancer listener on port 7999
# for the supplied load balancer name and region
# params: $1 - load balancer name , $2 - region
delete_lb_listener() {
  if [ "$#" -eq 2 ]; then
    local load_balancer_name="${1}"
    local region="${2}"
    aws elb delete-load-balancer-listeners --load-balancer-name "${load_balancer_name}" --load-balancer-ports 7999 --region "${region}"
  else
    echo "Usage: delete_lb_listener function expects 2 params <load_balancer_name> <region>"
  fi
}

# Create the load balancer listener on port 7999
# for the supplied load balancer name, instance port and region
# params: $1 - load balancer name , $2 - instance port, $3 - region
create_lb_listener() {
  if [ "$#" -eq 3 ]; then
    local load_balancer_name="${1}"
    local instance_port="${2}"
    local region="${3}"
    aws elb create-load-balancer-listeners --load-balancer-name "${load_balancer_name}" --listeners "Protocol=TCP,LoadBalancerPort=7999,InstanceProtocol=TCP,InstancePort=${instance_port}" --region "${region}"
  else
    echo "Usage: create_lb_listener function expects 3 params <load_balancer_name> <instance_port> <region>"
  fi
}

# Describe the load balancer listener on port 7999
# for the supplied load balancer name and region
# params: $1 - load balancer name , $2 - region
describe_lb_listener() {
  if [ "$#" -eq 2 ]; then
    local load_balancer_name="${1}"
    local region="${2}"
    aws elb describe-load-balancers --load-balancer-name "${load_balancer_name}" --query 'LoadBalancerDescriptions[*].ListenerDescriptions' --region "${region}" | grep 7999 -B 2 -A 3
  else
    echo "Usage: describe_lb_listener function expects 2 params <load_balancer_name> <region>"
  fi
}
