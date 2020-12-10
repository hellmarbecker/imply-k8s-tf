#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "imply" {
  cidr_block = "10.0.0.0/16"

  tags = map(
      "Name", "terraform-eks-imply-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
}

resource "aws_subnet" "imply" {
  count = var.az_count

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.imply.id
  map_public_ip_on_launch = true

  tags = map(
      "Name", "terraform-eks-imply-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
}

resource "aws_internet_gateway" "imply" {
  vpc_id = aws_vpc.imply.id

  tags = {
    Name = "terraform-eks-imply"
  }
}

resource "aws_route_table" "imply" {
  vpc_id = aws_vpc.imply.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.imply.id
  }
}

resource "aws_route_table_association" "imply" {
  count = var.az_count

  subnet_id      = aws_subnet.imply.*.id[count.index]
  route_table_id = aws_route_table.imply.id
}
