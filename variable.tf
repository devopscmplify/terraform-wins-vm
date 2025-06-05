variable "name" {
  description = "The name of the resource"
  type        = string
  default     = "DC"
  
}

variable "resource_group_location" {
  default     = "West Europe"
  description = "Location of the resource group."
}

variable "sub-id" {
  description = "Subscription ID for the Azure account"
  type        = string
  default     = "244f325e-8ad1-463f-898c-a17595527902"
  
}