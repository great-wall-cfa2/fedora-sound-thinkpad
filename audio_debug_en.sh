#!/usr/bin/env bash

LOG_FILE="audio_debug.log"
MODPROBE_CONF="/etc/modprobe.d/alsa.conf"

echo "=== AUDIO DEBUG LOG $(date) ===" | tee "$LOG_FILE"

# 1. Hardware audio device info
echo -e "\n== inxi -A ==" | tee -a "$LOG_FILE"
inxi -A | tee -a "$LOG_FILE"

# 2. Loaded sound modules
echo -e "\n== lsmod | grep snd ==" | tee -a "$LOG_FILE"
lsmod | grep snd | tee -a "$LOG_FILE"

# 3. Check SOF logs in the kernel
echo -e "\n== dmesg | grep -i sof ==" | tee -a "$LOG_FILE"
dmesg | grep -i sof | tee -a "$LOG_FILE"

# 4. Check dsp_driver configuration
echo -e "\n== Checking $MODPROBE_CONF ==" | tee -a "$LOG_FILE"
if [[ -f "$MODPROBE_CONF" ]]; then
    cat "$MODPROBE_CONF" | tee -a "$LOG_FILE"
else
    echo "File $MODPROBE_CONF does not exist" | tee -a "$LOG_FILE"
fi

# 5. Ask user whether to switch audio mode
echo -e "\nThe current audio mode might be incorrect." | tee -a "$LOG_FILE"
echo -e "Please choose an audio driver mode:" | tee -a "$LOG_FILE"
echo "1) SOF (modern DSP driver)" | tee -a "$LOG_FILE"
echo "2) HDA (legacy driver, often more reliable)" | tee -a "$LOG_FILE"
read -p "Enter 1 or 2 and press Enter: " choice

if [[ "$choice" == "1" ]]; then
    echo -e "\n✅ Enabling SOF mode (dsp_driver=3)" | tee -a "$LOG_FILE"
    echo 'options snd-intel-dspcfg dsp_driver=3' | sudo tee "$MODPROBE_CONF"
elif [[ "$choice" == "2" ]]; then
    echo -e "\n✅ Enabling HDA mode (dsp_driver=1)" | tee -a "$LOG_FILE"
    echo 'options snd-intel-dspcfg dsp_driver=1' | sudo tee "$MODPROBE_CONF"
else
    echo -e "\n❌ Invalid input. Mode not changed." | tee -a "$LOG_FILE"
fi

echo -e "\n⏳ Updating initramfs (if applicable):" | tee -a "$LOG_FILE"
if command -v update-initramfs &> /dev/null; then
    sudo update-initramfs -u | tee -a "$LOG_FILE"
elif command -v dracut &> /dev/null; then
    sudo dracut -f | tee -a "$LOG_FILE"
else
    echo "⚠ Neither update-initramfs nor dracut found" | tee -a "$LOG_FILE"
fi

echo -e "\n🔄 Please reboot your system to apply changes!" | tee -a "$LOG_FILE"
