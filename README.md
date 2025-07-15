# Splunk Universal Forwarder Deployment & Tracker

## 📌 Description

This project provides a full setup to automate and track the deployment of **Splunk Universal Forwarders (UF)** across Linux and Windows systems. It includes installation scripts, default configurations (`inputs.conf`, `outputs.conf`), and a sample Splunk dashboard XML to monitor forwarder health, connectivity, and log ingestion status across on-premises SOC environment running on Splunk.

Our Objective:
- Monitor whether UFs are alive (heartbeat tracking)
- Detect delayed/missing logs from hosts
- Track Deployment Server contact status
- Deploy UFs using automation scripts
  
---

## 🛠️ Components

### 📊 Dashboards
- `UF_Deployment_Tracker.xml` – A Splunk dashboard with 3 panels:
  - UF heartbeat check (via _internal index)
  - Deployment server communication status
  - Missing log detection from `linux_all` or `win` indexes

 ## 🐧 Linux UF Installation

### 🔧 Script: `uf_installation_script_linux.sh`
This script:
- Adds a dedicated user (`splunkfwd`)
- Extracts and installs the Splunk UF tarball
- Configures:
  - `user-seed.conf` (for admin creds)
  - `outputs.conf` (to forward logs to indexers or HF)
  - `inputs.conf` (for `/var/log` and heartbeat)
- Sets DS for config management
- Sets boot-start and restarts UF
- Adjusts OS permissions for log reading
  
### Usage

```bash
# Prerequisite: place Splunk UF .tgz in the same directory
sudo bash uf_installation_script_linux.sh
```
## 🪟 Windows UF Installation
### 🔧 Script: `uf_installation_script_windows.ps1`
This script:
- Installs the .msi silently
- Sets admin password
- Configures DS and outputs/inputs
- Starts Splunk UF as a service

### Usage
```powershell
# Run in PowerShell as Administrator
.\uf_installation_windows.ps1
```
Note: Make sure the .msi file is in the same directory or adjust the $Installer path.

### 📁 Sample inputs.conf
Linux:
```bash
[monitor:///var/log/]
disabled = false
index = linux_all
sourcetype = linux_syslog

[monitor:///tmp/uf_heartbeat.log]
disabled = false
index = linux_all
sourcetype = uf_heartbeat
```
Windows:
```
[WinEventLog://Application]
disabled = 0
index = win

[WinEventLog://Security]
disabled = 0
index = win

[WinEventLog://System]
disabled = 0
index = win
```
### 🔒 Security Notes
Change default splunk username/password in the script before production use.

Ensure network firewall allows TCP/9997 from UFs to indexers.

### 🧰 REST API Script (Optional)
- `check_forwarders.py`: Python script to hit Splunk's REST API and pull live status of forwarders (requires admin creds)

---
## 📢 Author:
Mortuja Mondal, <br>
SOC Analyst & Splunk Engineer <br>
🔗 linkedin.com/in/mortuja001
<br>
Reference: https://help.splunk.com/en/splunk-enterprise/forward-and-process-data/universal-forwarder-manual/9.4/about-the-universal-forwarder/about-the-universal-forwarder
