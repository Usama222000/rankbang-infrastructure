
resource "aws_security_group" "SG-GRP"{
   name        = "${var.sgname}"
   description = "Security Group"
   vpc_id      = "${var.VPC_ID}"
   dynamic "ingress" { 
    for_each = "${var.ingress}"
    iterator = port
    content {
      from_port   = port.key
      to_port     = port.key
      protocol    = "tcp"
      cidr_blocks = port.value
    }
    }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  tags = var.tag_list_sg

}

























# resource "aws_security_group" "WEB-DMZ"{
#    name        = "WEB-Sec-Group"
#    description = "Enable HTTP/HTTPS,SSH from 0.0.0.0/0"
#    vpc_id      = "${var.VPC_ID}"
#    dynamic "ingress" { 
#     for_each = "${var.WEB_ingress}"
#     iterator = port
#     content {
#       from_port   = port.key
#       to_port     = port.key
#       protocol    = "tcp"
#       cidr_blocks = port.value
#     }
#     }
#     egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }
#   tags = {
#      Name = "${var.ENV}-${terraform.workspace}-WEB-DMZ"
#  }
# }


# resource "aws_security_group" "DB-DMZ"{
#    name        = "DB-Sec-Group"
#    description = "Enable HTTP/HTTPS,SSH,MYSQL from 0.0.0.0/0"
#    vpc_id      = "${var.VPC_ID}"
#    dynamic "ingress" { 
#     for_each = "${var.DB_ingress}"
#     iterator = port
#     content {
#       from_port   = port.key
#       to_port     = port.key
#       protocol    = "tcp"
#       cidr_blocks = port.value
#     }
#     }
#     egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }
#   tags = {
#      Name = "${var.ENV}-${terraform.workspace}-DB-DMZ"
#  }
# }