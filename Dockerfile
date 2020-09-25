FROM ubuntu:20.04

###########################################
# X11 VNC XVFB
# integrated from https://github.com/fcwu/docker-ubuntu-vnc-desktop
###########################################
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        software-properties-common \
        curl wget \
        supervisor \
        sudo \
        vim-tiny \
        net-tools \ 
        xz-utils \
        dbus-x11 x11-utils alsa-utils \
        mesa-utils libgl1-mesa-dri \
        lxde x11vnc xvfb \
        gtk2-engines-murrine gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine arc-theme \
        firefox \
        gcc\
        python3-pip\
        g++\
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# tini for subreap                                   
ARG TINI_VERSION=v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

# set default screen to 1 (this is crucial for gym's rendering)
ENV DISPLAY=:1

###########################################
# gym
# see: https://github.com/openai/gym
###########################################
RUN apt-get update && apt-get install -y \
        git vim \
        python3-numpy python3-dev cmake zlib1g-dev libjpeg-dev xvfb ffmpeg xorg-dev python3-opengl libboost-all-dev libsdl2-dev swig \
    && rm -rf /var/lib/apt/lists/*

# install Mu Zero
RUN cd /opt \
    && git clone https://github.com/werner-duvaud/muzero-general.git \
    && cd muzero-general \
    && pip3 install -r 'requirements.txt' \
    && rm -rf ~/.cache/pip 

# vnc port
EXPOSE 5900

# startup
COPY image /
ENV HOME /root
ENV SHELL /bin/bash
WORKDIR /root
# services like lxde, xvfb, x11vnc will be started
ENTRYPOINT ["/startup.sh"]
