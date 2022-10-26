<#
	Fido GUI (for fido.ps1)
	----------------------------------------------------------------------------------------------------------------
	Author:				    GSolone
	Version:			    0.2
	First Version:		25-10-2022
	Info:				      https://gioxx.org/tag/powershell
	Credits:
		https://devblogs.microsoft.com/scripting/two-simple-powershell-methods-to-remove-the-last-letter-of-a-string/
		https://github.com/dlwyatt/WinFormsExampleUpdates/blob/master/ListBox.ps1
		https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash?view=powershell-7.2
		https://learn.microsoft.com/it-it/powershell/module/microsoft.powershell.core/about/about_switch?view=powershell-7.2
		https://shellgeek.com/powershell-string-remove/
		https://social.technet.microsoft.com/Forums/scriptcenter/en-US/ff142c25-fcb3-4504-a9cf-cf0784541d48/how-to-set-default-value-in-listbox-using-powershell?forum=ITCG
		https://stackoverflow.com/a/11876921/2220346
		https://stackoverflow.com/a/23343615/2220346
		https://stackoverflow.com/a/25690250/2220346
		https://stackoverflow.com/a/36553018/2220346
		https://stackoverflow.com/a/4988239/2220346
		https://stackoverflow.com/a/58277975/2220346
		https://stackoverflow.com/a/9236944/2220346
		https://superuser.com/a/1515759
	History:
		26/10/22- changing working directory (and turn back on script exit when exiting), cleaning, first version uploaded on GitHub.
	Example based on original Fido.ps1:
		.\Fido.ps1 -Win 10 -Rel latest -Ed Pro -Lang Italian
#>

Param(
	[Parameter(Mandatory=$false)]
	[Switch]$Update
)

$FGV = "0.2 (20221026)"

Function Check-Fido {
	if (Test-Path("Fido.ps1")) {
		return
	} else {
		Download-Fido("Fido.ps1")
	}
}

Function Download-Fido($filename) {
	Invoke-WebRequest "https://github.com/pbatard/Fido/raw/master/Fido.ps1" -OutFile $filename
}

Function Clean-Rows([string]$filename) {
	$output = ""
	foreach($line in Get-Content $filename){
		if ($line.StartsWith(" - ")) {
			$cleanoutput = $line.Remove(0,3)
			$output += "$cleanoutput`n"
		}
	}
	$output.Substring(0,$output.Length-1) | Set-Content $filename
	Start-Sleep -Seconds 1.5 # In some cases, access too much quickly output* files can cause errors.
}

Function ShowPopup([string]$PopupTitle,[string]$PopupText,[string]$PopupContent,[string]$WinVer,[string]$WinRel,[string]$WinLang) {
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	$form = New-Object System.Windows.Forms.Form
	$form.Text = "FIDO GUI - $($PopupTitle)"
	$form.Size = New-Object System.Drawing.Size(335,270)
	$form.StartPosition = "CenterScreen"

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(10,160)
	$OKButton.Size = New-Object System.Drawing.Size(75,23)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(90,160)
	$CancelButton.Size = New-Object System.Drawing.Size(75,23)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10)
	$label.Size = New-Object System.Drawing.Size(280,20)
	$label.Text = $PopupText
	$form.Controls.Add($label)

	$swinfo = New-Object System.Windows.Forms.Label
	$swinfo.Location = New-Object System.Drawing.Point(10,200)
	$swinfo.Size = New-Object System.Drawing.Size(280,20)
	$swinfo.Text = "FIDO GUI $($FGV)"
	$form.Controls.Add($swinfo)

	$listBox = New-Object System.Windows.Forms.ListBox
	$listBox.Location = New-Object System.Drawing.Point(10,30)
	$listBox.Size = New-Object System.Drawing.Size(300,20)
	$listBox.Height = 130

	Switch ($PopupContent)
	{
		"OSVersion" {
			$(.\Fido.ps1 -Win list) *>&1 > "output_win.txt"
			Clean-Rows "output_win.txt"
			Get-Content "output_win.txt" | Foreach {
				[void] $listBox.Items.Add("$_")
			}
			$listBox.SetSelected(0,$true)
			Remove-Item "output_win.txt"
		}
		"RelList" {
			$(.\Fido.ps1 -Win $WinVer -Rel List) *>&1 > "output_rel.txt"
			Clean-Rows "output_rel.txt"
			Get-Content "output_rel.txt" | Foreach {
				[void] $listBox.Items.Add("$_")
			}
			$listBox.SetSelected(0,$true)
			Remove-Item "output_rel.txt"
		}
		"Lang" {
			$(.\Fido.ps1 -Win $WinVer -Rel $WinRel -Lang list) *>&1 > "output_lang.txt"
			Clean-Rows "output_lang.txt"
			Get-Content "output_lang.txt" | Foreach {
				[void] $listBox.Items.Add("$_")
			}
			$listBox.SetSelected(0,$true)
			Remove-Item "output_lang.txt"
		}
		"Arch" {
			$(.\Fido.ps1 -Win $WinVer -Rel $WinRel -Lang $WinLang -Arch list) *>&1 > "output_arch.txt"
			Clean-Rows "output_arch.txt"
			Get-Content "output_arch.txt" | Foreach {
				[void] $listBox.Items.Add("$_")
			}
			$listBox.SetSelected(0,$true)
			Remove-Item "output_arch.txt"
		}
	}

	$form.Controls.Add($listBox)
	$form.Topmost = $True
	$result = $form.ShowDialog()
	if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
		$PopupOutput = $listBox.SelectedItem
		return $PopupOutput
	} else {
		exit
	}
}

Function Get-Folder($initialDirectory="") {
	[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

	$foldername = New-Object System.Windows.Forms.FolderBrowserDialog
	$foldername.Description = "Select a folder where download ISO file"
	$foldername.rootfolder = "MyComputer"
	$foldername.SelectedPath = $initialDirectory

	if($foldername.ShowDialog() -eq "OK") {
		$folder += $foldername.SelectedPath
	} else {
		exit
	}
	return $folder
}

Function Size-To-Human-Readable([uint64]$size)
{
	$suffix = "bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"
	$i = 0
	while ($size -gt 1kb) {
		$size = $size / 1kb
		$i++
	}
	"{0:N1} {1}" -f $size, $suffix[$i]
}

Function ISO-Download([string]$SelectedOS,[string]$SelectedRel,[string]$SelectedLang,[string]$SelectedArch,[string]$DownloadFolder) {
	$ISOUrl = .\Fido.ps1 -Win $SelectedOS -Rel $SelectedRel -Lang $SelectedLang -Arch $SelectedArch -GetUrl
	try {
		$pattern = '.*\/(.*\.iso).*'
		$File = [regex]::Match($ISOUrl, $pattern).Groups[1].Value
		$str_size = (Invoke-WebRequest -UseBasicParsing -Uri $ISOUrl -Method Head).Headers.'Content-Length'
		$tmp_size = [uint64]::Parse($str_size)
		$Size = Size-To-Human-Readable $tmp_size
		Write-Host "Downloading '$File' ($Size) ..."
		Invoke-WebRequest -UseBasicParsing -Uri $ISOUrl -OutFile "$($DownloadFolder)\$($File)"
	} catch {
		Error($_.Exception.Message)
		return 404
	}
	return "Done."
}

try {
	$prevPwd = $PWD; Set-Location -ErrorAction Stop -LiteralPath $PSScriptRoot
	Check-Fido
	if($Update) {
		Write-Host "Check for Fido updates ..."
		Download-Fido("Fido_new.ps1")
		$MD5Old = Get-FileHash -Algorithm MD5 "Fido.ps1" | Select-Object -ExpandProperty Hash
		$MD5New = Get-FileHash -Algorithm MD5 "Fido_new.ps1" | Select-Object -ExpandProperty Hash
		if ($MD5New -ne $MD5Old) {
			Remove-Item "Fido.ps1"
			Move "Fido_new.ps1" "Fido.ps1"
			$Fido_info = Invoke-RestMethod -Uri "https://api.github.com/repos/pbatard/Fido/tags"
			Write-Host "Fido updated to $($Fido_info.name[0])" -f Green
		} else {
			Remove-Item "Fido_new.ps1"
			Write-Host "Fido is up to date." -f Yellow
		}
	}

	$SelectedOS = ShowPopup "OS Version" "Please select OS version:" "OSVersion" "" "" ""
	$SelectedRel = ShowPopup "OS Release" "Please select OS release:" "RelList" "$SelectedOS" "" ""
	$SelectedLang = ShowPopup "OS Language" "Please select OS language:" "Lang" "$SelectedOS" "$SelectedRel" ""
	$SelectedArch = ShowPopup "OS Arch" "Please select OS arch:" "Arch" "$SelectedOS" "$SelectedRel" "$SelectedLang"
	Do { $DownloadFolder = Get-Folder }
	until ($DownloadFolder -ne $null)
	Write-Host "Trying to download Windows $SelectedOS $SelectedRel $SelectedArch ($SelectedLang) in $DownloadFolder ..."
	ISO-Download "$SelectedOS" "$SelectedRel" "$SelectedLang" "$SelectedArch" "$DownloadFolder"
}
finally {
  # Restore the previous location.
  $prevPwd | Set-Location
}
