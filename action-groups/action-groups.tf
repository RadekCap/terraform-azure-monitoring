resource "azurerm_resource_group" "action_group_resource_group" {
  name     = "action-groups"
  location = "West Europe"

  tags {
    environment = "ScriptingTesting"
  }
}

resource "azurerm_monitor_action_group" "sample_action_group" {
  name                = "monitoring"
  resource_group_name = "${azurerm_resource_group.action_group_resource_group.name}"
  short_name          = "mon"

  email_receiver {
    name          = "send-to-monitoring-team"
    email_address = "email@email.com"
  }
}