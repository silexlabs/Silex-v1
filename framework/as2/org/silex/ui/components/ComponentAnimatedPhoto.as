/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.core.Utils;

import org.silex.ui.components.ComponentAnimated;

class org.silex.ui.components.ComponentAnimatedPhoto extends ComponentAnimated {

	
	var loaderMedia_mcl:MovieClipLoader;
	var listenerLoader_obj:Object;
	
	var cible_photo:MovieClip;
	var contener_mc:MovieClip;
	
	/**
	 * constructor
	 */
	function ComponentAnimatedPhoto(){
		
	}
	
	
	/**
	 * initialize
	 */	
	function _initialize() {
		//parent
		super._initialize()		

		//change value in clip if different path
		cible_photo = contener_mc.cible_photo;
		
		//movieClip Loader
		this.loaderMedia_mcl = new MovieClipLoader();
		this.listenerLoader_obj = new Object();
		//listener events		
		this.listenerLoader_obj.onLoadStart = Utils.createDelegate(this, _onLoadStart);
		this.listenerLoader_obj.onLoadProgress 	= Utils.createDelegate(this, _onLoadProgress);
		this.listenerLoader_obj.onLoadComplete 	= Utils.createDelegate(this, _onLoadComplete);
		this.listenerLoader_obj.onLoadInit		= Utils.createDelegate(this, _onLoadInit);
		this.listenerLoader_obj.onLoadError 	= Utils.createDelegate(this, _onLoadError);		
		//add Listener
		this.loaderMedia_mcl.addListener(this.listenerLoader_obj);					
	}
	
	
	
	
	/**
	 * function _onLoadStart
	 * @param	MovieClip   cible
	 * @return 	void
	 */
	function _onLoadStart(cible_mc:MovieClip):Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_LOAD_START ,target:this});
	}
	
	/**
	 * function _onLoadProgress
	 * @param	MovieClip	cible
	 * @param	Number		bytes loaded
	 * @param	Number		total bytes to load
	 * @return 	void
	 */
	function _onLoadProgress (cible_mc:MovieClip, nBytesLoaded:Number, nBytesTotal:Number):Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_LOAD_PROGRESS ,target:this, loaded:nBytesLoaded, total:nBytesTotal });
	}
	
	/**
	 * function _onLoadStart
	 * @param	MovieClip   cible
	 * @return 	void
	 */
	function _onLoadComplete (cible_mc:MovieClip):Void {	
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_LOAD_COMPLETE ,target:this});
	}		
		
	function _onLoadInit (cible_mc:MovieClip):Void  {	 
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_LOAD_INIT ,target:this});
		//dimensions
		if (!__width) __width=		cible_mc._width;
		if (!__height) __height=	cible_mc._height;
		//cible dimensions
		cible_mc._width=__width;
		cible_mc._height=__height;
		//refresh position
		redraw();
	}
	
	
	/**
	 * function _onLoadError
	 * @param	MovieClip   cible
	 * @param	String		error code
	 * @param	Number		http status
	 * @return 	void
	 */
 	function _onLoadError (cible_mc:MovieClip,errorCode_str:String, HTTPStatus_str:Number):Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_LOAD_ERROR ,target:this, error:errorCode_str, status:HTTPStatus_str });
	}
	
	
	
	
	/**
	 * function loadmedia
	 * @param 	string	media url 
	 * @return 	void
	 */
	public function loadMedia(url_str:String):Void{
		//stock url
		this.url = url_str; // => setter will call doLoadMedia (see UiBase)
	}
	
	function doLoadMedia() {
		//appel MoviClipLoader
		this.loaderMedia_mcl.loadClip(silexInstance.rootUrl+this.privateUrl_str, cible_photo);
	}

	/**
	 * function unloadMedia
	 * @return 	void
	 */
	public function unloadMedia():Void {
		this.loaderMedia_mcl.unloadClip( cible_photo);
	}
	
}