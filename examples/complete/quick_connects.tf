locals {
  quick_connects = {
    phone_number = {
      quick_connect_config = {
        quick_connect_type = "PHONE_NUMBER"

        phone_config = {
          phone_number = "+18885551212"
        }
      }
    }
    queue = {
      quick_connect_config = {
        quick_connect_type = "QUEUE"

        queue_config = {
          contact_flow_id = try(module.amazon_connect.contact_flows["quick_connect"].contact_flow_id, null)
          queue_id        = try(module.amazon_connect.queues["sales"].queue_id, null)
        }
      }
    }
  }
}
