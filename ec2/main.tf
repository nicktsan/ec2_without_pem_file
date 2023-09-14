//keypair resource
//add ec2 instance on public subnet
//add security group to allow instance access

resource "aws_security_group" "secgroup" {
  name        = "secgroup"
  description = "Allow public access"
  vpc_id      = var.vpc_id

  ingress {
    //port 22 is the ssh port
    from_port = 22
    to_port   = 22
    //protocol  = "-1"
    protocol = "tcp"
    //Opening to 0.0.0.0/0 to allow public access to the instance.
    //Opening to 0.0.0.0/0 can lead to security vulnerabilities. Normally, we should
    //restrict ingress to just the necessary IPs and ports 
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.ssh_public_key
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  //data.aws_subnet_ids.example.ids returns a set of ids, but we only need one
  //Therefore, we will sort the set, convert it into a list, and grab the first element.
  subnet_id       = sort(data.aws_subnets.example.ids)[0]
  security_groups = [aws_security_group.secgroup.id]
  tags = {
    Name = "HelloWorld"
  }
}
