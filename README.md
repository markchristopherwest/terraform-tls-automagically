# TLS Automagically

```sh
data "external" "whoami" {
  program = ["${path.module}/externals/external-whoami.sh"]
}

resource "random_pet" "env" {
  length    = 2
  separator = "_"
}

module "tls_automagically" {
  source            = "github.com/markchristopherwest/terraform-tls-automagically"
  product_manifest  = var.product_portfolio
  organization_name = "${format("%s", resource.random_pet.env.id)} Unlimited"
  common_name_ca    = "${format("%s", resource.random_pet.env.id)}.local"
  dns_names = concat(
    formatlist("vault-%s.vault-%s-internal", keys(var.product_portfolio), keys(var.product_portfolio)),
    formatlist("vault-%s-0.vault-%s-internal", keys(var.product_portfolio), keys(var.product_portfolio)),
    formatlist("vault-%s-1.vault-%s-internal", keys(var.product_portfolio), keys(var.product_portfolio)),
    formatlist("vault-%s-2.vault-%s-internal", keys(var.product_portfolio), keys(var.product_portfolio)),
    # formatlist("vault-%s.vault-%s-internal.%s.svc.cluster.local", keys(var.product_portfolio), keys(var.product_portfolio), values(var.product_portfolio)[*]["location"]),
    # formatlist("vault-%s-0.vault-%s-internal.%s.svc.cluster.local", keys(var.product_portfolio), keys(var.product_portfolio), values(var.product_portfolio)[*]["location"]),
    # formatlist("vault-%s-1.vault-%s-internal.%s.svc.cluster.local", keys(var.product_portfolio), keys(var.product_portfolio), values(var.product_portfolio)[*]["location"]),
    # formatlist("vault-%s-2.vault-%s-internal.%s.svc.cluster.local", keys(var.product_portfolio), keys(var.product_portfolio), values(var.product_portfolio)[*]["location"])
  )
  ip_addresses          = ["127.0.0.1"]
  validity_period_hours = 87600
  tags                  = var.tags
}
```

