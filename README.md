# FidoGUI 🐶
*A graphical user interface for Fido.ps1*

## 📌 What is this?

**Fido.ps1** is a PowerShell script created by [Pete Batard](https://github.com/pbatard), the author of the brilliant [Rufus](https://github.com/pbatard/rufus) utility. It enables direct downloads of official Microsoft Windows ISO images from Microsoft’s servers.

While **Fido.ps1** is integrated into Rufus and can be accessed via its GUI, using the script independently requires knowledge of PowerShell parameters, syntax, and switches — which you might not care to learn.

That’s where **FidoGUI.ps1** comes in.

## 🎯 What does FidoGUI do?

**FidoGUI.ps1** is a wrapper that gives **Fido.ps1** a simple graphical interface, acting as a wizard that guides you through:

1. Selecting the Windows version  
2. Choosing a specific release  
3. Picking your preferred language  
4. Defining the system architecture  
5. Selecting the destination folder for your ISO  
6. Automatically downloading the ISO file from Microsoft’s servers

> All of this — without typing a single line of PowerShell.

---

## 🖼️ Screenshots

| Step-by-step GUI | Description |
|------------------|-------------|
| ![Select OS version](https://raw.githubusercontent.com/gioxx/FidoGUI/master/assets/0_fidogui_osversion.png) ![Select OS release](https://raw.githubusercontent.com/gioxx/FidoGUI/master/assets/1_fidogui_osrelease.png) | Choose version & release |
| ![Select OS language](https://raw.githubusercontent.com/gioxx/FidoGUI/master/assets/2_fidogui_oslang.png) ![Select OS architecture](https://raw.githubusercontent.com/gioxx/FidoGUI/master/assets/3_fidogui_osarch.png) | Choose language & architecture |
| ![Select download folder](https://raw.githubusercontent.com/gioxx/FidoGUI/master/assets/4_fidogui_folder.png) | Select where to save the ISO |
| ![Downloading ISO](https://raw.githubusercontent.com/gioxx/FidoGUI/master/assets/5_fidogui_pshelldownload.png) | PowerShell begins download |

---

## ⚙️ Requirements

- Windows with **PowerShell 5.1** or later  
- Internet connection  
- No administrative privileges required  

> `FidoGUI.ps1` checks for the presence of `Fido.ps1` in its working directory at launch.  
> If missing, it automatically downloads the latest version from [GitHub](https://github.com/pbatard/Fido).

---

## 🚀 Usage

Launch FidoGUI from PowerShell:

```powershell
.\FidoGUI.ps1
```

Optionally, check for updates to **Fido.ps1** before launching:

```powershell
.\FidoGUI.ps1 -Update
```

---

## 🧪 Run directly from GitHub (no download required)

If you just want to run **FidoGUI.ps1** without cloning the repository, you can do so directly via PowerShell:

```powershell
irm https://raw.githubusercontent.com/gioxx/FidoGUI/master/FidoGUI.ps1 | iex
```

Or, using the long form for clarity:

```powershell
Invoke-Expression (Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/gioxx/FidoGUI/master/FidoGUI.ps1).Content
```

> ⚠️ Make sure your execution policy allows this, or run from an **elevated prompt**:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope Process
> ```

This will:

- Download the latest version of `FidoGUI.ps1` into memory
- Run it immediately
- Download `Fido.ps1` automatically if missing

---

## 🔮 Roadmap

- [ ] Run update check for `Fido.ps1` automatically at startup  
- [ ] Add self-update feature for `FidoGUI.ps1`  
- [ ] Improve error handling and fallback messages for API blocks

---

## 🤝 Credits

- [Pete Batard](https://github.com/pbatard) for the original `Fido.ps1` script  
- Inspiration from Rufus, Microsoft Docs, and community examples  
- Various [Stack Overflow](https://stackoverflow.com/) contributors for GUI patterns and PowerShell tips  
