Building a Crankshaft image
--

The heart of Crankshaft is the ./crankshaft.sh script. I assume you use Linux.

Issue `sudo ./crankshaft.sh`

- If you call it with no parameters, it will generate a crankshaft image given you have supplied all the binary blobs
as listed in the BLOBS.txt file (see below)

- `sudo IMAGE=Your-Crankshaft-Image.img DROP_IN=1 ./crankshaft.sh` will allow you to "drop in" a root crankshaft shell of any crankshaft image. You can do whatever you like there.

- `sudo IMAGE=Your-Crankshaft-Image.img CUSTOM_SCRIPT=your_script.sh ./crankshaft.sh` will run your script after it has mounted or created the crankshaft image.


Obtaining the binary blobs
--

I have tried to cross-compile before. It isn't perfect and has many problems. I have given up on cross compiling. Now you actually have 2 choices to obtain the binary blobs:

1. Extract the binaries from the CS image.

I've tested this on Ubuntu. That's my main dev machine. Download the latest crankshaft image. Clone the newest git repo. Put the image into the repo, let's say it's called `crankshaft-2018-04-08.img`. Then do:

`sudo DROP_IN=1 IMAGE=crankshaft-2018-04-08.img ./crankshaft.sh`

It will drop into the prebuilt image for you. Now the image is mounted at `/mnt/raspbian-temp`. You can use whatever you like to extract the required blobs and put them into the correct location. Here are the list and where to put them: `https://github.com/htruong/crankshaft/blob/master/BLOBS.txt`

For example, when you need the `crankshaft/rootfs/usr/local/bin/autoapp` blob, it will be at `/mnt/raspbian-temp/usr/local/bin/autoapp`. Just copy it there. The exception to that is the Qt5 blob. You need to tar it first to make `libQt5_OpenGLES2.tar.xz`,then put it to prebuilt.

2. Build them. You can build everything starting off with a raspbian lite image and then do all the apt-get update && apt-get upgrade businesses (actually important). Then you can download the Qt5 build script. `https://github.com/htruong/crankshaft/blob/master/prebuilt/make-qt5.sh` - then `chmod +x` it and then run it, you'll end up with a `tar.xz` file.

For the aasdk + openauto blob, build them exactly as the wiki said on an actual rpi3 It'll work like a charm. The reason cross compiling didn't work was that the cross-compiler didn't know where to look for the Broadcom blobs, and openauto needs the Broadcom blobs, and you probably can't provide that in a cross-compiling environment. 
