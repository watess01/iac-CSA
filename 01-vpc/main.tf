# terraform to create a vpc
# terraform for a repeatable compute layer
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

# provider for aws and region
provider "aws" {
    region = var.region
}

# create a vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "MyVPC"
  }
}

# create 2 private subnets in 2 different availability zones
resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availability_zones[count.index]
  tags = {
    name = "Private-1${element(var.suffixes, count.index)}"
  }
}
# create 2 public subnets in 2 different availability zones
resource "aws_subnet" "public" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 4)
  availability_zone = var.availability_zones[count.index]
  tags = {
    name = "Public-1${element(var.suffixes, count.index)}"
  }
  lifecycle {
    create_before_destroy = true
  }
}


# CREATE PRIVATE ROUTE TABLE
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix}-private-rt"
  }

}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}



# create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix}-public-rt"
  }
}

# create public route table association
resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# create private route table association
resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)
  
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


# Create Route to Internet Gateway
resource "aws_route" "igw" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}
