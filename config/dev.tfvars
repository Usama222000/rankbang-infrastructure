region = "us-east-1"

###################################  vpc ####################################
VPC_vars = {
  rankbang = {
    vpc_cidr = "10.0.0.0/16"
    public_subnets = ["10.0.0.0/20","10.0.16.0/20"]
    private_subnets = ["10.0.32.0/20", "10.0.48.0/20"]
  }
  
}

################################### security group ##########################
sg = {
rankbang = {
  ENV = ""
  ingress_values =  {
    "22"  = ["0.0.0.0/0"]
    "80"  = ["0.0.0.0/0"]
    "443" = ["0.0.0.0/0"]
    }
    tags ={}
}
 
}

################################### EKS CLUSTER ##############################
eks_values = {
  rankbang = {
      CLUSTER_NAME                   = "eks"
      STAGE                          = "PRE-PROD"
      LOGS_RETENTION_IN_DAYS         = 7
      ENABLE_ENDPOINT_PUBLIC_ACCESS  = true
      PUBLIC_ACCESS_CIDRS            = "0.0.0.0/0"
      ENABLE_ENDPOINT_PRIVATE_ACCESS = true
      KUBERNETES_VERSION             = "1.29"
      LOGGING_TYPE                   = ["api"]
      CAPACITY_TYPE                  = "ON_DEMAND"
      DESIRED_CAPACITY               = 1
      MAX_SIZE                       = 3
      MIN_SIZE                       = 1
      NODE_INSTANCE_TYPE             = "t3a.small"
      NODE_INSTANCE_TAGS             = "ManagedBy = Terraform"
      TAGS                           = "EKS_TF"
      COMMON_TAGS                    = "EKS_TF"
      NODE_GROUPS = [
        {
          CAPACITY_TYPE         = "ON_DEMAND"
          DESIRED_CAPACITY      = 1
          MAX_SIZE              = 10
          MIN_SIZE              = 1
          NODE_INSTANCE_TYPE    = "t2.medium"
          NODE_INSTANCE_TAGS    = "ManagedBy = Terraform"
          LABELS                = "node1"
        }

      ]
  }
  
}

ingress_values = {
  "tcp.8080" = "default/hellobibleapi:8080",
}


ecr = {
  rankbang_ecr = {
    name                 = "rankbang"
    force_delete = true
    image_tag_mutability = "MUTABLE"
    policy_rules = [
      {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection" = {
              "tagStatus": "untagged",
              "countType": "sinceImagePushed",
              "countUnit": "days",
              "countNumber": 14
            }
            "action": {
                "type": "expire"
            }
        
      }
    ]
    
  }
}

