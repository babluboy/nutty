# Nutty [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=FZP8GK839VGQC)
A Network Utility

Author: Siddhartha Das

A simple application made for elementary OS to provide essential information on network related aspects. The information is broken into the following presented in a tab view.<br>
1. My Info: Provides basic and detailed information for the device network card<br>
2. Usage: Provides network data usage in two views - historical usage and current usage<br>
3. Speed: Check Upload and Download speeds and get route times to a host<br>
4. Ports: Provides information on active ports and application using them on the local device<br>
5. Devices: Monitors, alerts and provides information on the other devices connected on the network<br>

## How to install nutty:
if you are using Elementary OS, get Nutty from elementary OS AppCenter

<a href="https://appcenter.elementary.io/com.github.babluboy.nutty"><img src="https://appcenter.elementary.io/badge.svg" alt="Get it on AppCenter"></a>
  
PPA for Stable Build
```shell
sudo apt-add-repository ppa:bablu-boy/nutty
sudo apt-get update
sudo apt-get install nutty
  ```

PPA for Daily Build(Unstable):
```shell
sudo add-apt-repository ppa:bablu-boy/nutty-daily
sudo apt update
sudo apt install com.github.babluboy.nutty
  ```
## How to build nutty:

```shell
sudo apt-get build-dep granite-demo 
sudo apt-get install libgranite-dev libsqlite3-dev libxml2 libxml2-dev libgee-0.8-dev libgtk-3-dev valac
git clone https://github.com/babluboy/nutty.git
cd nutty
mkdir build && cd build 
cmake -DCMAKE_INSTALL_PREFIX=/usr ../
make
```
## Screenshot

![screenshot](https://github.com/babluboy/nutty/blob/gh-pages/screenshots/Nutty_Device_Alert.png)
