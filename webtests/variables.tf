variable "enabled" {
  description = "Is the test actively being monitored."
  default     = "true"
}

variable "expected_http_status_code" {
  description = "Expected HTTP response status code."
  default     = 200
}

variable "request_method" {
  description = "Requests method, default is GET."
  default     = "GET"
}

variable "credential_username" {
  default = ""
}

variable "credential_password" {
  default = ""
}

variable "timeout" {
  description = "Seconds until this WebTest will timeout and fail. Default value is 30."
  default     = 60
}

variable "send_to_service_owners" {
  description = "Send alert for webtests to subscription admins."
  default = "true"
}

variable "test_locations" {
  description = "A list of where to physically run the tests from to give global coverage for accessibility of your application."
  default     = "us-il-ch1-azr,emea-nl-ams-azr,emea-se-sto-edge"
}

variable "frequency" {
  description = "Interval in seconds between test runs for this WebTest. Default value is 300."
  default     = 120
}

variable "custom_emails" {
  description = "Emails"
  default = "mail@gmail.com,mail@mail.com"
}