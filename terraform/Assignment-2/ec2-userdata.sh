#!/bin/bash
yum update -y
yum install -y ec2-instance-connect
yum install -y httpd
systemctl start httpd
systemctl enable httpd