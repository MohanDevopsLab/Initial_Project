terraform {
    required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "~> 3.0"
      }
    }
}

provider "aws" {
  region = var.availability_zone[0]
  #here aws configure to give access key and secret key
}

# Create a VPC

resource "aws_vpc" "My_VPC" {
  cidr_block = var.cidr_block[0]

  tags = {
    Name = "My_VPC"
  }
}

#Create a Subnet

resource "aws_subnet" "My_Subnet" {
  vpc_id = aws_vpc.My_VPC.id
  cidr_block = var.cidr_block[1]
  availability_zone = var.availability_zone[1]

  tags = {
      Name = "My_Subnet"
  }
}

# Create internet Gateway

resource "aws_internet_gateway" "My_IGW" {
    vpc_id = aws_vpc.My_VPC.id

    tags = {
     Name = "My_IGW"
    }
}

# Create SecurityGroups

resource "aws_security_group" "My_SecurityGroup" {
  name        = "allow_tls"
  description = "Allow web inbound traffic"
  vpc_id = aws_vpc.My_VPC.id

  #Inbound protocols defining dynamically

  dynamic ingress {
    #description  = "Inbound protocols"
    iterator = port
    for_each  = var.ports
    content  {
    from_port        = port.value
    to_port          = port.value
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = var.cidr_block[4]
      }
  }

  #Outbound protocols
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    # here -1 represents all. i.e. all outbound protocols are allowed
    cidr_blocks   = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = var.cidr_block[4]
  }
}  

resource "aws_route_table" "My_Routetable" {
  vpc_id = aws_vpc.My_VPC.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.My_IGW.id
  }

      tags = {
        Name = "My_Routetable"
    }
}

/*
# 7.Create a network interface with an ip in the subnet that was created in step 4.
resource "aws_network_interface" "firstNI" {
  subnet_id       = aws_subnet.first_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.first_subnet.id]

  # attachment {
  #   instance     = aws_instance.test.id
  #   device_index = 1
  #}
}
# 8.Assign an elastic ip to the netwprk interface created in step 7.
resource "aws_eip" "first_elasticIP" {
  vpc                       = true
  network_interface         = aws_network_interface.firstNI.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.first_IGW]
    
}
*/
# Create route table association
resource "aws_route_table_association" "My_RTAssn" {
    subnet_id = aws_subnet.My_Subnet.id
    route_table_id = aws_route_table.My_Routetable.id
}

# Create a server and install jenkins

 resource "aws_instance" "Jenkins_Instance" {
  ami = var.instance
  instance_type = var.instance_type
  availability_zone = var.availabilityzone
  key_name = "Sample"
  vpc_security_group_ids = [aws_security_group.My_SecurityGroup.id]
  subnet_id = aws_subnet.My_Subnet.id
  associate_public_ip_address = true
  user_data = file("./installJenkins.sh")

   tags = {
    Name = "Jenkins_instance"
  }
 }


 # Create a server and install Ansible Controller /Control Node

 resource "aws_instance" "AnsibleControlNode_Instance" {
  ami = var.instance
  instance_type = var.instance_type
  availability_zone = var.availabilityzone
  key_name = "Sample"
  vpc_security_group_ids = [aws_security_group.My_SecurityGroup.id]
  subnet_id = aws_subnet.My_Subnet.id
  associate_public_ip_address = true
  user_data = file("./installAnsible.sh")

   tags = {
    Name = "AnsibleControlNode_instance"
  }
 }
 
 # Create a server and install Ansible Managed Node1 for launching tomcat

 resource "aws_instance" "AnsibleMN_Tomcat" {
  ami = var.instance
  instance_type = var.instance_type
  availability_zone = var.availabilityzone
  key_name = "Sample"
  vpc_security_group_ids = [aws_security_group.My_SecurityGroup.id]
  subnet_id = aws_subnet.My_Subnet.id
  associate_public_ip_address = true
  user_data = file("./installAnsibleMN1.sh")

   tags = {
    Name = "AnsibleMN_Tomcat"
  }
 }
 

  # Create a server and install Ansible Managed Node2 to host Docker

   resource "aws_instance" "AnsibleMN_Docker" {
  ami = var.instance
  instance_type = var.instance_type
  availability_zone = var.availabilityzone
  key_name = "Sample"
  vpc_security_group_ids = [aws_security_group.My_SecurityGroup.id]
  subnet_id = aws_subnet.My_Subnet.id
  associate_public_ip_address = true
  user_data = file("./installDockerMN2.sh")

   tags = {
    Name = "AnsibleMN_DockerHost"
  }
 }
 

 # Create a Ec2 instance to host Nexus
  resource "aws_instance" "My_Nexus" {
  ami = var.instance
  instance_type = var.instance_type_Nexus
  availability_zone = var.availabilityzone
  key_name = "Sample"
  vpc_security_group_ids = [aws_security_group.My_SecurityGroup.id]
  subnet_id = aws_subnet.My_Subnet.id
  associate_public_ip_address = true
  user_data = file("./installNexus.sh")

   tags = {
    Name = "My_Nexus"
  }
 }
  