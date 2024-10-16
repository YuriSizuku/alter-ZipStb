# ZipStb

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/yurisizuku/alter-ZipStb?color=green&label=ZipStb)![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/YuriSizuku/alter-ZipStb/build.yml?label=build)

🌿 A single header library (similar to [stb](https://github.com/nothings/stb)) for [zip](https://github.com/kuba--/zip),  
compatible with `gcc`, `tcc`, `llvm-mingw(clang)`, `msvc`.  

## usage

Include the single header file either in `src/stb_zip.h` or `build/stb_zip.h`, for example

```c
#define ZIP_IMPLEMENTATION
#ifndef ZIP_SHARED // if you want to build dll and export api
#include "std_zip.h"
```

## build

prepare enviroment

```sh
git clone https://github.com/YuriSizuku/alter-ZipStb.git --recursive
cd alter-ZipStb
chmod +x script/*.sh script/*.py
export MINGWSDK=/path/to/llvmmingw && script/install_llvmmingw.sh
```

build stb_zip.h

```sh
mkdir build
python script/build_stb_zip.py
```

build for debug

```sh
make prepare StbZip
make libzip libzip_test CC=i686-w64-mingw32-gcc BUILD_TYPE=32d
make libzip libzip_test CC=x86_64-w64-mingw32-gcc BUILD_TYPE=64d
```
