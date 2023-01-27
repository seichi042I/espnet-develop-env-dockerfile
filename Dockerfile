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

# install cuda
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
RUN mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
RUN wget https://developer.download.nvidia.com/compute/cuda/12.0.0/local_installers/cuda-repo-wsl-ubuntu-12-0-local_12.0.0-1_amd64.deb
RUN dpkg -i cuda-repo-wsl-ubuntu-12-0-local_12.0.0-1_amd64.deb
RUN cp /var/cuda-repo-wsl-ubuntu-12-0-local/cuda-*-keyring.gpg /usr/share/keyrings/
RUN apt-get update
# RUN apt-get -y install cuda

# install nvcc
# RUN apt-get install nvidia-cuda-toolkit -y

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
# RUN apt-get install cuda-drivers -y

# activate user
USER $USERNAME
WORKDIR /home/$USERNAME/

# espnet install
RUN git clone https://github.com/espnet/espnet
RUN cd espnet/tools && ./setup_anaconda.sh venv espnet 3.8 && \
    make TH_VERSION=1.12.1 CUDA_VERSION=11.6 && \
    ./venv/bin/conda init bash
ENV PATH /home/$USERNAME/espnet/tools/venv/bin:$PATH
# RUN conda activate espnet && \
#     pip install matplotlib pyopenjtalk==0.2.0 espnet_model_zoo
RUN cd espnet && \
    esp_root=`pwd` && \
    echo "export ESPNET_ROOT=$esp_root" >> /home/$USERNAME/.bashrc && \
    mkdir data_root && \
    echo "export TTS_DATA_ROOT=${esp_root}/data_root" >> /home/$USERNAME/.bashrc && \
    source /home/$USERNAME/.bashrc

