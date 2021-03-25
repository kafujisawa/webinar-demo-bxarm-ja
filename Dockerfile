FROM ubuntu:20.04

# USER_IDをdocker image作成ユーザーと同じに設定する
ARG USER_ID

# タイムゾーンの設定
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# IARのビルドツールへのパス設定
ENV IAR_PATH="/opt/iarsystems"
ENV IAR_BXARM_PATH="${IAR_PATH}/bxarm-8.50.9"
ENV IAR_LMS_SETTINGS_DIR="/.lms"
ENV IAR_BUILD_PATH="/build"
ENV PATH="${IAR_BXARM_PATH}/arm/bin:${IAR_BXARM_PATH}/common/bin:$PATH"

# 一般的なツール群のインストール
RUN apt update; apt -y install curl make git g++ cmake fontconfig sudo libsqlite3-0 language-pack-ja-base language-pack-ja
# language設定
RUN update-locale LANG=ja_JP.UTF-8

# docker image作成ユーザーと同じユーザーを追加
RUN  useradd --create-home --uid 1000 ubuntu && \
     echo "ubuntu:ubuntu" | chpasswd && \
     adduser ubuntu sudo


# C++testのインストールディレクトリをPATHに設定
ENV PATH="/home/ubuntu/parasoft/cpptest/10.5:$PATH"

# ホストからdebパッケージをcontainerにコピー
COPY bxarm-8.50.9.deb /tmp

# debパッケージのインストール
RUN  dpkg --install /tmp/bxarm-8.50.9.deb && \
     rm /tmp/bxarm-8.50.9.deb

# ビルドディレクトリの作成
RUN  mkdir ${IAR_BUILD_PATH} && \
     chmod u+rwx -R ${IAR_BUILD_PATH} && \
     chmod g+rwx -R ${IAR_BUILD_PATH} && \
     chown ubuntu:ubuntu ${IAR_BUILD_PATH}

# BXARMのライセンスのアクティベート
RUN /opt/iarsystems/bxarm/common/bin/lightlicensemanager init && \
    /opt/iarsystems/bxarm/common/bin/lightlicensemanager setup -s ec2-54-161-227-147.compute-1.amazonaws.com
 
USER ubuntu
ENV LC_ALL=ja_JP.UTF-8
