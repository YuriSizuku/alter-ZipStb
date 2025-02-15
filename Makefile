# build example, tested in linux 10.0.0-3, gcc 12, wine-9.0
# make stbzip
# make libzip libzip_test CC=i686-w64-mingw32-gcc BUILD_TYPE=32d
# make libzip libzip_test CC=x86_64-w64-mingw32-gcc BUILD_TYPE=64d
# make libzip libzip_test CC=i686-linux-gnu-gcc BUILD_TYPE=32d
# make libzip libzip_test CC=x86_64-linux-gnu-gcc BUILD_TYPE=64d

# general config
CC:=clang # clang (llvm-mingw), gcc (mingw-w64), tcc (x86 stdcall name has problem)
BUILD_TYPE:=32# 32, 32d, 64, 64d
BUILD_SYS:=# win, linux
BUILD_DIR:=build
INCS:=-Isrc
LIBS:=
CFLAGS:=-fPIC -std=gnu99 \
	-fvisibility=hidden \
	-ffunction-sections -fdata-sections
LDFLAGS:=-Wl,--gc-sections

ifneq (,$(findstring linux, $(CC)))
BUILD_SYS=linux
else ifneq (,$(findstring mingw, $(CC)))
BUILD_SYS=win
endif

ifneq (,$(findstring win, $(BUILD_SYS)))
LIBS+=-luser32
LDFLAGS+=-Wl,--enable-stdcall-fixup \
         -Wl,--kill-at \
         -D_WIN32_WINNT=0X0400 \
		 -Wl,--subsystem,console:4.0 # compatible for xp
EXEEXT=.exe
DLLEXT=.dll
else
EXEEXT=
DLLEXT=.so
endif

# build config
ifneq (,$(findstring 64, $(BUILD_TYPE)))
CFLAGS+=-m64
else
CFLAGS+=-m32
endif
ifneq (,$(findstring d, $(BUILD_TYPE)))
CFLAGS+=-g -D_DEBUG
else
CFLAGS+=-O3
endif
ifneq (,$(findstring tcc, $(CC)))
LDFLAGS= # tcc can not remove at at stdcall in i686
else
endif

all: prepare stbzip libzip libzip_test

clean:
	@rm -rf $(BUILD_DIR)/*zip*

prepare:
	@if ! [ -d $(BUILD_DIR) ]; then mkdir -p $(BUILD_DIR); fi

$(BUILD_DIR)/libzip$(BUILD_TYPE)${DLLEXT}: src/libzip.c src/stb_zip.h
	$(CC) $< -o $@ -shared \
		$(INCS) $(LIBS) \
		$(CFLAGS) $(LDFLAGS)

$(BUILD_DIR)/libzip_test$(BUILD_TYPE)${EXEEXT}: src/libzip_test.c $(BUILD_DIR)/libzip$(BUILD_TYPE)${DLLEXT}
	$(CC) $< -lzip$(BUILD_TYPE) -L$(BUILD_DIR) -o $@ \
	$(INCS) $(LIBS) \
	$(CFLAGS) $(LDFLAGS) 

stbzip: script/build_stbzip.py
	python $< depend/zip $(BUILD_DIR)/stb_zip.h
	cp -f $(BUILD_DIR)/stb_zip.h src/stb_zip.h

libzip: $(BUILD_DIR)/libzip$(BUILD_TYPE)${DLLEXT}

libzip_test: $(BUILD_DIR)/libzip_test$(BUILD_TYPE)${EXEEXT}

.PHONY: all clean prepare stbzip libzip libzip_test