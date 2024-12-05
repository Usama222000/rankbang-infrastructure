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
#       rolearn: rolearn
#       username: system:node:{{EC2PrivateDNSName}}
#     EOT

#     "mapUsers" = <<-EOT
#     - userarn: your user
#       username: preprod
#       groups:
#         - system:masters
#     EOT
#   }
# }
