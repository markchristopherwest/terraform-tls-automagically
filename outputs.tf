output "file_tls_ca_crt" {
  value = local_file.ca_crt.filename
}

output "content_tls_ca_crt" {
  value = tls_self_signed_cert.ca_crt.cert_pem
}

output "file_tls_ca_key" {
  value = tls_private_key.ca_key.private_key_pem
}

output "content_tls_ca_key" {
  value = local_file.ca_key.content
}

output "file_tls_server_crt" {
  value = "${zipmap(keys(var.product_manifest)[*], values(local_file.server_crt)[*].filename)}"
}

output "content_tls_server_crt" {
  value = "${zipmap(keys(var.product_manifest)[*], values(local_file.server_crt)[*].content)}"
}

output "file_tls_server_key" {
  value = "${zipmap(keys(var.product_manifest)[*], values(local_file.server_key)[*].filename)}"
}


output "content_tls_server_key" {
  value = "${zipmap(keys(var.product_manifest)[*], values(local_file.server_key)[*].content)}"

}




# output "ca_public_key_file_path" {
#   value = var.ca_public_key_file_path
# }

# output "public_key_file_path" {
#   value = var.public_key_file_path
# }

# output "private_key_file_path" {
#   value = var.private_key_file_path
# }

