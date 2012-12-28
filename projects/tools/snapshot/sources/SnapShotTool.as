/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * This class is used to create a snapshot of the curent silex publication
 * @author Raphael Harmel
 * @date 2011-03-10
 */

import flash.external.ExternalInterface;
import flash.geom.ColorTransform;
import mx.utils.Delegate;
import org.silex.core.Api;
import flash.display.BitmapData;
import org.silex.core.Layout;
import org.silex.core.Utils;
import org.silex.core.Sequencer;
import org.silex.plugins.snapshot.PluginConfigVO;
import org.silex.plugins.snapshot.ServerDataVO;

class SnapShotTool
{
	/**
	 * Reference to silex main Api object.
	 */
	private static var _silexPtr:Api = _global.getSilex();
	/**
	 * Object used to store plugin config
	 */
	private var _pluginConfig:PluginConfigVO;
	/**
	* PHP write image script Url
	**/
	private static var PHP_WRITE_IMAGE_SCRIPT_URL:String = 'plugins/snapshot/write_image.php';
	/**
	* Frame loop delay
	**/
	private var _frames:Number = 0;
	/**
	 * number of loops done on each frame (done to enhance performance)
	 * After tests, if value is >1, website navigation is too slow. So chosen value is 1.
	 */
	private var _loops:Number = 1;

	
	/**
	 * Class constructor. Adds a 'takeSnapShot' callback which is called by the JavaScript contained in the index.php of the plugin
	 */
	public function SnapShotTool()
	{
		//ExternalInterface.addCallback("SnapShotTool_takeSnapShot", this, Delegate.create(this, takeSnapShot));
		ExternalInterface.addCallback("SnapShotTool_takeSnapShot", this, Utils.createDelegate(this, takeSnapShot));

		// Retrieve the configuration of the plugin with the getPluginConf method
		getPluginConfig();
		/*for (var prop:String in _pluginConfig) {
			trace(prop + ": " + _pluginConfig[prop]);
		}*/
	}
	
	/**
	 * Entry point of the snapshot process. Gets the picture width/height using Silex API (the dimensions of the scene) and retrieves the configuration of the plugin with the getPluginConf method. These datas are then passed to getPluginsPixels method, and then to the writePicture method with the object containing all the required data.
	 */
	public function takeSnapShot():Void
	{
		// Layout taken as reference for the snapshot
		var layout:Layout;
		// Initialise the layout to layoutDepth
		layout = _silexPtr.application.layouts[_pluginConfig.layoutDepth];

		// get user message tranlations from php
		var snapshotTranslation:Object = new Object();
		snapshotTranslation = ExternalInterface.call("getSnapshotTranslation");

			// If layout exists (done to avoid errors)
		if (layout != undefined) {
			
			// Get the clean section name of the corresponding layer
			var serverData:ServerDataVO = new ServerDataVO;
			serverData.fileName = layout['cleanSectionName'] + '.' + _pluginConfig.imageType;
			
			// Snapshot process start user information message
			_silexPtr.utils.alertSimple( snapshotTranslation.SNAPSHOT_MESSAGE_START + " (" + serverData.fileName +")" );
			
			// Get the pixel data
			getPluginPixels(serverData);
		} else {
			_silexPtr.utils.alertSimple( snapshotTranslation.SNAPSHOT_MESSAGE_ERROR_7 + " " + _pluginConfig.layoutDepth + ".",null,null,'error');
		}
	}
	
	/**
	 * Gets the configuration of the plugin by retrieving it from silexApi::config object
	 * If no value is found, takes default values
	 */
	private function getPluginConfig(serverData:ServerDataVO):Void
	{
		/**
		 * Object to be filled with plugin config information and to be returned
		 */
		_pluginConfig = new PluginConfigVO;
		/**
		 * Reference to silex main Api config.
		 */
		var silexPtrConfig:Object = _silexPtr.config;
		/**
		 * snapShotTool_layoutDepth
		 */
		var layoutDepth:Number = 0;
		// If snapShotTool_layoutDepth is defined, initialise the layoutDepth to the corresponding value
		if (silexPtrConfig['snapShotTool_layoutDepth'] != undefined) {
			layoutDepth = parseInt(silexPtrConfig['snapShotTool_layoutDepth']);
		}
		_pluginConfig.layoutDepth = layoutDepth;
		
		
		/**
		 * snapShotTool_imageType
		 */
		var imageType:String = 'png';
		// If snapShotTool_imageType is defined, initialise the imageType to the corresponding value
		if (silexPtrConfig['snapShotTool_imageType'] != undefined) {
			imageType = silexPtrConfig['snapShotTool_imageType'];
		}
		_pluginConfig.imageType = imageType;
		
		
		/**
		 * snapShotTool_imageWidth
		 */ 
		var width:Number;
		var layoutStageWidth:Number = parseInt(silexPtrConfig['layoutStageWidth']);
		// If snapShotTool_imageWidth is defined in the plugin, use it, otherwise use layout stage width
		if (silexPtrConfig['snapShotTool_imageWidth'] != undefined) {
			width = parseInt(silexPtrConfig['snapShotTool_imageWidth']);
		} else {
			width = parseInt(silexPtrConfig['layoutStageWidth']);
		}
		_pluginConfig.width = Math.round(width);
		_pluginConfig.layoutStageWidth = layoutStageWidth;

		
		/**
		 * snapShotTool_imageHeight
		 */ 
		var height:Number;
		var layoutStageHeight:Number = parseInt(silexPtrConfig['layoutStageHeight']);
		// If snapShotTool_imageHeight is defined in the plugin, use it, otherwise use layout stage height
		if (silexPtrConfig['snapShotTool_imageHeight'] != undefined) {
			height = parseInt(silexPtrConfig['snapShotTool_imageHeight']);
		} else {
			height = parseInt(silexPtrConfig['layoutStageHeight']);
		}
		_pluginConfig.height = Math.round(height);
		_pluginConfig.layoutStageHeight = layoutStageHeight;

		
		/**
		 * snapShotTool_imageX & snapShotTool_imageHeight
		 */ 
		var xPosition:Number = 0;
		// If snapShotTool_imageX is defined, initialise the xPosition to the corresponding value
		if (silexPtrConfig['snapShotTool_imageX'] != undefined) {
			xPosition = parseInt(silexPtrConfig['snapShotTool_imageX']);
		}
		_pluginConfig.xPosition = xPosition;

		
		/**
		 * snapShotTool_imageY
		 */ 
		var yPosition:Number = 0;
		// If snapShotTool_imageY is defined, initialise the yPosition to the corresponding value
		if (silexPtrConfig['snapShotTool_imageY'] != undefined) {
			yPosition = parseInt(silexPtrConfig['snapShotTool_imageY']);
		}
		_pluginConfig.yPosition = yPosition;
		
	}
	
	/**
	 * Calls either the getPngPixels method either the getJpgPixels. Instantiates a BitmapData with the right parameters (pictureWidth/Height, transparent or not)
	 * 
	 */
	//private function getPluginPixels(_pluginConfig:Object):Object
	private function getPluginPixels(serverData:ServerDataVO):Void
	{
		var bitmapData:BitmapData;
		var layerMC:Object;
		
		// Select the chosen layout
		var targetPath:String = 'silex.application.layouts.' + _pluginConfig.layoutDepth + '._parent';
		layerMC = _silexPtr.utils.getTarget(_root, targetPath);
		
		// Initialize serverData.data LoadVar containing image data to be be sent as POST data
        serverData.data.width = _pluginConfig.width;
        serverData.data.height = _pluginConfig.height;
        serverData.data.colums = 0;
        serverData.data.rows = 0;
		
		// Depending on the pictureType, define BitmapData's transparency and call the corresponding method
		if (_pluginConfig.imageType == 'png')
		{
			// Increment _frames
			_frames++;
			// Create the bitmapData with stage layout width and height, with transparency on, and fill it with transparent color
			bitmapData = new BitmapData(_pluginConfig.layoutStageWidth, _pluginConfig.layoutStageHeight, true, 0x00FFFFFF);
			// fill bitmapData with layer Movie Clip
			bitmapData.draw(layerMC);
			getPngPixels( new Object({ serverData:serverData, bitmapData:bitmapData,heightIterator:0 }) );
		}
		else if (_pluginConfig.imageType == 'jpg')
		{
			// Increment _frames
			_frames++;
			// Create the bitmapData with stage layout width and height, with transparency off
			bitmapData = new BitmapData(_pluginConfig.layoutStageWidth, _pluginConfig.layoutStageHeight, false);
			// fill bitmapData with layer Movie Clip
			bitmapData.draw(layerMC);
			getJpgPixels( new Object({ serverData:serverData, bitmapData:bitmapData,heightIterator:0 }) );
		}
		else
		{
			// User information message if Snapshot plugin parameter snapShotTool_imageType does not correspond to a valid extension
			_silexPtr.utils.alertSimple("Snapshot plugin parameter snapShotTool_imageType=" + _pluginConfig.imageType + " does not correspond to a valid extension.",null,null,'error');
		}
	}
	
	
	/**
	 * Loops over the the pixels of the bitmap Image. Called by a setInterval so the browser does not hang.
	 * gets all pixels of a line of the bitmapData with their alpha, and stores them in an array
	 * 
	 * @param	Object containing:
	 * 			serverData: the server data 
	 * 			bitmapData: bitmap data from which data is retreived 
	 * 			heightIterator: the bitmap data height iterator
	 */
	private function getPngPixels(data:Object):Void
	{
		// Instanciate the function's parameters
		var serverData:ServerDataVO = data.serverData;
		var bitmapData:BitmapData = data.bitmapData;
		// Height iterator used when reading bitmapData
		var heightIterator:Number = data.heightIterator;
		var pixelData32:Number;
		var pixelString:String;
		var sequencer:Sequencer = _silexPtr.sequencer;
		var iterator:Number = 0;

		while ( (iterator < _loops) && (heightIterator < _pluginConfig.height) )
		{
			serverData.data[heightIterator] = new Array;
			// Get line pixels
			for (var x:Number = 0; x < _pluginConfig.width; x++)
			{
				pixelData32 = bitmapData.getPixel32(x + _pluginConfig.xPosition, heightIterator + _pluginConfig.yPosition);
				
				var alpha:String = (pixelData32 >> 28 & 0xF).toString(16) + (pixelData32 >> 24 & 0xF).toString(16);
				var red:String   = (pixelData32 >> 20 & 0xF).toString(16) + (pixelData32 >> 16 & 0xF).toString(16);
				var green:String = (pixelData32 >> 12 & 0xF).toString(16) + (pixelData32 >> 8 & 0xF).toString(16);
				var blue:String  = (pixelData32 >> 4 & 0xF).toString(16) + (pixelData32 & 0xF).toString(16);
				
				// build pixel hexacimal data
				pixelString = alpha + red + green + blue;
				// if pixel is blank, don't send it - done to reduce size of POST data
				if (pixelString == 'ffffffff') pixelString = "";   
				//trace('(x,y): (' + x + ',' + heightIterator + ') - ARGB: ' + pixelString);
				
				serverData.data[heightIterator].push(pixelString);
			}
			heightIterator++;
			iterator++;
		}
		// If all pixels have been stored into serverData
		if (heightIterator >= _pluginConfig.height) {
			bitmapData.dispose();
			writePicture(serverData);
		} else {
			var getPngPixelsParameters:Object = new Object();
			getPngPixelsParameters = { serverData:serverData, bitmapData:bitmapData, heightIterator:heightIterator };
			// Recursive call sequenced on N frames
			sequencer.doInNFrames(_frames, Utils.createDelegate(this,getPngPixels), getPngPixelsParameters);
		}
	}
	
	/**
	 * Loops over the the pixels of the bitmap Image. Called by a setInterval so the browser does not hang.
	 * gets all pixels of a line of the bitmapData, and stores them in an array
	 * 
	 * @param	Object containing:
	 * 			serverData: the server data 
	 * 			bitmapData: bitmap data from which data is retreived 
	 * 			heightIterator: the bitmap data hjeight iterator
	 */
	private function getJpgPixels(data:Object):Void
	{
		// Instanciate the function's parameters
		var serverData:ServerDataVO = data.serverData;
		var bitmapData:BitmapData = data.bitmapData;
		// Height iterator used when reading bitmapData
		var heightIterator:Number = data.heightIterator;

		var pixelData:Number;
		var pixelString:String;
		var sequencer:Sequencer = _silexPtr.sequencer;
		var iterator:Number = 0;

		while ( (iterator < _loops) && (heightIterator < _pluginConfig.height) )
		{
			serverData.data[heightIterator] = new Array;
			
			// Get line pixels
			for (var x:Number = 0; x < _pluginConfig.width; x++)
			{
				pixelData = bitmapData.getPixel(x + _pluginConfig.xPosition, heightIterator + _pluginConfig.yPosition);
				
				var red:String = (pixelData >> 20 & 0xF).toString(16) + (pixelData >> 16 & 0xF).toString(16);
				var green:String = (pixelData >> 12 & 0xF).toString(16) + (pixelData >> 8 & 0xF).toString(16);
				var blue:String = (pixelData >> 4 & 0xF).toString(16) + (pixelData & 0xF).toString(16);
				
				// build pixel hexacimal data
				pixelString = red + green + blue;
				// if pixel is blank, don't send it - done to reduce size of POST data
				if (pixelString == 'ffffff') pixelString = "";   
				
				//trace('(x,y): (' + x + ',' + heightIterator + ') - pixelData: ' + pixelData + ' - RGB: ' + pixelString);
				
				serverData.data[heightIterator].push(pixelString);
			}
			heightIterator++;
			iterator++;
		}
		// If all pixels have been stored into serverData
		if (heightIterator >= _pluginConfig.height) {
			bitmapData.dispose();
			writePicture(serverData);
		} else {
			var getJpgPixelsParameters:Object = new Object();
			getJpgPixelsParameters = { serverData:serverData, bitmapData:bitmapData, heightIterator:heightIterator };
			// Recursive call sequenced on N frames
			sequencer.doInNFrames(_frames, Utils.createDelegate(this,getJpgPixels), getJpgPixelsParameters);
		}
	}
	
	/**
	 * Sets the callback to the PHP script (writePictureCallback), then calls the script with the pictureData as $_POST parameters
	 * 
	 * @param	pictureData
	 */
	//private function writePicture(pictureData:Object):Void
	private function writePicture(serverData:ServerDataVO):Void
	{
		serverData.serverResponse.onLoad = Utils.createDelegate(this, writePictureCallback, serverData);	
		serverData.data.sendAndLoad(PHP_WRITE_IMAGE_SCRIPT_URL + "?id_site=" + _root.id_site + "&file=" + serverData.fileName, serverData.serverResponse, 'POST');
	}
	
	/**
	 * Displays either an OK or KO message
	 * 
	 * @param	event
	 */
	private function writePictureCallback(success:Boolean,serverData:ServerDataVO):Void
	{
		// removeMovieClip callback
		Utils.removeDelegate(this, writePictureCallback);
		var userMessage:String = '';
		// close snapshot wait alert popup - i.e. play the fade out animation
		//_alertMC.play();
		
		var message:String = serverData.serverResponse.message + "(" + serverData.fileName + ")";
		
		if ((success) && (serverData.serverResponse.phpStatus == "ok")) {
			_silexPtr.utils.alertSimple(message);
		} else {
			_silexPtr.utils.alertSimple(message,null,null,'error');
		}

		// Decrement _frames
		_frames--;

	}
	
}