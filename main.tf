resource "aws_vpc" "myVpc" {
  cidr_block = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "demo-vpc"
  }

}
resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.myVpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1"
  }
}
resource "aws_subnet" "sub2" {
  vpc_id     = aws_vpc.myVpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet2"
  }
}
resource "aws_internet_gateway" "ig-default" {
  vpc_id = aws_vpc.myVpc.id

}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myVpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig-default.id
  }
}
resource "aws_route_table_association" "subA1" {
  route_table_id = aws_route_table.rt.id
  subnet_id = aws_subnet.sub1.id
}
resource "aws_route_table_association" "subA2" {
  route_table_id = aws_route_table.rt.id
  subnet_id = aws_subnet.sub2.id
}
resource "aws_security_group" "webSg" {
  name        = "web-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myVpc.id

  ingress {
    description      = "SSH "
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "TCP "
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}
resource "aws_s3_bucket" "random" {
  bucket = "ashwin1430bucket"
}
resource "aws_instance" "webserver" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id = aws_subnet.sub1.id
  user_data=base64encode(file("userdata.sh"))

}
