variable "prefix" {
    type = string
    default = "ex-kuby"
}

variable "location" {
    type = string
    default = "westeurope"
}

variable "aks_subnet_name" {
  description = "AKS Subnet Name."
  default     = "subnet-dev-westeurope"
}

variable "password" {
  description = "Service Principal password"
  default = "YourPasswordHereCapitalWhatever!#"
}
