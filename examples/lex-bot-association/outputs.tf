output "amazon_connect" {
  value = { for k, v in module.amazon_connect : k => v if k != "users" }
}
