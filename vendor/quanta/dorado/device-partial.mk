#
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
#

# BEGIN QUANTA BLOBS
# this app section MAY NOT be necessary
PRODUCT_COPY_FILES := \
	vendor/quanta/dorado/proprietary/ims.apk:system/vendor/app/ims.apk:quanta \
PRODUCT_COPY_FILES := \
	vendor/quanta/dorado/proprietary/ims.odex:system/vendor/app/ims/oat/arm/ims.odex:quanta \
# ----------------------------------------
PRODUCT_COPY_FILES := \
	vendor/quanta/dorado/proprietary/fidodaemon:system/vendor/bin/fidodaemon:quanta \
PRODUCT_COPY_FILES := \
	vendor/quanta/dorado/proprietary/qti:system/vendor/bin/qti:quanta \
PRODUCT_COPY_FILES := \
	vendor/quanta/dorado/proprietary/thermal-engine:system/vendor/bin/thermal-engine:quanta \
PRODUCT_COPY_FILES := \
	vendor/quanta/dorado/proprietary/a300_pfp.fw:system/vendor/fw/a300_pfp.fw:quanta \
PRODUCT_COPY_FILES := \
	vendor/quanta/dorado/proprietary/a300_pm4.fw:system/vendor/fw/a300_pm4.fw:quanta \

