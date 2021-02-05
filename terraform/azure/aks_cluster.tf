# Resource Group details
resource "azurerm_resource_group" "imply-rg" {
    name     = var.resource_group_name
    location = var.location
}
#resource "azurerm_network_security_group" "imply_sec_gp" {
#  name                = "imply_sec_gp"
#  location            = var.location
#  resource_group_name = var.resource_group_name
#}

#Create virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "${var.dns_prefix}-${var.location}"
    address_space       = var.vnet_address_space
    location            = azurerm_resource_group.imply-rg.location
    resource_group_name = azurerm_resource_group.imply-rg.name
}

# MySql server
resource "azurerm_mysql_server" "imply" {
  name                = "imply"
  location            = azurerm_resource_group.imply-rg.location
  resource_group_name = azurerm_resource_group.imply-rg.name

  administrator_login          = "imply"
  administrator_login_password = "Qwerty123!"

  sku_name   = "B_Gen5_1"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  #ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_configuration" "imply_sql_config" {
  name                = "time_zone"
  resource_group_name = azurerm_resource_group.imply-rg.name
  server_name         = azurerm_mysql_server.imply.name
  value               = "+00:00"
}

resource "azurerm_mysql_firewall_rule" "imply_mysql_access" {
  name                = "office"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.imply.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
resource "azurerm_storage_account" "imply" {
  name                     = "imply"
  resource_group_name      = azurerm_resource_group.imply-rg.name
  location                 = azurerm_resource_group.imply-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "imply"
  }
}

resource "azurerm_storage_container" "druid" {
  name                  = "druid"
  storage_account_name  = azurerm_storage_account.imply.name
  container_access_type = "private"
}

resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}



resource "azurerm_kubernetes_cluster" "imply" {
    name                = var.cluster_name
    location            = azurerm_resource_group.imply-rg.location
    resource_group_name = azurerm_resource_group.imply-rg.name
    dns_prefix          = var.dns_prefix

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
        name            = "agentpool"
        node_count      = var.agent_count
        vm_size         = "Standard_D2a_v4"
    }

    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }


    addon_profile {
    kube_dashboard {
      enabled = true
    }
  }

    network_profile {
    load_balancer_sku = "Standard"
    network_plugin = "kubenet"
    }

    tags = {
        Environment = "Development"
    }
}
