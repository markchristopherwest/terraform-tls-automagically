

output "content_tls_ca_crt" {
  description = "CA Certificate for Root"
  value       = tls_self_signed_cert.ca_root_crt.cert_pem
}

output "content_tls_ca_key" {
  description = "CA Key for Root"
  value       = tls_private_key.ca_root_key.private_key_pem
  sensitive   = true
}

output "content_tls_int_crt" {
  description = "CA Certificate for Intermediate"
  value       = tls_locally_signed_cert.int_crt.cert_pem
}

output "content_tls_int_csr" {
  description = "CA Certificate Signing Request for Intermediate"
  value       = tls_cert_request.int_csr.cert_request_pem
}

output "content_tls_int_key" {
  description = "CA Key for Intermediate"
  value       = tls_private_key.int_key.private_key_pem
  sensitive   = true
}

output "content_tls_server_crt" {
  description = "Server Certificate"
  value       = zipmap(keys(var.product_manifest)[*], values(tls_locally_signed_cert.server_crt)[*].cert_pem)
}

output "content_tls_server_csr" {
  description = "Server Certificate Request"
  value       = zipmap(keys(var.product_manifest)[*], values(tls_cert_request.server_crt)[*].cert_request_pem)
}

output "content_tls_server_key" {
  description = "Server Key"
  value       = zipmap(keys(var.product_manifest)[*], values(tls_private_key.server_key)[*].private_key_pem)
  sensitive   = true
}

