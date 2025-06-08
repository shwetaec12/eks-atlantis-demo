######################
# VPC Module
######################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.16.0"

  name                 = "eks-vpc-test"
  cidr                 = var.vpc_cidr
  azs                  = ["eu-central-1a", "eu-central-1b"]
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "production"
  }
}

######################
# IAM Roles for EKS Admin & Node Group
######################

# EKS Admin Role with OIDC trust
resource "aws_iam_openid_connect_provider" "oidc" {
  url = "https://oidc.eks.eu-central-1.amazonaws.com/id/3BFFE8CF83A9EF9B9503868907B06C39"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0cbed5e11"]
}

data "aws_iam_policy_document" "eks_admin_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc.arn] # changed here
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}


resource "aws_iam_role" "eks_admin" {
  name               = "eks-admin"
  assume_role_policy = data.aws_iam_policy_document.eks_admin_assume.json
}

resource "aws_iam_role_policy_attachment" "eks_admin_attach" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Node Group IAM Role with trust policy for EC2
data "aws_iam_policy_document" "eks_node_group_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "node_group_role" {
  name               = "eks-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_group_assume.json
}

resource "aws_iam_role_policy_attachment" "node_group_worker_node" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_group_ecr_readonly" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_group_cni_policy" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

######################
# EKS Module
######################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0" # or latest compatible version

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  enable_irsa                = true
  manage_aws_auth_configmap  = true

  # Public endpoint enabled, restricted to your IP(s)
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs  = ["63.214.132.66/32"]

  eks_managed_node_groups = {
    default = {
      desired_size   = var.desired_node_count
      min_size       = var.desired_node_count
      max_size       = var.desired_node_count + 2
      instance_types = [var.instance_type]
      iam_role_arn   = aws_iam_role.node_group_role.arn
    }
  }

  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.eks_admin.arn
      username = "eks-admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = aws_iam_role.node_group_role.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::895976263444:user/shwetec12"
      username = "shwetec12"
      groups   = ["system:masters"]
    }
  ]

  tags = {
    Environment = "production"
  }
}


######################
# Helm Release for Atlantis
######################
resource "helm_release" "atlantis-new" {
  name       = "atlantis-new"
  namespace  = "default"

  repository = "https://runatlantis.github.io/helm-charts"
  chart      = "atlantis"

  values = [
    file("${path.module}/atlantis-values.yaml")
  ]

  depends_on = [
    module.eks
  ]
}
