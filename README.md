# leesuhzhoo
A tool for exploring Lissajous patterns on an oscilloscope

### Background
Developed in Processing, using a 2D slider as an intuitive way to discover ideal frequency ratio's for Lissajous patterns. Initially a gift for Stefanie Bräuer to reverse engineer Lissajous patterns in support of her PhD on early experimental film makers who used the oscilloscope (Mary Ellen Bute, Hy Hirsh, Norman McLaren) – it's now going open source for others to play with and enjoy! 

### Download
Run the software precompiled, just goto 'Releases' to download.<br>
Works on MacOS 10.7+

### Compile
Runs in Processing 3.3.6, with the following library dependences:
- Minim
- Control P5

### Usage
Works fine digitally, but ideally hooked up to an analog oscilloscope using your headphone jack and a 1/8" to RCA cable, feeding the left and right audio to the X and Y inputs of the scope using RCA » BNC adaptors.

View demonstration video:

[<img src="https://i.imgur.com/U6JkPv4.png" width="320px">](https://vimeo.com/254942204)

Find an ideal frequency relationship by dragging the circle anywhere within the grid.<br>
You can make minor adjustments with the arrow keys (hold down shift for bigger jumps).

<img src="https://media.giphy.com/media/3ohjUSC1jUj1Y33iKY/giphy.gif" width="320px">

Modify the frequency min/max to limit or expand the range in which you search.

<img src="https://i.imgur.com/TjA82I5.png" width="160px">

For each channel X/Y, you can modify what type of waveform it has and set an exact frequency.<br>
You can then adjust the phase and set a sweep for animating the Lissajous pattern (in XY-Mode).

<img src="https://i.imgur.com/ZnqGQRR.png" width="320px">

Under 'SCOPE' you can hide the emulated oscilloscope, pause it and enable/disable XY-Mode.<br>
Once you've found a nice Lissajous pattern, pause and disable XY-Mode to compare the waveforms.

<img src="https://i.imgur.com/UfYSISf.png" width="160px"> <img src="https://i.imgur.com/JY2wmdP.png" width="160px">

Save/Load Settings allows you to store and recall your favorite patterns.<br>
First create a folder to store them into, then all other settings will become available from a dropdown list once you've saved or loaded once.
