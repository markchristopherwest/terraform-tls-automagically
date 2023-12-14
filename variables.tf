# variable "owner" {
#   description = "The OS user who should be given ownership over the certificate files."
#   type        = string
#   default     = "Foo Owner"
# }

variable "organization_name" {
  description = "The name of the organization to associate with the certificates (e.g. Acme Co)."
  type        = string
  default     = "Foo Org"
}

variable "common_name_ca" {
  description = "The common name to use in the subject of the CA certificate (e.g. acme.co cert)."
  type        = string
  default     = "markchristopherwest"
}

variable "common_name_int" {
  description = "The common name to use in the subject of the Intermediate certificate (e.g. username.acme.co cert)."
  type        = string
  default     = "foo"
}

variable "product_manifest" {
  type = map(any)
  default = {
    "boundary" = "9200"
    "consul"   = "8500"
    "nomad"    = "4646"
    "tfe"      = "443"
    "vault"    = "8200"
    "waypoint" = "9782"
  }
}


variable "allowed_uses_ca_root" {
  description = "List of uses for the CA Crt"
  type        = list(string)

  default = [
    "client_auth",
    "cert_signing",
    "crl_signing",
    "data_encipherment",
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "ocsp_signing",
    "server_auth",
    "timestamping",
  ]
}

variable "allowed_uses_ca_int" {
  description = "List of uses for the Int Crt"
  type        = list(string)

  default = [
    "client_auth",
    "cert_signing",
    "crl_signing",
    "data_encipherment",
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "ocsp_signing",
    "server_auth",
    "timestamping",
  ]
}

variable "allowed_uses_server" {
  description = "List of uses for the Server Crt"
  type        = list(string)

  default = [
    "client_auth",
    "cert_signing",
    "crl_signing",
    "data_encipherment",
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "ocsp_signing",
    "server_auth",
    "timestamping",
  ]
}

variable "dns_names" {
  description = "List of DNS names for which the certificate will be valid (e.g. vault.service.consul, foo.example.com)."
  type        = list(string)
  default = [
    "localhost",
    "*.ec2.internal",
    "*.amazonaws.com"
  ]
}

variable "ip_addresses" {
  description = "List of IP addresses for which the certificate will be valid (e.g. 127.0.0.1)."
  type        = list(string)
  default = [
    "127.0.0.1"
  ]
}

variable "validity_period_hours" {
  description = "The number of hours after initial issuing that the certificate will become invalid."
  type        = number
  default     = 87600
}

variable "permissions" {
  description = "The Unix file permission to assign to the cert files (e.g. 0600)."
  type        = string
  default     = "0600"
}

variable "private_key_algorithm" {
  description = "The name of the algorithm to use for private keys. Must be one of: RSA or ECDSA."
  type        = string
  default     = "RSA"
}

variable "private_key_ecdsa_curve" {
  description = "The name of the elliptic curve to use. Should only be used if var.private_key_algorithm is ECDSA. Must be one of P224, P256, P384 or P521."
  type        = string
  default     = "P256"
}

variable "private_key_rsa_bits" {
  description = "The size of the generated RSA key in bits. Should only be used if var.private_key_algorithm is RSA."
  type        = string
  default     = "4096"
}

variable "service_map" {
  description = "Map of project names to configuration."
  type        = map(any)
  default = {
    client-webapp = {
      public_subnets_per_vpc  = 2,
      private_subnets_per_vpc = 2,
      instances_per_subnet    = 2,
      instance_type           = "t2.micro",
      environment             = "dev"
    },
    internal-webapp = {
      public_subnets_per_vpc  = 1,
      private_subnets_per_vpc = 1,
      instances_per_subnet    = 2,
      instance_type           = "t2.nano",
      environment             = "test"
    }
  }
}

variable "tags" {
  default     = {}
  description = "Resource tags"
  type        = map(string)
}
