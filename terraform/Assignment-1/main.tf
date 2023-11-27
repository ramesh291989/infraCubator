provider "aws" {
region = var.region
profile = var.profile
}


resource "aws_vpc" "test_vpc" {
  cidr_block = var.cidrblock

  tags = {
      Name = var.tagname
    }
}

resource "aws_internet_gateway" "test_gw" {
    vpc_id = aws_vpc.test_vpc.id

    tags = {
        Name = var.tagname
      }
}

resource "aws_subnet" "test-subnet" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = var.cidrblock
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.tagname
  }
}

resource "aws_route_table" "test_route" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/00"
    gateway_id = aws_internet_gateway.test_gw.id
  }
  tags = {
    Name = var.tagname
  }
}

resource "aws_route_table_association" "test_rt_asso" {
  subnet_id      = aws_subnet.test-subnet.id
  route_table_id = aws_route_table.test_route.id
}

resource "aws_security_group" "test-sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
     ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.tagname
  }
}

resource "tls_private_key" "test-rsa-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "test-key-pair" {
  key_name   = "test-key-pair"
  public_key = tls_private_key.test-rsa-key.public_key_openssh
}

resource "aws_instance" "test-main" {
  ami           = var.ami
  instance_type = var.instance-type
  subnet_id     = aws_subnet.test-subnet.id
  vpc_security_group_ids = [aws_security_group.test-sg.id]
  key_name      = aws_key_pair.test-key-pair.key_name
#   user_data = base64encode(file("ec2-userdata.sh"))

  tags = {
    Name = var.tagname
  }
}

output webserver_ip {
value = aws_instance.test-main.public_ip
description = "Public Ip for webserver"
}