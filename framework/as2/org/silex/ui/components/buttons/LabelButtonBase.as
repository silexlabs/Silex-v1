/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.core.Utils;
class org.silex.ui.components.buttons.LabelButtonBase extends org.silex.ui.components.buttons.ButtonBase {

	// registered variables (in editableProperties)
	private var _buttonLabelNormal:String;
	public function get buttonLabelNormal():String
	{
		return _buttonLabelNormal;
	}
	public function set buttonLabelNormal(str:String)
	{
		_buttonLabelNormal=str;
		redraw();
	}
	private var _buttonLabelPress:String;
	public function get buttonLabelPress():String
	{
		return _buttonLabelPress;
	}
	public function set buttonLabelPress(str:String)
	{
		_buttonLabelPress=str;
		redraw();
	}
	private var _buttonLabelOver:String;
	public function get buttonLabelOver():String
	{
		return _buttonLabelOver;
	}
	public function set buttonLabelOver(str:String)
	{
		_buttonLabelOver=str;
		redraw();
	}
	private var _buttonLabelSelect:String;
	public function get buttonLabelSelect():String
	{
		return _buttonLabelSelect;
	}
	public function set buttonLabelSelect(str:String)
	{
		_buttonLabelSelect=str;
		redraw();
	}
	
	
	// current label
	var label:String;
	
	/* label_txt
	 * label text field
	 * it s variable is label
	 */
	var label_txt:TextField;
	/**
	 * autoSize text?
	 */
	var autoSize:Boolean;
	/**
	 * multiline text?
	 */
	var wordWrap:Boolean;
	
	var centeredHoriz:Boolean;
	function _onLoad(){
		super._onLoad();
		label_txt.wordWrap=wordWrap;
		label_txt.autoSize = autoSize;
		redraw();
	}
	function _initialize() {
		super._initialize();
		//editableProperties
		this.editableProperties.unshift(
			{ name :"centeredHoriz" ,		description:"PROPERTIES_LABEL_CENTERED_H", 				type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: false	, isRegistered:true,group:"attributes" },
			{ name :"buttonLabelNormal" ,		description:"PROPERTIES_LABEL_ATTRIBUTES", 				type:"Text"		, defaultValue: "label"	, isRegistered:true,group:"attributes" },
			{ name :"buttonLabelSelect" ,		description:"PROPERTIES_LABEL_LABEL_SELECT", 				type:"Text"		, defaultValue: "<b>label</b>"	, isRegistered:true,group:"attributes" },
			{ name :"buttonLabelOver" ,		description:"PROPERTIES_LABEL_LABEL_OVER", 				type:"Text"		, defaultValue: "<u>label</u>"	, isRegistered:true,group:"attributes" },
			{ name :"buttonLabelPress" ,		description:"PROPERTIES_LABEL_LABEL_PRESS", 				type:"Text"	, defaultValue: "<b>label</b>"	, isRegistered:true,group:"attributes" },
			{ name :"autoSize" ,		description:"PROPERTIES_LABEL_AUTOSIZE", type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN, defaultValue: true	, isRegistered:true,group:"attributes" },
			{ name :"wordWrap" ,		description:"PROPERTIES_LABEL_WORD_WRAP", type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN, defaultValue: false	, isRegistered:true,group:"attributes" }
		);
	}
	/**
	 * function _initAfterRegister. 
	 * @return void
	 */
	function _initAfterRegister()
	{
		super._initAfterRegister();
		//redraw();
	}
	/**
	 * function redraw
	 * @return void
	 */
	function redraw(){
		super.redraw();
		
		// refresh label
		if (layoutInstance.selectedIcon==this) label=silexInstance.utils.revealAccessors(buttonLabelSelect,this);
		else label = silexInstance.utils.revealAccessors(buttonLabelNormal, this);
		
		// center textfield
		if (centeredHoriz){
			// center h and v
			silexInstance.utils.centerMedia(label_txt,bg_mc._width,bg_mc._height,bg_mc._x,bg_mc._y);
		}
		else{
			// center v only
			silexInstance.utils.centerMedia(label_txt,label_txt._width,bg_mc._height,label_txt._x,bg_mc._y);
		}
		// invisible if no label
		isVisible = (label != "");
	}
	////////////////////////////////////////////
	/**
	 * selectIcon
	 * called by openIcon and core.application::openSection
	 * to be overriden by sub classes - mark the media as selected?
	 */ 
	function selectIcon(isSelected:Boolean){
		super.selectIcon(isSelected);
		if (isSelected){
			label=silexInstance.utils.revealAccessors(buttonLabelSelect,this);
		}
		else{
			label=silexInstance.utils.revealAccessors(buttonLabelNormal,this);
		}
		// invisible if no label
		isVisible = (label != "");
	}
	
	function _onRollOut(){
		super._onRollOut();
		if (silexInstance.application.getLayout(this).selectedIcon==this) label=silexInstance.utils.revealAccessors(buttonLabelSelect,this);
		else label=silexInstance.utils.revealAccessors(buttonLabelNormal,this);
		// invisible if no label
		isVisible = (label != "");
	}
	function _onRollOver(){
		super._onRollOver();
		label=silexInstance.utils.revealAccessors(buttonLabelOver,this);
		// invisible if no label
		isVisible = (label != "");
	}
	function _onPress(){
		super._onPress();
		label=silexInstance.utils.revealAccessors(buttonLabelPress,this);
		// invisible if no label
		isVisible = (label != "");
	}
	/**
	 * function _onRelease
	 * @return 	void
	 */
	function _onRelease():Void{
		super._onRelease();
		label=silexInstance.utils.revealAccessors(buttonLabelOver,this);
	}
	/**
	 * function _onReleaseOutside
	 * @return 	void
	 */
	function _onReleaseOutside():Void{
		super._onReleaseOutside();
		_onRollOut();
	}
	////////////////////////////////////////////
	//override abstract method
	/*function getHtmlTags(url_str:String):Object {
		var res_obj:Object=new Object;
		res_obj.keywords=descriptionText+" "+buttonLabelNormal;
		res_obj.description=descriptionText;
		if (descriptionText){
			res_obj.htmlEquivalent="<div>"+buttonLabelNormal+"</div>";
		}
		return res_obj;
	}*/
	/* getSeoData
	 * return the seo data to be associated with this player
	 * to be overriden in derived class :
	 * @return	object with text (string), tags (array), description (string), links (object with link, title and description), htmlEquivalent (string), context (array)
	 */
	function getSeoData(url_str:String):Object {
		var res_obj:Object=super.getSeoData(url_str);
		
		// keywords
		if (buttonLabelNormal && buttonLabelNormal != "")
		{
			res_obj.text=silexInstance.utils.getRawTextFromHtml(buttonLabelNormal);

			// html equivalent
			res_obj.htmlEquivalent="<p>"+buttonLabelNormal+"</p>";
		}
		return res_obj;
	}
}
