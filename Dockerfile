FROM ubuntu:16.04
LABEL Name=dockerising Version=0.0.1
WORKDIR /usr/local/src
RUN apt-get -y update
ADD cpabe-0.11.tar.gz /usr/local/src
ADD gmp-6.1.2.tar /usr/local/src
ADD libbswabe-0.9.tar.gz /usr/local/src
ADD pbc-0.5.14.tar.gz /usr/local/src
COPY Makefile policy_lang.y /usr/local/src/
RUN ls
RUN apt-get -y install m4 && apt-get -y install libcrypt-openssl-random-perl && apt-get -y install libglib2.0-dev && apt-get -y install libssl-dev
RUN cd gmp-6.1.2 && ./configure && make && make install && cd ..
RUN apt-get -y install flex && apt-get -y install bison
RUN cd pbc-0.5.14 && ./configure && make && make install && cd ..
RUN cd libbswabe-0.9 && ./configure && make && make install && cd ..
RUN cd cpabe-0.11 && ./configure && cd ..
RUN cp Makefile /usr/local/src/cpabe-0.11/
RUN cp policy_lang.y /usr/local/src/cpabe-0.11/
RUN cd cpabe-0.11 && make && make install && cd ..

