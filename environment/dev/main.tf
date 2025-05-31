provider "aws" {
  region = var.region
}

# Call the VPC module
module "network" {
  source = "../../modules/vpc"

  vpc_cidr         = var.vpc_cidr
  subnet_1_cidr    = var.subnet_1_cidr
  subnet_2_cidr    = var.subnet_2_cidr
  az_1             = var.availability_zone1
  az_2             = var.availability_zone2
}

# Call IAM module
module "iam" {
  source = "../../modules/iam"
}

# Call EKS module
module "eks" {
  source               = "../../modules/eks"
  cluster_name         = "demo-eks-cluster"
  subnet_ids           = module.network.subnet_ids
  eks_cluster_role_arn = module.iam.eks_cluster_role_arn
  node_group_role_arn  = module.iam.node_group_role_arn
}