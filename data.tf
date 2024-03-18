# Fetch the details of the current region
data "aws_region" "current" {}

# Fetch the details of the current AWS account and user
data "aws_caller_identity" "current" {}