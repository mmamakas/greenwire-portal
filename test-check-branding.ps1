# Test Check Browser Extension Branding Configuration
# This script configures Check extension branding via Windows Registry for Chrome/Edge

# Extension ID for Check (you may need to verify this)
# To find: Open chrome://extensions/ with Developer mode on, look for the ID under Check
$ExtensionId = "YOUR_EXTENSION_ID_HERE"  # Replace with actual Check extension ID

# Branding Configuration
$BrandingConfig = @{
    companyName = "Greenwire Solutions Shield"
    logoUrl = "https://i.ibb.co/WvGNMNSn/smallgshieild.jpg"
    primaryColor = "#FF5733"
    supportEmail = "service@greenwiresolutions.com"
    supportUrl = "https://support.greenwiresolutions.com"
    privacyPolicyUrl = "https://greenwiresolutions.com/legal-privacy-policy"
}

# Registry paths
$ChromeBasePath = "HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions"
$EdgeBasePath = "HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions"

function Set-CheckBranding {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Browser,  # "Chrome" or "Edge"
        
        [Parameter(Mandatory=$true)]
        [string]$ExtensionId,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    $BasePath = if ($Browser -eq "Chrome") { $ChromeBasePath } else { $EdgeBasePath }
    $ExtensionPath = Join-Path $BasePath $ExtensionId
    $BrandingPath = Join-Path $ExtensionPath "customBranding"
    
    Write-Host "Configuring Check branding for $Browser..." -ForegroundColor Cyan
    
    # Create registry structure
    if (-not (Test-Path $BasePath)) {
        New-Item -Path $BasePath -Force | Out-Null
        Write-Host "  Created base path: $BasePath" -ForegroundColor Green
    }
    
    if (-not (Test-Path $ExtensionPath)) {
        New-Item -Path $ExtensionPath -Force | Out-Null
        Write-Host "  Created extension path: $ExtensionPath" -ForegroundColor Green
    }
    
    if (-not (Test-Path $BrandingPath)) {
        New-Item -Path $BrandingPath -Force | Out-Null
        Write-Host "  Created branding path: $BrandingPath" -ForegroundColor Green
    }
    
    # Set branding properties
    foreach ($key in $Config.Keys) {
        Set-ItemProperty -Path $BrandingPath -Name $key -Value $Config[$key] -Type String
        Write-Host "  Set $key = $($Config[$key])" -ForegroundColor Yellow
    }
    
    Write-Host "Branding configured successfully for $Browser!" -ForegroundColor Green
}

function Remove-CheckBranding {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Browser,
        
        [Parameter(Mandatory=$true)]
        [string]$ExtensionId
    )
    
    $BasePath = if ($Browser -eq "Chrome") { $ChromeBasePath } else { $EdgeBasePath }
    $ExtensionPath = Join-Path $BasePath $ExtensionId
    
    if (Test-Path $ExtensionPath) {
        Remove-Item -Path $ExtensionPath -Recurse -Force
        Write-Host "Removed Check branding for $Browser" -ForegroundColor Magenta
    } else {
        Write-Host "No branding found for $Browser" -ForegroundColor Yellow
    }
}

function Show-CheckBranding {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Browser,
        
        [Parameter(Mandatory=$true)]
        [string]$ExtensionId
    )
    
    $BasePath = if ($Browser -eq "Chrome") { $ChromeBasePath } else { $EdgeBasePath }
    $BrandingPath = Join-Path (Join-Path $BasePath $ExtensionId) "customBranding"
    
    Write-Host "`nCurrent branding for $Browser:" -ForegroundColor Cyan
    
    if (Test-Path $BrandingPath) {
        Get-ItemProperty -Path $BrandingPath | Format-List
    } else {
        Write-Host "  No branding configured" -ForegroundColor Yellow
    }
}

# Main script execution
if ($ExtensionId -eq "YOUR_EXTENSION_ID_HERE") {
    Write-Host @"
ERROR: Extension ID not set!

To find the Check extension ID:
1. Open Chrome or Edge
2. Go to: chrome://extensions/ (or edge://extensions/)
3. Enable 'Developer mode' (toggle in top-right)
4. Find the Check extension
5. Copy the ID (32-character string below the name)
6. Update this script with the ID

"@ -ForegroundColor Red
    exit 1
}

# Check for admin privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script requires administrator privileges!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Menu
Write-Host @"

==========================================
Check Extension Branding Test Script
==========================================

Extension ID: $ExtensionId

"@ -ForegroundColor Cyan

Write-Host "1. Apply branding to Chrome"
Write-Host "2. Apply branding to Edge"
Write-Host "3. Apply branding to both Chrome and Edge"
Write-Host "4. Show current branding (Chrome)"
Write-Host "5. Show current branding (Edge)"
Write-Host "6. Remove branding (Chrome)"
Write-Host "7. Remove branding (Edge)"
Write-Host "8. Remove branding (both)"
Write-Host "Q. Quit"
Write-Host ""

$choice = Read-Host "Select an option"

switch ($choice) {
    "1" { Set-CheckBranding -Browser "Chrome" -ExtensionId $ExtensionId -Config $BrandingConfig }
    "2" { Set-CheckBranding -Browser "Edge" -ExtensionId $ExtensionId -Config $BrandingConfig }
    "3" {
        Set-CheckBranding -Browser "Chrome" -ExtensionId $ExtensionId -Config $BrandingConfig
        Set-CheckBranding -Browser "Edge" -ExtensionId $ExtensionId -Config $BrandingConfig
    }
    "4" { Show-CheckBranding -Browser "Chrome" -ExtensionId $ExtensionId }
    "5" { Show-CheckBranding -Browser "Edge" -ExtensionId $ExtensionId }
    "6" { Remove-CheckBranding -Browser "Chrome" -ExtensionId $ExtensionId }
    "7" { Remove-CheckBranding -Browser "Edge" -ExtensionId $ExtensionId }
    "8" {
        Remove-CheckBranding -Browser "Chrome" -ExtensionId $ExtensionId
        Remove-CheckBranding -Browser "Edge" -ExtensionId $ExtensionId
    }
    "Q" { Write-Host "Exiting..." -ForegroundColor Cyan; exit 0 }
    default { Write-Host "Invalid selection" -ForegroundColor Red }
}

Write-Host @"

==========================================
Next Steps:
==========================================

1. Close and reopen Chrome/Edge completely
2. Open the Check extension
3. Verify branding appears:
   - Company name: Greenwire Solutions Shield
   - Logo shows the shield image
   - Primary color is orange-red
   - Support links point to GWS

To permanently apply:
- Use GPO for domain-joined machines
- Use Intune for cloud-managed devices
- Or keep this registry configuration

"@ -ForegroundColor Green
