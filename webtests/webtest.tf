locals {
  webtests = [
    {
      name = "google-web-availability"
      url  = "https://www.google.com"
    },
    {
      name = "opensource-web-availability"
      url  = "http://opensource.com/"
    },
  ]

  location = "West Europe"
  resource_group_name = "webtests"
}

resource "azurerm_resource_group" "monitoring_resource_group" {
  name     = "${local.resource_group_name}"
  location = "${local.location}"

  tags {
    environment = "ScriptingTesting"
  }
}

resource "azurerm_application_insights" "test" {
  name                = "monitoring"
  location            = "${local.location}"
  resource_group_name = "${azurerm_resource_group.monitoring_resource_group.name}"
  application_type    = "Web"
}

resource "random_uuid" "random_uuid" {
  count = "${length(local.webtests)}"
}

data "template_file" "webtest" {
  count = "${length(local.webtests)}"

  template = <<EOF
<WebTest Name="$${name}" Id="$${id}" Enabled="$${enabled}" CssProjectStructure="" CssIteration="" Timeout="$${timeout}" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="$${credentialUserName}" CredentialPassword="$${credentialPassword}" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale=""><Items><Request Method="$${requestMethod}" Guid="$${guid}" Version="1.1" Url="$${requestURL}" ThinkTime="0" Timeout="$${timeout}" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="$${expectedHttpStatusCode}" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" /></Items></WebTest>
EOF

  vars {
    name                   = "${lookup(local.webtests[count.index], "name")}"
    id                     = "${element(random_uuid.random_uuid.*.id, count.index)}"
    enabled                = "${var.enabled}"
    timeout                = "${var.timeout}"
    credentialUserName     = "${var.credential_username}"
    credentialPassword     = "${var.credential_password}"
    requestMethod          = "${var.request_method}"
    guid                   = "${element(random_uuid.random_uuid.*.id, count.index)}"
    requestURL             = "${lookup(local.webtests[count.index], "url")}"
    expectedHttpStatusCode = "${var.expected_http_status_code}"
  }
}

resource "azurerm_template_deployment" "webtest" {
  count               = "${length(local.webtests)}"
  name                = "${format("%s-arm-webtest", lookup(local.webtests[count.index], "name"))}"
  resource_group_name = "${azurerm_resource_group.monitoring_resource_group.name}"
  deployment_mode     = "Incremental"
  template_body       = "${file("${path.module}/webtest.json")}"

  parameters {
    name                   = "${lookup(local.webtests[count.index], "name")}"
    appInsightsName        = "${azurerm_application_insights.test.name}"
    appInsightsLocation    = "${local.location}"
    testLocations          = "${var.test_locations}"
    timeout                = "${var.timeout}"
    frequency              = "${var.frequency}"
    enabled                = "${var.enabled}"
    webTest                = "${data.template_file.webtest.*.rendered[count.index]}"
    customEmails           = "${var.custom_emails}"
    send_to_service_owners = "${var.send_to_service_owners}"
    concat_name            = "${lookup(local.webtests[count.index], "name")}-${azurerm_application_insights.test.name}"
  }
}
