resource "azurerm_resource_group" "rg" {
  for_each = var.vm_name
  name     = "${each.value}-ResourceGroup"
  location = var.resource_group_location
  
}

# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  for_each            = var.vm_name
  name                = "${each.value}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  for_each             = var.vm_name
  name                 = "${each.value}-subnet"
  resource_group_name  = azurerm_resource_group.rg[each.key].name
  virtual_network_name = azurerm_virtual_network.my_terraform_network[each.key].name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  for_each = var.vm_name
  name                = "${each.value}-PublicIP"
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  for_each = var.vm_name
  name                = "${each.value}-NetworkSecurityGroup"
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name
# Note that this rule will allow all external connections from internet to SSH port
  
  security_rule {
    name                       = "RDP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  for_each            = var.vm_name
  name                = "${each.value}-myNIC"
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  ip_configuration {
    name                          = "${each.value}-nic-configuration"
    subnet_id                     = azurerm_subnet.my_terraform_subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip[each.key].id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "my-nsg-assoc" {
  for_each = var.vm_name
  network_interface_id      = azurerm_network_interface.my_terraform_nic[each.key].id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg[each.key].id
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "my_terraform_vm" {
  for_each = var.vm_name
  name    = "${each.value}-VM"
  location              = azurerm_resource_group.rg[each.key].location
  resource_group_name   = azurerm_resource_group.rg[each.key].name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic[each.key].id]
  size                  = "Standard_DS1_v2"
  computer_name                   = "${each.value}-vm"
  admin_username                  = "secureadmin"
  admin_password                  = "SecureP@ssw0rd!"
  
  os_disk {
    name                 = "${each.value}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-Datacenter"
    version   = "latest"
  }

  
}