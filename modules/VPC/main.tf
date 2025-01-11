resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = merge(var.tags, {Name = try("${var.tags["Name"]}-VPC", "Default-VPC")})
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {Name = try("${var.tags["Name"]}-igw")})
}

data "aws_availability_zone" "available_zones" {}

# create public subnet pub_sub_1a
resource "aws_subnet" "pub_sub_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.pub_sub_1a_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags      = {
    Name    = "pub_sub_1a"
  }
}

# create public subnet pub_sub_2b
resource "aws_subnet" "pub_sub_2b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_sub_2b_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags      = {
    Name    = "pub_sub_2b"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public-rt"
  }
}

resource "aws_route_table_association" "pub_sub_1a" {
  subnet_id = aws_subnet.pub_sub_1a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "pub_sub_2b" {
  subnet_id = aws_subnet.pub_sub_2b.id
  route_table_id = aws_route_table.public_route_table.id
  
}

resource "aws_subnet" "pri_sub_3a" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.pri_sub_3a_cidr
  availability_zone = data.aws_availability_zone.available_zones.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "pri-sub-3a"
  }
}

resource "aws_subnet" "pri_sub_4b" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.pri_sub_4b_cidr
  availability_zone = data.aws_availability_zone.available_zones.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "pri-sub-4b"
  }
}

resource "aws_subnet" "pri_sub_5a" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.pri_sub_5a_cidr
  availability_zone = data.aws_availability_zone.available_zones.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "pri-sub-5a"
  }
}

resource "aws_subnet" "pri_sub_6b" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.pri_sub_6b_cidr
  availability_zone = data.aws_availability_zone.available_zones.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "pri-sub-6b"
  }
}