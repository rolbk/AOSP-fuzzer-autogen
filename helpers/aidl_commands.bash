aidl -I packages/modules/DnsResolver/aidl_api/dnsresolver_aidl_interface/current/ \
 	-I packages/modules/Connectivity/staticlibs/netd/aidl_api/netd_event_listener_interface/current/ \
 	--lang fuzz-harness packages/modules/DnsResolver/aidl_api/dnsresolver_aidl_interface/current/android/net/IDnsResolver.aidl \
 	--out ~/aidl_gen --header_out ~/aidl_gen/include/
cp ~/aidl_gen/android/net/IDnsResolver.cpp ~/AOSP/packages/modules/DnsResolver/tests/fuzzer/autogen.cpp
# WORKS, slightly better

cd hardware/interfaces/nfc/aidl
aidl --structured --stability=vintf -I . --lang fuzz-harness android/hardware/nfc/INfc.aidl --out ~/aidl_gen --header_out ~/aidl_gen/include/ 
cp ~/aidl_gen/android/hardware/nfc/INfc.cpp ~/AOSP/hardware/st/nfc/aidl/fuzzer/Autogen.cpp
# WORKS but gets stuck

cd frameworks/hardware/interfaces/sensorservice/aidl
aidl --structured --stability=vintf -I . \
	-I ../../../../../hardware/interfaces/sensors/aidl \
	-I ../../../../../hardware/interfaces/common/aidl \
	-I ../../../../../hardware/interfaces/common/fmq/aidl \
	--lang fuzz-harness android/frameworks/sensorservice/ISensorManager.aidl --out ~/aidl_gen --header_out ~/aidl_gen/include/
# not possible because linux/android/binder.h not found

cd hardware/interfaces/vibrator/aidl
aidl --structured --stability=vintf -I . -I ../../../../frameworks/native/aidl/binder/ --lang fuzz-harness android/hardware/vibrator/IVibratorManager.aidl --out ~/aidl_gen --header_out ~/aidl_gen/include/
# not possible because weird incompatibility with stability in aidl generation

cd ./packages/modules/Virtualization/android/virtualizationservice/aidl
aidl --structured -I . --lang fuzz-harness android/system/virtualizationservice/IVirtualizationService.aidl --out ~/aidl_gen --header_out ~/aidl_gen/include/
# not supported: List<FD>

cd packages/modules/StatsD/aidl
aidl --structured -I . --lang fuzz-harness android/os/IStatsd.aidl --out ~/aidl_gen --header_out ~/aidl_gen/include/
cp ~/aidl_gen/android/os/IStatsd.cpp ~/AOSP/packages/modules/StatsD/statsd/fuzzers/autogen.cpp
# WORKS, speeeeed!cd 

cd hardware/interfaces/neuralnetworks/aidl
aidl --structured --stability=vintf -I . \
    -I ../../common/aidl/ \
    -I ../../graphics/common/aidl/ \
   	--lang fuzz-harness android/hardware/neuralnetworks/IDevice.aidl \
    --out ~/aidl_gen --header_out ~/aidl_gen/include/
cp ~/aidl_gen/android/hardware/neuralnetworks/IDevice.cpp ~/AOSP/packages/modules/NeuralNetworks/driver/sample/autogen.cpp
# naming collision "model_pools_ashmem_size"
# resolved manually
# not possible because linux/android/binder.h not found

cd hardware/interfaces/threadnetwork/aidl
aidl --structured --stability=vintf -I . --lang fuzz-harness android/hardware/threadnetwork/IThreadChip.aidl --out ~/aidl_gen --header_out ~/aidl_gen/include/
cp ~/aidl_gen/android/hardware/threadnetwork/IThreadChip.cpp ~/AOSP/hardware/interfaces/threadnetwork/aidl/default/autogen.cpp
# WORKS, but gets stuck sooner than parcel fuzzer

cd hardware/interfaces/automotive/occupant_awareness/aidl/
aidl --structured --stability=vintf -I . --lang fuzz-harness android/hardware/automotive/occupant_awareness/IOccupantAwareness.aidl --out ~/aidl_gen --header_out ~/aidl_gen/include/
cp ~/aidl_gen/android/hardware/automotive/occupant_awareness/IOccupantAwareness.cpp ~/AOSP/hardware/interfaces/automotive/occupant_awareness/aidl/default/autogen.cpp
#CANNOT LINK EXECUTABLE "./android.hardware.automotive.occupant_awareness-service.fuzzer": cannot locate symbol "AIBinder_Class_setTransactionCodeToFunctionNameMap" referenced by "/data/local/tmp/android.hardware.automotive.occupant_awareness-service.fuzzer"...

# ./frameworks/av/media/libaudioclient/aidl/android/media/IAudioPolicyService.aidl
# frameworks/av/services/audiopolicy/fuzzer/aidl/audiopolicy_aidl_fuzzer.cpp
cd frameworks/av/media/libaudioclient/aidl/
aidl --structured -I . \
    -I ../../../aidl \
    -I ../../../../native/libs/permission/aidl \
    -I ../../../../../system/hardware/interfaces/media/aidl_api/android.media.audio.common.types/current/ \
    --lang fuzz-harness android/media/IAudioPolicyService.aidl --out ~/aidl_gen --header_out ~/aidl_gen/include/
# segfaults my code, fuck

# frameworks/native/cmds/installd/binder/android/os/IInstalld.aidl
# frameworks/native/cmds/installd/tests/fuzzers/InstalldServiceFuzzer.cpp
cd frameworks/native/cmds/installd/binder/
aidl --structured --stability=vintf -I . --lang fuzz-harness android/os/IInstalld.aidl --out ~/aidl_gen --header_out ~/aidl_gen/include/
cp ~/aidl_gen/android/os/IInstalld.cpp ~/AOSP/frameworks/native/cmds/installd/tests/fuzzers/Autogen.cpp
# not supported: List
# fixed, WORKS, but needs -fork=8 -ignore_crashes=1 -> speed? plateau at ~1900, max out equally?

# frameworks/av/media/libmedia/aidl/android/IMediaExtractorService.aidl
# frameworks/av/services/mediaextractor/fuzzers/MediaExtractorServiceFuzzer.cpp
cd frameworks/av/media/libmedia/aidl/
aidl --structured --stability=vintf -I . --lang fuzz-harness android/IMediaExtractorService.aidl --out ~/aidl_gen --header_out ~/aidl_gen/include/
cp ~/aidl_gen/android/IMediaExtractorService.cpp ~/AOSP/frameworks/av/services/mediaextractor/fuzzers/Autogen.cpp
# WORKS but also slower than parcel_fuzzer
# OK Ratio only 0.7

