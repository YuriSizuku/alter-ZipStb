make prepare
make libzip_test CC=i686-linux-gnu-gcc BUILD_TYPE=32d
make libzip_test CC=x86_64-linux-gnu-gcc BUILD_TYPE=64d
pushd build
LD_LIBRARY_PATH=./ ./libzip_test32d
LD_LIBRARY_PATH=./ ./libzip_test64d
popd