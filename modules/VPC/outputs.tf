
output "VPC" {
  value = {
    vpc_id = aws_vpc.VPC.id
    public_subnet = aws_subnet.PUBLIC-SUBNETS.*.id
    private_subnet = aws_subnet.PRIVATE-SUBNETS.*.id
  }
}