<#
.SYNOPSIS
	Fido GUI (for fido.ps1)
.DESCRIPTION
	Fido GUI (for fido.ps1) is a graphical user interface for Fido, a PowerShell script that allows you to download Windows ISO files.
	You can select the OS version, release, language, and architecture, and the script will download the ISO file to the specified folder.
	You can also check for updates to Fido and download the latest version if available.
.EXAMPLE
	.\FidoGUI.ps1
	Displays the GUI for selecting the OS version, release, language, and architecture, and downloads the ISO file to the specified folder.
	.\FidoGUI.ps1 -Update
	Checks for updates to Fido and downloads the latest version if available.
.NOTES
	Author: Giovanni Solone
	Website: https://go.gioxx.org/fidogui
	Date: 2022-10-25
	License: MIT
	License URL: https://opensource.org/licenses/MIT
	Tags: Fido, Windows, ISO, download, GUI, PowerShell

	Credits:
	- https://devblogs.microsoft.com/scripting/two-simple-powershell-methods-to-remove-the-last-letter-of-a-string/
	- https://github.com/dlwyatt/WinFormsExampleUpdates/blob/master/ListBox.ps1
	- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash?view=powershell-7.2
	- https://learn.microsoft.com/it-it/powershell/module/microsoft.powershell.core/about/about_switch?view=powershell-7.2
	- https://shellgeek.com/powershell-string-remove/
	- https://social.technet.microsoft.com/Forums/scriptcenter/en-US/ff142c25-fcb3-4504-a9cf-cf0784541d48/how-to-set-default-value-in-listbox-using-powershell?forum=ITCG
	- https://stackoverflow.com/a/11876921/2220346
	- https://stackoverflow.com/a/23343615/2220346
	- https://stackoverflow.com/a/25690250/2220346
	- https://stackoverflow.com/a/36553018/2220346
	- https://stackoverflow.com/a/4988239/2220346
	- https://stackoverflow.com/a/58277975/2220346
	- https://stackoverflow.com/a/9236944/2220346
	- https://superuser.com/a/1515759

	Example based on the original Fido.ps1 script:
	.\Fido.ps1 -Win 10 -Rel latest -Ed Pro -Lang Italian

	Modification History:
	- 2025-05-13: Bugfixes, added support for Windows 11, and improved error handling. Partial refactoring.
	- 2022-10-26: Changing working directory (and turn back on script exit when exiting), cleaning, first version uploaded on GitHub.
	- 2022-10-25: Initial version
#>

Param(
	[Switch] $Update,
	[Switch] $TestMode
)

$FGV = "0.3 (20250513)"
$tmpDir = Join-Path $PSScriptRoot "tmp"
New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null

Function Search-FidoFile {
	$FidoPath = Join-Path $PSScriptRoot "Fido.ps1"
	if (Test-Path $FidoPath) {
		if ((Get-Item $FidoPath).LastWriteTime -lt (Get-Date).AddDays(-10)) {
			Remove-Item $FidoPath -Force
			Get-FidoFile -FidoFilePath $FidoPath
		}
	} else {
		Write-Host "Fido.ps1 not found. Downloading..."
		Get-FidoFile -FidoFilePath $FidoPath
	}
}

Function Get-FidoFile {
	param([string]$FidoFilePath)
	
	try {
		Invoke-WebRequest "https://github.com/pbatard/Fido/raw/master/Fido.ps1" -OutFile $FidoFilePath
	} catch {
		Write-Error "Failed to download Fido.ps1. Check your internet connection."
		exit 1
	}
}

Function Clear-Rows {
	param([string]$filename)

	$output = ""
	foreach ($line in Get-Content $filename) {
		if ($line.StartsWith(" - ")) {
			$cleanoutput = $line.Remove(0, 3)
			$output += "$cleanoutput`n"
		}
	}

	if ($output.Length -gt 0) {
		$output.Substring(0, $output.Length - 1) | Set-Content $filename
	} else {
		Clear-Content $filename
	}

	Start-Sleep -Seconds 1.5
}

Function Get-ListBoxItemsFromFido {
	param (
		[string[]]$Arguments,
		[string]$TempFile
	)

	Function QuoteIfNeeded {
		param ([string]$text)
		if ($text -match '\s|\(|\)|-') { return '"' + $text + '"' }
		return $text
	}

	$escapedArgs = for ($i = 0; $i -lt $Arguments.Count; $i += 2) {
		$key = $Arguments[$i]
		$val = if ($i + 1 -lt $Arguments.Count) { QuoteIfNeeded $Arguments[$i + 1] } else { '' }
		"$key $val"
	}

	$joinedArgs = $escapedArgs -join ' '

	$psi = New-Object System.Diagnostics.ProcessStartInfo
	$psi.FileName = "powershell.exe"
	$psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Fido.ps1`" $joinedArgs"
	$psi.RedirectStandardOutput = $true
	$psi.UseShellExecute = $false
	$psi.CreateNoWindow = $true

	$process = New-Object System.Diagnostics.Process
	$process.StartInfo = $psi
	$process.Start() | Out-Null
	$output = $process.StandardOutput.ReadToEnd()
	$process.WaitForExit()

	$lines = $output -split "`r?`n"
	$cleaned = $lines | Where-Object { $_ -like ' - *' } | ForEach-Object { $_.Substring(3).Trim() }

	if ($output -match 'banned from using this service') {
		Write-Error \"Microsoft has blocked access to the service from this IP or network.\"
		exit 1
	} elseif (-not $cleaned -or $cleaned.Count -eq 0) {
		Write-Host "[ERROR] No items were extracted for arguments: $joinedArgs" -ForegroundColor Red
		Write-Host "--- Raw output from Fido.ps1 ---" -ForegroundColor DarkGray
		Write-Host $output
		throw "No valid items found. Cannot continue."
	}

	Set-Content -Path $TempFile -Value ($cleaned -join "`n")
	return $cleaned
}

Function Show-Popup {
	param(
		[string]$PopupTitle,
		[string]$PopupText,
		[string]$PopupContent,
		[string]$WinVer,
		[string]$WinRel,
		[string]$WinLang
	)

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	$form = New-Object Windows.Forms.Form
	$form.Text = "FIDO GUI - $PopupTitle"
	$form.Size = '335,270'
	$form.StartPosition = 'CenterScreen'

	$label = New-Object Windows.Forms.Label
	$label.Location = '10,10'
	$label.Size = '300,20'
	$label.Text = $PopupText
	$form.Controls.Add($label)

	$swinfo = New-Object Windows.Forms.Label
	$swinfo.Location = '10,200'
	$swinfo.Size = '280,20'
	$swinfo.Text = "FIDO GUI $FGV"
	$form.Controls.Add($swinfo)

	$listBox = New-Object Windows.Forms.ListBox
	$listBox.Location = '10,30'
	$listBox.Size = '300,130'

	$items = switch ($PopupContent) {
		"OSVersion" { Get-ListBoxItemsFromFido -Arguments @('-Win', 'list') -TempFile (Join-Path $tmpDir 'output_os.txt') }
		"RelList" { Get-ListBoxItemsFromFido -Arguments @('-Win', $WinVer, '-Rel', 'list') -TempFile (Join-Path $tmpDir 'output_rel.txt') }
		"Lang" { Get-ListBoxItemsFromFido -Arguments @('-Win', $WinVer, '-Rel', $WinRel, '-Lang', 'list') -TempFile (Join-Path $tmpDir 'output_lang.txt') }
		"Arch" { Get-ListBoxItemsFromFido -Arguments @('-Win', $WinVer, '-Rel', $WinRel, '-Lang', $WinLang, '-Arch', 'list') -TempFile (Join-Path $tmpDir 'output_arch.txt') }
	}

	if ($items -and $items.Count -gt 0) {
		$listBox.Items.AddRange($items)
		$listBox.SetSelected(0, $true)
	} else {
		[System.Windows.Forms.MessageBox]::Show(
			"No items found for selection.",
			"FIDO GUI",
			[System.Windows.Forms.MessageBoxButtons]::OK,
			[System.Windows.Forms.MessageBoxIcon]::Warning
		)
		exit
	}
	$form.Controls.Add($listBox)

	$okButton = New-Object Windows.Forms.Button
	$okButton.Location = '10,160'
	$okButton.Size = '75,23'
	$okButton.Text = 'OK'
	$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $okButton
	$form.Controls.Add($okButton)

	$cancelButton = New-Object Windows.Forms.Button
	$cancelButton.Location = '90,160'
	$cancelButton.Size = '75,23'
	$cancelButton.Text = 'Cancel'
	$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $cancelButton
	$form.Controls.Add($cancelButton)

	$form.Topmost = $true
	$result = $form.ShowDialog()

	if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
		return $listBox.SelectedItem
	} else {
		exit
	}
}

Function Get-Folder {
	param([string]$initialDirectory = "")

	Add-Type -AssemblyName System.Windows.Forms
	$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
	$dialog.Description = "Select download folder"
	$dialog.SelectedPath = $initialDirectory

	if ($dialog.ShowDialog() -eq 'OK') {
		return $dialog.SelectedPath
	} else {
		exit
	}
}

Function Format-Size {
	param([uint64]$size)

	$suffix = "bytes", "KB", "MB", "GB", "TB"
	$i = 0
	while ($size -ge 1024 -and $i -lt $suffix.Length - 1) {
		$size = $size / 1024
		$i++
	}

	return "{0:N1} {1}" -f $size, $suffix[$i]
}

Function Get-ISO {
	param(
		[string]$SelectedOS,
		[string]$SelectedRel,
		[string]$SelectedLang,
		[string]$SelectedArch,
		[string]$DownloadFolder
	)

	$ISOUrl = .\Fido.ps1 -Win $SelectedOS -Rel $SelectedRel -Lang $SelectedLang -Arch $SelectedArch -GetUrl
	
	if ($TestMode) {
		Write-Host "[TEST MODE] Download URL: $ISOUrl"
		return
	}

	try {
		$pattern = '.*\/(.*\.iso).*'
		$File = [regex]::Match($ISOUrl, $pattern).Groups[1].Value
		$str_size = (Invoke-WebRequest -UseBasicParsing -Uri $ISOUrl -Method Head).Headers.'Content-Length'
		$tmp_size = [uint64]::Parse($str_size)
		$Size = Format-Size -size $tmp_size
		Write-Host "Downloading '$File' ($Size) ..."
		Invoke-WebRequest -UseBasicParsing -Uri $ISOUrl -OutFile (Join-Path $DownloadFolder $File)
	} catch {
		Write-Error $_.Exception.Message
		return 404
	}

	return "Done."
}

if ($PSVersionTable.PSVersion.Major -lt 5) {
	Write-Error "FIDO GUI requires PowerShell 5.1 or later."
	exit 1
}

$prevPwd = $PWD
Set-Location -LiteralPath $PSScriptRoot

try {
	Search-FidoFile

	if ($Update) {
		Write-Host "Check for Fido updates ..."
		$newPath = Join-Path $PSScriptRoot "Fido_new.ps1"
		Get-FidoFile -FidoFilePath $newPath
		$MD5Old = Get-FileHash -Algorithm MD5 "Fido.ps1" | Select-Object -ExpandProperty Hash
		$MD5New = Get-FileHash -Algorithm MD5 $newPath | Select-Object -ExpandProperty Hash

		if ($MD5New -ne $MD5Old) {
			Move-Item -Force $newPath -Destination "Fido.ps1"
			$Fido_info = Invoke-RestMethod -Uri "https://api.github.com/repos/pbatard/Fido/tags"
			Write-Host "Fido updated to $($Fido_info.name[0])" -ForegroundColor Green
		} else {
			Remove-Item $newPath
			Write-Host "Fido is up to date." -ForegroundColor Yellow
		}
	}

	$SelectedOS = Show-Popup -PopupTitle "OS Version" -PopupText "Please select OS version:" -PopupContent "OSVersion" -WinVer "" -WinRel "" -WinLang ""
	$SelectedRel = Show-Popup -PopupTitle "OS Release" -PopupText "Please select OS release:" -PopupContent "RelList" -WinVer $SelectedOS -WinRel "" -WinLang ""
	$SelectedLang = Show-Popup -PopupTitle "OS Language" -PopupText "Please select OS language:" -PopupContent "Lang" -WinVer $SelectedOS -WinRel $SelectedRel -WinLang ""
	$SelectedArch = Show-Popup -PopupTitle "OS Arch" -PopupText "Please select OS architecture:" -PopupContent "Arch" -WinVer $SelectedOS -WinRel $SelectedRel -WinLang $SelectedLang

	Do { $DownloadFolder = Get-Folder }
	until ($null -ne $DownloadFolder)

	Write-Host "Trying to download Windows $SelectedOS $SelectedRel $SelectedArch ($SelectedLang) in $DownloadFolder ..."
	Get-ISO -SelectedOS $SelectedOS -SelectedRel $SelectedRel -SelectedLang $SelectedLang -SelectedArch $SelectedArch -DownloadFolder $DownloadFolder

} finally {
	Set-Location $prevPwd
	if (Test-Path $tmpDir) { Remove-Item $tmpDir -Recurse -Force }
}
