#!/usr/bin/env bash

LOG_FILE="audio_debug.log"
MODPROBE_CONF="/etc/modprobe.d/alsa.conf"

echo "=== АУДИО ОТЛАДКА $(date) ===" | tee "$LOG_FILE"

# 1. Аппаратное аудио-устройство
echo -e "\n== inxi -A ==" | tee -a "$LOG_FILE"
if ! command -v inxi &>/dev/null; then
    echo "⚠ inxi не установлен. Установите с помощью: sudo pacman -S inxi" | tee -a "$LOG_FILE"
else
    inxi -A | tee -a "$LOG_FILE"
fi

# 2. Загруженные модули
echo -e "\n== lsmod | grep snd ==" | tee -a "$LOG_FILE"
lsmod | grep snd | tee -a "$LOG_FILE"

# 3. Проверка SOF в ядре
echo -e "\n== dmesg | grep -i sof ==" | tee -a "$LOG_FILE"
dmesg | grep -i sof | tee -a "$LOG_FILE"

# 4. Проверка конфигурации dsp_driver
echo -e "\n== Проверка $MODPROBE_CONF ==" | tee -a "$LOG_FILE"
if [[ -f "$MODPROBE_CONF" ]]; then
    cat "$MODPROBE_CONF" | tee -a "$LOG_FILE"
else
    echo "Файл $MODPROBE_CONF не существует" | tee -a "$LOG_FILE"
fi

# 5. Вопрос пользователю: переключить режим?
echo -e "\nТекущий режим может быть неправильным." | tee -a "$LOG_FILE"
echo -e "Выбери режим звука:" | tee -a "$LOG_FILE"
echo "1) SOF (современный драйвер для DSP)" | tee -a "$LOG_FILE"
echo "2) HDA (надежный старый драйвер, часто работает лучше)" | tee -a "$LOG_FILE"
read -p "Введите 1 или 2 и нажмите Enter: " choice

if [[ "$choice" == "1" ]]; then
    echo -e "\n✅ Включение режима SOF (dsp_driver=3)" | tee -a "$LOG_FILE"
    echo 'options snd-intel-dspcfg dsp_driver=3' | sudo tee "$MODPROBE_CONF"
elif [[ "$choice" == "2" ]]; then
    echo -e "\n✅ Включение режима HDA (dsp_driver=1)" | tee -a "$LOG_FILE"
    echo 'options snd-intel-dspcfg dsp_driver=1' | sudo tee "$MODPROBE_CONF"
else
    echo -e "\n❌ Неверный ввод. Режим не изменён." | tee -a "$LOG_FILE"
fi

# 6. Обновление initramfs в Arch
echo -e "\n⏳ Обновление initramfs с помощью mkinitcpio:" | tee -a "$LOG_FILE"
if command -v mkinitcpio &>/dev/null; then
    sudo mkinitcpio -P | tee -a "$LOG_FILE"
else
    echo "⚠ mkinitcpio не найден. Проверьте, установлен ли пакет 'mkinitcpio'." | tee -a "$LOG_FILE"
fi

echo -e "\n🔄 Перезагрузите систему, чтобы применить изменения!" | tee -a "$LOG_FILE"
