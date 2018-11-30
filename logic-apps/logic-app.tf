locals {
  logic_apps = [
    {
      name = "first-sample-logic-app",
      frequency = "Week",
      interval = 1
    },
    {
      name = "second-sample-logic-app",
      frequency = "Hour",
      interval = 10
    },
  ]

  location = "West Europe"
  resource_group_name = "webtests"
}

resource "azurerm_resource_group" "logic_apps_resource_group" {
  name     = "${local.resource_group_name}"
  location = "${local.location}"

  tags {
    environment = "ScriptingTesting"
  }
}

resource "azurerm_logic_app_workflow" "logic-app" {
  count               = "${length(local.logic_apps)}"
  name                = "${lookup(local.logic_apps[count.index], "name")}"
  location            = "${local.location}"
  resource_group_name = "${azurerm_resource_group.logic_apps_resource_group.name}"
}

resource "azurerm_logic_app_trigger_recurrence" "hourly_trigger" {
  count        = "${length(local.logic_apps)}"
  name         = "hourly-trigger"
  logic_app_id = "${azurerm_logic_app_workflow.logic-app.*.id[count.index]}"
  frequency    = "${lookup(local.logic_apps[count.index], "frequency")}"
  interval     = "${lookup(local.logic_apps[count.index], "interval")}"
}

resource "azurerm_logic_app_action_http" "http_action" {
  count        = "${length(local.logic_apps)}"
  name         = "clear-stale-objects"
  logic_app_id = "${azurerm_logic_app_workflow.logic-app.*.id[count.index]}"
  method       = "DELETE"
  uri          = "http://example.com/clear-stable-objects"
}
