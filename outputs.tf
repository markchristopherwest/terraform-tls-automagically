output "content_tls_ca_crt" {
  description = "Root CA certificate (distribute this as the trust anchor)."
  value       = tls_self_signed_cert.ca_root_crt.cert_pem
}

output "content_tls_ca_key" {
  description = "Root CA private key. Offline-root pattern: export this, store it cold, and keep this state file encrypted/isolated — the key is in state."
  value       = tls_private_key.ca_root_key.private_key_pem
  sensitive   = true
}

output "content_tls_int_crt" {
  description = "Intermediate CA certificate."
  value       = tls_locally_signed_cert.int_crt.cert_pem
}

output "content_tls_int_csr" {
  description = "Intermediate CA certificate signing request."
  value       = tls_cert_request.int_csr.cert_request_pem
}

output "content_tls_int_key" {
  description = "Intermediate CA private key."
  value       = tls_private_key.int_key.private_key_pem
  sensitive   = true
}

# NEW: with an offline root, clients trust only the root — servers must
# present leaf + intermediate. This is the value that goes in e.g. Vault's
# tls_cert_file; the bare leaf in content_tls_server_crt will not validate.
output "content_tls_chain" {
  description = "Per-product full presentation chain: leaf + intermediate."
  value = {
    for k, v in tls_locally_signed_cert.server_crt :
    k => "${v.cert_pem}${tls_locally_signed_cert.int_crt.cert_pem}"
  }
}

# NEW: intermediate + root, for trust stores that want the issuing chain
# (e.g. Vault tls_client_ca_file, curl --cacert).
output "content_tls_ca_chain" {
  description = "Issuing chain: intermediate + root."
  value       = "${tls_locally_signed_cert.int_crt.cert_pem}${tls_self_signed_cert.ca_root_crt.cert_pem}"
}

output "content_tls_server_crt" {
  description = "Server (leaf) certificates only — see content_tls_chain for what servers should actually present."
  value       = { for k, v in tls_locally_signed_cert.server_crt : k => v.cert_pem }
}

output "content_tls_server_csr" {
  description = "Server certificate signing requests."
  value       = { for k, v in tls_cert_request.server_csr : k => v.cert_request_pem }
}

output "content_tls_server_key" {
  description = "Server private keys."
  value       = { for k, v in tls_private_key.server_key : k => v.private_key_pem }
  sensitive   = true
}
