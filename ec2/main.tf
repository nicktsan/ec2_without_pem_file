//For access to the ec2 instance via ssh, we will need the following:
//key pair resource
//ec2 instance on public subnet
//security group to allow instance access

//For access to the ec2 instance via session manager, we will need the following:
//iam role
//attach policy to enable session manager
//iam instance profile to be attached to the instance

//Define a firewall security group that will allow virtual machines within the VPC to access each other
//Create VPC bound security group
resource "aws_security_group" "vpcbound" {
  name        = "vpcbound"
  description = "VPC bound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block] #VPC CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    //Name = "allow_tls"
    Name = "vpc_bound"
  }
}

//vpc endpoints can be used to enable only private access, but they cost money.
// - com.amazonaws.us-east-1.ec2messages
// - com.amazonaws.us-east-1.ssm
// - com.amazonaws.us-east-1.ssmmessages
resource "aws_vpc_endpoint" "interface" {
  //loop through all vpc endpoints in locals.tf file
  for_each            = toset(local.vpc_endpoints)
  vpc_id              = var.vpc_id
  service_name        = each.key
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpcbound.id]
  private_dns_enabled = true
  subnet_ids          = data.aws_subnets.example.ids
}

//Add IAM role
resource "aws_iam_role" "ec2_role" {
  name = "ec2roleforssm"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

//Add an IAM role policy attachment
resource "aws_iam_role_policy_attachment" "ec2policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

//Create an IAM instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

//add security group to allow instance access
resource "aws_security_group" "secgroup" {
  name        = "secgroup"
  description = "Allow public access"
  vpc_id      = var.vpc_id
  /*#comment out this ingress block when we don't want the ec2 instance to be publicly accessible
  ingress {
    #port 22 is the ssh port
    #from_port = 22
    #to_port   = 22
    //port 443 is what system manager will use to access ec2 instance
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    //Opening to 0.0.0.0/0 to allow public access to the instance.
    //Opening to 0.0.0.0/0 can lead to security vulnerabilities. Normally, we should
    //restrict ingress to just the necessary IPs and ports 
    cidr_blocks = ["0.0.0.0/0"]
  }
  */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#Add key pair resource
/*resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.ssh_public_key
}*/
//Add ec2 instance on public subnet
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  #key_name      = aws_key_pair.deployer.key_name
  //data.aws_subnet_ids.example.ids returns a set of ids, but we only need one
  //Therefore, we will sort the set, convert it into a list, and grab the first element.
  subnet_id       = sort(data.aws_subnets.example.ids)[0]
  security_groups = [aws_security_group.secgroup.id]
  //This allows for access via system manager
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.id
  tags = {
    Name = "HelloWorld"
  }
}

//Create a private instance that we can connect to with session manager
resource "aws_instance" "private" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  //data.aws_subnet_ids.example.ids returns a set of ids, but we only need one
  //Therefore, we will sort the set, convert it into a list, and grab the first element.
  subnet_id       = sort(data.aws_subnets.example.ids)[0]
  security_groups = [aws_security_group.secgroup.id]
  //This allows for access via system manager
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.id
  associate_public_ip_address = false
  tags = {
    Name = "HelloWorld-Private"
  }
}
