output "nginx_url" {
  value = module.nginx.url
}

output "commands" {
  value = <<-EOT
# service logs:
sudo journalctl -u health-check.service
sudo journalctl -u health-check.timer
sudo journalctl -u nginx.service

# service status:
sudo systemctl status health-check.service
sudo systemctl status health-check.timer
sudo systemctl status nginx
  EOT
}
