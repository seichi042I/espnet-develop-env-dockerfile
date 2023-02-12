FROM ubuntu:latest
SHELL ["/bin/bash", "-c"]

# register user
ARG USERNAME=user
ARG GROUPNAME=user
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID $GROUPNAME && \
    useradd -m -s /bin/bash -u $UID -g $GID $USERNAME
RUN echo "$USERNAME:password" | chpasswd && adduser $USERNAME sudo

RUN apt-get update
RUN apt-get install \
    sudo \
    git \
    nano \
    wget \
    curl -y

# other
RUN apt-get install libsndfile1-dev -y
RUN apt-get install make \
    g++ \
    unzip \
    cmake \
    sox \
    -y
RUN apt-get install \
    ffmpeg \
    flac \
    -y

# activate user
USER $USERNAME
WORKDIR /home/$USERNAME/

# espnet install
RUN git clone https://github.com/espnet/espnet
RUN cd espnet/tools && ./setup_anaconda.sh venv espnet 3.8 && \
    make TH_VERSION=1.12.1 CUDA_VERSION=11.6 && \
    ./venv/bin/conda init bash
ENV PATH /home/$USERNAME/espnet/tools/venv/bin:$PATH
RUN cd espnet && \
    esp_root=`pwd` && \
    echo "export ESPNET_ROOT=$esp_root" >> /home/$USERNAME/.bashrc && \
    mkdir data_root && \
    echo "export TTS_DATA_ROOT=${esp_root}/data_root" >> /home/$USERNAME/.bashrc && \
    source /home/$USERNAME/.bashrc

