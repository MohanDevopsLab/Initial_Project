variable "cidr_block" {
  type = list(string)
  default = ["10.0.0.0/16", "10.0.1.0/24" ]
}

variable "availability_zone" {
    type = list(string)
    default = ["ap-south-1" , "ap-south-1a"]
}


variable "ports" {
    type = list(number)
    default = [80,8080,443,8081,22]
}

variable "instance" {
    type = string
    default = "ami-04db49c0fb2215364"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
  
}


variable "availabilityzone" {
    type = string
    default = "ap-south-1a"
  
}

variable "instance_type_Nexus" {
    type = string
    default = "t2.medium"
  
}