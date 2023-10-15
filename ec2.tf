# Create instance
resource "aws_instance" "app" {
  ami                    = "ami-03d294e37a4820c21"
  instance_type          = "t2.micro"
  key_name               = "terra"
  subnet_id              = aws_subnet.pub-sub-1.id
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  user_data              = file("data.sh")
  tags = {
    Name = "webapplication"
  }
}

# Create Security-group
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.mvpc.id

  #Inbound Rules
  # HTTP acces from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from any where
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSh access from any where
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #outbound Rules
  #internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-sg"
  }

}

# Create instance
resource "aws_instance" "app2" {
  ami           = "ami-03d294e37a4820c21"
  instance_type = "t2.micro"
  #count                  =  1
  # for load-balancer target-id attachment is done by commenting to the Count = 1 and by defaultely every instance count is 1
  key_name               = "terra"
  subnet_id              = aws_subnet.pub-sub-2.id
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  user_data              = file("data.sh")
  tags = {
    Name = "webapplication2"
  }
}

# Create Security-group
resource "aws_security_group" "sg2" {
  vpc_id = aws_vpc.mvpc.id

  #Inbound Rules
  # HTTP acces from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from any where
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSh access from any where
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #outbound Rules
  #internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-sg2"
  }

}



# Create instance
resource "aws_instance" "web-app" {
  ami           = "ami-03d294e37a4820c21"
  instance_type = "t2.micro"
  #count                  =  1
  # by defaultely every instance count is 1
  key_name               = "terra"
  subnet_id              = aws_subnet.pvt-sub-1.id
  vpc_security_group_ids = ["${aws_security_group.demo.id}"]
  tags = {
    Name = "web-pvt"
  }
}

# Create Security-group
resource "aws_security_group" "demo" {
  vpc_id = aws_vpc.mvpc.id

  #Inbound Rules
  # HTTP acces from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from any where
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSh access from any where
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #outbound Rules
  #internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-sg"
  }

}

# Create elastic ip
resource "aws_eip" "elastic" {
  vpc = true
}

# Create Nat-gateway
resource "aws_nat_gateway" "nat" {

  allocation_id     = aws_eip.elastic.id
  subnet_id         = aws_subnet.pub-sub-1.id
  connectivity_type = "public"
  tags = {
    Name = "mynat"
  }
}

# Create subnet groups
resource "aws_db_subnet_group" "db-sub" {
  subnet_ids = [aws_subnet.pvt-sub-1.id, aws_subnet.pvt-sub-2.id]
  tags = {
    Name = "dbsubnet"
  }
}
# Create the data-base
resource "aws_db_instance" "data" {
  allocated_storage      = "10"
  db_subnet_group_name   = aws_db_subnet_group.db-sub.id
  db_name                = "mydata"
  engine                 = "mysql"
  engine_version         = "8.0.28"
  instance_class         = "db.t2.micro"
  multi_az               = "true"
  username               = "admin"
  password               = "admin1230"
  vpc_security_group_ids = ["${aws_security_group.db-sg.id}"]
  skip_final_snapshot    = "true"

}

# Create the security groups
resource "aws_security_group" "db-sg" {
  vpc_id = aws_vpc.mvpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.demo.id]
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "database-sg"
  }
}


# Create load_balancer
resource "aws_lb" "application" {
  internal           = false
  name               = "APPLI-LB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.pub-sub-1.id, aws_subnet.pub-sub-2.id]
}

resource "aws_lb_target_group" "tar" {
  name     = "target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mvpc.id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    protocol            = "HTTP"
    port                = 80
    path                = "/ping"
    matcher             = 200
  }
}
resource "aws_lb_target_group_attachment" "att" {
  target_group_arn = aws_lb_target_group.tar.arn
  #count            = 0
  #target_id        = aws_instance.app.id[count.index]
  target_id  = aws_instance.app.id
  port       = 80
  depends_on = [aws_instance.app, ]
}
resource "aws_lb_target_group_attachment" "att2" {
  target_group_arn = aws_lb_target_group.tar.arn
  #count            = 0
  #target_id        = aws_instance.app2.id[count.index]
  target_id  = aws_instance.app2.id
  port       = 80
  depends_on = [aws_instance.app2, ]
}

resource "aws_lb_listener" "lb-lis" {
  load_balancer_arn = aws_lb.application.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tar.arn
  }
}


#getting the DNS of load-balancer
output "lb_dns_name" {
  description = "the name of the loadbalancer"
  value       = aws_lb.application.dns_name
}

