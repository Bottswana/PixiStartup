# Hide this window (Comment for debugging purposes)
Add-Type -Name win -Member '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -Namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)

# Resolve Host MAC (Wait for network adapter to come up)
$MacAddr = "00:00:00:00:00:00"
while($True)
{
    $GetDefaultAdapterID = Get-WmiObject -Class Win32_IP4RouteTable -Filter 'destination = "0.0.0.0" AND mask = "0.0.0.0"' | Sort-Object Metric1 | Select InterfaceIndex
    if( $GetDefaultAdapterID -ne $null )
    {
        $GetMainAdapterInfo = Get-NetAdapter -InterfaceIndex $GetDefaultAdapterID[0].InterfaceIndex | Select Name, MacAddress, Status
        if( ($GetMainAdapterInfo -ne $null) -and ($GetMainAdapterInfo.MacAddress.Length -ne 0) -and ($GetMainAdapterInfo.Status -eq "Up") )
        {
            $MacAddr = $GetMainAdapterInfo.MacAddress.Replace("-",":")
            Write-Host -ForegroundColor DarkGreen "Resolved MAC from active adapter"$GetMainAdapterInfo.Name"as:"$MacAddr
            break
        }
    }

    # No Adapter is up right now
    Write-Host -ForegroundColor DarkRed "No adapter present/online. Waiting for adapter to come online"
    Start-Sleep -Seconds 2
    continue
}

# Start Pixi (Using Firefox)
Start-Sleep -Seconds 2
$TargetDir = (${env:ProgramFiles(x86)}, ${env:ProgramFiles} -ne $null)[0]
& "$TargetDir\Mozilla Firefox\firefox.exe" "http://pixi.guide/spot/?mac=$MacAddr"