#!/bin/bash

# Check if the script is run as root
if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root"
    exit 1
fi

# Print information about the script
echo "//=============================================================="
echo "   Nessus latest Download, Install, and Crack by k4t3pr0"
echo "   Special thanks to John Doe for showing this works on Debian"
echo "   THANKS 369 for tip about LATEST as a version number"
echo "//=============================================================="

# Remove immutable attributes from Nessus directory
echo "Removing immutable attributes from /opt/nessus directory"
chattr -i -R /opt/nessus

# Ensure prerequisites are installed
echo "Installing prerequisites..."
apt update &>/dev/null
apt -y install curl dpkg expect &>/dev/null

# Stop old Nessus service if it exists
echo "Stopping old Nessus service if it exists..."
systemctl stop nessusd.service &>/dev/null

# Download Nessus
echo "Downloading Nessus..."
curl -A Mozilla --request GET \
  --url 'https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-latest-ubuntu1404_amd64.deb' \
  --output 'Nessus-latest-ubuntu1404_amd64.deb' &>/dev/null

# Check if Nessus download was successful
if [ ! -f Nessus-latest-ubuntu1404_amd64.deb ]; then
  echo "Nessus download failed :/ Exiting. Get a copy from t.me/pwn3rzs"
  exit 1
fi

# Install Nessus
echo "Installing Nessus..."
dpkg -i Nessus-latest-ubuntu1404_amd64.deb &>/dev/null

# Start Nessus service for the first time initialization
echo "Starting Nessus service for the first time initialization..."
systemctl start nessusd.service &>/dev/null

# Allow Nessus time to initialize
echo "Allowing Nessus time to initialize..."
sleep 20

# Stop Nessus service
echo "Stopping Nessus service..."
systemctl stop nessusd.service &>/dev/null

# Configure Nessus settings
echo "Configuring Nessus settings..."
/opt/nessus/sbin/nessuscli fix --set xmlrpc_listen_port=11127 &>/dev/null
/opt/nessus/sbin/nessuscli fix --set ui_theme=dark &>/dev/null
/opt/nessus/sbin/nessuscli fix --set safe_checks=false &>/dev/null
/opt/nessus/sbin/nessuscli fix --set backend_log_level=performance &>/dev/null
/opt/nessus/sbin/nessuscli fix --set auto_update=false &>/dev/null
/opt/nessus/sbin/nessuscli fix --set auto_update_ui=false &>/dev/null
/opt/nessus/sbin/nessuscli fix --set disable_core_updates=true &>/dev/null
/opt/nessus/sbin/nessuscli fix --set report_crashes=false &>/dev/null
/opt/nessus/sbin/nessuscli fix --set send_telemetry=false &>/dev/null

# Add a user
echo "Adding a user..."
cat > expect.tmp <<EOF
spawn /opt/nessus/sbin/nessuscli adduser admin
expect "Login password:"
send "admin\r"
expect "Login password (again):"
send "admin\r"
expect "*(can upload plugins, etc.)? (y/n)*"
send "y\r"
expect "*(the user can have an empty rules set)"
send "\r"
expect "Is that ok*"
send "y\r"
expect eof
EOF
expect -f expect.tmp &>/dev/null
rm -rf expect.tmp &>/dev/null

# Download and install plugins
echo "Downloading and installing plugins..."
curl -A Mozilla -o all-2.0.tar.gz \
  --url 'https://plugins.nessus.org/v2/nessus.php?f=all-2.0.tar.gz&u=4e2abfd83a40e2012ebf6537ade2f207&p=29a34e24fc12d3f5fdfbb1ae948972c6' &>/dev/null
if [ ! -f all-2.0.tar.gz ]; then
  echo "Plugin download failed :/ Exiting. Get a copy from t.me/pwn3rzs"
  exit 1
fi
/opt/nessus/sbin/nessuscli update all-2.0.tar.gz &>/dev/null

# Fetch version number
echo "Fetching version number..."
vernum=$(curl https://plugins.nessus.org/v2/plugins.php 2> /dev/null)

# Build plugin feed
echo "Building plugin feed..."
cat > /opt/nessus/var/nessus/plugin_feed_info.inc <<EOF
PLUGIN_SET = "${vernum}";
PLUGIN_FEED = "ProfessionalFeed (Direct)";
PLUGIN_FEED_TRANSPORT = "Tenable Network Security Lightning";
EOF

# Protect files
echo "Protecting files..."
chattr -i /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc &>/dev/null
cp /opt/nessus/var/nessus/plugin_feed_info.inc /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc &>/dev/null
chattr +i /opt/nessus/var/nessus/plugin_feed_info.inc &>/dev/null
chattr +i -R /opt/nessus/lib/nessus/plugins &>/dev/null

# Start Nessus service
echo "Starting Nessus service..."
systemctl start nessusd.service &>/dev/null

# Wait for server to start
echo "Waiting for Nessus server to start..."
sleep 20

# Monitor Nessus progress
zen=0
while [ $zen -ne 100 ]; do
 statline=$(curl -sL -k https://localhost:11127/server/status|awk -F"," -v k="engine_status" '{ gsub(/{|}/,""); for(i=1;i<=NF;i++) { if ( $i ~ k ){printf $i} } }')
 if [[ $statline != *"engine_status"* ]]; then
    echo -ne "\nProblem: Nessus server unreachable? Trying again..\n"
 fi
 echo -ne "\r$statline"
 if [[ $statline == *"100"* ]]; then
    zen=100
 else
    sleep 10
 fi
done

echo -ne '\n\no Done!\n\n'
echo "Access Nessus:  https://localhost:11127/ (or your Server IP)"
echo "Username: admin"
echo "Password: admin"
echo "You can change this any time"
echo
read -p "Press enter to continue"
