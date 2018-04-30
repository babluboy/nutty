#Download base image for ubuntu
FROM ubuntu

# Update Ubuntu Software repository
RUN apt-get update

#install required packages
RUN apt-get install -y \
    git                               \
    cmake                       \
    debhelper                 \
    libgee-0.8-dev         \
    libgtk-3-dev              \
    libgranite-dev          \
    libsqlite3-dev           \
    libxml2                      \
    libxml2-dev              \
    libnotify-dev             \
    valac                         \
    net-tools                   \ 
    nmap                        \
    traceroute                \
    vnstat                       \ 
    nethogs                   \
    curl                           \
    wireless-tools         \
    iproute2                   \
    gobject-introspection  \
    libgirepository1.0-dev \
    
&& rm -rf /var/lib/apt/lists/*

RUN dpkg -l libgee-0.8-dev; \
          dpkg -l libgranite-dev; \
          dpkg -l libgtk-3-dev; \
          dpkg -l libsqlite3-dev; \
          dpkg -l libxml2-dev; \
          dpkg -l libnotify-dev;

#build and install granite0.5
RUN mkdir /home/git; \
    cd /home/git; \
    git clone https://github.com/elementary/granite.git -b master; \
    cd granite; \
    mkdir build; \
    cd build; \
    cmake -DCMAKE_INSTALL_PREFIX=/usr ../; \
    make; \
    make install

#build and install nutty
RUN mkdir /home/git; \
    cd /home/git; \
    git clone https://github.com/babluboy/nutty.git -b master; \
    cd nutty; \
    mkdir build; \
    cd build; \
    cmake -DCMAKE_INSTALL_PREFIX=/usr ../; \
    make; \
    make install

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
