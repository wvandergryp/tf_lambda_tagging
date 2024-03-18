# Create an S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name  # Set the bucket name
  acl    = "private"  # Set the bucket to be private

  # If true, allows the bucket to be deleted even if it contains objects
  force_destroy = var.force_destroy

  # Add tags to the bucket
  tags = {
    Name        = var.bucket_name
    Environment = var.tags["Dev"]
  }  
}

# Create a CloudWatch Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  name = var.aws_cloudwatch_log_group_name
}

# Define a policy document that allows assuming a role
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

# Create an IAM role that can be assumed by CloudTrail
resource "aws_iam_role" "role" {
  name               = var.aws_iam_role_loggroup
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# Attach a policy to the IAM role that allows creating and managing log groups and log streams
resource "aws_iam_role_policy" "policy" {
  name = var.loggroup_policy_name
  role = aws_iam_role.role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogGroups"]
        Resource  = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.log_group.name}:*"]
      }
    ]
  })
}

# Create a CloudTrail trail that logs events to the CloudWatch Log Group
resource "aws_cloudtrail" "tagtrail" {
  depends_on = [aws_cloudwatch_log_group.log_group, aws_s3_bucket_policy.bucket_policy]

  name                          = var.aws_cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.bucket.bucket
  cloud_watch_logs_group_arn    = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.log_group.name}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.role.arn
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  enable_log_file_validation    = var.enable_log_file_validation
}

# Define a policy document that allows CloudTrail to get the bucket's ACL and put objects in the bucket
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.bucket.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

# Attach the policy to the S3 bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

# Create a CloudWatch Event Rule to capture EC2, VPC, and Subnet creation events
resource "aws_cloudwatch_event_rule" "ec2_vpc_creation" {
  name        = var.aws_cloudwatch_event_rule_name
  description = "Capture EC2, VPC, and Subnet creation events"

  # Define the event pattern for the rule
  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "ec2.amazonaws.com"
    ],
    "eventName": ${jsonencode(var.event_names)}
  }
}
PATTERN
}

# Create a CloudWatch Event Target to send the captured events to a Lambda function
resource "aws_cloudwatch_event_target" "capture_ec2_vpc_creation" {
  rule      = aws_cloudwatch_event_rule.ec2_vpc_creation.name  # The name of the rule
  target_id = "SendToLambdaFunction"  # The ID of the target
  arn       = aws_lambda_function.example.arn  # The ARN of the Lambda function
}

# Grant permission to CloudWatch Events to invoke the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_vpc_creation.arn
}

# Create a ZIP archive of the Lambda function code
data "archive_file" "example_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# Create a Lambda function
resource "aws_lambda_function" "example" {
  filename      = data.archive_file.example_zip.output_path  # The path to the ZIP archive
  function_name = var.lambda_function_name  # The name of the Lambda function
  role          = aws_iam_role.iam_for_lambda.arn  # The ARN of the IAM role
  handler       = "lambda_function.lambda_handler"  # The handler function

  source_code_hash = data.archive_file.example_zip.output_base64sha256

  runtime = var.runtime_name  # The runtime of the Lambda function

  # Define environment variables for the Lambda function
  environment {
    variables = {
      environment = var.tags["Dev"]
    }
  }
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  # Define the assume role policy for the role
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach a policy to the IAM role that allows creating tags
resource "aws_iam_role_policy" "lambda_policy" {
  name = var.aws_iam_role_policy_name
  role = aws_iam_role.iam_for_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = ["ec2:CreateTags"]
        Resource  = ["*"]
      }
    ]
  })
}