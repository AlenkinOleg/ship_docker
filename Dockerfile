FROM cern/cc7-base

MAINTAINER Oleg Alenkin <alenkin.oleg@phystech.edu>

RUN echo "export SHIPSOFT=/opt" >> /root/.bash_profile
RUN echo "export FAIRROOTPATH=\$SHIPSOFT/FairRootInst" >> /root/.bash_profile
RUN echo "export SIMPATH=\$SHIPSOFT/FairSoftInst" >> /root/.bash_profile
RUN echo "export FAIRSHIP=\$SHIPSOFT/FairShip" >> /root/.bash_profile
RUN echo "export PYTHONPATH=\$FAIRSHIP/python:\$SIMPATH/lib:\$SIMPATH/lib/Geant4:\$PYTHONPATH" >> /root/.bash_profile

ENV SHIPSOFT=/opt
ENV FAIRROOTPATH=$SHIPSOFT/FairRootInst
ENV SIMPATH=$SHIPSOFT/FairSoftInst
ENV FAIRSHIP=$SHIPSOFT/FairShip
ENV PYTHONPATH=$FAIRSHIP/python:$SIMPATH/lib:$SIMPATH/lib/Geant4:$PYTHONPATH

RUN set -e
RUN yum install -y yum-plugin-ovl
RUN yum -y update
RUN yum -y install mesa-libGL mesa-libGL-devel tigervnc-server vnc \
		krb5-workstation krb5-libs tkinter mesa-libglapi
RUN yum -y install which file bc bash-completion man
RUN yum -y install unzip tar patch gcc gcc-c++ gcc-gfortran \
		compat-gcc-34-g77 git subversion \ 
		xorg-x11-xauth libX11-devel libXpm-devel libXmu-devel libXft-devel libXext-devel \
		mesa-libGL-devel mesa-libGLU-devel ncurses-devel \
		expat-devel python-mtTkinter python-devel libxml2-devel vim redhat-lsb-core \
		x11vnc libpng xterm twm openssl openssl-devel openssl-CERN-CA-certs \
		curl libcurl libcurl-openssl automake autoconf aclocal libcurl-devel libtool cmake bzip2 bzip2-devel \
		make sed libbz2-dev gzip flex bison imake redhat-lsb-core wget curl-devel

RUN cd /usr/bin/; wget https://cmake.org/files/v3.8/cmake-3.8.2.tar.gz; tar -zxvf cmake-3.8.2.tar.gz; rm -rf cmake-3.8.2.tar.gz; cd cmake-3.8.2; cmake .; make; make install

RUN mkdir -p $SHIPSOFT; cd $SHIPSOFT; git clone https://github.com/ShipSoft/FairSoft.git; cd FairSoft; echo 1 | ./configure.sh

RUN cd $SHIPSOFT; git clone https://github.com/ShipSoft/FairRoot.git; cd FairRoot; ./configure.sh

RUN cd $SHIPSOFT; git clone https://github.com/ShipSoft/FairShip.git; cd FairShip; ./configure.sh

RUN cd $SHIPSOFT; mkdir src; cd src; git clone https://github.com/hushchyn-mikhail/FairShip.git; rsync -a FairShip/Developments ../FairShip/; cd ..; rm -rf src

RUN yum install -y epel-release; yum install -y python-pip; pip install --upgrade pip

RUN pip install numpy pandas scipy scikit-learn matplotlib

RUN pip install gpy; pip install  gpyopt

COPY src/ /tmp/docker_src/

RUN mv /tmp/docker_src/strawtubes* $FAIRSHIP/strawtubes/; mv /tmp/docker_src/shipDet_conf.py $FAIRSHIP/python/; mv /tmp/docker_src/geometry_config* $FAIRSHIP/geometry/; cd $SHIPSOFT/FairShipRun; make

RUN echo "export SHIPOPT=\$SHIPSOFT/ShipOpt" >> /root/.bash_profile

ENV SHIPOPT=$SHIPSOFT/ShipOpt

RUN cd $SHIPSOFT; git clone https://github.com/AlenkinOleg/ShipOpt2.git; mv ShipOpt2 ShipOpt; ls -l

CMD ["bash"]
