locals {
  values = {
    RESOURCE_PREFIX = "rankbang-${terraform.workspace}"
  }
}

module VPC {
    for_each = var.VPC_vars
    source = "./modules/VPC"
    VPC_vars = each.value
    local_values = local.values
}

module SG {
    for_each = var.sg
    source = "./modules/security_group"
    ENV = each.value.ENV
    sgname = "${local.values.RESOURCE_PREFIX}-SG"
    VPC_ID = module.VPC[each.key].VPC.vpc_id
    ingress = each.value.ingress_values
    tag_list_sg = each.value.tags
    depends_on = [  module.VPC ]
 }


module "eks" {
  for_each = var.eks_values
  source       = "./modules/eks"
  eks_values   = each.value
  subnets_ids  = module.VPC[each.key].VPC.public_subnet
  local_values = local.values
  sg_id = [module.SG[each.key].SG-ID]
  depends_on = [ module.SG , module.VPC ]
}

module "ecr" {
  for_each = var.ecr
  source = "./modules/ecr"
  ecr_conf = each.value
  resource_prefix = local.values.RESOURCE_PREFIX
}

resource "helm_release" "nginx_ingress_controller" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  create_namespace = true

  dynamic "set" {
    for_each = var.ingress_values
    content {
      name  = set.key
      value = set.value
    }
  }
  depends_on = [ module.SG , module.VPC , module.eks]
}


resource "helm_release" "csi_driver" {
  name             = "aws-ebs-csi-driver"
  namespace        = "kube-system"
  repository       = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart            = "aws-ebs-csi-driver"
  depends_on = [ module.SG , module.VPC , module.eks]
}

