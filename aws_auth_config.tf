# resource "kubernetes_config_map" "aws-auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     "mapRoles" = <<-EOT
#     - groups:
#       - system:bootstrappers
#       - system:nodes
#       rolearn: arn:aws:iam::905418367633:role/preprod-Cluster-node-group-role
#       username: system:node:{{EC2PrivateDNSName}}
#     EOT

#     "mapUsers" = <<-EOT
#     - userarn: arn:aws:iam::905418367633:user/AdminUser
#       username: preprod
#       groups:
#         - system:masters
#     EOT
#   }
# }
