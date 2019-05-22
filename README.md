# Wear24 NFC ROM from AOSP

**THIS REPO IS STILL VERY VERY UNDER CONSTRUCTION**

[![Build Status](https://travis-ci.org/davwheat/Wear24-NFC-ROM.svg?branch=master)](https://travis-ci.org/davwheat/Wear24-NFC-Kernel)

This project is a modified mirror of Google's AOSP specifically targetted at the Quanta `dorado` (sold as the Verizon Wear24) to pair with our custom NFC kernel. Our aim is to get the watch to support NFC, a feature Verizon promised, yet never shipped. In the future, greater modifications may be made to support more features or update to newer systems such as Oreo or "H".

## Discord

https://discord.gg/8XyTeUC

## Branches

![](check_your_branch.png)

PLEASE CHECK WHICH BRANCH YOU ARE ON BEFORE BUILDING!

This repository has a different branch for each Android Wear AOSP build: `android-wear-7.1.1_r1`, `android-wear-8.1.0_r1` and `one for system H when we add it`. These branches are named identically to the applicable [Android Open Source Project](https://android.googlesource.com/) branches.

Our releases are automagically built by our [Travis CI integration](https://travis-ci.org/quantify-nfc/Wear24-NFC-ROM-AOSP/branches) and uploaded to [GitHub releases](https://github.com/quantify-nfc/Wear24-NFC-ROM-AOSP/releases).

## Contributing

### Cloning

Due to high file sizes, it is recommended to only clone the whole repository if necessary. If you do plan on doing so, **it is highly recommended you use SSH and not HTTPS**.

To do so...
1. Open the terminal
2. Paste the following code, substituting your GitHub email: `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`
3. When asked to choose the file location, press `ENTER` (accept the default location)
4. Enter a secure passphrase (which you'll remember!)
5. Start the `ssh-agent` (enter `eval "$(ssh-agent -s)"` into the console)
6. Add your SSH key to `ssh-agent` (type `ssh-add ~/.ssh/id_rsa` and enter your passphrase when asked)
7. [Add the SSH key to your GitHub account](https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account)
8. After, just clone the repo using `git clone --recursive git@github.com:quantify-nfc/Wear24-NFC-ROM-AOSP`
9. Follow the instructions under [Repo Setup](#repo-setup)

### Pushing

If you are planning on pushing large changes, it is recommended to change the following git config values:

```bash
git config core.bigFileThreshold 15m
git config --global http.postBuffer 157286400
```

### Meanings

|Config value|Description|Benefit|
|---|---|---|
|`core.bigFileThreshold 15m`|Disables delta compression on files larger than 15 MB|Vastly reduces `git push` time|
|`http.postBuffer 157286400`|Increases the Git buffer size to the largest file in the repo|Decreases failed `push` attempts|

## Repo Setup

### Automatic

A repo setup script is included in the repository. Just run:

```bash
. repo-setup.sh
```

### Manual

1. Install all required packages

```bash
sudo apt install git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip
```

2. Install the Google Repo tool

```bash
mkdir ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
```

3. Initialise a Repo client

```bash
# For 7.1.1
repo init --depth 1 -b android-wear-7.1.1_r1 [OR THE BRANCH YOU ARE USING] -u https://android.googlesource.com/platform/manifest
```

4. Synchronise the Android source

```bash
repo sync -c --no-clone-bundle -j$(nproc --all)
```

5. Check that the local manifest is located at `.repo/local_manifests/local_manifest.xml`. This contains our custom Repo 'submodules'. If this doesn't exist, then [download it from GitHub](https://github.com/quantify-nfc/Wear24-NFC-ROM-AOSP/blob/android-wear-7.1.1_r1/.repo/local_manifests/local_manifest.xml).

## Pulling updates

Just running the usual `git pull` isn't (normally) enough anymore! Follow a few simple steps every time a change is made:
1. `git pull`
2. `git submodule update`
3. `repo sync`

## Building

**This section has NOT been updated to suit this repository.**

`android-tools-fsutils` is needed for `make_ext4fs`!

`sudo apt install android-tools-fsutils`

### Automatic

**This section has NOT been updated to suit this repository.**

Extract the existing `system.img`, add our own files, and rebuild using `./build.sh`.

### Manual

**This section has NOT been updated to suit this repository.**

**NOT RECOMMENDED**

*Coming soon*


