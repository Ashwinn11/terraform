#!/usr/bin/env bash

# Update packages and install Apache
apt update
apt install apache2 -y

# Get the instance ID
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Install AWS CLI
apt install awscli -y

# Write HTML content to index.html
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Greeting</title>
</head>
<body>
  <h1>Hi Ashwin,</h1>
  <p>You are done with your first Terraform tutorial!</p>
  <p>Instance ID: $INSTANCE_ID</p>
</body>
</html>
EOF

# Start and enable Apache service
systemctl start apache2
systemctl enable apache2
