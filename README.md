Crankshaft = Raspberry Pi 💖 Android Auto
==

Crankshaft is a turn-key distribution for the Raspberry Pi. It transforms your Raspberry Pi to an [Android Auto headunit](https://www.android.com/auto/) thanks to the power of [OpenAuto](https://github.com/f1xpl/openauto) and [aasdk](https://github.com/f1xpl/aasdk).

This is the source code repository, just in case you want to build the system yourself. To get the binary without dealing with all this stuff, please head to [GetCrankshaft.com](http://getcrankshaft.com). There you can find guides and videos too. 

Report a bug?
--

To file a bug or an enhancement idea, please file an issue on this repository. For bugs or ideas related to OpenAuto or aasdk, please go to f1xpl's corresponding repository to file a bug report.


How to build a Crankshaft image
--

This repository provides a skeleton for you to build your own Crankshaft image, but it doesn't have all the binary blobs that are the result of the build process. When you supply all the three, you should be able to call `sudo ./make-crankshaft.sh` and it will build the `img` file for you.

There are three missing binary blobs in the `precompiled` directory: 

- `libQt5_OpenGLES2.tar.xz`: Qt5 library compiled with Raspberry Pi OpenGL ES2 library.
- `autoapp`: OpenAuto binary
- `libaasdk.so`: aasdk binary

Please head to the Wiki for instruction how to build each of the component yourself.


