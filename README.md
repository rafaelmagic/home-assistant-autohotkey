# home-assistant-autohotkey
Control Home Assistant (Rest API) with AutoHotKey


✅ HOW TO INSTALL AutoHotkey v2.0

🧩 AutoHotkey lets you automate anything on Windows — keyboard, mouse, web requests, and more!

🔹 1. Go to the Official Download Page

👉 https://www.autohotkey.com/download

You’ll be taken to the official AutoHotkey download page.

🔹 2. Click on “Download AutoHotkey v2.0”

You’ll see multiple download options — make sure to click the one labeled:

Download AutoHotkey v2.0

✅ This is the modern version you want (AutoHotkey v1.1 is legacy).

🔹 3. Run the Installer

Once downloaded:

🖱️ Double-click AutoHotkey_2.x.x_setup.exe to run the installer.
📋 Choose “Express Installation” unless you have a specific need.

🔹 4. Verify the Install

After install, you can confirm it’s working:

Press Win + R

Type: notepad

Paste this code:

#Requires AutoHotkey v2.0

MsgBox "✅ AutoHotkey v2 is working!"


Save it as test.ahk on your desktop

Double-click the file — you should see a message box.




✅ STEP-BY-STEP INSTALLATION FOR JSON.ahk

🔹 1. Download JSON.ahk
Go to:
👉 https://github.com/thqby/ahk2_lib/blob/master/JSON.ahk

Click the “Raw” button (top right of the code block).
Then press Ctrl+S (or right-click > “Save As”) to save the file as:

JSON.ahk

🔹 2. Place it in your AutoHotkey Lib folder

Put the file in one of the following folders:

📁 Option A: Per-user

C:\Users\YourName\Documents\AutoHotkey\Lib\JSON.ahk

📁 Option B: Same folder as your script

Just drop it next to your .ahk file.



✅ STEP-BY-STEP INSTALLATION FOR passwords.ahk
(🔐 Credential Manager for AHK)
📦 From:
👉 https://gist.github.com/fattredd/169835fa26972df8029f9dd7b4d3d6d4

🔹 1. Download passwords.ahk
Go to the link above.
Click the “Raw” button (top right of the code block).
Then press Ctrl+S (or right-click > “Save As”) and save it as:

passwords.ahk

🔹 2. Place it in your AutoHotkey Lib folder

Put the file in one of the following folders:

📁 Option A: Per-user

C:\Users\YourName\Documents\AutoHotkey\Lib\passwords.ahk

📁 Option B: Same folder as your script

Just drop it next to your .ahk file.


✅ HOW TO OPEN WINDOWS CREDENTIAL MANAGER
🔐 Windows Credential Manager is where passwords are stored securely with encryption.

🔹 1. Open Credential Manager
There are 3 easy ways to launch it:

✅ Option A: Use Windows Search
Press Win (Windows key)

Type: Credential Manager

Click Credential Manager from the search results

✅ Option B: Run Command
Press Win + R to open the Run dialog

Type:

control /name Microsoft.CredentialManager
Press Enter

✅ Option C: From Control Panel
Open Control Panel

Go to:
User Accounts → Credential Manager

🔹 2. Choose "Windows Credentials"
🟢 Click the Windows Credentials tab (not Web Credentials)
That's where AHK stores tokens when using passwords.ahk.

🔹 3. Add or Edit a Credential
To add a new credential manually:

Click Add a Windows credential

Enter:

Internet or network address: AHK_HomeAssistantAPI

User name: (anything, e.g. ahk_user)

Password: your Home Assistant long-lived token

Click OK



✅ INSTALL & SETUP Home_Assistant_AutoHotKey.ahk

🔹 1. Download the Script

📥 Download or create the script file named:

Home_Assistant_AutoHotKey.ahk

Place it anywhere — for example:

📁 C:\Users\YourName\Desktop\Home_Assistant_AutoHotKey.ahk

🔹 2. Launch the Script

▶️ Double-click the file to launch it.

This will run the script in the background (🟢 green H icon in your system tray).

🔹 3. Store Your API Token via Hotkey

Press this hotkey to store your Home Assistant token securely:

Ctrl + Alt + C

You’ll see a popup window with these fields===

Key: AHK_HomeAssistantAPI

User name: (can be anything, like ahk_user)

Password: your Home Assistant long-lived access token

🖱️ Click the "Add Pass" button.

✅ You can confirm it was saved by checking:

👉 Credential Manager > Windows Credentials

Look for: AHK_HomeAssistantAPI

🔹 4. Set Your Home Assistant URL

Open the script in Notepad:

📄 Right-click Home_Assistant_AutoHotKey.ahk > "Edit with Notepad"

Find this line (around line 84):

static Url := "https://myhomeassistanturl.com"

Replace it with your own Home Assistant URL

💾 Save the file.

🔹 5. Reload the Script

📦 Double-click the script again to reload it with the new settings.

🔹 6. Test the API Connection

Press this hotkey:

Ctrl + Alt + Z

✅ A message will display:

"API is running."

If you get an error instead, double-check your URL and token.



