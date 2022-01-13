terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.12.26"
}




# ---------------------------------------------------------------------------------------------------------------------
#  CREATE A CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "ca_key" {
  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits
}


resource "local_file" "ca_key" {
  content  = tls_private_key.ca_key.private_key_pem
  filename = "${var.path_tls}/${var.ca_common_name}.key.pem"
}

resource "tls_self_signed_cert" "ca_crt" {
  key_algorithm     = tls_private_key.ca_key.algorithm
  private_key_pem   = tls_private_key.ca_key.private_key_pem
  is_ca_certificate = true

  validity_period_hours = var.validity_period_hours
  allowed_uses          = var.ca_allowed_uses

  subject {
    common_name  = var.ca_common_name
    organization = var.organization_name
  }

}

resource "local_file" "ca_crt" {
  content  = tls_self_signed_cert.ca_crt.cert_pem
  filename = "${var.path_tls}/${var.ca_common_name}.crt.pem"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A TLS CERTIFICATE SIGNED USING THE CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "server_key" {
  for_each    = var.product_manifest
  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits

}

resource "local_file" "server_key" {
  for_each = var.product_manifest
  content  = tls_private_key.server_key[each.key].private_key_pem
  filename = "${var.path_tls}/${each.key}.${var.ca_common_name}.key.pem"
}

resource "tls_cert_request" "server_crt" {
  for_each        = var.product_manifest
  key_algorithm   = tls_private_key.server_key[each.key].algorithm
  private_key_pem = tls_private_key.server_key[each.key].private_key_pem

  dns_names    = var.dns_names
  ip_addresses = var.ip_addresses

  subject {
    common_name  = "${each.key}.${var.ca_common_name}"
    organization = var.organization_name
  }

}

resource "tls_locally_signed_cert" "server_crt" {
  for_each         = var.product_manifest
  cert_request_pem = tls_cert_request.server_crt[each.key].cert_request_pem

  ca_key_algorithm   = tls_private_key.ca_key.algorithm
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_crt.cert_pem

  validity_period_hours = var.validity_period_hours
  allowed_uses          = var.allowed_uses

}


resource "local_file" "server_crt" {
  for_each = var.product_manifest
  content  = tls_locally_signed_cert.server_crt[each.key].cert_pem
  filename = "${var.path_tls}/${each.key}.${var.ca_common_name}.crt.pem"

}

