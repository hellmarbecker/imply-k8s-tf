variable "client_id" {
    default = "xxxx"
}
variable "client_secret" {
    default = "xxxx"
}

variable "agent_count" {
    default = 3
}

variable "ssh_public_key" {
    default = "/xxx.pub"
}

variable "dns_prefix" {
    default = "imply"
}

variable "vnet_address_space" {
    type = list
    description = "Address space for Virtual Network"
    default = ["10.0.0.0/16"]
}

variable cluster_name {
    default = "imply-cluster"
}

variable resource_group_name {
    default = "rdobson-rg"
}

variable location {
    default = "uksouth"
}

variable cprovider {
    default = "azure"
}
