# AutoHashBang
HashBangs for AutoHotkey.
Specify which AHK to use with your script with an interpreter directive. Simply put `;#! C:\Path\To\AutoHotkey.exe` at the top of your .ahk or .ahc file to switch interpreters.

---

To install or uninstall, just run the script file directly. If the script is moved while it is installed, the .ahk and .ahc shell associations will be broken, so it is recommended to uninstall before moving it.

When AutoHashBang is installed, it will create a second copy of AutoHotkey.exe called AutoHotConsole.exe. It will then set AutoHotConsole to be a console application, allowing scripts run through it to use StdIn/Out from a normal console.

AutoHashBang will override the shell extensions for .ahk and .ahc files with itself being run through AutoHotkey.exe and AutoHotConsole.exe, respectively. Because of how windows works, you can't choose whether to be a console app after execution starts, so that's why a separate shell association for it is necessary.