resource "aws_internet_gateway" "main-vpc-igw" {
  vpc_id = aws_vpc.main-vpc.id
  tags = merge(var.tags, {})
}

resource "aws_subnet" "public_a" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = var.public_subnet.a
  tags = merge(var.tags, {})
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = var.public_subnet.b
  tags = merge(var.tags, {})
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_c" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = var.public_subnet.c
  tags = merge(var.tags, {})
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true
}

resource "aws_eip" "eip_a" {
    tags = merge(var.tags, {})
}

resource "aws_eip" "eip_b" {
    tags = merge(var.tags, {})
}

resource "aws_eip" "eip_c" {
    tags = merge(var.tags, {})
}

resource "aws_nat_gateway" "nat-gw-1a-public" {
  allocation_id = aws_eip.eip_a.id
  subnet_id     = aws_subnet.public_a.id
  tags = merge(var.tags, {})
  depends_on = [aws_eip.eip_a]
}

resource "aws_nat_gateway" "nat-gw-1b-public" {
  allocation_id = aws_eip.eip_b.id
  subnet_id     = aws_subnet.public_b.id
  tags = merge(var.tags, {})
  depends_on = [aws_eip.eip_b]
}

resource "aws_nat_gateway" "nat-gw-1c-public" {
  allocation_id = aws_eip.eip_c.id
  subnet_id     = aws_subnet.public_c.id
  tags = merge(var.tags, {})
  depends_on = [aws_eip.eip_c]
}

resource "aws_route_table" "rt_public_a" {
  vpc_id = aws_vpc.main-vpc.id
  tags = merge(var.tags, {})
}

resource "aws_route_table_association" "rt_assoc_public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.rt_public_a.id
}

resource "aws_route" "route_a" {
  route_table_id            = aws_route_table.rt_public_a.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main-vpc-igw.id
}

resource "aws_route_table" "rt_public_b" {
  vpc_id = aws_vpc.main-vpc.id
  tags = merge(var.tags, {})
}

resource "aws_route_table_association" "rt_assoc_public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.rt_public_b.id
}

resource "aws_route" "route_b" {
  route_table_id            = aws_route_table.rt_public_b.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main-vpc-igw.id
}

resource "aws_route_table" "rt_public_c" {
  vpc_id = aws_vpc.main-vpc.id
  tags = merge(var.tags, {})
}

resource "aws_route_table_association" "rt_assoc_public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.rt_public_c.id
}

resource "aws_route" "route_c" {
  route_table_id            = aws_route_table.rt_public_c.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main-vpc-igw.id
}