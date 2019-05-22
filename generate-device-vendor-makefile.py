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
lines = [aosp_license, "\n\n"]

os.chdir("vendor/")
for file in glob.iglob("**/*.*", recursive=True):
    lines.append("PRODUCT_COPY_FILES := \\" + "\n")
    lines.append("	" + "vendor/quanta/dorado/proprietary/" + file + ":system/vendor/" + file + ":quanta\n")

makefile.writelines(lines)
   
