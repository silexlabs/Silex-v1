COMPILING THE SILEX FLASH FRAMEWORK INTO A SWC AND FLASH PLUGIN

You need to have Flash IDE CS5 and the adobe extension manager installed

1. open the SilexFlashFrameWorkPackager.fla file.

2. In the Flash library, right click on the "SilexFlashFrameWork" compiled asset.

3. Select "export the SWC" and export it in the same directory as the .fla. IMPORTANT : the "SilexFlashFrameWorkPackager_exclude.xml" file must not be in the folder at this moment, else
  the framework classes won't be put in the SWC. You can move or rename it.
  You must now restore the xml file before step 4.

4. Publish the .fla with F12. It will create a .swf called "SilexFlashFrameWork" in the same directory.

5. With 7zip or another zip tool, open the "SilexFlashFrameWork.swc" (it is just a .zip file with a different extension).

6. In 7zip, replace the "SilexFlashFrameWork.swf" file with the one you published previously in step 4. 

  The aim is to replace the .swf containing the silex framework classes with a ligther one,
  lighter thanks to the exclude file in the directory excluding all of the silex framework class from the published "SilexFlashFrameWork.swf". 
  All those classes are always loaded at Silex startup, so we only need the interfaces of the classes in the .swc to compile components.
  It greatly reduce the size of the compiled components to not include the Silex As2 framework (around 50kb) in each of them.

7. Double click on the "SilexFlashFrameWorkPackager.mxi" file. It will open the adobe extension manager and allow you to save an ".mxp" file which is
  the Flash plugin to distribute. When double clicking the ".mxp" file, it will install the Silex As2 FrameWork as a Flash Component, accesible within
  the component panel in Flash.
