# build example, tested in linux 10.0.0-3, gcc 12, wine-9.0
# make stbzip
# make libzip libzip_test CC=i686-w64-mingw32-gcc BUILD_TYPE=32d
# make libzip libzip_test CC=x86_64-w64-mingw32-gcc BUILD_TYPE=64d

# general config
CC:=clang # clang (llvm-mingw), gcc (mingw-w64), tcc (x86 stdcall name has problem)
BUILD_TYPE:=32# 32, 32d, 64, 64d
BUILD_DIR:=build
INCS:=-Isrc
LIBS:=-luser32
CFLAGS:=-fPIC -std=c99 \
	-fvisibility=hidden \
	-ffunction-sections -fdata-sections
LDFLAGS:=-Wl,--enable-stdcall-fixup \
		 -Wl,--kill-at \
		 -Wl,--gc-sections \
		 -D_WIN32_WINNT=0X0400 \
		 -Wl,--subsystem,console:4.0 # compatible for xp

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

$(BUILD_DIR)/libzip$(BUILD_TYPE).dll: src/libzip.c src/stb_zip.h
	$(CC) $< -o $@ -shared \
		$(INCS) $(LIBS) \
		$(CFLAGS) $(LDFLAGS)

$(BUILD_DIR)/libzip_test$(BUILD_TYPE).exe: src/libzip_test.c $(BUILD_DIR)/libzip$(BUILD_TYPE).dll
	$(CC) $< -lzip$(BUILD_TYPE) -L$(BUILD_DIR) -o $@ \
	$(INCS) $(LIBS) \
	$(CFLAGS) $(LDFLAGS) 

stbzip: script/build_stbzip.py
	python $< depend/zip $(BUILD_DIR)/stb_zip.h
	cp -f $(BUILD_DIR)/stb_zip.h src/stb_zip.h

libzip: $(BUILD_DIR)/libzip$(BUILD_TYPE).dll

libzip_test: $(BUILD_DIR)/libzip_test$(BUILD_TYPE).exe

.PHONY: all clean prepare stbzip libzip libzip_test