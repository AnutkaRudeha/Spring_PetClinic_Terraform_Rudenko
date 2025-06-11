# VARIABLES

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-2a"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "App name"
  type = string
  default = "test-app" 
}

variable "instance_type" {
  description = "Instance type"
  type = string
  default = "t3a.medium"
}

variable "app_version" {
  description = "App version" 
  type = string
  default = "v1.6"
}

variable "app_port" {
  description = "App Port"
  type = string
  default = "8080"
}