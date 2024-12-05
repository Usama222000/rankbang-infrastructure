
resource "aws_ecr_repository" "ecr_repository" {
  name                 = lower("${var.resource_prefix}")
  force_delete = var.ecr_conf.force_delete
  image_tag_mutability = var.ecr_conf.image_tag_mutability

}


resource "aws_ecr_lifecycle_policy" "ecr_policy" {
 
  repository = aws_ecr_repository.ecr_repository.name

  policy = jsonencode({
    rules = [for rule in var.ecr_conf.policy_rules : rule
    ]
  })
}