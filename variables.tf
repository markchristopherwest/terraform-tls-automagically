variable "organization_name" {
  description = "The name of the organization to associate with the certificates (e.g. Acme Co)."
  type        = string
  default     = "Foo Org"
}

variable "common_name_ca" {
  description = "Label used in the intermediate/leaf subject CNs (e.g. acme.co)."
  type        = string
  default     = "markchristopherwest"
}

variable "user" {
  description = "Operator/identity label used to namespace the PKI. When null, falls back to externals/external-user.sh (whoami). Set this explicitly in CI so the chain isn't keyed to whoever runs the plan."
  type        = string
  default     = null
}

variable "product_manifest" {
  description = "Map of product name => port; one leaf cert is issued per key."
  type        = map(string)
  default = {
    "boundary" = "9200"
    "consul"   = "8500"
    "nomad"    = "4646"
    "tfe"      = "443"
    "vault"    = "8200"
    "waypoint" = "9782"
  }
}

# CA usages only. server_auth/client_auth/timestamping on a CA is wrong and
# strict validators reject mixed-purpose CAs.
variable "allowed_uses_ca_root" {
  description = "Key usages for the root CA certificate."
  type        = list(string)
  default = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

variable "allowed_uses_ca_int" {
  description = "Key usages for the intermediate CA certificate."
  type        = list(string)
  default = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

# Leaf usages only. cert_signing/crl_signing/ocsp_signing on a server cert is
# a misissuance — anything holding that key could mint certs.
variable "allowed_uses_server" {
  description = "Key usages for server (leaf) certificates."
  type        = list(string)
  default = [
    "digital_signature",
    "key_encipherment",
    "key_agreement",
    "server_auth",
    "client_auth",
  ]
}

variable "dns_names" {
  description = "List of DNS SANs for the server certificates."
  type        = list(string)
  default = [
    "localhost",
  ]
}

variable "ip_addresses" {
  description = "List of IP SANs for the server certificates."
  type        = list(string)
  default = [
    "127.0.0.1",
  ]
}

# Tiered validity: root >= intermediate >= leaf, enforced by preconditions in
# main.tf. var.validity_period_hours keeps its original name/meaning (leaf
# validity) so existing callers don't break.
variable "validity_period_hours" {
  description = "Validity of the server (leaf) certificates, in hours."
  type        = number
  default     = 8760 # 1 year
}

variable "validity_period_hours_int" {
  description = "Validity of the intermediate CA certificate, in hours."
  type        = number
  default     = 43800 # 5 years
}

variable "validity_period_hours_root" {
  description = "Validity of the root CA certificate, in hours."
  type        = number
  default     = 87600 # 10 years
}

variable "early_renewal_hours_server" {
  description = "Terraform plans replacement of leaf certs this many hours before expiry."
  type        = number
  default     = 720 # 30 days
}

variable "early_renewal_hours_ca" {
  description = "Terraform plans replacement of CA certs this many hours before expiry."
  type        = number
  default     = 2160 # 90 days
}

variable "private_key_algorithm" {
  description = "Private key algorithm. One of: RSA, ECDSA, ED25519."
  type        = string
  default     = "RSA"

  validation {
    condition     = contains(["RSA", "ECDSA", "ED25519"], var.private_key_algorithm)
    error_message = "Must be one of RSA, ECDSA, ED25519."
  }
}

variable "private_key_ecdsa_curve" {
  description = "Elliptic curve when algorithm is ECDSA. One of P224, P256, P384, P521."
  type        = string
  default     = "P256"
}

variable "private_key_rsa_bits" {
  description = "RSA key size in bits when algorithm is RSA."
  type        = number # was string; worked only via implicit conversion
  default     = 4096
}

variable "tags" {
  description = "Resource tags (unused by tls_* resources; retained for caller interface compatibility)."
  type        = map(string)
  default     = {}
}
