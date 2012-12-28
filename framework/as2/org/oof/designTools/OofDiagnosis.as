/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.OofBase;
import mx.utils.Delegate;

/** this is a design tool to be used at run time that helps you analyse the current state
 * of your application. The idea is to run tests on all the oof components instanciated
 * at the moment of the diagnosis. Drop it on the stage, you should see a few buttons which
 * run some tests when clicked and output them in a text box.
 * 
 * These tests are defined by the type of the component, so there
 * are tests common ot all components, or families of components, and some are specific 
 * to the component. At the moment only a few tests are implemented and this is
 * still all experimental. The idea is to integrate a unit testing framework such as AsUnit 
 * to do live unit testing. The hierarchy of the tests would be based on the class hierarchy. 
 * 
* @author Ariel Sommeria-klein
 * */
class org.oof.designTools.OofDiagnosis extends OofBase{
	var dumpBadLinks_btn:Button;
	var dumpAllLinks_btn:Button;
	var dumpAllOofComps_btn:Button;
	var testAllOofComps_btn:Button;
	var output_txt:TextField;
	
	//test class references. it would be nice to get the dynamically using _global[className], but
	//the class is not imported unless used(not just imported)
	var dataIos_Display:org.oof.designTools.diagnosis.dataIos.DisplayTest = null;
	var dataUsers_DataSelector:org.oof.designTools.diagnosis.dataUsers.DataSelectorTest = null;
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		dataIos_Display = new org.oof.designTools.diagnosis.dataIos.DisplayTest();
		dataUsers_DataSelector = new org.oof.designTools.diagnosis.dataUsers.DataSelectorTest();

		dumpBadLinks_btn.onRelease = Delegate.create(this, dumpBadLinks);
		dumpAllLinks_btn.onRelease = Delegate.create(this, dumpAllLinks);
		dumpAllOofComps_btn.onRelease = Delegate.create(this, dumpAllOofComps);
		testAllOofComps_btn.onRelease = Delegate.create(this, testAllOofComps);
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
	
	function searchAndReplace(holder, searchfor, replacement) {
		var temparray = holder.split(searchfor);
		var holder = temparray.join(replacement);
		return (holder);
	}

	function testAllOofComps(){
		output_txt.text = "";
		for(var i = 0; i < _alloofCompsList.length; i++){
			var testObjName:String = _alloofCompsList[i].className.substr(8); //8 = "org.oof.".length. 
			testObjName = searchAndReplace(testObjName,".", "_");
			trace("test obj name : " + testObjName);//"." not accepted in instance name
			var testObj = this[testObjName];
			trace ("test obj : " + testObj);
			if(testObj){
				var testRes = testObj.runTests(_alloofCompsList[i]);
				if(testRes != "")
					output_txt.text += testRes + "\r\n";
			}
		}
		
	}
}