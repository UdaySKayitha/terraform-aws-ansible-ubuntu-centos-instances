# main.tf
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.organisation}-${var.application}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.organisation}-${var.application}-${var.environment}-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.organisation}-${var.application}-${var.environment}-igw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.organisation}-${var.application}-${var.environment}-route-table"
  }
}

resource "aws_route_table_association" "rts" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  name_prefix = "allow-http-ssh"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2024
    to_port     = 2024
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.organisation}-${var.application}-${var.environment}-sg"
  }
}

resource "aws_instance" "ubuntu_control_instances" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance_type
  count                       = var.num_ubuntu_control_instances
  key_name                    = var.key_name # Reference the existing key pair
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "ubuntu-c" # Setting hostname as ubuntu-1, ubuntu-2, etc.
  }

  user_data = <<-EOF
              #!/bin/bash
              # Change the hostname
              hostnamectl set-hostname ubuntu-c

              # Update the packages
              sudo apt update -y && apt install ansible -y
              
              # Create Ansible user and set password
              useradd -m -s /bin/bash ${var.username}
              echo "${var.username}:${var.password}" | chpasswd

              # Add the Ansible user to sudo group
              usermod -aG sudo ${var.username}

              # Allow passwordless sudo
              echo "${var.username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

              # Generate SSH key for ansible user
              sudo -u ansible ssh-keygen -t rsa -b 4096 -N "" -f /home/ansible/.ssh/id_rsa

              # Add public key to authorized_keys
              mkdir -p /home/ansible/.ssh
              cat /home/ansible/.ssh/id_rsa.pub >> /home/ansible/.ssh/authorized_keys
              chmod 600 /home/ansible/.ssh/authorized_keys
              chown -R ansible:ansible /home/ansible/.ssh
              
              # cat /var/log/cloud-init-output.log # To check the Cloud Init log for user data
              EOF
}

resource "aws_instance" "ubuntu_instances" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance_type
  count                       = var.num_ubuntu_instances
  key_name                    = var.key_name # Reference the existing key pair
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "ubuntu-${count.index + 1}" # Setting hostname as ubuntu-1, ubuntu-2, etc.
  }

  user_data = <<-EOF
              #!/bin/bash
              # Change the hostname
              hostnamectl set-hostname ubuntu-${count.index + 1}

              # Update the packages
              sudo apt update -y

              # Create Ansible user and set password
              useradd -m -s /bin/bash ${var.username}
              echo "${var.username}:${var.password}" | chpasswd

              # Add the Ansible user to sudo group
              usermod -aG sudo ${var.username}

              # Allow passwordless sudo
              echo "${var.username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

              # Create .ssh folder and authorized_keys
              mkdir -p /home/ansible/.ssh
              touch /home/ansible/.ssh/authorized_keys
              chmod 600 /home/ansible/.ssh/authorized_keys
              chown -R ansible:ansible /home/ansible/.ssh
        
              # cat /var/log/cloud-init-output.log # To check the Cloud Init log for user data
              EOF
}

resource "aws_instance" "centos_instances" {
  ami                         = var.centos_ami
  instance_type               = var.instance_type
  count                       = var.num_centos_instances
  key_name                    = var.key_name # Reference the existing key pair
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "centos-${count.index + 1}" # Setting hostname as centos-1, centos-2, etc.
  }

  user_data = <<-EOF
              #!/bin/bash
              # Change the hostname
              hostnamectl set-hostname centos-${count.index + 1}

              # Update the packages
              sudo yum update -y
              sudo yum epel-release -y 
              
              # Create Ansible user and set password
              useradd -m -s /bin/bash ${var.username}
              echo "${var.username}:${var.password}" | chpasswd

              # Add the Ansible user to sudo group
              usermod -aG wheel ${var.username}

              # Allow passwordless sudo
              echo "${var.username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

               # Create .ssh folder and authorized_keys
              mkdir -p /home/ansible/.ssh
              touch /home/ansible/.ssh/authorized_keys
              chmod 600 /home/ansible/.ssh/authorized_keys
              chown -R ansible:ansible /home/ansible/.ssh
              
              # cat /var/log/cloud-init-output.log # To check the Cloud Init log for user data
              EOF
}


