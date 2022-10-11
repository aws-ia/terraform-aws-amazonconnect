locals {
  routing_profiles = {
    sales = {
      description               = "Routing profile for Sales"
      default_outbound_queue_id = data.aws_connect_queue.example.queue_id

      media_concurrencies = [
        {
          channel     = "VOICE"
          concurrency = 1
        },
        {
          channel     = "CHAT"
          concurrency = 2
        }
      ]
    }
  }

  security_profiles = {
    example = {
      description = "Example security profile"

      permissions = [
        "BasicAgentAccess",
        "OutboundCallAccess",
      ]
    }
  }
}
