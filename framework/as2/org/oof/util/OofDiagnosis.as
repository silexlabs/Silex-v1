/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.OofBase;
import mx.utils.Delegate;
class org.oof.util.OofDiagnosis extends OofBase{
	var dumpBadLinks_btn:Button;
	var dumpAllLinks_btn:Button;
	var dumpAllOofComps_btn:Button;
	var output_txt:TextField;
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		dumpBadLinks_btn.onRelease = Delegate.create(this, dumpBadLinks);
		dumpAllLinks_btn.onRelease = Delegate.create(this, dumpAllLinks);
		dumpAllOofComps_btn.onRelease = Delegate.create(this, dumpAllOofComps);
	}
	
	function dumpBadLinks(){
		output_txt.text = "";
		for(var i = 0; i < _linkQueue.length; i++){
			if(_linkQueue[i].found != true){
				output_txt.text = output_txt.text + " source : " + _linkQueue[i].requestSource.playerName + ", target : " + _linkQueue[i].targetPath + "\n";
			}
		}

	}
	
	function dumpAllLinks(){
		output_txt.text = "";
		for(var i = 0; i < _linkQueue.length; i++){
			output_txt.text = output_txt.text + " source : " + _linkQueue[i].requestSource.playerName + ", target : " + _linkQueue[i].targetPath + ", found : " + _linkQueue[i].found + "\n";
		}

	}
	
	function dumpAllOofComps(){
		output_txt.text = "";
		for(var i = 0; i < _alloofCompsList.length; i++){
			output_txt.text = output_txt.text + _alloofCompsList[i].playerName + "\n";
		}
	}
}