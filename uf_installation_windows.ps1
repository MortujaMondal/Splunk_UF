<#
.SYNOPSIS
    Splunk Universal Forwarder Silent Install Script for Windows

.NOTES
    Author  : Golam Mortuja Mondal
    Project : splunk-uf-deployment-tracker
#>

# ======================
# === Configuration ===
# ======================
$Installer = "splunkforwarder-9.2.4-c103a21bb11d-x64-release.msi" #Or you can wget the agent
$SplunkUser = "splunk"
$SplunkPassword = "<Your-Password>"
$DeployServer = "<YOUR-DS-IP>:8089"
$InstallDir = "C:\Program Files\SplunkUniversalForwarder"
$LogFile = "$env:TEMP\splunk_uf_install.log"


# ============================
# === Install Splunk UF ====
# ============================

Write-Output "[-] Installing Splunk UF..."
Start-Process msiexec.exe -ArgumentList "/i `"$Installer`" AGREETOLICENSE=Yes INSTALLDIR=`"$InstallDir`" /quiet" -Wait -NoNewWindow

if (!(Test-Path "$InstallDir\bin\splunk.exe")) {
    Write-Error "[-] Splunk UF not found after installation."
    exit 1
}

# ===========================
# === Set Admin Password ===
# ===========================
& "$InstallDir\bin\splunk.exe" set admin-user $SplunkUser -password $SplunkPassword --accept-license --answer-yes --no-prompt

# =============================
# === Set Deployment Server ===
# =============================
& "$InstallDir\bin\splunk.exe" set deploy-poll $DeployServer -auth "$SplunkUser:$SplunkPassword"

# ============================
# === Configure outputs.conf ===
# ============================
$outConf = "$InstallDir\etc\system\local\outputs.conf"
@"
[tcpout]
defaultGroup = default-autolb-group

[tcpout:default-autolb-group]
server = <YOUR-INDEXER-IP>:9997
"@ | Set-Content -Path $outConf -Encoding UTF8
###########
#OR IF You Have multiple indexer
#@"
#[tcpout]
#defaultGroup = indexer_group

#[tcpout:indexer_group]
#server = 192.168.252.31:9997,192.168.252.32:9997,192.168.252.33:9997,...,192.168.252.44:9997
#autoLBFrequency = 30
#"@ | Set-Content -Path $outConf -Encoding UTF8
############

# ============================
# === Configure inputs.conf ===
# ============================
$inConf = "$InstallDir\etc\system\local\inputs.conf"
@"
[WinEventLog://Application]
disabled = 0
index = win

[WinEventLog://Security]
disabled = 0
index = win

[WinEventLog://System]
disabled = 0
index = win
"@ | Set-Content -Path $inConf -Encoding UTF8

# ============================
# === Start UF Service =======
# ============================
& "$InstallDir\bin\splunk.exe" restart

Write-Host "[✅] Splunk Universal Forwarder installed and configured."
