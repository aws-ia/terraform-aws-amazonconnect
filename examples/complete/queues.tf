locals {
  queues = {
    sales = {
      hours_of_operation_id = try(module.amazon_connect.hours_of_operations["sales"].hours_of_operation_id, null)
      max_contacts          = 5
    }
    support = {
      hours_of_operation_id = try(module.amazon_connect.hours_of_operations["support"].hours_of_operation_id, null)
      max_contacts          = 9
    }
  }
}
