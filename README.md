# Linux Bohai - Season 2 [![Build Status](https://api.travis-ci.org/metasepi/linux-bohai-s2.svg)](https://travis-ci.org/metasepi/linux-bohai-s2/)

## How to build

### Debian

```
$ sudo apt-get install fakeroot kernel-package
$ fakeroot make-kpkg -j 2 --initrd --revision=0.1 kernel_image kernel_headers
```
