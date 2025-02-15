#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "stb_zip.h"

int main(int argc, char *argv[])
{
    printf("%s ", argv[0]);
    #if defined(_MSC_VER)
    printf("compiler MSVC=%d\n", _MSC_VER);
    #elif defined(__GNUC__)
    printf("compiler GNUC=%d.%d\n", __GNUC__, __GNUC_MINOR__);
    #elif defined(__TINYC__)
    printf("compiler TCC\n");
    #endif
    
    // write zip stream
    const char *inbuf = "test data for libzip\0";
    char *zipbuf = NULL;
    size_t zipsize = 0;
    struct zip_t *zip = zip_stream_open(NULL, 0, ZIP_DEFAULT_COMPRESSION_LEVEL, 'w');
    assert(zip);
    zip_entry_open(zip, "test1.txt");
    zip_entry_write(zip, inbuf, strlen(inbuf) + 1);
    zip_entry_close(zip);
    zip_stream_copy(zip, (void **)&zipbuf, &zipsize); /* copy compressed stream into zipbuf */
    printf("write zipbuf=%p zipsize=%zd\n", zipbuf, zipsize);
    zip_stream_close(zip);
    assert(zipbuf);
    assert(zipsize);

    // read zip stream
    char *outbuf = NULL;
    size_t outsize = 0;
    zip = zip_stream_open(zipbuf, zipsize, 0, 'r');
    assert(zip);
    zip_entry_open(zip, "test1.txt");
    zip_entry_read(zip, (void **)&outbuf, &outsize);
    printf("read outbuf=%p outsize=%zd\n", outbuf, outsize);
    puts(outbuf);
    assert(outbuf);
    assert(outsize == strlen(inbuf) + 1);
    assert(strcmp(inbuf, outbuf)==0);
    zip_entry_close(zip);
    zip_stream_close(zip);
    free(outbuf);
    free(zipbuf);

    return 0;
}