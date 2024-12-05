variable "ENV" {
       type=string
       default="default" 
}

variable "VPC_ID" {
       type=string
       default="" 
}

variable "sgname" {
  type = string
  default = ""
}


variable "ingress" {
  type = map
  default = {
    "22"  = ["0.0.0.0/0"]
    "80"  = ["0.0.0.0/0"]
    "443" = ["0.0.0.0/0"]
    }
}

variable "tag_list_sg" {
  default = {
    "Security-Group"  = {}
    }
}



