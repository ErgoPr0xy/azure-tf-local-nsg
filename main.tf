
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.49.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# create resource group for the k8s cluster
resource "azurerm_resource_group" "cluster-rg" {
  name = "cluster-example-rg"
  location = "westeurope"
}

# create vnet (you can create a separate rg for this if you'd like)
resource "azurerm_virtual_network" "example-vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.cluster-rg.location
  resource_group_name = azurerm_resource_group.cluster-rg.name
  address_space       = ["10.10.0.0/16"]
}

# create subnet used in cluster
resource "azurerm_subnet" "example-subnet" {
  name                 = "default"
  virtual_network_name = azurerm_virtual_network.example-vnet.name
  resource_group_name  = azurerm_resource_group.cluster-rg.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "nsg-example" {
  name                = "nsg-example"
  resource_group_name = azurerm_resource_group.cluster-rg.name
  location            = "westeurope" 
}

data "azurerm_resources" "example" {
  resource_group_name = azurerm_kubernetes_cluster.k8s-dev.node_resource_group

  type = "Microsoft.Network/networkSecurityGroups"
}

output name_nsg {
    value = data.azurerm_resources.example.resources.0.name
}

resource "azurerm_network_security_rule" "example" {
  name                        = "example"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "8.8.8.8"
  destination_address_prefix  = "10.10.0.1"
  resource_group_name         = azurerm_kubernetes_cluster.k8s-dev.node_resource_group
  network_security_group_name = data.azurerm_resources.example.resources.0.name
}

resource "azurerm_kubernetes_cluster" "k8s-dev" {
  name                = "${var.prefix}-weu"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.cluster-rg.name
  dns_prefix          = "${var.prefix}-weu"
  sku_tier            = "Paid" 

    service_principal {
        client_id     = azuread_service_principal.examplesp-app.application_id
        client_secret = var.password
    }
    
    default_node_pool {
        name                = "devnodes"
	enable_auto_scaling = true
	max_count	    = 4
	min_count           = 3
        vm_size             = "Standard_B2s"
	type                = "VirtualMachineScaleSets"
        max_pods            = 30
        vnet_subnet_id      = azurerm_subnet.example-subnet.id
        os_disk_size_gb     = 30 
    }

    network_profile {
        network_plugin     = "azure"
        service_cidr       = "172.16.0.0/23"
        dns_service_ip     = "172.16.1.10"
        docker_bridge_cidr = "172.16.10.1/24"
        outbound_type      = "loadBalancer"
    }	

    role_based_access_control {
	    enabled = true
    }

    tags = {
        Environment = "Test" 
        Team        = "Dev"
        Location    = "West Europe"
    }
addon_profile {
    aci_connector_linux {
      enabled = false
    }

    azure_policy {
      enabled = false
    }

    http_application_routing {
      enabled = false
    }

    kube_dashboard {
      enabled = true
    }

    oms_agent {
      enabled = false
    }
  }
}

resource "azurerm_role_assignment" "examplesp-ra" {
  scope                = azurerm_subnet.example-subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.examplesp-app.object_id
}

resource "azuread_application" "display_name" {
  name                       = "examplesp-app"
  homepage                   = "http://examplesp"
  identifier_uris            = ["http://uri"]
  reply_urls                 = ["http://replyurl"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "examplesp-app" {
  application_id               = azuread_application.display_name.application_id
  app_role_assignment_required = false
}

resource "azuread_service_principal_password" "examplesp-pass" {
  service_principal_id = azuread_service_principal.examplesp-app.id
  description          = "My managed password"
  value                = var.password
  end_date             = "2050-01-01T01:02:03Z"
}




