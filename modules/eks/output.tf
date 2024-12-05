output "eks_output" {

  value = {
    EKS_CLUSTER          = aws_eks_cluster.eks
    EKS_CLUSTER_ARN      = aws_eks_cluster.eks.arn
    EKS_CLUSTER_ENDPOINT = aws_eks_cluster.eks.endpoint
    EKS_CLUSTER_ID       = aws_eks_cluster.eks.id
    OIDC_ARN             = aws_iam_openid_connect_provider.cluster.arn
  }

}
