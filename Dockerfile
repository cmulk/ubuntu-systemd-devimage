FROM ubuntu:rolling


ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
&& apt-get install -y  ssh net-tools bash-completion dnsutils sudo systemd systemd-sysv git python3 python3-pip \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Systemd setup
## Adapted from https://github.com/j8r/dockerfiles/blob/master/systemd/ubuntu/20.04.Dockerfile

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

##

## install docker
RUN wget -O install.sh https://get.docker.com \
&& bash install.sh \
&& rm install.sh

ENV DEBIAN_FRONTEND interactive

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN usermod -aG docker $USERNAME
RUN echo "$USERNAME:ruse" | chpasswd

RUN systemctl enable ssh
RUN systemctl enable docker

# enable login by normal users
RUN systemctl set-default multi-user.target
RUN ln -s /lib/systemd/system/systemd-user-sessions.service /lib/systemd//system/multi-user.target.wants/

CMD ["/lib/systemd/systemd"]