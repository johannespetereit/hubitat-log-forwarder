variable "subscription_id" {
  type = string
}
variable "tenant_id" {
  type = string
}
variable "appi" {
  type = object({
    name = string
    location = string
    resource_group_name = string
    retention_in_days = number
  })
}