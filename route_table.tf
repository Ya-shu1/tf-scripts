#Create Pub-Route-table
resource "aws_route_table" "pub-route" {
  vpc_id = aws_vpc.mvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }
  tags = {
    Name = "pub-rot"
  }

}

#Create Pvt-Route-table
resource "aws_route_table" "pvt-route" {
  vpc_id = aws_vpc.mvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "pvt-rot"
  }

}

#subnets Associations
#pub-subnet-association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub-sub-1.id
  route_table_id = aws_route_table.pub-route.id
}

#pvt subnet-association
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pvt-sub-1.id
  route_table_id = aws_route_table.pvt-route.id

}



#subnets Associations
#pub-subnet-association
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.pub-sub-2.id
  route_table_id = aws_route_table.pub-route.id
}

#pvt subnet-association
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.pvt-sub-2.id
  route_table_id = aws_route_table.pvt-route.id

}
