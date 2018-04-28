Porting Crankshaft to a new Distribution/board
--

If you need to get it to work with a custom board, The general direction is generally this:

- Start with a clean stock image from the provider: raspbian, rock64 image, tinkerboard...
- Try to compile Qt with the script in `prebuilt` (refer to `COMPILE.md`).
- Try to compile OpenAuto & aasdk according to aadsk wiki. Try to see if that works.
- If it does, you need to "rescue" those binaries out of your test image.
- Transplant the binaries to another clean image (so we only have binaries, but no source) to see if that still works.

If all those works, you'll have to begin modifying `crankshaft.sh` to ask it to make it work with your board of choice. It does three things basically:

- First, it downloads and resizes the image so we have enough space for the stuff we're going to install. It also copies the binaries to the image.
- Second, it `chroot`s to the image and `apt install` more stuff to the image by executing `customize-image-pi.sh`.
- Third, it does some tweakings to make the filesystem read-only by executing `read-only-fs.sh`

To make it work minimally, you only need to do 1 & 2. 3 is the bonus, but it's not necessary for you just need Crankshaft to work.
