
// BUILD:  $CC foo.c -dynamiclib  -install_name $RUN_DIR/libfoo-static.dylib  -o $BUILD_DIR/libfoo-static.dylib
// BUILD:  $CC foo.c -dynamiclib  -install_name $RUN_DIR/libfoo-dynamic.dylib -o $BUILD_DIR/libfoo-dynamic.dylib -DDYN
// BUILD:  $CC main.c $BUILD_DIR/libfoo-static.dylib -o $BUILD_DIR/dlsym-RTLD_DEFAULT.exe -DRUN_DIR="$RUN_DIR"

// RUN:  ./dlsym-RTLD_DEFAULT.exe

#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <mach-o/dyld_priv.h>

#include "test_support.h"

// verify RTLD_DEFAULT search order

int mainSymbol = 4;


// my local implemention of free
void free(void* p) { }


static bool symbolInImage(const char* symName, const char* image)
{
    void* sym = dlsym(RTLD_DEFAULT, symName);
    if ( sym == NULL )
        return false;
    const char* imagePath = dyld_image_path_containing_address(sym);
    if ( imagePath == NULL )
        return false;
    return (strstr(imagePath, image) != NULL);
}



int main(int argc, const char* argv[], const char* envp[], const char* apple[]) {
    // verify mainSymbol is found in main executable
    if ( !symbolInImage("mainSymbol", "dlsym-RTLD_DEFAULT") ) {
        FAIL("mainSymbol");
    }

    // verify free is found in main executable, overrideing one in OS
    if ( !symbolInImage("free", "dlsym-RTLD_DEFAULT") ) {
        FAIL("free");
    }

    // verify foo is found in libfoo-static.dylib
    if ( !symbolInImage("foo", "libfoo-static.dylib") ) {
        FAIL("foo not in libfoo-static.dylib");
    }

    void* handle = dlopen(RUN_DIR "/libfoo-dynamic.dylib", RTLD_LAZY);
    if ( handle == NULL ) {
        FAIL("libfoo-dynamic.dylib could not be loaded");
    }

    // verify foo is still found in statically linked lib
    if ( !symbolInImage("foo", "libfoo-static.dylib") ) {
        FAIL("foo not in libfoo-static.dylib");
    }

    // verify foo2 is found in libfoo-dynamic.dylib"
    if ( !symbolInImage("foo2", "libfoo-dynamic.dylib") ) {
        FAIL("foo2 not in libfoo-dynamic.dylib");
    }

    // renamed and re-exported symbols work
    if ( dlsym(RTLD_DEFAULT, "strcmp") == NULL ) {
        FAIL("strcmp not found");
    }
    
    PASS("Success");
}

