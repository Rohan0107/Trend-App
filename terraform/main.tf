provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "trend_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "trend-app"
  }
}

# Subnet
resource "aws_subnet" "trend_subnet" {
  vpc_id                  = aws_vpc.trend_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "trend-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "trend_igw" {
  vpc_id = aws_vpc.trend_vpc.id
  tags = {
    Name = "trend-igw"
  }
}

# Route Table
resource "aws_route_table" "trend_rt" {
  vpc_id = aws_vpc.trend_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.trend_igw.id
  }
}

# Route Table Association
resource "aws_route_table_association" "trend_rta" {
  subnet_id      = aws_subnet.trend_subnet.id
  route_table_id = aws_route_table.trend_rt.id
}

# Security Group
resource "aws_security_group" "trend_sg" {
  vpc_id = aws_vpc.trend_vpc.id
  name   = "trend-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for EC2
resource "aws_iam_role" "trend_ec2_role" {
  name = "trend-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "trend_profile" {
  name = "trend-ec2-profile"
  role = aws_iam_role.trend_ec2_role.name
}

# EC2 Instance (Jenkins Server)
resource "aws_instance" "jenkins_server" {
  ami                    = "ami-07e29570afffc72c1"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.trend_subnet.id
  vpc_security_group_ids = [aws_security_group.trend_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.trend_profile.name
  key_name               = "linux"


  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y java-11-openjdk
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    yum install -y jenkins
    systemctl start jenkins
    systemctl enable jenkins
  EOF

  tags = {
    Name = "jenkins-server"
  }
}