/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

@author	Raphael Harmel
@date	2011-03-17

********************
**  Description   **
********************

This plugin is used to take a snapshot of a publication.
The snapshot image will be generated in the content folder of the publication, based on the visible page when the user presses the snapshot icon.


********************
**  Installation  **
********************

To install this plugin on a silex server, use the manager's plugin installer (exchange platform), or copy the snapshot plugin folder in the silex_server/plugins folder.


********************
**  Activation    **
********************

Server activation (for all publications):
In the server's manager go to "Settings > Plugins > Activate a plugin", click on the plugin icon and then on "confirm".

Specific publication activation:
In the server's manager go to "Manage", click on the publication on which the plugin should be activated, then click on "Plugins > Activate a plugin", and finally click on the plugin icon and then on "confirm".


********************
**  Parameters    **
********************

It is not a requisite to set following parameters as they all have default values.
If needed, their values can be changed in the server's manager. To do so, go to "Manage", click on the publication, click on "Plugins => snapshot" and then change the needed parameters.
Please keep in mind only publication's snapshot plugin parameters are taken in account, but not server ones.

	snapShotTool_layoutDepth:
		depth of the layout to be taken as snapshot source, and which gives its name to the image.
		example: when the user takes a snapshot of page /start/layer1/layer1-1/, the picture will be named "start.png" if layoutDepth is set to 0, or "layer1.png" if layoutDepth is set to 1, or "layer1-1.png" if layoutDepth is set to 2 
		default is "0"
		
	snapShotTool_imageType (jpg or png):
		the snapshot picture type.
		default is "png"
		
	snapShotTool_imageWidth:
		the width of the zone to be taken as snapshot source
		default is the publication width

	snapShotTool_imageHeight:	
		the height of the zone to be taken as snapshot source
		default is the publication height
	
	snapShotTool_imageX:
		the X offset of the zone to be taken as snapshot source
		default is 0
	
	snapShotTool_imageY:
		the Y offset of the zone to be taken as snapshot source
		default is 0

		
********************
**  Use           **
********************

Click on the ViewMenu's snapShot button.
Information messages will be dispatched at the start and end of the process.


********************
**  Content       **
********************

The snapshot plugin folder contains several files:

	index.php:
		contains the php and the links to the swf files needed to load the plugin. It inserts a reference to snap_shot_tool_view_menu_item.swf in the admin api's view menu items. It then loads snapshot_tool.swf in silex. Finally it has the two javascript functions used by the 2 swfs to communicate by ExternalInterface function.
		
	snap_shot_tool_view_menu_item.swf:
		the snapshot button visible in the viewmenu. (AS3)
		
	snapshot_tool.swf:
		Handles the snapshot process.
		When ViewMenu's snapShot button is clicked, it retrieves the plugin config, stores all the plugin info and pixel info in an object and send the object to write_image.php to be saved.

