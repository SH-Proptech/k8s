variable "client_id" {
  type        = string
  description = "Azure client id"
}

variable "client_secret" {
  type        = string
  description = "Azure client secret"
  sensitive   = true
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription id"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant id"
}

variable "location" {
  type        = string
  description = "The Azure region to deploy the resources"
  default     = "northeurope"
}

variable "prefix" {
  type        = string
  description = "The prefix to apply to all resource e.g. my_resource"
  default     = "prop"
}

variable "vnet_address_space" {
  type        = string
  description = "The address space for the virtual network"
  default     = "10.0.0.0/16"
}

variable "dns_address_space" {
  type        = string
  description = "The address space for the DNS subnet"
  default     = "10.0.5.0/24"
}

variable "vpn_gtw_address_space" {
  type        = string
  default     = "10.0.255.0/27"
  description = "Address space for the VPN gateway subnet"
}

variable "aks_address_space" {
  type        = string
  default     = "10.0.2.0/24"
  description = "Address space for AKS subnet"
}

variable "db_address_space" {
  type        = string
  default     = "10.0.3.0/24"
  description = "Address space for PostgreSQL Flexible server subnet"
}

variable "app_address_space" {
  type        = string
  default     = "10.0.4.0/24"
  description = "Address space for application subnet"
}

variable "aks_internal_address_space" {
  type        = string
  default     = "10.2.0.0/24"
  description = "Service CIDR for AKS"
}

variable "vpn_client_address_space" {
  type        = string
  default     = "10.3.0.0/24"
  description = "Address space for VPN clients"
}

variable "node_count" {
  type        = number
  description = "The number of nodes to create for the k8s cluster"
  default     = 2
}

variable "vm_size" {
  type        = string
  description = "The Azure vm size of the nodes"
  default     = "Standard_DS2_v2"
}

variable "hans_id" {
  type        = string
  description = "Hans ID"
  default     = "76cb3772-2153-472a-9229-e138ada1729c"
}
