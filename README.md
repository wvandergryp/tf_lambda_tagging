# tf_lambda_tagging
# Introduction:
Ensuring consistent tagging across AWS resources is paramount for effective resource management and cost optimization. Inspired by the insights shared in the AWS blog posts "Tag Your AWS Resources Consistently with AWS Resource Explorer and AWS CloudTrail" and "Using Python to Automate AWS Services | Lambda and EC2," I present a solution leveraging Terraform and AWS CloudTrail for automated resource tagging. While the original blog discusses DynamoDB, my approach utilizes Terraform and GitHub (or anything similar) for infrastructure provisioning, enabling seamless integration with AWS CloudTrail to enforce tagging policies dynamically. This will allow you to make changes as part of a change management system like GitHub and then utilize a CI/CD pipeline to deploy. This only cover "CreateBy" tag mapped to a username for now but can be extended easily to add extra tags.

# Motivation:
Driven by the need for standardized resource tagging and inspired by AWS's best practices, I've developed a solution to streamline resource tagging using Terraform, CloudTrail, Lambda (Python) and Amazon EventBridge. Organizations can achieve greater visibility, cost management, and compliance within their AWS environments by adopting automation. Building upon the foundation in the referenced AWS blog, I present an alternative approach employing Terraform for infrastructure as code (IaC) and CloudTrail for event-driven tagging.
Solution Overview:
The automated resource tagging solution, deployed via Terraform, streamlines the application of your organization's required tags to newly created resources. This solution seamlessly integrates four key services: Terraform, Git repository, Lambda, and AWS CloudTrail. At its core, it establishes an Amazon CloudTrail rule, utilized by Amazon EventBridge, triggering a Lambda function responsible for orchestrating the tagging process.

# Here's how it works:

Terraform Deployment: Terraform is employed to provision the infrastructure necessary for the tagging solution. This includes defining the Lambda function, CloudTrail rule, and associated permissions.

Git Repository Integration: The solution architecture incorporates a Git repository to manage changes and updates to the tagging logic. Any modifications, such as adding additional resources to be tagged, are made within the repository.

Lambda Function Execution: When a new resource is created within the AWS environment, the CloudTrail rule captures the event and triggers the Lambda function. This Lambda function is responsible for executing the tagging process based on predefined rules.

Dynamic Tagging Process: The Lambda function applies tags to the newly created resource, ensuring consistency and adherence to tagging policies. Currently, the solution tags resources with owner and username information, providing essential context for resource ownership and management.

Scalability and Flexibility: As your organization's tagging requirements evolve or expand to cover more resources, adjustments can be made within the Git repository. Upon applying these changes and reapplying Terraform, the tagging solution is automatically updated to reflect the modifications.

By leveraging Terraform for infrastructure management, Git repository for version control and collaboration, Lambda for event-driven execution, and AWS CloudTrail for event capturing, this solution offers a robust framework for automating resource tagging within your AWS environment. With the ability to easily scale and adapt to changing requirements, it ensures consistent and compliant tagging practices across your organization's AWS resources.

# Requirements:
You have the following prerequisites:

AWS Account: Sign up for an AWS account if you haven't already, of course if you just want to explore first. Otherwise, you need to plan accordingly got your organization. Start small and then build out if satisfied with the results.

Budget Setup: Set up a budget in your AWS Billing Dashboard to monitor your spending. Configure alerts for expenditures exceeding $5 to ensure cost control and avoid unexpected charges for Proof of Concept.

Terraform Installed: Terraform serves as our infrastructure as code tool for automating the deployment of AWS resources. Install Terraform on your local machine by following the official documentation for your operating system.

Git Installed: Git facilitates version control and collaboration. Ensure Git is installed on your system to clone the necessary Terraform configuration files from my repo.

Install and Configuring AWS CLI:Install the AWS Command Line Interface (CLI) on your local machine following the official AWS CLI documentation tailored to your operating system. Once installed, configure the AWS CLI with your AWS credentials using the following command:

aws configure
Deploying the Solution:
Clone the GitHub repository containing the Terraform configuration files required for deploying Automatic tagging on AWS. This repository simplifies the migration process by providing pre-configured Terraform scripts.

Ensure you have Git installed on your system, then clone the repository using the following command:

git clone https://github.com/wvandergryp/wordpress-aws-free-one-vm.git

cd wordpress-aws-free-one-vm
The code can be accessed from the web here - Automatic tagging.

Running Terraform:
Once you've cloned the repository, navigate to the directory containing the Terraform files and run the Terraform commands to deploy the Automatic tagging infrastructure on AWS. 

Edit the file terraform.tfvars.template with your favorite editor. At a minimum change at least these parameters.

# The AWS region where resources will be created
region = "<region>"

# The AWS CLI profile to use
profile = "<AWS profile id - can be default if only use on AWS access key>"

# The name of the S3 bucket
bucket_name = "<unique bucket name>"
Navigate to the directory containing the Terraform files and initialize Terraform:

terraform init
terraform plan -var-file=terraform.tfvars.template
terraform apply -var-file=terraform.tfvars.template
This process will deploy the Automatic tagging infrastructure on AWS, including a CloudTrail rule, CloudWatch loggroup, EventBridge trigger and a Lambda function.

From now on when a new EC2, VPC or subnet get created it will tag with the username that created the resource. "CreatedBy" = "username".

Minimize image
Edit image
Delete image


Extending the Solution for other AWS Services:
The current code in your Git repository enables tagging for the following services. You can extend this functionality by adjusting the code according to your requirements:

Maximize image
Edit image
Delete image


By tracing these events and incorporating the necessary changes in your codebase, you can extend the tagging capabilities to cover additional AWS services as needed.

Make the changes in the terraform.tfvars.template file here:

# What events do you want to trace and then create tags for thatevent_names = ["RunInstances", "CreateVpc", "CreateSubnet"]
Summary: 
In this blog, I introduced an automated resource tagging solution utilizing Terraform, AWS Lambda, and AWS CloudTrail to enforce consistent tagging practices across AWS resources. Inspired by industry best practices and the need for standardized resource management, ,my solution provides a scalable framework for tagging EC2 instances, VPCs, and subnets dynamically.

Key components of our solution include Terraform for infrastructure provisioning, a Lambda function triggered by CloudTrail events, and IAM policies for secure resource access. By integrating with AWS CloudTrail, our solution captures relevant API events and applies predefined tags based on user activity, ensuring clarity and accountability in resource ownership.

Furthermore, we emphasized the flexibility of our solution, allowing organizations to easily adjust tagging logic and scale tagging efforts as needed. Through Git repository integration, changes to tagging rules can be managed efficiently, providing a seamless workflow for maintaining tagging policies.

In conclusion, our solution offers a robust and adaptable approach to automated resource tagging in AWS environments, empowering organizations to enhance visibility, compliance, and cost management across their infrastructure. By embracing automation and leveraging cloud-native services, organizations can streamline resource management processes and drive operational efficiency in the cloud.

Disclaimer and Caution:

Before proceeding with the deployment of resources on AWS, it's crucial to acknowledge and understand potential risks and costs associated with cloud services.

Cost Considerations: Utilizing cloud services, even within the free tier, may result in charges if certain limits are exceeded or additional resources are utilized. Always be mindful of the resources you provision and regularly monitor your usage to avoid unexpected costs. As the author of this guide, I cannot be held responsible for any unforeseen expenses incurred during the usage of AWS services.

Cleanup and Resource Management: After completing the setup, it's crucial to perform cleanup actions to avoid ongoing charges. You can terminate the EC2 instance and associated resources by running appropriate commands with Terraform. Ensure that you follow AWS best practices for resource cleanup to prevent unnecessary charges.

terraform destroy -var-file=terraform.tfvars.template
Budget Monitoring: To further mitigate the risk of unexpected costs, consider setting up a budget alert within the AWS Billing Dashboard. This feature allows you to define a budget threshold and receive email notifications if your expenditure approaches or exceeds the specified limit. Setting a budget alert provides an additional layer of financial oversight and helps prevent inadvertent overspending.

By exercising diligence, regularly monitoring resource usage, and implementing appropriate budget controls, you can enjoy the benefits of AWS services while minimizing financial risks. Remember, responsible cloud usage is key to maximizing the value of cloud computing resources.

The ec2.create_tags() function can be used to tag a variety of AWS resources that are managed through the EC2 service. Here are some of the resources that can be tagged:

Eveny Name:                 Event Type
RunInstances                EC2 instances
CreateVolume                EBS volumes
CreateSecurityGroup         Security groups
AllocateAddress             Elastic IP addresses
CreateVpc                   VPCs
CreateSubnet                Subnets
CreateInternetGateway       Internet gateways
CreateCluster               Amazon EKS clusters
