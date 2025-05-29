provider "aws" {
  region = var.region
}

# Call the VPC module
module "network" {
  source = "./modules/vpc"

  vpc_cidr           = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
  environment         = var.environment
}

# Call IAM module
module "iam" {
  source = "./modules/iam"
}

# Call EKS module
module "eks" {
  source               = "./modules/eks"
  cluster_name         = "demo-eks-cluster"
  subnet_ids           = module.network.subnet_ids
  eks_cluster_role_arn = module.iam.eks_cluster_role_arn
  node_group_role_arn  = module.iam.node_group_role_arn
}