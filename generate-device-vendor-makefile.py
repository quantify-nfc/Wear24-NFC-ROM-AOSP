import glob
import os

aosp_license = ("""#
# Copyright 2014 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#""")

makefile = open("device-vendor.mk", "w+")
lines = [aosp_license, "\n\n\n", "# COPIED FILES\n\n"]
packages = []

os.chdir("vendor/")
for file in glob.iglob("**/*.*", recursive=True):
    if file.endswith("apk"):
        directory = file.rsplit('/', 1)[0]
        filename = file.rsplit('/', 1)[-1]
        with open(directory + "/Android.mk", "w+") as packagemakefile:
            mkLines = [aosp_license, "\n\n"]
            
            mkLines.append("LOCAL_PATH := $(call my-dir)\n")
            mkLines.append("include $(CLEAR_VARS)\n")
            mkLines.append("LOCAL_MODULE_TAGS := optional\n")
            mkLines.append("LOCAL_MODULE := "+filename+"\n")
            mkLines.append("LOCAL_SRC_FILES := $(LOCAL_MODULE).apk\n")
            mkLines.append("LOCAL_MODULE_CLASS := APPS\n")
            mkLines.append("LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)\n")
            mkLines.append("LOCAL_CERTIFICATE := PRESIGNED\n")
            mkLines.append("include $(BUILD_PREBUILT)\n")

            packagemakefile.writelines(mkLines)
        
        packages.append(filename)
    else:
        lines.append("PRODUCT_COPY_FILES := \\" + "\n")
        lines.append("	" + "vendor/quanta/dorado/proprietary/" + file + ":system/vendor/" + file + ":quanta\n")

lines += ["\n\n\n", "# APPLICATION PACKAGES\n\n"]

for package in packages:
    lines.append("PRODUCT_PACKAGES += \\\n")
    lines.append("    " + package + "\n")

makefile.writelines(lines)

