# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-mini-finance"
  location = var.location
}

# 2. Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-finance"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 3. Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-finance"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. Network Security Group (Ports 22 and 80)
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-finance"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# 5. Public IP
resource "azurerm_public_ip" "pip" {
  name                = "pip-finance"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 6. Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "nic-finance"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# 7. Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                            = "vm-finance"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = var.vm_size
  admin_username                  = var.admin_user
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
  username   = var.admin_user
  public_key = file(var.ssh_public_key_path)
}

  os_disk {
    name                 = "osdisk-finance"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# 8. Output
output "public_ip" {
  description = "The public IP of the Mini Finance VM"
  value       = azurerm_linux_virtual_machine.main.public_ip_address
}
