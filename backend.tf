terraform {
  backend "s3" {
    bucket = "hackathon-terraform-backend" # your s3 bucket name
    key    = "terraform.tfstate"           # key
    region = "us-east-1"                   # region
  }
}
