provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "${terraform.workspace}"
      # Timestamp   = timestamp()
      Project     = "rankbang"
    }
  }
}
data "aws_eks_cluster" "cluster" {
  name = module.eks["rankbang"].eks_output.EKS_CLUSTER_ID
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name ]
      command     = "aws"
    }
} 

