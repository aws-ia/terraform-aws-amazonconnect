resource "random_string" "instance_alias" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

module "amazon_connect" {
  # source  = "aws-ia/amazonconnect/aws"
  # version = ">= 0.0.1"

  source = "../../"

  instance_identity_management_type = "CONNECT_MANAGED"
  instance_inbound_calls_enabled    = true
  instance_outbound_calls_enabled   = true
  instance_alias                    = random_string.instance_alias.result

  # Queues
  queues = {
    example = {
      hours_of_operation_id = try(module.amazon_connect.hours_of_operations["weekday"].hours_of_operation_id, null)
      max_contacts          = 5
    }
  }

  # Hours of Operations
  hours_of_operations = {
    weekday = {
      description = "HOOP for weekdays"
      time_zone   = "EST"
      config = [
        for d in ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY"] : {
          day = d
          start_time = {
            hours   = 8 # 8 AM
            minutes = 0
          }
          end_time = {
            hours   = 18 # 6 PM
            minutes = 0
          }
        }
      ]
    }
  }
}
