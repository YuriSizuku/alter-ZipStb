msbuild libzip.sln -t:libzip_test:rebuild -p:configuration=debug -p:Platform=x86 
msbuild libzip.sln -t:libzip_test:rebuild -p:configuration=debug -p:Platform=x64
pushd build
libzip_test32d
libzip_test64d
popd