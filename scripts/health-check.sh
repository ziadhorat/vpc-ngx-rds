#!/bin/bash
set -euo pipefail

PROJECT_NAME="${PROJECT_NAME:-vpc-ngx-rds}"
HTML_FILE="/usr/share/nginx/html/index.html"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

nginx_status() {
  systemctl is-active --quiet nginx && echo "OK" || echo "Error"
}

http_status() {
  code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80 2>/dev/null || echo "Error")
  [ "$code" = "200" ] && echo "OK" || echo "Error"
}

db_status() {
  db_info=$(aws ssm get-parameter --name "/${PROJECT_NAME}/db/info" --query 'Parameter.Value' --output text 2>/dev/null || echo "")
  if [ -z "$db_info" ]; then
    echo "Error"
    return
  fi
  
  host=$(echo "$db_info" | jq -r '.host')
  port=$(echo "$db_info" | jq -r '.port')
  dbname=$(echo "$db_info" | jq -r '.dbname')
  username=$(echo "$db_info" | jq -r '.username')
  resource_id=$(echo "$db_info" | jq -r '.resource_id')
  
  if [ -z "$resource_id" ]; then
    echo "Error"
    return
  fi
  
  secret_arn=$(aws secretsmanager list-secrets --query "SecretList[?starts_with(Name, 'rds!db-')].ARN" --output text 2>/dev/null | head -1)
  
  if [ -z "$secret_arn" ]; then
    echo "Error"
    return
  fi
  
  secret_value=$(aws secretsmanager get-secret-value --secret-id "$secret_arn" --query 'SecretString' --output text 2>/dev/null)
  if [ -z "$secret_value" ]; then
    echo "Error"
    return
  fi
  
  secret_username=$(echo "$secret_value" | jq -r '.username' 2>/dev/null)
  if [ "$secret_username" != "$username" ]; then
    echo "Error"
    return
  fi
  
  password=$(echo "$secret_value" | jq -r '.password')
  
  if [ -z "$password" ]; then
    echo "Error"
    return
  fi
  
  PGPASSWORD="$password" psql -h "$host" -p "$port" -U "$username" -d "$dbname" -c "SELECT 1" >/dev/null 2>&1 && echo "OK" || echo "Error"
}

disk_usage() {
  df -h / | awk 'NR==2 {print $5}'
}

memory_usage() {
  free -h | awk 'NR==2 {print $3 "/" $2}'
}

nginx_stat=$(nginx_status)
http_stat=$(http_status)
db_stat=$(db_status)
disk_stat=$(disk_usage)
memory_stat=$(memory_usage)

echo "Nginx: $nginx_stat"
echo "HTTP: $http_stat"
echo "PostgreSQL: $db_stat"
echo "Disk Usage: $disk_stat"
echo "Memory Usage: $memory_stat"
echo "Last updated: $TIMESTAMP"

cat > "$HTML_FILE" <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Nginx Status</title>
</head>
<body>
    <h1>Welcome to nginx!</h1>
    <table>
        <tr><td>Nginx:</td><td>$nginx_stat</td></tr>
        <tr><td>HTTP:</td><td>$http_stat</td></tr>
        <tr><td>PostgreSQL:</td><td>$db_stat</td></tr>
        <tr><td>Disk Usage:</td><td>$disk_stat</td></tr>
        <tr><td>Memory Usage:</td><td>$memory_stat</td></tr>
    </table>
    <p><small>Last updated: $TIMESTAMP</small></p>
</body>
</html>
EOF
