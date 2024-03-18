# The AWS region where resources will be created
variable "region" {
  description = "The region where resources will be created"
}

# The AWS CLI profile to use
variable "profile" {
  description = "The AWS CLI profile to use"
}

# The name of the S3 bucket
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

# The name of the aws_cloudwatch_log_group
variable "aws_cloudwatch_log_group_name" {
  description = "The name of the aws_cloudwatch_log_group name"
  type        = string
  default = "loggrouptagw"
}

# Role to be used to create loggroups and logstreams
variable "aws_iam_role_loggroup" {
  description = "Role to be used to create loggroups and logstreams"
  type        = string
  default = "tag-role-on-create"
}

# Policy to be used to create loggroups and logstreams
variable "loggroup_policy_name" {
  description = "Policy to be used to create loggroups and logstreams"
  type        = string
  default = "loggroup_policy_tagging"
}

# New cloud trail name
variable "aws_cloudtrail_name" {
  description = "New cloud trail name"
  type        = string
  default = "tagtrailw"
}

# aws_cloudwatch_event_rule
variable "aws_cloudwatch_event_rule_name" {
  description = "aws_cloudwatch_event_rule"
  type        = string
  default = "ec2-vpc-creationw"
}

# output_path
variable "output_path_name" {
  description = "output_path"
  type        = string
  default = "lambda_function.zip"
}

# source_file
variable "source_file_name" {
  description = "source_file"
  type        = string
  default = "lambda_function.py"
}

# The name of the Lambda function
variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default = "example_lambda_name"
}

# runtime of the Lambda function
variable "runtime_name" {
  description = "runtime of the Lambda function"
  type        = string
  default = "python3.8"
}

# aws_iam_role
variable "aws_iam_role_name" {
  description = "aws_iam_role"
  type        = string
  default = "iam_for_lambda"
}

# aws_iam_role_policy
variable "aws_iam_role_policy_name" {
  description = "aws_iam_role_policy"
  type        = string
  default = "lambda_policy"
}

# A map of tags to add to all resources
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Dev = "dev"
    // Add more tags here
  }
}

# Flag to enable multi-region trail
variable "is_multi_region_trail" {
  type        = bool
  description = "Flag to enable multi-region trail"
  default     = false
}

# Flag to enable force_destroy in a bucket even if got something in it
variable "force_destroy" {
  type        = bool
  description = "Flag to enable force_destroy in a bucket even if got something in it"
  default     = true
}

# include_global_service_events
variable "include_global_service_events" {
  type        = bool
  description = "include_global_service_events"
  default     = true
}

# enable_log_file_validation
variable "enable_log_file_validation" {
  type        = bool
  description = "enable_log_file_validation"
  default     = true
}

variable "event_names" {
  description = "List of event names to capture"
  type        = list(string)
  default     = ["RunInstances", "CreateVpc", "CreateSubnet"]
}