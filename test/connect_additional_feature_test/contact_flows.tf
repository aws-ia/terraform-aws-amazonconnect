locals {
  contact_flows = {
    inbound = {
      content = templatefile(
        "${path.module}/contact-flows/inbound.json.tftpl",
        {
          lambda_arn = aws_lambda_function.example.arn
        }
      )
    }
  }
  contact_flow_modules = {
    inbound = {
      filename     = "${path.module}/contact-flows/inboundflow.json.tftpl"
      content_hash = filebase64sha256("${path.module}/contact-flows/inboundflow.json.tftpl")
    }
  }
}
