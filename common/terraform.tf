terraform {
  backend "s3" {
    bucket         = "tf-state-management-statebucket-djbi0ffgviw5"
    dynamodb_table = "TerraformLockTable"
    key            = "172173733067/ap-southeast-2/production/terraform.tfstate"
    region         = "ap-southeast-2"
  }
}