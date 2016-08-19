# nutty
A Network Utility

Author: Siddhartha Das

A simple application made for elementary OS to provide essential information on network related aspects. The information is broken into the following presented in a tab view.<br>
(1) My Info: Provides basic and detailed information for the device network card<br>
(2) Usage: Provides network data usage in two views - historical usage and current usage<br>
(3) Speed: Check Upload and Download speeds and get route times to a host<br>
(4) Ports: Provides information on active ports and application using them on the local device<br>
(5) Devices: Monitors and provides information on the other devices connected on the network<br>

##How to install nutty:

  ```shell
  sudo apt-add-repository ppa:bablu-boy/nutty.0.1
  sudo apt-get update
  sudo apt-get install nutty
  ```

## How to build nutty:

```shell
sudo apt-get build-dep granite-demo 
sudo apt-get install libgranite-dev
sudo apt-get install valac
git clone https://github.com/babluboy/nutty.git
cd nutty
mkdir build && cd build 
cmake -DCMAKE_INSTALL_PREFIX=/usr ../
make
```
## Screenshot

![screenshot](https://github.com/babluboy/nutty/blob/master/screenshots/Nutty_Device_Alert.png)
