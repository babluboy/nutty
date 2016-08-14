# nutty
A Network Utility

Author: Siddhartha Das

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

![screenshot](https://drive.google.com/open?id=0B3qvTaZlWfvrU0U5SUdicFdTVEE)
