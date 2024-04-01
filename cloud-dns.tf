resource "google_dns_record_set" "webapp_a_record" {
  name         = "ashutoxh.me."
  type         = "A"
  ttl          = 600
  managed_zone = "ashutoxh-me"
  rrdatas      = [google_compute_global_forwarding_rule.webapp_forwarding_rule.ip_address]
  depends_on   = [google_compute_global_forwarding_rule.webapp_forwarding_rule]
}

resource "google_dns_record_set" "webapp_mx_record" {
  name         = "ashutoxh.me."
  type         = "MX"
  ttl          = 600
  managed_zone = "ashutoxh-me"
  rrdatas = [
    "10 mxa.mailgun.org.",
    "10 mxb.mailgun.org."
  ]
}
