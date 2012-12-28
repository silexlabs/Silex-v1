COMPILING THE SILEX AS2 FRAMEWORK INTO A SWC AND FLASH PLUGIN

You need to have Flash IDE CS5 and the adobe extension manager installed


- open the SilexAs2FrameWorkPackager.fla file.

- In the Flash library, right click on the "SilexAs2FrameWork" compiled asset.

- Select "export the SWC" and export it in the same directory as the .fla. IMPORTANT : the "SilexAs2FrameWorkPackager_exclude.xml" file must not be in the folder at this moement, else
  the framework classes won't be put in the SWC. You restore the xml file in the next step.

- Publish the .fla with F12. It will create a .swf called "SilexAs2FrameWork" in the same directory.

- With Winrar or another zip tool, open the "SilexAs2FrameWork.swc" (it is just a .zip file with a different extension).

- In Winrar, replace the "SilexAs2FrameWork.swf" file with the one you published previously. 

  The aim is to replace the .swf containing the silex framework classes with a ligther one,
  lighter thanks to the exclude file in the directory excluding all of the silex framework class from the published "SilexAs2FrameWork.swf". 
  All those classes are always loaded at Silex startup, so we only need the interfaces of the classes in the .swc to compile components.
  It greatly reduce the size of the compiled components to not include the Silex As2 framework (around 50kb) in each of them.

- Double click on the "SilexAs2FrameWorkPackager.mxi" file. It will open the adobe extension manager and allow you to save an ".mxp" file which is
  the Flash plugin to distribute. When double clicking the ".mxp" file, it will install the Silex As2 FrameWork as a Flash Component, accesible within
  the component panel in Flash.
