#!/usr/bin/env bash

LOG_FILE="audio_debug.log"
MODPROBE_CONF="/etc/modprobe.d/alsa.conf"

echo "=== AУДИО ОТЛАДКА $(date) ===" | tee "$LOG_FILE"

# 1. Аппаратное аудио-устройство
echo -e "\n== inxi -A ==" | tee -a "$LOG_FILE"
inxi -A | tee -a "$LOG_FILE"

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

echo -e "\n⏳ Обновление initramfs (если используется):" | tee -a "$LOG_FILE"
if command -v update-initramfs &> /dev/null; then
    sudo update-initramfs -u | tee -a "$LOG_FILE"
elif command -v dracut &> /dev/null; then
    sudo dracut -f | tee -a "$LOG_FILE"
else
    echo "⚠ Не найдено ни update-initramfs, ни dracut" | tee -a "$LOG_FILE"
fi

echo -e "\n🔄 Перезагрузите систему, чтобы применить изменения!" | tee -a "$LOG_FILE"
