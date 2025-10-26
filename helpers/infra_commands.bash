
###### to have cmdtools available ###### 

export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator

###### commands to create emulator ###### 

export ANDROID_AVD_HOME=/emanuel-avd
export ANDROID_EMULATOR_HOME=/emanuel-avd

SYSIMG="system-images;android-35;google_apis;x86_64"
AVDNAME="pixel6-rooted-8"
DEVICE_ID="pixel_6"

avdmanager delete avd -n $AVDNAME 2>/dev/null || true

echo "no" | avdmanager create avd \
        -n $AVDNAME \
        -k "$SYSIMG" \
        -d "$DEVICE_ID"

emulator -avd $AVDNAME \
         -no-window -no-audio -gpu swiftshader_indirect \
         -writable-system & disown
EMU_PID=$!

adb wait-for-device

###### emulator mapping ###### 

emulator-5554: pixel6-rooted-1       # 00_FuzzHelloServer
emulator-5556: testdevice            # 01_resolv_service_fuzzer
emulator-5558: pixel6-rooted-3       # 02_nfc_service_fuzzer
emulator-5560: pixel6-rooted-4       # 03_statsd_service_fuzzer
emulator-5562: pixel6-rooted-5       # 04_android.hardware.threadnetwork-service.fuzzer
emulator-5564: pixel6-rooted-6       # 05_installd_service_fuzzer
emulator-5566: pixel6-rooted-7       # 06_mediaextractor_service_fuzzer
emulator-5568: pixel6-rooted-8       # 07_android.hardware.automotive.occupant_awareness-service.fuzzer

###### copy stuff to emulators ###### 

adb -s emulator-5554 shell "rm -rf /data/local/tmp/*"
adb -s emulator-5554 push 00_FuzzHelloServer/* /data/local/tmp
adb -s emulator-5554 shell "chmod +x /data/local/tmp/*"

adb -s emulator-5556 shell "rm -rf /data/local/tmp/*"
adb -s emulator-5556 push 01_resolv_service_fuzzer/* /data/local/tmp
adb -s emulator-5556 shell "cp /apex/com.android.tethering/lib64/libcom.android.tethering.dns_helper.so /data/local/tmp/"
adb -s emulator-5556 shell "chmod +x /data/local/tmp/*"

adb -s emulator-5558 shell "rm -rf /data/local/tmp/*"
adb -s emulator-5558 push 02_nfc_service_fuzzer/* /data/local/tmp
adb -s emulator-5558 shell "chmod +x /data/local/tmp/*"

adb -s emulator-5560 shell "rm -rf /data/local/tmp/*"
adb -s emulator-5560 push 03_statsd_service_fuzzer/* /data/local/tmp
adb -s emulator-5560 shell "chmod +x /data/local/tmp/*"

adb -s emulator-5562 shell "rm -rf /data/local/tmp/*"
adb -s emulator-5562 push 04_android.hardware.threadnetwork-service.fuzzer/* /data/local/tmp
adb -s emulator-5562 shell "chmod +x /data/local/tmp/*"

adb -s emulator-5564 shell "rm -rf /data/local/tmp/*"
adb -s emulator-5564 push 05_installd_service_fuzzer/* /data/local/tmp
adb -s emulator-5564 shell "chmod +x /data/local/tmp/*"

adb -s emulator-5566 shell "rm -rf /data/local/tmp/*"
adb -s emulator-5566 push 06_mediaextractor_service_fuzzer/* /data/local/tmp
adb -s emulator-5566 shell "chmod +x /data/local/tmp/*"

adb -s emulator-5568 shell "rm -rf /data/local/tmp/*"
adb -s emulator-5568 push 07_android.hardware.automotive.occupant_awareness-service.fuzzer/* /data/local/tmp
adb -s emulator-5568 shell "chmod +x /data/local/tmp/*"

###### start fuzzing ###### 

adb -s emulator-5554 shell "ps -A | grep uzz"
adb -s emulator-5554 shell "ps -A | grep logcat"
adb -s emulator-5554 shell "nohup logcat -e 'Binder transactions' -f /data/local/tmp/logcat.txt </dev/null >/dev/null 2>&1 &"
adb -s emulator-5554 shell "cd /data/local/tmp && nohup sh run_fuzz.sh </dev/null >/dev/null 2>&1 &"
adb -s emulator-5554 shell "ps -A | grep uzz"
adb -s emulator-5554 shell "ps -A | grep logcat"

adb -s emulator-5556 shell "ps -A | grep uzz"
adb -s emulator-5556 shell "ps -A | grep logcat"
adb -s emulator-5556 shell "nohup logcat -e 'Binder transactions' -f /data/local/tmp/logcat.txt </dev/null >/dev/null 2>&1 &"
adb -s emulator-5556 shell "cd /data/local/tmp && nohup sh run_fuzz.sh </dev/null >/dev/null 2>&1 &"
adb -s emulator-5556 shell "ps -A | grep uzz"
adb -s emulator-5556 shell "ps -A | grep logcat"

adb -s emulator-5558 shell "ps -A | grep uzz"
adb -s emulator-5558 shell "ps -A | grep logcat"
adb -s emulator-5558 shell "nohup logcat -e 'Binder transactions' -f /data/local/tmp/logcat.txt </dev/null >/dev/null 2>&1 &"
adb -s emulator-5558 shell "cd /data/local/tmp && nohup sh run_fuzz.sh </dev/null >/dev/null 2>&1 &"
adb -s emulator-5558 shell "ps -A | grep uzz"
adb -s emulator-5558 shell "ps -A | grep logcat"

adb -s emulator-5560 shell "ps -A | grep uzz"
adb -s emulator-5560 shell "ps -A | grep logcat"
adb -s emulator-5560 shell "nohup logcat -e 'Binder transactions' -f /data/local/tmp/logcat.txt </dev/null >/dev/null 2>&1 &"
adb -s emulator-5560 shell "cd /data/local/tmp && nohup sh run_fuzz.sh </dev/null >/dev/null 2>&1 &"
adb -s emulator-5560 shell "ps -A | grep uzz"
adb -s emulator-5560 shell "ps -A | grep logcat"

adb -s emulator-5562 shell "ps -A | grep uzz"
adb -s emulator-5562 shell "ps -A | grep logcat"
adb -s emulator-5562 shell "nohup logcat -e 'Binder transactions' -f /data/local/tmp/logcat.txt </dev/null >/dev/null 2>&1 &"
adb -s emulator-5562 shell "cd /data/local/tmp && nohup sh run_fuzz.sh </dev/null >/dev/null 2>&1 &"
adb -s emulator-5562 shell "ps -A | grep uzz"
adb -s emulator-5562 shell "ps -A | grep logcat"

adb -s emulator-5564 shell "ps -A | grep uzz"
adb -s emulator-5564 shell "ps -A | grep logcat"
adb -s emulator-5564 shell "nohup logcat -e 'Binder transactions' -f /data/local/tmp/logcat.txt </dev/null >/dev/null 2>&1 &"
adb -s emulator-5564 shell "cd /data/local/tmp && nohup sh run_fuzz.sh </dev/null >/dev/null 2>&1 &"
adb -s emulator-5564 shell "ps -A | grep uzz"
adb -s emulator-5564 shell "ps -A | grep logcat"

adb -s emulator-5566 shell "ps -A | grep uzz"
adb -s emulator-5566 shell "ps -A | grep logcat"
adb -s emulator-5566 shell "nohup logcat -e 'Binder transactions' -f /data/local/tmp/logcat.txt </dev/null >/dev/null 2>&1 &"
adb -s emulator-5566 shell "cd /data/local/tmp && nohup sh run_fuzz.sh </dev/null >/dev/null 2>&1 &"
adb -s emulator-5566 shell "ps -A | grep uzz"
adb -s emulator-5566 shell "ps -A | grep logcat"

adb -s emulator-5568 shell "ps -A | grep uzz"
adb -s emulator-5568 shell "ps -A | grep logcat"
adb -s emulator-5568 shell "nohup logcat -e 'Binder transactions' -f /data/local/tmp/logcat.txt </dev/null >/dev/null 2>&1 &"
adb -s emulator-5568 shell "cd /data/local/tmp && nohup sh run_fuzz.sh </dev/null >/dev/null 2>&1 &"
adb -s emulator-5568 shell "ps -A | grep uzz"
adb -s emulator-5568 shell "ps -A | grep logcat"







###### start fuzzing (in tmux) ###### 

adb -s emulator-5554 logcat | grep "Binder transactions" | tee -a ~/prod/logcat_00.log
adb -s emulator-5554 shell "cd /data/local/tmp && sh run_fuzz.sh"

adb -s emulator-5556 logcat | grep "Binder transactions" | tee -a ~/prod/logcat_01.log
adb -s emulator-5556 shell "cd /data/local/tmp && sh run_fuzz.sh"

adb -s emulator-5558 logcat | grep "Binder transactions" | tee -a ~/prod/logcat_02.log
adb -s emulator-5558 shell "cd /data/local/tmp && sh run_fuzz.sh"

adb -s emulator-5560 logcat | grep "Binder transactions" | tee -a ~/prod/logcat_03.log
adb -s emulator-5560 shell "cd /data/local/tmp && sh run_fuzz.sh"

adb -s emulator-5562 logcat | grep "Binder transactions" | tee -a ~/prod/logcat_04.log
adb -s emulator-5562 shell "cd /data/local/tmp && sh run_fuzz.sh"

adb -s emulator-5564 logcat | grep "Binder transactions" | tee -a ~/prod/logcat_05.log
adb -s emulator-5564 shell "cd /data/local/tmp && sh run_fuzz.sh"

adb -s emulator-5566 logcat | grep "Binder transactions" | tee -a ~/prod/logcat_06.log
adb -s emulator-5566 shell "cd /data/local/tmp && sh run_fuzz.sh"

adb -s emulator-5568 logcat | grep "Binder transactions" | tee -a ~/prod/logcat_07.log
adb -s emulator-5568 shell "cd /data/local/tmp && sh run_fuzz.sh"














