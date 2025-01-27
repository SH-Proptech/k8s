resource "azurerm_resource_group" "default" {
  name     = "${var.prefix}_rg"
  location = var.location
}

# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = [var.vnet_address_space] # Ensure it doesn't overlap with VPN client's address pool
}

# DNS Subnet (for Private DNS)
resource "azurerm_subnet" "dns_subnet" {
  name                 = "${var.prefix}-dns-subnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.dns_address_space] # Ensure this doesn't overlap with your existing subnets

  delegation {
    name = "Microsoft.Network/dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}

# Gateway Subnet (for VPN Gateway)
resource "azurerm_subnet" "vpn_gtw_subnet" {
  name                 = "GatewaySubnet" # Azure requires the VPN Gateway to be placed in a subnet specifically named GatewaySubnet
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vpn_gtw_address_space] # Specific subnet required for VPN Gateway
}

# AKS Subnet (for AKS worker nodes)
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.prefix}-aks-subnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.aks_address_space]                              # AKS nodes subnet, adjust size based on scale
  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.Storage"] # Enable service endpoint for AKS
}

# PostgreSQL Subnet (for PostgreSQL Flexible server)
resource "azurerm_subnet" "db_subnet" {
  name                 = "${var.prefix}-db-subnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.db_address_space]

  delegation {
    name = "db-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Application Subnet (for app services or other workloads)
resource "azurerm_subnet" "app_subnet" {
  name                 = "${var.prefix}-app-subnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.app_address_space] # General purpose for other workloads
}

# Create Network Security Group for AKS
resource "azurerm_network_security_group" "aks-nsg" {
  name                = "${var.prefix}-aks-nsg"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  # Allow outbound traffic to AKS
  security_rule {
    name                       = "AllowVnetInBound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443" # Kubernetes API port
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Allow outbound traffic to Azure services especially DNS
  security_rule {
    name                       = "AllowOutboundDNS"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp" # Add TCP as well if necessary
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with AKS Subnet
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks-nsg.id
}


