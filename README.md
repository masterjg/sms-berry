
# SMSBerry 🍓 - Raspberry Pi SMS Gateway

**SMSBerry** is a set of scripts to turn your Raspberry Pi and a Huawei USB stick into a fully functional SMS gateway. This setup leverages [Gammu](https://wammu.eu/gammu/) for managing SMS services and provides a straightforward way to handle incoming SMS messages on your Raspberry Pi.

## 🛠️ Setup Overview

### Prerequisites
- Raspberry Pi (tested on Raspberry Pi OS)
- Huawei USB stick (configured for SMS-only use, without internet or ModemManager)

### 📁 Scripts Overview

1. **setup1.sh**: Initial Raspberry Pi system preparation
2. **setup2.sh**: Configures the USB stick and sets up a symbolic link for SMS handling
3. **setup3.sh**: Installs and configures Gammu for SMS gateway functionality

---

## 🔧 Script Details

### `setup1.sh` - Raspberry Pi System Update and Upgrade
This script ensures that the Raspberry Pi is up-to-date and ready for SMSBerry setup:
- Performs a system update and upgrade.
- Reboots the system to apply updates.

#### Usage
```bash
bash setup1.sh
```

---

### `setup2.sh` - Configure Huawei USB Stick and Udev Rule
This script configures the Huawei USB stick for SMS use only on the Raspberry Pi:
- Sets `HuaweiAltModeGlobal` to enable compatibility with the USB device.
- Disables `ModemManager` to prevent conflicts with the SMS setup.
- Installs `gawk`, required for identifying the modem’s USB Vendor and Product IDs.
- Creates a udev rule that:
  - Establishes a symbolic link `/dev/sms-proxy` for the USB stick.
  - Automatically reloads the Gammu SMS service (`gammu-smsd`) when the modem is connected.

#### Usage
```bash
bash setup2.sh
```

---

### `setup3.sh` - Gammu and SMS Configuration
This script completes the SMSBerry setup by:
1. Installing Gammu and Gammu-SMSD.
2. Configuring Gammu to communicate with the Huawei USB stick via `/dev/sms-proxy`.
3. Creating a `process_sms.sh` script that handles incoming SMS messages by:
   - Reading the sender’s number and message content.
   - Logging the SMS data for easy monitoring.
4. Configuring Gammu-SMSD to use the `process_sms.sh` script to process received SMS.

#### Usage
```bash
bash setup3.sh
```

---

## 🔍 How to Use SMSBerry

1. Run each setup script in order.
2. Once the setup is complete, SMS messages sent to the Huawei USB stick will automatically be logged by Gammu on the Raspberry Pi.

---

## 📝 Notes
- Ensure `gammu-smsd` is running and enabled to manage incoming messages.
- To view SMS logs, use `journalctl -xef`.

Transform your Raspberry Pi into a dedicated SMS gateway with **SMSBerry**! 🍓📲
