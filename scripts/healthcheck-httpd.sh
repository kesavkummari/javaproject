#!/bin/bash

# Check if the httpd service is running
if systemctl is-active --quiet httpd; then
    echo "httpd service is running."
else
    echo "httpd service is not running. Starting httpd service..."
    systemctl start httpd

    # Check again if the service started successfully
    if systemctl is-active --quiet httpd; then
        echo "httpd service started successfully."
    else
        echo "Failed to start httpd service."
    fi
fi
