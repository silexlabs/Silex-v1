/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.dataIos.upload.Uploader;
import flash.net.FileReference;

/**
* adds an animation control to the uploader class.
*/


class org.oof.dataIos.upload.VisualUploader extends Uploader{
	
	/**
	 * group: public
	 * */
	/**
	 * group: internal
	 * */
	 
	 
	 //the animation we are going to drive. Has to have NUM_FRAMES_IN_ANIM frames. This could be made into a property later, maybe
	private var anim:MovieClip;	
	
	/** function _initAfterRegister
	* @returns void
	*/
	public function _initAfterRegister(){
		super._initAfterRegister(); 
		if(anim){
			anim.stop();
		}
			
	}
	// Action while uploading
	private function onProgress(file:FileReference, bytesLoaded:Number, bytesTotal:Number){
		super.onProgress(file, bytesLoaded, bytesTotal);
		var newPlayHeadPos:Number = Math.round(bytesLoaded / bytesTotal * anim._totalframes);
		anim.gotoAndStop(newPlayHeadPos);
	}

	
	
}