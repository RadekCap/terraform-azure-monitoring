locals {
  location = "West Europe"
}

resource "azurerm_resource_group" "classic_alerts_resource_group" {
  name     = "action-groups"
  location = "${local.location}"

  tags {
    environment = "ScriptingTesting"
  }
}

resource "azurerm_logic_app_workflow" "logic-app" {
  name                = "sample-logic-app"
  location            = "${local.location}"
  resource_group_name = "${azurerm_resource_group.classic_alerts_resource_group.name}"
}

resource "azurerm_metric_alertrule" "sample_classic_alert" {
  name                = "sample-classic-alert"
  location            = "${local.location}"
  resource_group_name = "${azurerm_resource_group.classic_alerts_resource_group.name}"

  description = "Alert for failed actions."

  resource_id = "${azurerm_logic_app_workflow.logic-app.id}"
  metric_name = "ActionsFailed"
  operator    = "GreaterThan"
  threshold   = 0.1
  aggregation = "Average"
  period      = "PT5M"

  email_action {
    custom_emails = ["email@email.com"]
  }
}
