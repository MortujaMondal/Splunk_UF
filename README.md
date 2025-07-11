# 🚀 Splunk Universal Forwarder Deployment Tracker

## 📌 Description

This project provides a full setup to track Universal Forwarder (UF) health across your on-premises SOC environment running on Splunk.

You can:
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

### 🧪 Installation Script
- Bash script for deploying UF with:
  - User creation
  - Extraction, install, boot enable
  - OS-based log permissions
  - Deploy-poll setup

### 🧰 REST API Script (Optional)
- `check_forwarders.py`: Python script to hit Splunk's REST API and pull live status of forwarders (requires admin creds)

---
