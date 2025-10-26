.PHONY: push setup tmux_build wait_build execute_aidl wait_aidl pull

# Remote server configuration
REMOTE_USER = 
REMOTE_HOST = 
REMOTE_AOSP_PATH = 
LOCAL_AOSP_PATH = 
TMUX_SESSION = aosp_build

# Setup commands for AOSP (adjust as needed)
SETUP_CMD = source build/envsetup.sh && lunch aosp_cf_arm64_phone-trunk_staging-eng

# The build command you want to run
BUILD_CMD = cd system/tools/aidl && mm -j64

# File that indicates build completion on the remote server
BUILD_DONE_FILE = /tmp/build_done

# The aidl command to run
AIDL_CMD = cd AIDLCppDemo && aidl -I aidl --lang fuzz-harness aidl/com/yuandaima/IHello.aidl --out ../aidl_gen --header_out ../aidl_gen/include/
# old command: aidl-cpp aidl/com/yuandaima/IHello.aidl ../aidl_gen/include/ ../aidl_gen/IHello.cpp -I aidl

# File that indicates aidl execution completion on the remote server
AIDL_DONE_FILE = /tmp/aidl_done

FUZZER_DONE_FILE = /tmp/fuzzer_done

# Whitelisted directories to sync for pushing
WHITELIST_DIRS = system/tools/aidl
WHITELIST_DIRS_RECURSIVE = AIDLCppDemo frameworks/native/libs/binder/tests/parcel_fuzzer

# Whitelist for pulling build artifacts recursively
PULL_WHITELIST = aidl_gen out/target/product/vsoc_arm64/data/fuzz/arm64 out/target/product/vsoc_arm64/system/bin

# Run all steps in sequence.
all_but_fuzz: push setup tmux_build wait_build execute_aidl wait_aidl pull

all: push setup tmux_build wait_build execute_aidl wait_aidl build_fuzzer wait_fuzzer pull adb_push

# 1. Push only the whitelisted directories to the remote server.
push:
	@echo "Pushing whitelisted code changes to remote server..."
	for dir in $(WHITELIST_DIRS); do \
	  rsync -avz --progress \
	    --include '*.hpp' \
	    --include '*.h' \
	    --include '*.cpp' \
	    --include '*.c' \
	    --include '*.aidl' \
	    --include '*.bp' \
	    --include 'Makefile' \
	    --include 'LICENSE' \
	    --exclude '*' \
	    $(LOCAL_AOSP_PATH)/$$dir/ $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_AOSP_PATH)/$$dir; \
	done
	for dir in $(WHITELIST_DIRS_RECURSIVE); do \
	  rsync -avz --progress \
	  	--include '*/' \
	    --exclude '*/gen/' \
	    --include '*.hpp' \
	    --include '*.h' \
	    --include '*.cpp' \
	    --include '*.c' \
	    --include '*.aidl' \
	    --include '*.bp' \
	    --include 'Makefile' \
	    --include 'LICENSE' \
	    --exclude '*' \
	    $(LOCAL_AOSP_PATH)/$$dir/ $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_AOSP_PATH)/$$dir; \
	done


# 2. Set up or attach to a tmux session on the remote server.
setup:
	@echo "Setting up tmux session on remote server..."
	ssh $(REMOTE_USER)@$(REMOTE_HOST) "\
	  if ! tmux has-session -t $(TMUX_SESSION) 2>/dev/null; then \
	    tmux new-session -d -s $(TMUX_SESSION) 'cd $(REMOTE_AOSP_PATH) && $(SETUP_CMD) && bash'; \
	  else \
	    echo 'tmux session exists'; \
	  fi"

# 3. Send the build command to the tmux session.
tmux_build:
	@echo "Starting remote build in tmux session..."
	ssh $(REMOTE_USER)@$(REMOTE_HOST) "\
	  tmux send-keys -t $(TMUX_SESSION) 'cd $(REMOTE_AOSP_PATH) && rm -f $(BUILD_DONE_FILE) && $(BUILD_CMD) && touch $(BUILD_DONE_FILE)' C-m"

# 4. Wait for the build to complete by polling for the marker file.
wait_build:
	@echo "Waiting for build to complete..."
	@while ! ssh $(REMOTE_USER)@$(REMOTE_HOST) "test -f $(BUILD_DONE_FILE)"; do \
		echo "Build in progress..."; \
		sleep 5; \
	done
	@echo "Build completed. Removing marker file..."
	ssh $(REMOTE_USER)@$(REMOTE_HOST) "rm -f $(BUILD_DONE_FILE)"

# 3. Execute the aidl command in the tmux session.
execute_aidl:
	@echo "Executing aidl command in tmux session..."
	ssh $(REMOTE_USER)@$(REMOTE_HOST) "\
	  tmux send-keys -t $(TMUX_SESSION) 'cd $(REMOTE_AOSP_PATH) && rm -f $(AIDL_DONE_FILE) && $(AIDL_CMD) && touch $(AIDL_DONE_FILE)' C-m"

# 4. Wait for the aidl command to complete by polling for the marker file.
wait_aidl:
	@echo "Waiting for aidl execution to complete..."
	@while ! ssh $(REMOTE_USER)@$(REMOTE_HOST) "test -f $(AIDL_DONE_FILE)"; do \
		echo "Aidl execution in progress..."; \
		sleep 5; \
	done
	@echo "Aidl execution completed. Removing marker file..."
	ssh $(REMOTE_USER)@$(REMOTE_HOST) "rm -f $(AIDL_DONE_FILE)"

# 4.5 Copy generated fuzzer file to AIDLCppDemo and build module
build_fuzzer:
	@echo "Copying generated fuzzer file to AIDLCppDemo and building module..."
	ssh $(REMOTE_USER)@$(REMOTE_HOST) "\
	  tmux send-keys -t $(TMUX_SESSION) 'cd $(REMOTE_AOSP_PATH)/AIDLCppDemo && cp -f ../aidl_gen/com/yuandaima/IHello.cpp ./src/Autogen.cpp && rm -f $(FUZZER_DONE_FILE) && mm -j64 && touch $(FUZZER_DONE_FILE)' C-m"

# 4.6 Wait for the fuzzer build to complete by polling for the marker file.
wait_fuzzer:
	@echo "Waiting for fuzzer build to complete..."
	@while ! ssh $(REMOTE_USER)@$(REMOTE_HOST) "test -f $(FUZZER_DONE_FILE)"; do \
		echo "Fuzzer build in progress..."; \
		sleep 5; \
	done
	@echo "Fuzzer build completed. Removing marker file..."
	ssh $(REMOTE_USER)@$(REMOTE_HOST) "rm -f $(FUZZER_DONE_FILE)"


# 5. Pull the build artifacts from the remote server using a recursive whitelist.
pull:
	@echo "Pulling build artifacts (recursive) from remote server..."
	for dir in $(PULL_WHITELIST); do \
	  rsync -avz --progress \
	    $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_AOSP_PATH)/$$dir/ $(LOCAL_AOSP_PATH)/$$dir/; \
	done

adb_push:
	@echo "Pushing files to Android..."
	adb push $(LOCAL_AOSP_PATH)/out/target/product/vsoc_arm64/data/fuzz/arm64/resolv_service_fuzzer_autogen/resolv_service_fuzzer_autogen /data/local/tmp/


