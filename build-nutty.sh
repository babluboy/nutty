cd /home/sid/Documents/Projects/nutty/dev/
rm -Rf ./build/*
cd ./build/
cmake -DCMAKE_INSTALL_PREFIX=/usr ../
make pot
make
sudo make install
