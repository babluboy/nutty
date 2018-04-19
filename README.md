# Nutty [![Translation status](https://hosted.weblate.org/widgets/nutty/-/svg-badge.svg)](https://hosted.weblate.org/engage/nutty/?utm_source=widget) [![Build Status](https://travis-ci.org/babluboy/nutty.svg?branch=master)](https://travis-ci.org/babluboy/nutty) [![Snap Status](https://build.snapcraft.io/badge/babluboy/nutty.svg)](https://build.snapcraft.io/user/babluboy/nutty) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=FZP8GK839VGQC)
A Network Utility

Author: Siddhartha Das

A simple application made for elementary OS to provide essential information on network related aspects. The information is broken into the following presented in a tab view.<br>
1. My Info: Provides basic and detailed information for the device network card<br>
2. Usage: Provides network data usage in two views - historical usage and current usage<br>
3. Speed: Check Upload and Download speeds and get route times to a host<br>
4. Ports: Provides information on active ports and application using them on the local device<br>
5. Devices: Monitors, alerts and provides information on the other devices connected on the network<br>

Check the Nutty website for details on features, shortcuts, installation guides for Ubuntu and other supported distros, etc. : <br>
https://babluboy.github.io/nutty/

## How to install nutty:
if you are using Elementary OS, get Nutty from elementary OS AppCenter by clicking on the badge below <br>

<a href="https://appcenter.elementary.io/com.github.babluboy.nutty"><img src="https://appcenter.elementary.io/badge.svg" alt="Get it on AppCenter"></a>

## How to build nutty from source:

```shell
sudo apt-get build-dep granite-demo
git clone https://github.com/babluboy/nutty.git
sudo apt-get install cmake debhelper libgee-0.8-dev libgtk-3-dev valac libgranite-dev libsqlite3-dev  libxml2 libxml2-dev libnotify-dev
cd nutty
mkdir build && cd build 
cmake -DCMAKE_INSTALL_PREFIX=/usr ../
make
sudo make install
```
## Screenshot

![screenshot](https://raw.githubusercontent.com/babluboy/nutty/gh-pages/images/Nutty_Device_Alert.png)
