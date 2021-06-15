# lzw-hptdemo
**happy party three demo** is a ZX Spectrum 128K production, done by LZW group and first shown at the happy party three (an online visual art show). The source code is presented mostly for archival purposes - due to being my first attempt at coding something bigger in Z80 assembly, the code is mostly a mess and probably not good for anyone to use as a reference. 

# Credits
* wermi - programming, design
* Zlew - music
* Loni - graphics, animation

## 3rd party assets
* [Enter Command font](https://fontenddev.com/fonts/enter-command/) from fontenddev.com (CC BY 4.0)
* VTII PT3 player from http://bulba.untergrund.net/VT1.0beta19Plus.src.7z
* 8b\*8b multiplication adapted from https://www.cpcwiki.eu/index.php/Programming:Integer_Multiplication#Fastest.2C_accurate_8bit_.2A_8bit_Unsigned_with_16_KB_tables
* aPLib decompressor from https://www.cpcwiki.eu/forum/programming/quick-update-on-the-state-of-the-art-compression-using-aplib/
* screen LUT generation routine from https://chuntey.wordpress.com/2010/03/22/sprite-graphics-tutorial/
#### The repository also includes executables for following software:
* sjasmplus - https://github.com/z00m128/sjasmplus
* apultra - https://github.com/emmanuel-marty/apultra
* oapack - https://gitlab.com/eugene77/oapack

# Building
## Windows
Run `make.bat`.
## Linux/macOS/others
Build/install sjasmplus, then run `sjasmplus prog.asm --sld --fullpath`.

# TODO
* verify real hardware compatibility
* add compression of main demo data for reduced size
