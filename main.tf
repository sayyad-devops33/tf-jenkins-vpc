resource "aws_vpc" "main_vpc" {

  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraform-vpc"
  }
}
resource "aws_subnet" "public_subnet" {

  vpc_id = aws_vpc.main_vpc.id

  cidr_block = "10.0.1.0/24"

  availability_zone = "ap-south-1a"

  tags = {
    Name = "public-subnet"
  }
}
resource "aws_subnet" "private_subnet" {

  vpc_id = aws_vpc.main_vpc.id

  cidr_block = "10.0.2.0/24"

  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet"
  }
}
resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}
resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}
resource "aws_route_table_association" "public_assoc" {

  subnet_id      = aws_subnet.public_subnet.id

  route_table_id = aws_route_table.public_rt.id
}
resource "aws_security_group" "web_sg" {

  name        = "web-sg"

  description = "Allow SSH"

  vpc_id = aws_vpc.main_vpc.id

  ingress {

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
}
ingress {

 from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {

 from_port = 8080

    to_port = 8080

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-security-group"
  }
}
resource "aws_instance" "web_server" {

  ami = "ami-01b40e1bcccae197a"

  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  associate_public_ip_address = true

  key_name = "mykeypair"

  tags = {
    Name = "terraform-server"
  }
}
