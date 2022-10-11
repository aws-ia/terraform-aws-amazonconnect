locals {
  routing_profiles = {
    sales = {
      description               = "Routing profile for Sales"
      default_outbound_queue_id = data.aws_connect_queue.example.queue_id

      media_concurrencies = [
        {
          channel     = "VOICE"
          concurrency = 1 // Always 1 for Voice
        },
        {
          channel     = "CHAT"
          concurrency = 2 // between 1 and 5
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
