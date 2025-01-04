resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = var.tags
}

resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = var.tags
}

resource "aws_subnet" "sub2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = var.tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = var.tags
}

resource "aws_route_table" "RT1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = var.tags
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT1.id
}

resource "aws_route_table" "RT2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = var.tags
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT2.id
}

resource "aws_security_group" "mysg" {
  name        = "web-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id
  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP_ipv4" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_SSH_ipv4" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_s3_bucket" "example" {
  bucket = "terraform-project-pranav4321"
  tags = var.tags
}

resource "aws_instance" "webserver1" {
  ami           = "ami-0e2c8caa4b6378d8c"
  instance_type = "t2.micro"
  tags = merge(var.tags,{"Name" = "webserver1"})
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id = aws_subnet.sub1.id
  user_data = base64encode(file("userdata.sh"))
  iam_instance_profile = aws_iam_instance_profile.webserver1_role.name
}

resource "aws_instance" "webserver2" {
  ami           = "ami-0e2c8caa4b6378d8c"
  instance_type = "t2.micro"
  tags = merge(var.tags,{"Name" = "webserver2"})
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id = aws_subnet.sub2.id
  user_data = base64encode(file("userdata2.sh"))
  iam_instance_profile = aws_iam_instance_profile.webserver2_role.name
}

resource "aws_lb" "myalb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mysg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]
  tags = merge(var.tags,{"Name" = "WebALB"})
}

resource "aws_lb_target_group" "test" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}