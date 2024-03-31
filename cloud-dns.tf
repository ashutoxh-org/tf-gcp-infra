resource "google_dns_record_set" "webapp_a_record" {
  name         = "ashutoxh.me."
  type         = "A"
  ttl          = 600
  managed_zone = "ashutoxh-me"
  rrdatas      = [google_compute_instance.webapp_instance.network_interface.0.access_config.0.nat_ip]
  depends_on   = [google_compute_instance.webapp_instance]
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
