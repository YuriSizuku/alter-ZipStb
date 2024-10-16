"""
generate stb_zip.h file
    v0.1, developed by devseed
"""

info = \
"""// single header file composed by devseed
// see https://github.com/YuriSizuku/alter-ZipStb
"""

import re
import os
import sys

# general functions
def mark_section(info):
    def wrapper1(func): # decorator(dec_args)(func)(fun_args)
        def wrapper2(*args, **kw):
            ccode = func(*args, **kw)
            return f"#if 1 // {info}\n{ccode}\n#endif"
        return wrapper2
    return wrapper1

def ccode_replace(pattern, repl, count=0, flags=0):
    def wrapper1(func): # decorator(dec_args)(func)(fun_args)
        def wrapper2(*args, **kw):
            ccode = func(*args, **kw)
            return re.sub(pattern, repl, ccode, count=count, flags=flags)
        return wrapper2
    return wrapper1

def read_lines(inpath, encoding="utf-8"):
    with open(inpath, "r", encoding=encoding) as fp:
        lines = fp.readlines()
    return lines

def replace_lines(lines, replace_map, strip_left=False):
    for i, line in enumerate(lines):
        for k, v in replace_map.items():
            if line.find(k) >=0: 
                lines[i] = line.replace(k, v)
                if strip_left: lines[i] = lines[i].lstrip()
    return lines

def static_func(lines):
    for i, line in enumerate(lines):
        if re.match(r"\w(.+?)\s*(.+?)\((.+?)\)\s*;", line.lstrip()):
            lines[i] = "static " + line
    return lines

def make_stbdecl() -> str:
    return  """
#if defined(_MSC_VER) || defined(__TINYC__)
#ifndef EXPORT
#define EXPORT __declspec(dllexport)
#endif
#else
#ifndef EXPORT 
#define EXPORT __attribute__((visibility("default")))
#endif
#endif // _MSC_VER
#ifndef ZIP_API
#ifdef ZIP_STATIC
#define ZIP_API_DEF static
#else
#define ZIP_API_DEF extern
#endif // ZIP_STATIC
#ifdef ZIP_SHARED
#define ZIP_API_EXPORT EXPORT
#else  
#define ZIP_API_EXPORT
#endif // ZIP_SHARED
#define ZIP_API ZIP_API_DEF ZIP_API_EXPORT
#endif // ZIP_API
"""

def patch_zip(inpath) -> str:
    lines_h = read_lines(os.path.splitext(inpath)[0] + ".h")
    lines_h = replace_lines(lines_h, {
        "#define ZIP_EXPORT": "#define ZIP_EXPORT_HIDE",
        "extern ZIP_EXPORT": "ZIP_API"
    })
    lines_c = read_lines(os.path.splitext(inpath)[0] + ".c")
    lines_c = replace_lines(lines_c, {
        '#include "miniz.h"': '// #include "miniz.h"',
        '#include "zip.h"': '// #include "zip.h"',
    })
    return "".join(lines_h), "".join(lines_c)

def patch_minniz(inpath) -> str:
    lines = read_lines(inpath)
    return "".join(lines)

def make_zipstb(repodir, info, version) -> str:
    stbdecl_ccode = make_stbdecl()
    zipdecl_ccode, zip_ccode = patch_zip(os.path.join(repodir, "src/zip.c"))
    miniz_ccode = patch_minniz(os.path.join(repodir, "src/miniz.h"))
    return f"""{info}
#ifndef _ZIP_H
#define _ZIP_H
#define ZIP_VERSION {version} 
{stbdecl_ccode} 
{zipdecl_ccode}

#ifdef ZIP_IMPLEMENTATION 
#endif // ZIP_IMPLEMENTATION
#include <direct.h>
{miniz_ccode}
{zip_ccode}
#endif // _ZIP_H" 
"""

if __name__ == "__main__":
    srcdir = sys.argv[1] if len(sys.argv) > 1 else "depend/zip" 
    outpath = sys.argv[2] if len(sys.argv) > 2 else "build/stb_zip.h"
    version = sys.argv[3] if len(sys.argv) > 3 else "320"
    ccode = make_zipstb(srcdir, info, version)
    with open(outpath, "w", encoding="utf-8") as fp:
        fp.write(ccode)
    with open(f"{os.path.splitext(outpath)[0]}_v{version}.h", "w", encoding="utf-8") as fp:
        fp.write(ccode)