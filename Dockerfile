FROM public.ecr.aws/ubuntu/ubuntu:20.04 AS base

ENV DEBIAN_FRONTEND=nonintercative
ENV TZ=America/Los_Angeles
ENV ROS_MIRROR_URL=http://packages.ros.org/ros/ubuntu
# ENV ROS_MIRROR_URL=http://mirrors.sjtug.sjtu.edu.cn/ros/ubuntu
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Use local Ubuntu sources if necessary
# COPY aliyun_sources.list /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg \
    dirmngr \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "deb ${ROS_MIRROR_URL} focal main" > /etc/apt/sources.list.d/ros-latest.list \
    && apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake \
    `# Pangolin deps` libgl1-mesa-dev libwayland-dev libxkbcommon-dev wayland-protocols libegl1-mesa-dev libc++-dev libglew-dev libeigen3-dev \
    libopencv-dev \
    ros-noetic-desktop \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


FROM base AS pangolin

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/stevenlovegrove/Pangolin.git

RUN mkdir /build && cd /build
RUN cmake /Pangolin
RUN cmake --build .
RUN make install


FROM base AS orb-slam2

COPY --from=pangolin /usr/local /usr/local

