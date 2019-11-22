sudo apt-get update
cd gmp-6.1.2/
sudo apt-get install m4
./configure
make
sudo make install
cd ..
cd pbc-0.5.14/
./configure
make
sudo make install
cd ..
sudo apt-get install libcrypt-openssl-random-perl
sudo apt-get install libglib2.0-dev
sudo apt-get install libssl-dev
cd libbswabe-0.9/
./configure
make
sudo make install
cd ..
cd cpabe-0.11/
./configure
make
sudo make install

