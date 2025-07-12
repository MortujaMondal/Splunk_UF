#!/bin/bash

#============================
# Splunk UF Installation Script - Linux
#============================

# --- Configuration Variables ---
USER="splunkfwd"
GROUP="splunkfwd"
SPLUNK_HOME="/opt/splunkforwarder"
TAR_FILE="splunkforwarder-9.2.4-c103a21bb11d-Linux-x86_64.tgz" # Or You can Wget this
DEPLOYMENT_SERVER="<Your-DS-IP>:8089"
SPLUNK_USERNAME="splunk"
SPLUNK_PASSWORD="<Give-a-Password-to-set>"

# --- Pre-Checks ---
echo "[+] Checking prerequisites..."

if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run this script as root."
  exit 1
fi

if ! [ -f "$TAR_FILE" ]; then
  echo "[-] Splunk UF tarball ($TAR_FILE) not found in current directory."
  exit 1
fi

# --- Create User & Group ---
echo "[+] Ensuring Splunk user/group exists..."
id "$USER" &>/dev/null || useradd -m "$USER"
getent group "$GROUP" &>/dev/null || groupadd "$GROUP"

# --- Extract Splunk UF ---
echo "[+] Extracting Splunk Universal Forwarder to /opt..."
tar -xzvf "$TAR_FILE" -C /opt || { echo "[-] Extraction failed."; exit 1; }

# --- Set Permissions ---
echo "[+] Setting ownership..."
chown -R "$USER:$GROUP" "$SPLUNK_HOME"

# --- Configure Initial Admin Credentials ---
echo "[+] Setting initial admin credentials..."
mkdir -p "$SPLUNK_HOME/etc/system/local"
cat > "$SPLUNK_HOME/etc/system/local/user-seed.conf" <<EOF
[user_info]
USERNAME = $SPLUNK_USERNAME
PASSWORD = $SPLUNK_PASSWORD
EOF

# --- Start & Stop Splunk to Initialize ---
echo "[+] Starting Splunk for initial setup..."
$SPLUNK_HOME/bin/splunk start --accept-license --answer-yes --no-prompt
$SPLUNK_HOME/bin/splunk stop

# --- Enable Boot Start ---
echo "[+] Enabling Splunk UF at boot..."
$SPLUNK_HOME/bin/splunk enable boot-start -user "$USER"

# --- Start Splunk UF ---
$SPLUNK_HOME/bin/splunk start --no-prompt

# --- Set Deployment Server ---
echo "[+] Setting deployment server to $DEPLOYMENT_SERVER..."
$SPLUNK_HOME/bin/splunk set deploy-poll "$DEPLOYMENT_SERVER" -auth "$SPLUNK_USERNAME:$SPLUNK_PASSWORD"

############OPTIONAL####START###############################
# --- Configure Inputs & Outputs ---
#echo "[+] Setting up default inputs & outputs (optional)..."
#cat > "$SPLUNK_HOME/etc/system/local/outputs.conf" <<EOF
#[tcpout]
#defaultGroup = default-autolb-group

#[tcpout:default-autolb-group]
#server = <IP-of-HF>:9997
#EOF
#OR TRY This if you have multiple indexer
#cat > "$SPLUNK_HOME/etc/system/local/outputs.conf" <<EOF
#[tcpout]
#defaultGroup = indexer_group

#[tcpout:indexer_group]
#server = 192.168.252.31:9997,192.168.252.32:9997,192.168.252.33:9997,...,192.168.252.44:9997
#autoLBFrequency = 30
#EOF

#cat > "$SPLUNK_HOME/etc/system/local/inputs.conf" <<EOF
#[monitor:///var/log/]
#disabled = false
#index = linux_all
#sourcetype = linux_syslog

#[monitor:///tmp/uf_heartbeat.log]
#disabled = false
#index = linux_all
#sourcetype = uf_heartbeat
#EOF
############OPTIONAL##END#################################

# --- OS-Specific Permission Handling ---
echo "[+] Adjusting log permissions based on OS type..."
OS_NAME=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')

case "$OS_NAME" in
  ubuntu|debian)
    chmod -R o+r /var/log/
    ;;
  rhel|centos|fedora)
    setfacl -Rm u:$USER:rx /var/log
    ;;
  *)
    echo "[!] Unknown OS: $OS_NAME. Please set /var/log permissions manually."
    ;;
esac

# --- Final Restart ---
echo "[+] Restarting Splunk UF..."
$SPLUNK_HOME/bin/splunk restart

# --- Cleanup ---
unset SPLUNK_USERNAME
unset SPLUNK_PASSWORD

echo "Splunk Universal Forwarder installed and configured successfully."

