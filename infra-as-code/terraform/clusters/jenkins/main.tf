terraform {
  backend "s3" {
    bucket = "new-jenkins-state"
    key = "terraform"
    region = "ap-south-1"
  }
}
module "network" {
  source             = "../../modules/kubernetes/aws/network"
  vpc_cidr_block     = "${var.vpc_cidr_block}"
  cluster_name       = "${var.cluster_name}"
  availability_zones = "${var.network_availability_zones}"
}

data "aws_eks_cluster" "cluster" {
  name = "${module.eks.cluster_id}"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "${module.eks.cluster_id}"
}
provider "kubernetes" {
  host                   = "${data.aws_eks_cluster.cluster.endpoint}"
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)}"
  token                  = "${data.aws_eks_cluster_auth.cluster.token}"
  load_config_file       = false
  version                = "~> 1.11"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  vpc_id = "${module.network.vpc_id}"
  cluster_name    = "${var.cluster_name}"
  cluster_version = "${var.kubernetes_version}"
  subnet_ids         = "${concat(module.network.private_subnets, module.network.public_subnets)}"

  tags = "${
    tomap({
      "kubernetes.io/cluster/${var.cluster_name}" = "owned",
      "KubernetesCluster" = "${var.cluster_name}"
    })
  }"

  eks_managed_node_groups = {
    "${var.cluster_name}" = {
      min_size     = 1
      max_size     = "${var.number_of_worker_nodes}"
      desired_size = "${var.number_of_worker_nodes}"
      node_group_name = "${var.cluster_name}"
      instance_types = "${var.override_instance_types}"
      capacity_type  = "SPOT"
      subnet_ids = "${slice(module.network.private_subnets, 0, length(var.availability_zones))}"
      labels = {
        Environment = "${var.cluster_name}"
      }
      tags = {
        ExtraTag = "${var.cluster_name}"
      }
    }
  }
}

module "jenkins" {
  source = "../../modules/storage/aws"
  storage_count = 1
  environment = "${var.cluster_name}"
  disk_prefix = "jenkins-home"
  availability_zones = "${var.availability_zones}"
  storage_sku = "gp2"
  disk_size_gb = "30"
  
}