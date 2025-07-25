cd LoRa
make clean; make; make install

rmmod sx1278 || true
modprobe sx1278