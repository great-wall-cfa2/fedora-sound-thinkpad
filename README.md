# Sound problems in Lenovo Thinkpad series
Universal tool for Intel/Lenovo audio diagnostics and treatment
Solving Problems Related to No Sound on Lenovo Thinkpad Series Laptops (Fedora, Ubuntu, Arch)

Autoscript that:

1. Determines which audio device is being used
2. Checks loaded modules
3. Shows SOF errors in dmesg
4. Suggests switching from SOF to HDA or vice versa
5. Writes everything to the audio_debug.log file

How to use:
1. Save as audio_debug_en.sh (English) or audio_debug_ru.sh (Russian)
2. Give execute permissions: chmod +x audio_debug.sh
3. Run: ./audio_debug.sh
