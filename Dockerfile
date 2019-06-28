FROM centos:7.3.1611

MAINTAINER ...

# change aliyun yum source
ADD ./CentOS-Base-aliyun.repo /etc/yum.repos.d/CentOS-Base.repo

# add epel source
ADD ./epel-7.repo /etc/yum.repos.d/epel-7.repo

# make cache
RUN yum clean all && yum makecache

# set python version
ENV PYTHON_VERSION 3.6.2
ENV PYTHON_VERSION_SHORT 362

# create directory
RUN mkdir /root/app /root/source /root/www

# set config
ADD ./vimrc /root/.vimrc

# net-tools=ifconfig netstat
RUN yum install -y wget net-tools telnet bzip2 which gcc make zlib zlib-devel openssl openssl-devel

# install pip
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py && rm -rf get-pip.py

# set pip.conf
RUN mkdir -p /root/.pip
ADD ./pip.conf /root/.pip/pip.conf

# set sys_time
RUN rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# set utf-8
ENV LANG zh_CN.UTF-8
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8

# set default path
WORKDIR /root

# compile env for python package pillow
RUN yum install -y python-devel \
        install -y zlib-devel \
        install -y libjpeg-turbo-devel

# to import bz2
RUN yum install -y bzip2-devel

# install python3
ADD ["Python-$PYTHON_VERSION.tgz","."]
WORKDIR /root/Python-$PYTHON_VERSION
#RUN ./configure --prefix=/root/app/python362 --enable-optimizations && \
RUN ./configure --enable-shared --prefix=/root/app/python$PYTHON_VERSION_SHORT --enable-optimizations && \
    make && make install

# need cp libpython3.6m.so.1.0 to /usr/lib64
#RUN cp /root/app/python$PYTHON_VERSION_SHORT/lib/libpython3.5m.so.1.0 /usr/lib64
RUN cp /root/app/python$PYTHON_VERSION_SHORT/lib/libpython*.1.0 /usr/lib64

WORKDIR /root
RUN rm -rf /root/Python-$PYTHON_VERSION

# link python to python3, call python3 with python
ADD yum /usr/bin/
RUN chmod +x /usr/bin/yum
ADD urlgrabber-ext-down /usr/libexec/
RUN chmod +x /usr/libexec/urlgrabber-ext-down
WORKDIR /usr/bin/
RUN mv python python.bak && \
    mv pip pip.bak
RUN ln -s /root/app/python362/bin/python3  /usr/bin/python
RUN ln -s /root/app/python362/bin/pip3 /usr/bin/pip

WORKDIR /root

RUN pip install --upgrade pip
RUN pip install python-dateutil==2.6.0
# install python package
ADD ["requirements.txt", "."]
RUN pip install -r requirements.txt

WORKDIR /root/www
CMD ["/bin/bash"]

