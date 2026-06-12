terraform {
  # preconditions + optional() require >= 1.3
  required_version = ">= 1.3.0"

  required_providers {
    # Code is v4-style: no key_algorithm on tls_locally_signed_cert,
    # set_subject_key_id on cert resources. v3 will not plan.
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0, < 5.0.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.2.0"
    }
  }
}
