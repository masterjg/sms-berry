
# Huawei USB Stick SMS Gateway 📱

This repository contains scripts to set up a Huawei USB stick as an SMS gateway on a Linux system. The setup uses [Gammu](https://wammu.eu/gammu/) for managing SMS services and includes three essential scripts for configuring and preparing the system.

## 🛠️ Setup Overview

### Prerequisites
- Linux system (tested on Raspberry Pi)
- Huawei USB stick (configured for SMS-only, without internet or ModemManager)

### 📁 Scripts Overview

1. **setup1.sh**: Initial system preparation
2. **setup2.sh**: Configures the USB stick and sets up a symbolic link for easy access
3. **setup3.sh**: Installs and configures Gammu for SMS handling

---

## 🔧 Script Details

### `setup1.sh` - System Update and Upgrade
This script ensures that the system is up-to-date:
- Performs a system update and upgrade.
- Reboots the system to apply updates.

#### Usage
```bash
bash setup1.sh
```

---

### `setup2.sh` - Configure Huawei USB Stick and Udev Rule
This script is essential for configuring the Huawei USB stick in a mode suitable for SMS use:
- Sets `HuaweiAltModeGlobal` to enable compatibility with the Huawei USB device.
- Disables `ModemManager` to avoid conflicts with the SMS configuration.
- Installs `gawk`, required for detecting the modem’s USB Vendor and Product IDs.
- Configures a udev rule that:
  - Creates a symbolic link `/dev/sms-proxy` pointing to the USB stick.
  - Automatically reloads the Gammu SMS service (`gammu-smsd`) whenever the modem is connected.

#### Usage
```bash
bash setup2.sh
```

---

### `setup3.sh` - Gammu and SMS Configuration
This script completes the SMS gateway setup by:
1. Installing Gammu and Gammu-SMSD.
2. Configuring Gammu to communicate with the Huawei USB stick via `/dev/sms-proxy`.
3. Setting up a processing script (`process_sms.sh`) to handle received SMS messages:
   - Reads the SMS sender’s number and message.
   - Logs the SMS data for easy monitoring.
4. Configuring Gammu-SMSD to use the `process_sms.sh` script when messages are received.

#### Usage
```bash
bash setup3.sh
```

---

## 🔍 How to Use the SMS Gateway

1. Run each setup script in sequence.
2. Once the setup is complete, send SMS messages to the Huawei USB stick, and Gammu will automatically log the messages.

---

## 📝 Notes
- Ensure that `gammu-smsd` is running and enabled to handle incoming messages.
- You can view the SMS logs by using `journalctl -xef`.

Enjoy using your Huawei USB stick as a dedicated SMS gateway! 🚀
