This project creates an EC2 instance without using PEM files

Command to generate ssh keys:
ssh-keygen -f <path to ssh private key>

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
Alternatively, if you want to use an input file, run:
terraform plan -var-file input.tfvars -out out.tfplan