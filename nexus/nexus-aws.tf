# AWS resources we require in order to proceed with 
# service deployment into K8s cluster

resource "aws_iam_user" "nexus-oss" {
  name = "nexus-oss"
  path = "/ifm/k8s/"
}

resource "aws_iam_access_key" "nexus-oss" {
  user = aws_iam_user.nexus-oss.name
}

output "nexus-aws-access-key-id" {
  value = aws_iam_access_key.nexus-oss.id
}

output "nexus-aws-secret-key" {
  value = aws_iam_access_key.nexus-oss.secret
}

resource "aws_iam_user_policy" "nexus-oss-user-policy" {
  name   = "ifm-nexus-oss-user-s3-access"
  user   = aws_iam_user.nexus-oss.name
  policy = data.aws_iam_policy_document.nexus-blob-store-policy-document.json
}

data "aws_iam_policy_document" "nexus-blob-store-policy-document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetLifecycleConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutObjectTagging",
      "s3:GetObjectTagging",
      "s3:DeleteObjectTagging",
      "s3:GetBucketAcl",
      "s3:CreateBucket",
      "s3:DeleteBucket"
    ]
    resources = [
      # We want to put certain restriction to naming the buckets for Nexus
      "arn:aws:s3:::ifm-nexus-blob-*",
      "arn:aws:s3:::ifm-nexus-blob-*/*"
    ]
  }
}

data "aws_availability_zones" "z" {
  state = "available"
}

variable "vpc_id" {
  type = string
  description = "VPC id to use to provision NFS"
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_subnet" "nfs" {
  count = length(data.aws_availability_zones.z.names)
  availability_zone = data.aws_availability_zones.z.names[count.index]
  cidr_block = cidrsubnet(data.aws_vpc.this.cidr_block,8,16 + count.index)
  vpc_id = data.aws_vpc.this.id
  # Must be passed as variables
  tags = {
    "Owner" = "tyermolenko"
    "ProvisionedBy" = "manual"
    "Service" = "Nexus"
   }
}

resource "aws_efs_file_system" "nexus-fs" {
  creation_token = "nexus-efs"
  performance_mode = "generalPurpose"
  encrypted = true
  tags = {
    "Owner" = "tyermolenko@infomedia.com.au"
    "ProvisionedBy" = "terraform"
  }
}

locals {
  fs = aws_efs_file_system.nexus-fs.id
}

resource "aws_efs_mount_target" "nexus-mount-targets" {
  count = length(data.aws_availability_zones.z.names)
  file_system_id = aws_efs_file_system.nexus-fs.id
  subnet_id = aws_subnet.nfs[count.index].id
}

resource "aws_efs_access_point" "nexus-access-point" {
  file_system_id = aws_efs_file_system.nexus-fs.id
  root_directory {
    path = "/nexus-data"
    creation_info {
      owner_gid = "200"
      owner_uid = "200"
      permissions = "0755"
    }
  }
}

# In its current state, the kubernetes-alpha provider is, well, alpha
# I can't get PersistentVolume manifest to get into the state file 
# reliably, so commenting this out for now.
#module "k8s-nexus-oss" {
#  source = "../terraform/modules/k8s-nexus-oss"
#
#  application = "nexus"
#  environment = "development"
#  ver = "0.2"
#
#  nexus-fs = aws_efs_file_system.nexus-fs.id
#  nexus-ap = aws_efs_access_point.nexus-access-point.id
#
#  nexus-image-tag = "sonatype/nexus3:3.28.1"
#  nexus-targets = aws_efs_mount_target.nexus-mount-targets.*.id
#}

output "volume_handle" {
  description = "Volume handle construct for the PersistentVolume manifest."
  value = "volumeHandle: ${aws_efs_file_system.nexus-fs.id}::${aws_efs_access_point.nexus-access-point.id}"
}

output "target_points" {
  description = "Target points in AZs, for reference only."
  value = aws_efs_mount_target.nexus-mount-targets.*.mount_target_dns_name
}

