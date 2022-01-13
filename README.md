# TLS Automagically

```sh
# Step 1 : Generate your Certificates
module "tls_automagically" {
  source            = "../../modules/tls-automagically"
  product_manifest  = local.product_manifest
  path_tls          = "${path.module}/tls"
  owner             = "mark"
  organization_name = "${title(replace(local.pet_name.id, "_", " "))} Unlimited"
  ca_common_name    = "${replace(local.pet_name.id, "_", "-")}.local"

  target_regions = var.target_regions

  tags = local.standard_tags
}
```

