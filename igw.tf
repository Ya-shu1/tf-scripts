#Creating IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mvpc.id
  tags = {

    Name = "my-igw"
  }
}

