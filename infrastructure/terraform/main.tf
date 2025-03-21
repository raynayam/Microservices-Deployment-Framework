provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_name        = "${var.project_name}-vpc"
  vpc_cidr        = var.vpc_cidr
  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs
  
  tags = var.tags
}

module "eks" {
  source = "./modules/eks"
  
  cluster_name    = "${var.project_name}-cluster"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  
  node_groups = {
    default = {
      desired_capacity = var.eks_node_desired_capacity
      max_capacity     = var.eks_node_max_capacity
      min_capacity     = var.eks_node_min_capacity
      instance_types   = var.eks_node_instance_types
    }
  }
  
  tags = var.tags
}

module "kubernetes_addons" {
  source = "./modules/kubernetes-addons"
  
  cluster_name = module.eks.cluster_name
  
  # Optional: configure add-ons
  enable_metrics_server    = true
  enable_cluster_autoscaler = true
  
  tags = var.tags
  
  depends_on = [module.eks]
} 