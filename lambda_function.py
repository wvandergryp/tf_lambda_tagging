import json
import boto3

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    print(event)

    # User name  
    user = event['detail']['userIdentity']['userName']

    # Mapping of event names to functions
    event_to_function = {
        'RunInstances': (tag_ec2_instance, 'responseElements.instancesSet.items[0].instanceId'),
        'CreateVolume': (tag_ebs_volume, 'responseElements.volumeId'),
        'CreateSecurityGroup': (tag_security_group, 'responseElements.groupId'),
        'RegisterImage': (tag_ami, 'responseElements.imageId'),
        'AllocateAddress': (tag_eip, 'responseElements.allocationId'),
        'CreateVpc': (tag_vpc, 'responseElements.vpc.vpcId'),
        'CreateSubnet': (tag_subnet, 'responseElements.subnet.subnetId'),
        'CreateInternetGateway': (tag_internet_gateway, 'responseElements.internetGateway.internetGatewayId'),
        'CreateLoadBalancer': (tag_elb, 'responseElements.loadBalancerName'),
        'CreateAutoScalingGroup': (tag_asg, 'requestParameters.autoScalingGroupName'),
        'CreateDBInstance': (tag_rds_instance, 'responseElements.dBInstanceIdentifier'),
        'CreateTable': (tag_dynamodb_table, 'requestParameters.tableName'),
        'CreateBucket': (tag_s3_bucket, 'requestParameters.bucketName'),
        'CreateCluster': (tag_eks_cluster, 'responseElements.cluster.name'),
    }

    # Get the function and path for the event
    function, path = event_to_function.get(event['detail']['eventName'], (None, None))

    # Call the function if it exists
    if function:
        resource_id = get_resource_id(event, path)
        function(resource_id, user)

# Define your tagging functions here
import boto3

def tag_ec2_instance(resource_id, user):
    ec2 = boto3.resource('ec2')
    ec2.Instance(resource_id).create_tags(Tags=[{'Key': 'CreatedBy', 'Value': user}])

def tag_ebs_volume(resource_id, user):
    ec2 = boto3.resource('ec2')
    ec2.Volume(resource_id).create_tags(Tags=[{'Key': 'CreatedBy', 'Value': user}])

def tag_security_group(resource_id, user):
    ec2 = boto3.resource('ec2')
    ec2.SecurityGroup(resource_id).create_tags(Tags=[{'Key': 'CreatedBy', 'Value': user}])

def tag_ami(resource_id, user):
    ec2 = boto3.resource('ec2')
    ec2.Image(resource_id).create_tags(Tags=[{'Key': 'CreatedBy', 'Value': user}])

def tag_eip(resource_id, user):
    ec2 = boto3.client('ec2')
    ec2.create_tags(Resources=[resource_id], Tags=[{'Key': 'CreatedBy', 'Value': user}])

def tag_vpc(resource_id, user):
    ec2 = boto3.resource('ec2')
    ec2.Vpc(resource_id).create_tags(Tags=[{'Key': 'CreatedBy', 'Value': user}])

def tag_subnet(resource_id, user):
    ec2 = boto3.resource('ec2')
    ec2.Subnet(resource_id).create_tags(Tags=[{'Key': 'CreatedBy', 'Value': user}])

def tag_internet_gateway(resource_id, user):
    ec2 = boto3.resource('ec2')
    ec2.InternetGateway(resource_id).create_tags(Tags=[{'Key': 'CreatedBy', 'Value': user}])

def tag_elb(resource_id, user):
    elb = boto3.client('elbv2')
    elb.add_tags(ResourceArns=[resource_id], Tags=[{'Key': 'CreatedBy', 'Value': user}])

def tag_asg(resource_id, user):
    asg = boto3.client('autoscaling')
    asg.create_or_update_tags(Tags=[{'ResourceId': resource_id, 'Key': 'CreatedBy', 'Value': user, 'PropagateAtLaunch': True}])

def tag_rds_instance(resource_id, user):
    rds = boto3.client('rds')
    rds.add_tags_to_resource(ResourceName=resource_id, Tags=[{'Key': 'CreatedBy', 'Value': user}])

def tag_dynamodb_table(resource_id, user):
    dynamodb = boto3.client('dynamodb')
    dynamodb.tag_resource(ResourceArn=resource_id, Tags=[{'Key': 'CreatedBy', 'Value': user}])

def tag_s3_bucket(resource_id, user):
    s3 = boto3.client('s3')
    s3.put_bucket_tagging(Bucket=resource_id, Tagging={'TagSet': [{'Key': 'CreatedBy', 'Value': user}]})


def tag_eks_cluster(resource_id, user):
    eks = boto3.client('eks')
    eks.tag_resource(resourceArn=resource_id, tags={'CreatedBy': user})   
# Function to get the resource ID from the event detail
def get_resource_id(event, path):
    parts = path.split('.')
    detail = event['detail']
    for part in parts:
        if '[' in part:
            part, index = part.split('[')
            index = int(index[:-1])
            detail = detail[part][index]
        else:
            detail = detail[part]
    return detail