data "external" "user" {
  program = ["${path.module}/externals/external-user.sh"]
}

# ---------------------------------------------------------------------------------------------------------------------
#  CREATE A CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "ca_root_key" {
  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits
}


resource "tls_self_signed_cert" "ca_root_crt" {
  private_key_pem   = tls_private_key.ca_root_key.private_key_pem
  is_ca_certificate = true

  validity_period_hours = var.validity_period_hours
  allowed_uses          = var.allowed_uses_ca_root

  subject {
    common_name  = "${data.external.user.result["user"]}.local"
    organization = var.organization_name
  }

}


# ---------------------------------------------------------------------------------------------------------------------
#  CREATE A INT CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "int_key" {
  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits
}

resource "tls_cert_request" "int_csr" {
  private_key_pem = tls_private_key.int_key.private_key_pem


  subject {
    common_name  = "${var.common_name_ca}.${data.external.user.result["user"]}.local"
    organization = var.organization_name
  }
}

resource "tls_locally_signed_cert" "int_crt" {
  cert_request_pem   = tls_cert_request.int_csr.cert_request_pem
  ca_private_key_pem = tls_self_signed_cert.ca_root_crt.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_root_crt.cert_pem

  is_ca_certificate = true

  validity_period_hours = 12

  allowed_uses = var.allowed_uses_ca_int
}

# ---------------------------------------------------------------------------------------------------------------------
#  CREATE A SERVER CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------


resource "tls_private_key" "server_key" {
  for_each    = var.product_manifest
  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits

}

resource "tls_cert_request" "server_crt" {
  for_each        = var.product_manifest
  private_key_pem = tls_private_key.server_key[each.key].private_key_pem

  dns_names    = var.dns_names
  ip_addresses = var.ip_addresses

  subject {
    common_name  = "server-${each.key}.${var.common_name_ca}.${data.external.user.result["user"]}.local"
    organization = data.external.user.result["user"]
  }

}

resource "tls_locally_signed_cert" "server_crt" {
  for_each         = var.product_manifest
  cert_request_pem = tls_cert_request.server_crt[each.key].cert_request_pem

  ca_private_key_pem = tls_private_key.int_key.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.int_crt.cert_pem

  validity_period_hours = var.validity_period_hours
  allowed_uses          = var.allowed_uses_server

}
