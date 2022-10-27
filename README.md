# FidoGUI 🐶
"*A graphical user interface for Fido.ps1*"

**Fido.ps1** is a PowerShell script made by [Pete Batard](https://github.com/pbatard), father of the fantastic utility [Rufus](https://github.com/pbatard/rufus). It allows you to easily download Microsoft Windows ISO files directly from Microsoft's servers.

The Fido.ps1 functions are built into Rufus and can be used directly from the application's GUI, but if you want to use only the PowerShell script, you need to know parameters, syntax, and other details of PowerShell (and of the Fido.ps1 script) that you maybe don't care about.

For this reason, I wrote a small PowerShell script that adds the GUI to Fido.ps1, allowing you to interact with a series of windows (a wizard) that will allow you to choose the version of Windows to download, the language, and the architecture.

![FidoGUI: Select OS version](https://raw.githubusercontent.com/gioxx/FidoGUI/master/assets/0_fidogui_osversion.png) ![FidoGUI: Select OS release](https://raw.githubusercontent.com/gioxx/FidoGUI/master/assets/1_fidogui_osrelease.png)  
![FidoGUI: Select OS language](https://raw.githubusercontent.com/gioxx/FidoGUI/master/assets/2_fidogui_oslang.png) ![FidoGUI: Select OS architecture](https://raw.githubusercontent.com/gioxx/FidoGUI/master/assets/3_fidogui_osarch.png)   

![FidoGUI: Select folder where download ISO file](https://raw.githubusercontent.com/gioxx/FidoGUI/master/assets/4_fidogui_folder.png)   

![FidoGUI: PowerShell can now download the ISO file from Microsoft](https://raw.githubusercontent.com/gioxx/FidoGUI/master/assets/5_fidogui_pshelldownload.png)  

**FidoGUI.ps1** needs PowerShell version 5 or superior.  
FidoGUI.ps1 searches for the Fido.ps1 script at startup (in the same working directory of FidoGUI.ps1), downloading it directly from the GitHub repository in case it cannot find it.

## Next step:

- Search for updates of Fido.ps1 in opening FidoGUI.ps1 script (actually you can use `.\FidoGUI.ps1 -Update`).
- Integration of an automatic update search and installation function for FidoGUI.ps1 at startup.
