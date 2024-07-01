variable aws_region {
  description = "This is aws region"
  default     = "us-west-2"
  type        = string
}


variable "profile" {
  description = "user account to use"
  default = "default"
}

variable aws_instance_type {
  description = "This is aws ec2 type "
  default = "t2.medium"
  type        = string
}

variable aws_key {
  description = "Key in region"
  default     = "kind-key-pair"
  type        = string
}

