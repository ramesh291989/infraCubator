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

resource "aws_launch_configuration" "test-lc" {
  image_id      = var.ami
  instance_type = var.instance-type
  security_groups = [aws_security_group.test-sg.id]
  user_data = file("ec2-userdata.sh")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "test-asg" {
   vpc_zone_identifier = [aws_subnet.test-subnet.id]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2
  launch_configuration = aws_launch_configuration.test-lc.name
  }

resource "aws_autoscaling_policy" "test-as-policy" {
  name                   = "test-as-policy"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.test-asg.name
}

resource "aws_cloudwatch_metric_alarm" "test-cw-alrm" {
  alarm_name          = "test-cw-alrm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 30
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.test-asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.test-as-policy.arn]
}

resource "aws_route53_record" "test-www" {
  zone_id = var.hostedzoneid
  name    = var.sitedomain
  type    = "A"
  ttl = 300
  records = data.aws_instances.test-instances.public_ips
  }
