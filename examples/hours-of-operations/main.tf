locals {
  time_zone = "EST"
  weekdays  = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY"]
  weekends  = ["SUNDAY", "SATURDAY"]
}

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

  # Hours of Operations
  hours_of_operations = {
    weekday = {
      description = "HOOP for weekdays"
      time_zone   = local.time_zone
      config = [
        for w in local.weekdays : {
          day = w
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
    weekend_with_lunch_break = {
      description = "HOOP for weekends with a lunch break"
      time_zone   = local.time_zone
      config = flatten([
        for w in local.weekends : [
          # Second loop, need two start/end times per day, with break in between
          # 9 AM - 12PM, 1 PM - 5 PM
          for t in [{ start = 9, end = 12 }, { start = 13, end = 17 }] : {
            day = w
            start_time = {
              hours   = t.start
              minutes = 0
            }
            end_time = {
              hours   = t.end
              minutes = 0
            }
          }
        ]
      ])
    }
  }
}
