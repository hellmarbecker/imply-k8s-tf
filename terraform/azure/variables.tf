variable "client_id" {}
variable "client_secret" {}

variable "agent_count" {
    default = 7
}

variable "ssh_public_key" {
    default = "~/keys/<AZURE PUBLIC KEY>.pub"
}

variable "dns_prefix" {
    default = "imply"
}

variable cluster_name {
    default = "imply-cluster"
}

variable resource_group_name {
    default = "azure-imply"
}

variable location {
    default = "germanywestcentral"
}

variable cprovider {
    default = "azure"
}

#variable log_analytics_workspace_name {
#    default = "implyLogAnalyticsWorkspaceName"
#}

## refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
#variable log_analytics_workspace_location {
#    default = "westcentral"
#}

## refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
#variable log_analytics_workspace_sku {
#    default = "PerGB2018"
#}
