# Docker File for Jupyterhub used by Dawn-team members(https://dawn-team.github.io)
# Will be invoked by dockerspawner
# Technical Requirement:
#     - [√] Nvidia Cards Support
#     - [√] Python3 Support
#     - [√] Notebook
#     - [√] Numpy
#     - [√] Tensorflow GPU Support
#     - [√] Keras Support
#     - [ ] Octave
#     - [ ] Pytorch
#     - [?] Bash Shell Client
# 

FROM tensorflow/tensorflow:1.7.0-gpu-py3

MAINTAINER Arvin Si.Chuan "arvinsc@foxmail.com"

# Version Tag
ENV REFRESHED_AT 2018-04-12-19:20:00 
ENV VERSION V1.0.1-beta



# Step 1. Prepare demostic sources list.
COPY ["sources/sources.list","/etc/apt/sources.list"]

# Step 2. Update apt repositories.
# Step 3. Install whole `apt` support.
# Step 4. Enimilate problems caused by dialog missing
# Step 5. Install system level packages.
# Step 6. Clean Installation
RUN \
    DEBIAN_FRONTEND=noninteractive apt-get update -yqq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
        apt-utils && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
    dialog  && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
    language-pack-en locales \
    net-tools \
    git graphviz\
    openssh-server \
    python3 python3-pip \
    vim && \
    DEBIAN_FRONTEND=noninteractive apt-get -yqq upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -yqq dist-upgrade &&\
    DEBIAN_FRONTEND=noninteractive apt-get -yqq autoremove && \
    DEBIAN_FRONTEND=noninteractive apt-get clean
    
    
# Step 7. Update LOCALE
ENV LANG en_US.UTF-8 
RUN update-locale LANG="en_US.UTF-8" LANGUAGE

# Step 8. Install `python3-pip` and upgrade it to the latest
RUN pip3 install --no-cache-dir --upgrade  pip && \
    pip3 install --no-cache-dir pqi &&\
    pqi use tuna 



# Step 9. Install application level packages from `python3-pip`
COPY requirement.txt /home/requirement.txt
RUN pip3 install  --no-cache-dir -r  /home/requirement.txt  
    

# Step A. Change default shell
RUN ln -sf /bin/bash /bin/sh

# Step B. Enable nbextension, choose `--system` due to the docker env.
RUN jupyter contrib nbextension install --system

# Step C. create a user, since we don't want to run as root
RUN useradd -m -s /bin/bash jovyan
ENV HOME=/home/jovyan
WORKDIR $HOME
USER jovyan

# Step D. Copy startup shell scripts.
COPY start-singleuser.sh /usr/local/bin/
COPY start.sh /usr/local/bin/

# Step E. Set entrypoint
# ENTRYPOINT ["/bin/bash"]
CMD ["start-singleuser.sh"]


# Step F. Set labels
LABEL version="1.0.1-beta" location="Shanghai, China." role="Team Computaion Platform."
