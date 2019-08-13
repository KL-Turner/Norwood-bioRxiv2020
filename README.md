# Streaming and analyzing an Intel RealSense camera using Matlab

Repository contents:
* +realsense - Intel RealSense library, contains Matlab wrapper to run/stream the camera. See https://github.com/IntelRealSense/librealsense
* StreamRealSenseCam.m - Run to stream camera
* AnalyzeRealSenseData.m - Run to analyze saved camera data
* Support Scripts
* kalmanStackFilter - See https://www.mathworks.com/matlabcentral/fileexchange/26334-kalman-filter-for-noisy-movies

Clone or download the repository and add the folder to the Matlab filepath. Open *StreamRealSenseCam.m* and hit **Run**. Follow the Command Window prompts:
1) Enter the number of minutes you want to stream the camera for (multiples of 5 minutes)
2) Select or create the folder for the data to be saved to.
3) Verify the camera alignment. You will be presented a brief still-shot of something similar to **Figure [A]**. If the camera is aligned, type 'y'. If not, type 'n' and re-align the camera. 

Once completed, the camera will begin streaming a pseudo-depth imagesc stream similar to **Figure [B]**. I refer to this stream as pseudo-depth because the colorized image is relative to the topography of the image and tries to emphasize contrast. It also updates in real-time based on the max/min depth of the image. If you move your hand into the image stream, you'll notice the entire color scheme changes slightly. This image stream therefore contains no useful information, and is not saved. However, it is useful in trouble-shooting and evaluating how the mouse moves in the container.

| [A] Verify camera alignment | [B] Live pseudo-depth stream |
| :---: | :---: |
| ![](https://user-images.githubusercontent.com/30758521/58644880-31b0f580-82d0-11e9-934c-e95dd4d3ec70.PNG) | ![](https://user-images.githubusercontent.com/30758521/58645042-8ce2e800-82d0-11e9-9a1d-fceb67a770b3.png) |

I chose a smooth-bottom, opaque plastic container that is slightly larger than the mouse's home cage. Bedding can be applied to the bottom of the cage if desired. The mouse's original cage, which has yellow-tinted clear walls, creates a mirror reflection of the mouse that shows up whenever the mouse approaches the wall. This causes significant issues when trying to background-subract the movie and easily track the moving mouse. An opaque, not-reflective container such as these plastic dish bins from Amazon work surprisingly well. They are sufficiently tall that the mouse cannot climb out, provide a smooth depth across the top/sides that doesn't change or reflect the mouse's image, and are easy to clean in-between animals. 

| [C] Initial background removal | [D] Aggressive removal | [E] Colormap adjustment |
| :---: | :---: | :---: | 
![](https://user-images.githubusercontent.com/30758521/58644916-49887980-82d0-11e9-86a6-41bfe30f98c1.PNG) | ![](https://user-images.githubusercontent.com/30758521/58644945-5907c280-82d0-11e9-9d08-62836ba1c563.PNG) | ![](https://user-images.githubusercontent.com/30758521/58644986-6b81fc00-82d0-11e9-98e5-c07f3dc26254.PNG)

After the data has been saved, the **AnalyzeRealSenseData.m** function can be run.

| [F] | [G] |
| :---: | :---: | 
![](https://user-images.githubusercontent.com/30758521/58645601-b51f1680-82d1-11e9-8258-6ea087f5e876.PNG) | ![](https://user-images.githubusercontent.com/30758521/58645661-cbc56d80-82d1-11e9-9e34-41f5d369d6ca.PNG)

https://drive.google.com/open?id=1bm5rme1uLDVhCFwZuQwwitrVzJbDFngH