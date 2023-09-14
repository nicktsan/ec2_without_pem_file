This project creates an EC2 instance without using PEM files

Command to generate ssh keys:
ssh-keygen -f <path to ssh private key>
This will generate a private key and a public key. We will be using the public key later.

Navigate to the ec2 directory.
Set environment variable AWS_PROFILE to a valid AWS IAM user with
Windows command prompt:
SETX AWS_PROFILE <iam user>

Then create a dev workspace within the s3 bucket with
terraform workspace new <dev environment name>

Then run:
terraform init
This will initialize the current directory with terraform configuration files

Then run: 
terraform plan -out outtfplan
This will save the output of the plan to a file and create the workspace in your Terraform organization.
Alternatively, if you want to use an input file to avoid manually inputting values for region, vpc_id, and ssh_public_key, run:
terraform plan -var-file input.tfvars -out out.tfplan
where input.tfvars contains values for region, vpc_id, and ssh_public_key