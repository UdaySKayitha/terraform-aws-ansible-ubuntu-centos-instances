# terraform.tfvars

aws_region                   = "us-east-1" # specify your desired region
instance_type                = "t2.micro"
num_ubuntu_instances         = 2
num_centos_instances         = 2
num_ubuntu_control_instances = 1
key_name                     = "k8s"
organisation                 = "lc"
application                  = "ansible"
environment                  = "dev"
vpc_cidr                     = "10.0.0.0/16"
subnet_cidr                  = "10.0.2.0/24"
username                     = "ansible"
password                     = "ansible"

# AMI IDs must be specific to your AWS region
ubuntu_ami = "ami-0e86e20dae9224db8" # Example: Ubuntu 20.04 LTS AMI ID
centos_ami = "ami-0b898040803850657" # Example: CentOS 7 AMI ID
