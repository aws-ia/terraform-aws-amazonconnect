locals {
  users = {
    sales_agent = {
      password             = "SomeSecurePassword!1234" # Recommended to be passed in through variables if used
      hierarchy_group_id   = try(module.amazon_connect.user_hierarchy_groups["child"].hierarchy_group_id, null)
      routing_profile_id   = try(module.amazon_connect.routing_profiles["sales"].routing_profile_id, null)
      security_profile_ids = try([module.amazon_connect.security_profiles["example"].security_profile_id], [])

      identity_info = {
        email      = "sales@example.com"
        first_name = "Sales"
        last_name  = "Agent"
      }

      phone_config = {
        phone_type                    = "SOFT_PHONE"
        after_contact_work_time_limit = 5
        auto_accept                   = false
      }
    }
  }

  user_hierarchy_groups = {
    child = {
      parent_group_id = try(module.amazon_connect_parent_group.user_hierarchy_groups["parent"].hierarchy_group_id, null)
    }
  }

  user_hierarchy_structure = {
    level_one = "level-1"
    level_two = "level-2"
  }
}
