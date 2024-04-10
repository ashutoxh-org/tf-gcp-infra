#!/bin/bash
set -e
echo "Error on line $LINENO. Command exited with status $?" >> /var/log/startup-script.log

# Define the error handling function
errorHandler() {
  echo "Error on line $LINENO. Command exited with status $?" >> /var/log/startup-script.log
}

# Set trap to call errorHandler on any errors
trap errorHandler ERR

if which curl >/dev/null; then
  echo "curl exists on this system." >> /var/log/startup-script.log
else
  echo "curl does not exist on this system." >> /var/log/startup-script.log
fi

# Fetch database connection details from metadata service
DB_HOST=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-host -H "Metadata-Flavor: Google")
DB_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-name -H "Metadata-Flavor: Google")
DB_USER=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-user -H "Metadata-Flavor: Google")
DB_PASS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-pass -H "Metadata-Flavor: Google")
echo "Fetched DB details" >> /var/log/startup-script.log

cat <<EOF > /etc/webapp.env
ENV_DATABASE_URL=jdbc:postgresql://$DB_HOST/$DB_NAME
ENV_DATABASE_USER=$DB_USER
ENV_DATABASE_PASSWORD=$DB_PASS
EOF
echo "Created env file" >> /var/log/startup-script.log

# Example of explicitly checking a command's success
if ! systemctl restart webapp.service; then
  echo "Failed to restart webapp.service" >> /var/log/startup-script.log
fi

echo "Script execution completed" >> /var/log/startup-script.log

# Your script's commands here
echo "Script finished" >> /var/log/startup-script.log