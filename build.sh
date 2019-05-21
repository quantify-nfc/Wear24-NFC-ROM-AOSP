# Setup build environment
. build/envsetup.sh

# install jack server if it isn't present
if [ ! -d "~/.jack-server" ]; then
	cd prebuilts/sdk/tools
	./jack-admin install-server jack-launcher.jar jack-server-4.8.ALPHA.jar
	cd ../../../
fi

# Set Java max heap size to 8GB (or AOSP won't build/fail at ~40-80%)
export ANDROID_JACK_VM_ARGS="-Xmx8G -Xms1G -Dfile.encoding=UTF-8 -XX:+TieredCompilation"
export JACK_SERVER_VM_ARGUMENTS="-Xmx8G -Xms1G -Dfile.encoding=UTF-8 -XX:+TieredCompilation"

# Restart the Jack server to use the new arguments
./prebuilts/sdk/tools/jack-admin kill-server
./prebuilts/sdk/tools/jack-admin start-server

# Select the dorado product
lunch full_dorado-userdebug

# Build with (total cores * 8) concurrent jobs
m -j$((`nproc`*8))
