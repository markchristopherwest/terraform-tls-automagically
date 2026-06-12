# Operator identity used to namespace the PKI. Overridable via var.user so CI /
# other operators don't silently force a full chain rotation (the external data
# source re-evaluates every plan and the subject CN feeds every cert).
data "external" "user" {
  count   = var.user == null ? 1 : 0
  program = ["${path.module}/externals/external-user.sh"]
}

locals {
  user = var.user != null ? var.user : data.external.user[0].result["user"]
}

# ---------------------------------------------------------------------------------------------------------------------
# ROOT CA (offline pattern: key touches state once, only ever signs the intermediate)
# ---------------------------------------------------------------------------------------------------------------------
resource "tls_private_key" "ca_root_key" {
  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits
}

resource "tls_self_signed_cert" "ca_root_crt" {
  private_key_pem       = tls_private_key.ca_root_key.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = var.validity_period_hours_root
  early_renewal_hours   = var.early_renewal_hours_ca
  allowed_uses          = var.allowed_uses_ca_root
  # SKI/AKI matching is how Go x509, Java, and Vault's own client-cert
  # verification build the chain; without it some validators fail even
  # when the signature math checks out.
  set_subject_key_id = true

  subject {
    common_name  = "${local.user}.local"
    organization = var.organization_name
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# INTERMEDIATE CA
# ---------------------------------------------------------------------------------------------------------------------
resource "tls_private_key" "int_key" {
  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits
}

resource "tls_cert_request" "int_csr" {
  private_key_pem = tls_private_key.int_key.private_key_pem

  subject {
    common_name  = "${var.common_name_ca}.${local.user}.local"
    organization = var.organization_name
  }
}

resource "tls_locally_signed_cert" "int_crt" {
  cert_request_pem = tls_cert_request.int_csr.cert_request_pem
  # BUG FIX: was tls_self_signed_cert.ca_root_crt.private_key_pem — echoing an
  # input back through the cert resource. Sign with the key resource directly.
  ca_private_key_pem = tls_private_key.ca_root_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_root_crt.cert_pem
  is_ca_certificate  = true
  # BUG FIX: was hardcoded 12h while leaves got var.validity_period_hours
  # (87600h) — every leaf outlived its issuer and the chain died after 12h.
  validity_period_hours = var.validity_period_hours_int
  early_renewal_hours   = var.early_renewal_hours_ca
  allowed_uses          = var.allowed_uses_ca_int
  set_subject_key_id    = true

  lifecycle {
    precondition {
      condition     = var.validity_period_hours_int <= var.validity_period_hours_root
      error_message = "Intermediate validity must not exceed root validity."
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# SERVER (LEAF) CERTIFICATES — one per product
# ---------------------------------------------------------------------------------------------------------------------
resource "tls_private_key" "server_key" {
  for_each    = var.product_manifest
  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits
}

# Renamed from tls_cert_request.server_crt — it's a CSR, not a cert.
moved {
  from = tls_cert_request.server_crt
  to   = tls_cert_request.server_csr
}

resource "tls_cert_request" "server_csr" {
  for_each        = var.product_manifest
  private_key_pem = tls_private_key.server_key[each.key].private_key_pem
  dns_names       = var.dns_names
  ip_addresses    = var.ip_addresses

  subject {
    common_name  = "server-${each.key}.${var.common_name_ca}.${local.user}.local"
    organization = var.organization_name
  }
}

resource "tls_locally_signed_cert" "server_crt" {
  for_each              = var.product_manifest
  cert_request_pem      = tls_cert_request.server_csr[each.key].cert_request_pem
  ca_private_key_pem    = tls_private_key.int_key.private_key_pem
  ca_cert_pem           = tls_locally_signed_cert.int_crt.cert_pem
  validity_period_hours = var.validity_period_hours
  early_renewal_hours   = var.early_renewal_hours_server
  allowed_uses          = var.allowed_uses_server
  set_subject_key_id    = true

  lifecycle {
    precondition {
      condition     = var.validity_period_hours <= var.validity_period_hours_int
      error_message = "Leaf validity must not exceed intermediate validity, or the chain expires before the leaf does."
    }
  }
}
