import logging
import sys
from argparse import ArgumentParser
import time
from time import sleep
import boto3
from boto3.exceptions import Boto3Error
from botocore.exceptions import ClientError


def wait_for_node_group_delete(eks_client, cluster_name, node_group):
    timeout = 900  # 15 min
    attempt = 0
    sleep_time = 10
    attempts = timeout // sleep_time

    while attempt < attempts:
        try:
            status_info = eks_client.describe_nodegroup(clusterName=cluster_name, nodegroupName=node_group)['nodegroup']
        except eks_client.exceptions.ResourceNotFoundException:
            logging.info(f"Node group {node_group} for cluster {cluster_name} was successfully deleted.")
            break
        if status_info['status'] == "DELETING":
            logging.info(f"Node group {node_group} for cluster {cluster_name} status is {status_info['status']}. "
                         f"Attempt {attempt}/{attempts}. Sleeping {sleep_time} seconds.")

            sleep(sleep_time)
            attempt += 1
        else:
            logging.error(f"Node group {node_group} for cluster {cluster_name} has "
                          f"unexpected status: {status_info['status']}.")
            logging.error(f"Health status: {status_info['health']}")
            return
    else:
        logging.error(f"Node group {node_group} for cluster {cluster_name} was not deleted in {timeout} seconds.")


def wait_for_cluster_delete(eks_client, cluster_name):
    timeout = 600  # 10 min
    attempt = 0
    sleep_time = 10
    attempts = timeout // sleep_time

    while attempt < attempts:
        try:
            status = eks_client.describe_cluster(name=cluster_name)['cluster']['status']
        except eks_client.exceptions.ResourceNotFoundException:
            logging.info(f"Cluster {cluster_name} was successfully deleted.")
            break
        logging.info(f"Cluster {cluster_name} status is {status}. "
                     f"Attempt {attempt}/{attempts}. Sleeping {sleep_time} seconds.")
        sleep(sleep_time)
        attempt += 1
    else:
        logging.error(f"Cluster {cluster_name} was not deleted in {timeout} seconds.")


def wait_for_rds_delete(rds_client, db_name):
    timeout = 600  # 10 min
    attempt = 0
    sleep_time = 10
    attempts = timeout // sleep_time

    while attempt < attempts:
        try:
            status = \
                rds_client.describe_db_instances(DBInstanceIdentifier=db_name)['DBInstances'][0]['DBInstanceStatus']
        except rds_client.exceptions.DBInstanceNotFoundFault:
            logging.info(f"RDS {db_name} was successfully deleted.")
            break
        logging.info(f"RDS {db_name} status is {status}. "
                     f"Attempt {attempt}/{attempts}. Sleeping {sleep_time} seconds.")
        sleep(sleep_time)
        attempt += 1
    else:
        logging.error(f"RDS {db_name} was not deleted in {timeout} seconds.")


def delete_nodegroup(aws_region, cluster_name):
    eks_client = boto3.client('eks', region_name=aws_region)
    autoscaling_client = boto3.client('autoscaling', region_name=aws_region)
    node_groups = eks_client.list_nodegroups(clusterName=cluster_name)['nodegroups']

    if node_groups:
        for node_group in node_groups:
            autoscaling_group_name = None
            try:
                autoscaling_group_name = eks_client.describe_nodegroup(
                    clusterName=cluster_name,
                    nodegroupName=node_group)['nodegroup']['resources']['autoScalingGroups'][0]['name']
                autoscaling_client.delete_auto_scaling_group(AutoScalingGroupName=autoscaling_group_name,
                                                             ForceDelete=True)
            except Boto3Error as e:
                logging.error(f"Deleting autoscaling group {autoscaling_group_name} failed with error: {e}")

            try:
                eks_client.delete_nodegroup(clusterName=cluster_name, nodegroupName=node_group)
                wait_for_node_group_delete(eks_client, cluster_name, node_group)
            except Boto3Error as e:
                logging.error(f"Deleting node group {node_group} failed with error: {e}")
    else:
        logging.info(f"Cluster {cluster_name} does not have nodegroups.")


def delete_cluster(aws_region, cluster_name):
    eks_client = boto3.client('eks', region_name=aws_region)
    eks_client.delete_cluster(name=cluster_name)
    wait_for_cluster_delete(eks_client, cluster_name)


def delete_lb(aws_region, vpc_id):
    lb_names = []
    elb_client = boto3.client('elb', region_name=aws_region)
    lb_names = [lb['LoadBalancerName']
                for lb in elb_client.describe_load_balancers()['LoadBalancerDescriptions']
                if lb['VPCId'] == vpc_id]
    if lb_names:
        for lb_name in lb_names:
            try:
                logging.info(f"Deleting load balancer: {lb_name} for vpc id: {vpc_id}")
                elb_client.delete_load_balancer(LoadBalancerName=lb_name)
            except Boto3Error as e:
                logging.error(f"Deleting load balancer {lb_name} failed with error: {e}")


def wait_for_nat_gateway_delete(ec2, nat_gateway_id):
    timeout = 600  # 10 min
    attempt = 0
    sleep_time = 10
    attempts = timeout // sleep_time

    while attempt < attempts:
        try:
            status = ec2.describe_nat_gateways(NatGatewayIds=[nat_gateway_id])['NatGateways'][0]['State']
        except ec2.exceptions.ResourceNotFoundException:
            logging.info(f"NAT gateway with id {nat_gateway_id} was not found.")
            break

        if status == 'deleted':
            logging.info(f"NAT gateway with id {nat_gateway_id} was successfully deleted.")
            break

        logging.info(f"NAT gateway with id {nat_gateway_id} status is {status}. "
                     f"Attempt {attempt}/{attempts}. Sleeping {sleep_time} seconds.")
        sleep(sleep_time)
        attempt += 1

    else:
        logging.error(f"NAT gateway with id {nat_gateway_id} was not deleted in {timeout} seconds.")


def delete_nat_gateway(aws_region, vpc_id):
    ec2_client = boto3.client('ec2', region_name=aws_region)
    filters = [{'Name': 'vpc-id', 'Values': [f'{vpc_id}', ]}, ]
    nat_gateway = ec2_client.describe_nat_gateways(Filters=filters)
    nat_gateway_ids = [nat['NatGatewayId'] for nat in nat_gateway['NatGateways']]
    if nat_gateway_ids:
        for nat_gateway_id in nat_gateway_ids:
            logging.info(f"Deleting NAT gateway with id: {nat_gateway_id}")
            try:
                ec2_client.delete_nat_gateway(NatGatewayId=nat_gateway_id)
                wait_for_nat_gateway_delete(ec2_client, nat_gateway_id)
            except Boto3Error as e:
                logging.error(f"Deleting NAT gateway with id {nat_gateway_id} failed with error: {e}")


def delete_igw(ec2_resource, vpc_id):
    vpc_resource = ec2_resource.Vpc(vpc_id)
    igws = vpc_resource.internet_gateways.all()
    if igws:
        for igw in igws:
            try:
                logging.info(f"Detaching and Removing igw id: {igw.id}")
                igw.detach_from_vpc(
                    VpcId=vpc_id
                )
                igw.delete()
            except Boto3Error as e:
                logging.error(f"Deleting igw failed with error: {e}")


def delete_subnets(ec2_resource, vpc_id):
    vpc_resource = ec2_resource.Vpc(vpc_id)
    subnets_all = vpc_resource.subnets.all()
    subnets = [ec2_resource.Subnet(subnet.id) for subnet in subnets_all]

    if subnets:
        for sub in subnets:
            # here we try to delete and except errors to try again after 30 seconds
            # sometimes subnets still have dependencies which are completely gone in ~1 min
            for attempt in range(0, 10):
                logging.info(f"Removing subnet with id: {sub.id}. Attempt {attempt}/10")
                try:
                    sub.delete()
                except ClientError as e:
                    logging.error(f"Failed to delete subnet, will try again. The error was: {e}. Sleeping 30 seconds")
                    sleep(30)
                    continue
                break


def delete_route_tables(ec2_resource, vpc_id):
    vpc_resource = ec2_resource.Vpc(vpc_id)
    rtbs = vpc_resource.route_tables.all()
    if rtbs:
        try:
            for rtb in rtbs:
                if rtb.associations_attribute and rtb.associations_attribute[0]['Main'] == True:
                    logging.info(f"{rtb.id} is the main route table, skipping...")
                    continue
                logging.info(f"Removing rtb-id: {rtb.id}")
                table = ec2_resource.RouteTable(rtb.id)
                table.delete()
        except Boto3Error as e:
            logging.error(f"Delete of route table failed with error: {e}")


def delete_security_groups(ec2_resource, vpc_id):
    vpc_resource = ec2_resource.Vpc(vpc_id)
    sgps = vpc_resource.security_groups.all()
    if sgps:
        try:
            for sg in sgps:
                if sg.group_name == 'default':
                    logging.info(f"{sg.id} is the default security group, skipping...")
                    continue
                if sg.ip_permissions:
                    logging.info(f"Removing ingress rules for security group with id: {sg.id}")
                    sg.revoke_ingress(IpPermissions=sg.ip_permissions)
                if sg.ip_permissions_egress:
                    logging.info(f"Removing egress rules for security group with id: {sg.id}")
                    sg.revoke_egress(IpPermissions=sg.ip_permissions_egress)
            for sg in sgps:
                if sg.group_name == 'default':
                    logging.info(f"{sg.id} is the default security group, skipping...")
                    continue
                logging.info(f"Removing security group with id: {sg.id}")
                sg.delete()
        except Boto3Error as e:
            logging.error(f"Delete of security group failed with error: {e}")


def delete_rds(aws_region, vpc_name):
    rds_client = boto3.client('rds', region_name=aws_region)
    rds_name_pattern = f'{vpc_name.replace("-vpc", "-")}'
    db_instances = rds_client.describe_db_instances()['DBInstances']
    db_names = [db_instance['DBInstanceIdentifier']
                for db_instance in db_instances
                if rds_name_pattern in db_instance['DBInstanceIdentifier']]
    for db in db_names:
        try:
            logging.info(f"Deleting RDS {db}.")
            rds_client.delete_db_instance(DBInstanceIdentifier=db, SkipFinalSnapshot=True, DeleteAutomatedBackups=True)
            wait_for_rds_delete(rds_client, db)
        except Boto3Error as e:
            logging.error(f"Delete RDS {db} failed with error: {e}")


def terminate_vpc(vpc_name, aws_region):
    ec2_resource = boto3.resource('ec2', region_name=aws_region)
    filters = [{'Name': 'tag:Name', 'Values': [vpc_name]}]
    vpc = list(ec2_resource.vpcs.filter(Filters=filters))
    # we assume that if vpc is gone, all resources attached to it are gone too
    if not vpc:
        logging.info(f"VPC {vpc_name} not found in {aws_region}. Assuming all related aws resources are deleted")
        return
    vpc_id = vpc[0].id

    logging.info(f"Checking RDS for VPC {vpc_name}.")
    delete_rds(aws_region, vpc_name)

    logging.info(f"Checking load balancers for VPC {vpc_name}.")
    delete_lb(aws_region, vpc_id)

    logging.info(f"Checking NAT gateway for VPC {vpc_name}.")
    delete_nat_gateway(aws_region, vpc_id)

    logging.info(f"Checking internet gateway for VPC {vpc_name}.")
    delete_igw(ec2_resource, vpc_id)

    logging.info(f"Checking subnets for VPC {vpc_name}.")
    delete_subnets(ec2_resource, vpc_id)
    logging.info(f"Checking route tables for VPC {vpc_name}.")
    delete_route_tables(ec2_resource, vpc_id)

    logging.info(f"Checking security groups for VPC {vpc_name}.")
    delete_security_groups(ec2_resource, vpc_id)

    logging.info(f"Deleting VPC {vpc_name}.")
    try:
        ec2_resource.Vpc(vpc_id).delete()
    except Boto3Error as e:
        logging.error(f"Deleting VPC {vpc_name} failed with error: {e}.")


def terminate_cluster(cluster_name, aws_region):
    delete_nodegroup(aws_region, cluster_name)
    delete_cluster(aws_region, cluster_name)


def get_clusters_to_terminate(service_name, aws_region):
    eks_client = boto3.client('eks', region_name=aws_region)
    clusters = eks_client.list_clusters()['clusters']
    for cluster in clusters:
        cluster_info = eks_client.describe_cluster(name=cluster)['cluster']
        service_name_tag = cluster_info['tags'].get('service_name')
        if service_name_tag == service_name:
            return cluster
    return


def release_unused_eips(aws_region):
    ec2_client = boto3.client('ec2', region_name=aws_region)
    addresses_dict = ec2_client.describe_addresses()
    for eip_dict in addresses_dict['Addresses']:
        if "NetworkInterfaceId" not in eip_dict:
            name = next((tag["Value"] for tag in eip_dict["Tags"] if tag["Key"] == "Name"), None)
            logging.info(f"Releasing EIP {eip_dict['PublicIp']} with name: {name}")
            ec2_client.release_address(AllocationId=eip_dict['AllocationId'])


def terminate_open_id_providers(service_name):
    iam_client = boto3.client('iam')
    providers = iam_client.list_open_id_connect_providers()['OpenIDConnectProviderList']
    for provider in providers:
        arn = provider['Arn']
        tags = iam_client.list_open_id_connect_provider_tags(OpenIDConnectProviderArn=provider['Arn'])['Tags']
        service_name_tag_val = next((tag["Value"] for tag in tags if tag["Key"] == "service_name"), None)
        if not service_name_tag_val:
            logging.info(f'No service_name tag found in {arn}. Skipping')
        else:
            if service_name_tag_val == service_name:
                logging.info(f"Deleting Open ID provider {arn} with tag service_name={service_name}.")
                iam_client.delete_open_id_connect_provider(OpenIDConnectProviderArn=provider['Arn'])


def delete_volumes(service_name, aws_region):
    ec2_client = boto3.resource('ec2', region_name=aws_region)
    volumes = ec2_client.volumes.filter(Filters=[{'Name': 'status', 'Values': ['available']}])
    for vol in volumes:
        for tag in vol.tags:
            if service_name in tag["Key"]:
                logging.info(f"Volume {vol} with tag {tag} is unused. Deleting it")
                vol.delete()
            else:
                if tag["Key"] == 'service_name':
                    service_name_tag = tag["Value"]
                    if service_name in service_name_tag:
                        logging.info(f"Volume {vol} with tag {service_name_tag} is unused. Deleting it")
                        vol.delete()


def delete_certificates(service_name, aws_region):
    logging.info('Deleting unused certificates')
    client = boto3.client('acm', region_name=aws_region)
    response = client.list_certificates(CertificateStatuses=['ISSUED'])
    for crt in response['CertificateSummaryList']:
        if not (crt['InUse']) and (service_name in crt['DomainName']):
            logging.info('Deleting unused certificate ' + crt['CertificateArn'])
            client.delete_certificate(CertificateArn=crt['CertificateArn'])


def delete_hosted_zones(service_name):
    logging.info('Deleting unused hosted zones')
    client = boto3.client('route53')
    response = client.list_hosted_zones()
    for hz in response['HostedZones']:
        if service_name in hz['Name']:
            hosted_zone_records = client.list_resource_record_sets(HostedZoneId=hz['Id'])
            for hzr in hosted_zone_records['ResourceRecordSets']:
                if (hzr['Type'] == 'CNAME') or (hzr['Type'] == 'A'):
                    logging.info('Deleting record: ' + hzr['Name'])
                    client.change_resource_record_sets(HostedZoneId=hz['Id'], ChangeBatch={"Changes": [
                        {"Action": "DELETE", "ResourceRecordSet": hzr}]})
            logging.info('Deleting hosted zone: ' + hz['Name'])
            client.delete_hosted_zone(Id=hz['Id'])


def main():
    parser = ArgumentParser()
    parser.add_argument("--service_name")
    parser.add_argument("--region")
    args = parser.parse_args()
    if not (args.service_name or args.region):
        sys.exit('One or more mandatory arguments not provided')
    else:
        service_name = args.service_name
        aws_region = args.region

    # delete_iam_roles(service_name)
    logging.info(f"Searching for resources to remove in {aws_region}.")
    cluster = get_clusters_to_terminate(service_name, aws_region)
    if cluster:
        logging.info(f"Terminating {cluster}")
        terminate_cluster(cluster_name=cluster, aws_region=aws_region)
    else:
        logging.info(f"No eks clusters found in {aws_region} with tag service_name={service_name}")
        # we need cluster name to get the vpc name
        cluster = "atlas-" + args.service_name + "-cluster"

    logging.info(f"Delete all resources and VPC for environment with tag service_name={service_name}.")
    vpc_name = f'{cluster.replace("-cluster", "-vpc")}'
    terminate_vpc(vpc_name, aws_region)
    logging.info("Release unused EIPs")
    release_unused_eips(aws_region)
    logging.info("Terminate open ID providers")
    terminate_open_id_providers(service_name)
    logging.info("Delete unused EBS volumes")
    delete_volumes(service_name, aws_region)
    delete_certificates(service_name, aws_region)
    delete_hosted_zones(service_name)


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    main()
