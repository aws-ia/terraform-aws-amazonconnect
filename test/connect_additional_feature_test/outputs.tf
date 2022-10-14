/*
The security profile is excluded from the outputs as go lang was unable to parse the map object output from
security profile as it contains list and was throwing the error "Type switching to map[string]interface{} failed."
*/

output "amazon_connect" {
  value       = { for k, v in module.amazon_connect : k => v if !contains(["users", "security_profiles"], k) }
  description = "Amazon Connect module outputs"
}
