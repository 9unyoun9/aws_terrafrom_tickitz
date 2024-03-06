# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "title_name" {
  description = "The title to use for all the resources"
  type        = string
  default     = "T2Movie"
  
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}


variable "SubnetPrivateContainer1A_cidr_block" {
  description = "The CIDR block for the private subnet in the first Availability Zone"
  type        = string
  default     = "10.0.8.0/24"
}

variable "SubnetPrivateContainer1C_cidr_block" {
  description = "The CIDR block for the private subnet in the first Availability Zone"
  type        = string
  default     = "10.0.9.0/24"
}


variable "SubnetPrivateDb1A_cidr_block" {
  description = "The CIDR block for the private subnet in the first Availability Zone"
  type        = string
  default     = "10.0.16.0/24"
}

variable "SubnetPrivateDb1C_cidr_block" {
  description = "The CIDR block for the private subnet in the first Availability Zone"
  type        = string
  default     = "10.0.17.0/24"
}

variable "SubnetPublicIngress1A_cidr_block" {
  description = "The CIDR block for the public subnet in the first Availability Zone"
  type        = string
  default     = "10.0.0.0/24"
}

variable "SubnetPublicIngress1C_cidr_block" {
  description = "The CIDR block for the public subnet in the first Availability Zone"
  type        = string
  default     = "10.0.1.0/24"
}


variable "SubnetPublicManagement1A_cidr_block" {
  description = "The CIDR block for the public subnet in the first Availability Zone"
  type        = string
  default     = "10.0.240.0/24"
}

variable "SubnetPublicManagement1C_cidr_block" {
  description = "The CIDR block for the public subnet in the first Availability Zone"
  type        = string
  default     = "10.0.241.0/24"
}

variable "SubnetPrivateEgress1A_cidr_block" {
  description = "The CIDR block for the private subnet in the first Availability Zone"
  type        = string
  default     = "10.0.248.0/24"
}

variable "SubnetPrivateEgress1C_cidr_block" {
  description = "The CIDR block for the private subnet in the first Availability Zone"
  type        = string
  default     = "10.0.249.0/24"
}

#-----------------------------------------------------------------
variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type        = string
  default     = "terraform-s3-9unyun9.dasdf"
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type        = string
  default     = "stage/terraform.tfstage.dsaf" # 값 추가
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "server_ssh_port" {
  description = "The port the server will use for ssh requests"
  type        = number
  default     = 22
}
