####### Control Plane Logging ####### 

resource "aws_cloudwatch_log_group" "cluster-logs" {
  name              = "${var.local_values.RESOURCE_PREFIX}-Cluster-Log-Group"
  retention_in_days = var.eks_values.LOGS_RETENTION_IN_DAYS

}
#######  EKS Cluster ####### 

resource "aws_eks_cluster" "eks" {
  name = "${var.local_values.RESOURCE_PREFIX}-Cluster"

  role_arn                  = aws_iam_role.cluster.arn
  enabled_cluster_log_types = var.eks_values.LOGGING_TYPE

  vpc_config {
    security_group_ids      = var.sg_id
    subnet_ids              = var.subnets_ids
    endpoint_private_access = var.eks_values.ENABLE_ENDPOINT_PRIVATE_ACCESS
    endpoint_public_access  = var.eks_values.ENABLE_ENDPOINT_PUBLIC_ACCESS

  }



}
data "aws_region" "current" {}
# Fetch OIDC provider thumbprint for root CA

data "external" "thumbprint" {
  program = ["${path.module}/oidc-thumbprint.sh", data.aws_region.current.name]
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = concat([data.external.thumbprint.result.thumbprint], [])
  url             = aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

#######  EKS Node Group ####### 

resource "aws_eks_node_group" "eks-node-group" {
  count           = length(var.eks_values.NODE_GROUPS)
  cluster_name    = "${var.local_values.RESOURCE_PREFIX}-Cluster"
  node_group_name = "${var.local_values.RESOURCE_PREFIX}-EKS-node-group-${count.index}"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = var.subnets_ids

  capacity_type   = var.eks_values.NODE_GROUPS[count.index].CAPACITY_TYPE


  scaling_config {
    desired_size = var.eks_values.NODE_GROUPS[count.index].DESIRED_CAPACITY
    max_size     = var.eks_values.NODE_GROUPS[count.index].MAX_SIZE
    min_size     = var.eks_values.NODE_GROUPS[count.index].MIN_SIZE
  }
  instance_types = [
    var.eks_values.NODE_GROUPS[count.index].NODE_INSTANCE_TYPE
  ]

  update_config {
    max_unavailable = 1
  }
  depends_on = [
    aws_eks_cluster.eks
  ]

}

resource "aws_iam_role" "eks_node_group" {
  name = "${var.local_values.RESOURCE_PREFIX}-Cluster-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

}
resource "aws_iam_policy" "node_group_policy" {
  name = "${var.local_values.RESOURCE_PREFIX}-Cluster-node-group-policy"
  path = "/"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeImages",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:DescribeVolumes",
          "ec2:ModifyVolume"
        ],
        "Resource" : "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}
resource "aws_iam_role_policy_attachment" "eks-node-group-policy" {
  policy_arn = aws_iam_policy.node_group_policy.arn
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}
resource "aws_iam_role_policy_attachment" "eks-AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_node_group.name
}




#######  EKS Cluster IAM Role ####### 
resource "aws_iam_role" "cluster" {
  name = "${var.local_values.RESOURCE_PREFIX}-Cluster-Role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}
resource "aws_iam_role_policy_attachment" "cluster_AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.cluster.name
}