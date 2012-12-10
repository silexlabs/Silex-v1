/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * This class is used to store all silex constants default values which may be overriden by getDynData function or by values passed to FLash in index.php with SetVariable.
 * So, to change these default data you can use : FlashVars (javascript or html), conf/silex.ini, the url GET method (silex.swf?var=value&).
 * Use _global.getSilex().config to access these constants from SILEX commands, accessors or from ActionScript (in the components or layouts or tools).
 * In the repository : /trunk/core/Constants.as
 * @author	Alexandre Hoyau
 * @version	1
 * @date	2007-10-01
 * @mail : lex@silex.tv
 */
dynamic class org.silex.core.Constants extends org.silex.core.TranslatableConstants{

	//////////////////////////////////////////////
	//	Group: hard coded constants
	///////////////////////////////////////////////
	/**
	 * Loader stage width.
	 * Corresponds to the white rectangle in fla/loader.fla in SILEX source code.
	 */
	var LOADER_STAGE_HALF_SIZE_X:Number=100; // silex.fla stage size / 2
	/**
	 * Loader stage height.
	 * Corresponds to the white rectangle in fla/loader.fla in SILEX source code.
	 */
	var LOADER_STAGE_HALF_SIZE_Y:Number = 100; // silex.fla stage size / 2
	/////////////////////////////////////
	// Group: scale mode names
	/////////////////////////////////////
	/**
	 * scale mode name, case insensitive
	 */
	public static var SCALE_MODE_PIXEL:String = "pixel";
	/**
	 * scale mode name, case insensitive
	 */
	public static var SCALE_MODE_SCROLL:String = "scroll";
	/**
	 * scale mode name, case insensitive
	 */
	public static var SCALE_MODE_NO_SCALE:String = "noscale";
	/**
	 * scale mode name, case insensitive
	 */
	public static var SCALE_MODE_SHOW_ALL:String = "showall";
	////////////////////////////////////
	//	Group: anim names
	///////////////////////////////////
	/**
	 * Preload animation name in the layout files.
	 * Name of the screens in the layout files.
	 * For example, in layouts/minimal.fla you have the screens on the left, under application main screen.
	 * This animation is played before any content is loaded (either text or medias) and after the transition of the parent page.
	 */
	var ANIM_NAME_PRELOAD:String="preload";
	/**
	 * Show animation name in the layout files.
	 * Name of the screens in the layout files.
	 * For example, in layouts/minimal.fla you have the screens on the left, under application main screen.
	 * This animation is played once the content is loaded (at least the text) and after the preload anim is over.
	 */
	var ANIM_NAME_SHOW:String="show";
	/**
	 * Close animation name in the layout files.
	 * Name of the screens in the layout files.
	 * For example, in layouts/minimal.fla you have the screens on the left, under application main screen.
	 * This animation is played when the current page is closing before the parent "transition close" anim is started and after the current page "transition close" anim is over (only if a child page was open).
	 */
	var ANIM_NAME_CLOSE:String="close";
	/**
	 * Transition animation name in the layout files.
	 * Name of the screens in the layout files.
	 * For example, in layouts/minimal.fla you have the screens on the left, under application main screen.
	 * This animation is played when a page is opened in the current layout and only after the show anim is over.
	 */
	var ANIM_NAME_TRANSITION:String="transition";
	/**
	 * Transition close animation name in the layout files.
	 * Name of the screens in the layout files.
	 * For example, in layouts/minimal.fla you have the screens on the left, under application main screen.
	 * This animation is played when the current layout has a child page opened in and this child page is closed.
	 */
	var ANIM_NAME_TRANSITION_CLOSE:String="transitionClose";
	
	///////////////////////////////////////////
	// Group: media properties types in the properties tool box.
	// Constants used to select editors in properties class.
	///////////////////////////////////////////
    var PROPERTIES_TYPE_BOOLEAN:String = "boolean" ;
    var PROPERTIES_TYPE_NUMBER:String = "number" ;
    var PROPERTIES_TYPE_TEXT:String = "text" ;
    var PROPERTIES_TYPE_RICHTEXT:String = "rich text" ;
    var PROPERTIES_TYPE_COLOR:String = "color" ;
	var PROPERTIES_TYPE_COMMAND:String = "string";
	
	//deprecated : use "string" instead
    var PROPERTIES_TYPE_URL:String = "string" ;
	var PROPERTIES_TYPE_STRING:String = "string";
	
    var PROPERTIES_TYPE_ARRAY:String = "array" ;
	var PROPERTIES_TYPE_ARRAY_ARRAY:String = "array_array" ;
	var PROPERTIES_TYPE_ENUM:String = "enum" ;
	
	var PROPERTIES_TYPE_REFERENCE:String = "reference";
	var PROPERTIES_TYPE_URI:String = "uri" ;
	
	///////////////////////////////////////////
	// Group: event names
	///////////////////////////////////////////
	var UI_PLAYERS_EVENT_PRESS 		= "onPress";
	var UI_PLAYERS_EVENT_RELEASE 	= "onRelease";
	var UI_PLAYERS_EVENT_ROLLOVER 	= "onRollOver";
	var UI_PLAYERS_EVENT_ROLLOUT 	= "onRollOut";
	var UI_PLAYERS_EVENT_MOUSEMOVE 		= "onMouseMove";
	var UI_PLAYERS_EVENT_ONLOAD 		= "onLoad";
	var UI_PLAYERS_EVENT_LOAD_START 	= "onLoadStart";
	var UI_PLAYERS_EVENT_LOAD_ERROR 	= "onLoadError";
	var UI_PLAYERS_EVENT_LOAD_PROGRESS 	= "onLoadProgress";
	var UI_PLAYERS_EVENT_LOAD_COMPLETE 	= "onLoadComplete";
	var UI_PLAYERS_EVENT_LOAD_INIT 		= "onLoadInit";
	var UI_PLAYERS_EVENT_UNLOAD 			= "onUnload";
	var UI_PLAYERS_EVENT_DEEPLINK 		= "onDeeplink";
	var UI_PLAYERS_EVENT_XMLLOADED 		= "onXMLLoaded";
	var UI_PLAYERS_EVENT_CONTENT_SHOW 	= "showContent";	
	var UI_PLAYERS_EVENT_CONTENT_HIDE 	= "hideContent";	
	var UI_PLAYERS_EVENT_CHILD_SHOW 	= "showChild";
	var UI_PLAYERS_EVENT_CHILD_HIDE 	= "hideChild";	
	var UI_PLAYERS_EVENT_CONTENT_HIDE_START 	= "hideContentStart";	
	var UI_PLAYERS_EVENT_CHANGED 	= "onChanged";	
	var UI_PLAYERS_EVENT_KILLFOCUS 	= "onKillFocus";	
	var UI_PLAYERS_EVENT_SETFOCUS 	= "onSetFocus";	
	var UI_PLAYERS_EVENT_SCROLLER 	= "onScroller";	
	var UI_PLAYERS_EVENT_STATUS 		= "onStatus";	
	var UI_PLAYERS_EVENT_METADATA 	= "onMetadata";	
	var UI_PLAYERS_EVENT_BUFFER_EMPTY = "bufferEmpty";	
	var UI_PLAYERS_EVENT_BUFFER_FULL = "bufferFull";
	var UI_PLAYERS_EVENT_NOSTREAM 	= "netStreamNotFound";	
	var UI_PLAYERS_EVENT_PLAY 		= "netStreamPlay";		
	var UI_PLAYERS_EVENT_PAUSE 		= "netStreamPause";		
	var UI_PLAYERS_EVENT_STOP 		= "netStreamStop";
	var UI_PLAYERS_EVENT_START 		= "netStreamStart";		
	var UI_PLAYERS_EVENT_END 		= "netStreamEnd";		
	var UI_PLAYERS_EVENT_SOUND_COMPLETE 	= "onSoundComplete";
	var UI_PLAYERS_EVENT_SOUND_PLAY 		= "soundPlay";
	var UI_PLAYERS_EVENT_SOUND_PAUSE 	= "soundPause";
	var UI_PLAYERS_EVENT_SOUND_STOP		= "soundStop";
	var UI_PLAYERS_EVENT_SOUND_ID3		= "soundId3";
	var UI_PLAYERS_EVENT_SOUND_LOADED 	= "soundLoaded";
	
	var LAYOUT_EVENT_ALL_PLAYERS_LOADED = "allPlayersLoaded";
	var LAYOUT_EVENT_HIDE_CONTENT = "hideContent";
	
	var APP_EVENT_LAYOUT_ADDED = "layoutAdded";
	var APP_EVENT_LAYOUT_REMOVED = "layoutRemoved";
	var APP_EVENT_COMPONENT_CHANGED = "componentChanged";

	///////////////////////////////////////////////
	// Group: setter/getter constants
	///////////////////////////////////////////////
	
	/**
	 * True if mouse pointer is visible and false otherwise.
	 * Very useful for touch screens.
	 * May be true or false and String or Boolean.
	 * You may change this for one specific website at runtime: use a command to change the value of silex.config.mouse .
	 * You can change the default value for all websites on a server: in conf/silex.ini, mouse parameter.
	 * @default	true
	 * @example	onRelease silex.config.mouse=false
	 */
	var _mouse:Boolean=true;
	function set mouse(showOrHide){
		if (showOrHide.toString()!="false"){
			Mouse.show();
			_mouse=true;
		}else{
			Mouse.hide();
			_mouse=false;
		}
	}
	function get mouse():Boolean{
		return _mouse;
	}
	
	/**
	 * When you change this value, the website switches to another context, e.g. fr, en, nl, highBandWidth, lowBandWidth... any value that you want to use in the medias context (see http://silex-ria.org/help/documentation/multi.context/multi.context.home).
	 * The default value can be changed in the website tool box.
	 * @example	onRelease silex.globalContext=fr,client2
	 */ 
	var globalContext:String = "*";
	
	/**
	 * The available context list.
	 * Use this if you do a multilingual website.
	 * This value can be changed in the website tool box.
	 */
	var AVAILABLE_CONTEXT_LIST:String = "*,fr,en";
	
	///////////////////////////////////////////
	// Group: admin language constants
	///////////////////////////////////////////
	/**
	 * Tools configuration file.
	 * This file is loaded only when user enter the admin mode / editing / WYSIWYG.
	 */
	var toolsConfigFileName:String = "conf/admin_config.ini";
	/**
	 * Tools language file.
	 * This file is loaded only when user enter the admin mode / editing / WYSIWYG.
	 */
	var toolsLanguageConfigFileName:String="lang/admin_<<silex.config.adminLanguage>>.txt";
	/**
	 * Silex language file.
	 * This file is loaded at start of SILEX, before the website is opened. It is loaded with the first call to silex.core.Com::getDynData.
	 * @see	silex.core.Com
	 */
	var languageConfigFileName:String = "lang/<<adminLanguage>>.txt";
	/**
	 * Language for the admon mode / editing / WYSIWYG.
	 * The value is set to the browser language code if this code is in _root.SILEX_ADMIN_AVAILABLE_LANGUAGES (in the flashvars or in the URL).
	 * @default	en
	 */
	var adminLanguage:String="en";

	/** 
	 * Website language.
	 * Stores the language code for the website's current language.
	 * @default	en
	 */
	var language:String="en";
	/**
	 * The available language list.
	 * If a context in this list is the same as the language of the browser, then it is added to "globalContext" and set in "language" at start.
	 * Use this if you need browser language auto detection.
	 */
	var AVAILABLE_LANGUAGE_LIST:String = "fr,en";
	/**
	 * Default language used by language auto detection if the language code of the browser is not in AVAILABLE_LANGUAGE_LIST.
	 * This value should be in AVAILABLE_LANGUAGE_LIST.
	 * Change this value in the website tool box.
	 */
	var DEFAULT_LANGUAGE="en";
	

	///////////////////////////////////////////////
	// Group: config constants
	// - replaced by values read in config files (see config_files_list in index.php)
	// - use _global.getSilex().config to access these variables
	///////////////////////////////////////////////
	/**
	 * SILEX version
	 * Read from SCRIPT_LATEST_SILEX_VERSION through a call to silex.core.Com::getLatestSilexVersion.
	 * @see	silex.core.Com
	 */
	var version:String="-";

	///////////////////////////////////////////
	// Group: server config, read in silex.ini
	///////////////////////////////////////////
	/**
	 * interval time for the timer used to keep php session active
	 * in milliseconds
	 */
	var PHP_SESSION_WAKE_UP_INTERVAL:Number = 30000;
	/**
	 * Allow access to SILEX WYSIWYG (allow context menu which leads to authentication process + cookie).
	 * Change this value in conf/silex.ini.
	 * Boolean: true or false.
	 * @default	true
	 */
	var ALLOW_LOGIN:String="true";
	
	/** 
	 * Name of first page of the website.
	 * Change this value in the website tool box.
	 * @default	start
	 */
	var CONFIG_START_SECTION:String="start";

	/**
	 * Name of the configuration file for the website.
	 * This is a constant.
	 * This is where the values of the website tool box are stored - in contents/<<id_site>>/<<CONFIG_WEBSITE_CONF_FILE>>.
	 * @default	conf.txt
	 */
	var CONFIG_WEBSITE_CONF_FILE:String="conf.txt";

	/**
	 * the extendion of amf files (if USE_AMF_FILES is true for a given website, look into contents/mysite/conf.txt).<br />
	 * .amf.php is recommanded since some server configurations do not allow to call .amf or .xml files with post data.<br />
	 * @default	.amf
	 */
	var AMF_FILE_EXTENSION:String=".amf";
	
	/**
	 * Name of the folder which will contain the layer skin folder.
	 * This is a constant.
	 * Change this value for all websites in conf/silex_server.ini.
	 * @default	fp<<silex.config.flashPlayerVersion>>/
	 */
	var FLASH_PLAYER_FOLDER:String = "fp<<silex.config.flashPlayerVersion>>/";
	/**
	 * Flash player version used for a given website.
	 * Change this value in the website tool box.
	 * @default	7
	 */
	var flashPlayerVersion:String = "7";
	/**
	 * True if the website uses deeplinking.
	 * Change this value in index.php or in conf/silex.ini.
	 * @default	true
	 */
	var ENABLE_DEEPLINKING:String="true";
	
	///////////////////////////////////////////
	// Group: path on the server
	///////////////////////////////////////////
	/**
	 * Tools folder path on the server.
	 * @default	tools/
	 */
	var initialToolsFolderPath:String="tools/"; 
	/**
	 * Media folder path on the server.
	 * @default	media/
	 */
	var initialFtpFolderPath:String="media/";
	/**
	 * Contents folder path on the server.
	 * @default	contents/
	 */
	var initialContentFolderPath:String="contents/";
	/**
	 * Install folder path on the server.
	 * @default	install/
	 */
	var installPath:String="install/";
	
// bug => in library.as ?????	static var FtpClientPath:String="tools/FtpClient/index.php";
	/**
	 * Layouts folder path on the server.
	 * @default	layouts/
	 */
	var layoutFolderPath:String="layouts/";//"layouts/basic/";
	
	///////////////////////////////////////////
	// Group: screen saver
	///////////////////////////////////////////
	/**
	 * Number of seconds of inactivity before the screen saver activation commands are executed.
	 */
	var screenSaverDelay:Number = 0;
	/**
	 * Commands to be executed after inactivity was detected, i.e. when the screen saver activates. Commands have to be separated by a pipe: "|".
	 * @example	alertSimple("enter the screen saver mode")|open:screen saver page
	 */
	var screenSaverActivateCommands:String;
	/**
	 * Commands to be executed in screen saver mode after activiity is detected, i.e. when the the mouse moved and screen saver deactivates. Commands have to be separated by a pipe: "|".
	 * @example	alertSimple("exits the screen saver mode")|open:home page
	 */
	var screenSaverDeactivateCommands:String;

	/**
	 * URL of xray online debugging console.
	 * Used by the xray button in the view menu.
	 */
	var XRAY_URL:String="http://www.rockonflash.com/xray/flex/Xray.html";
	
	//var HELP_URL_:String="wysiwyg//";
	///////////////////////////////////////////
	// Group: application default config
	// WEBSITE DATA IN org.silex.core.Api.config OBJECT:
	///////////////////////////////////////////
	/**
	 * name of the cookie used to store the login, password and login 
	 */
	var SHARED_OBJECT_NAME:String = "silexSharedData";
	/**
	 * the cookie data is set by the manager - name of the cookie used to store the login, password and login 
	 */
	var MANAGER_SHARED_OBJECT_NAME:String = "silexManager";
	/**
	 * First page will be opened in this layout.
	 */
	var initialLayoutFile:String = "minimal.swf";
	/**
	 * Stage width for a given website.
	 * This is the area which is allways visible in showAll mode.
	 * @see scaleMode
	 * @default	800
	 */
	var layoutStageWidth:String = "800";
	/**
	 * Stage height for a given website.
	 * This is the area which is allways visible in showAll mode.
	 * @see scaleMode
	 * @default	600
	 */
	var layoutStageHeight:String="600";
	/**
	 * scaleMode for a given website.
	 * A string which determines how the website is scaled depending on the browser window size.
	 * @see http://livedocs.adobe.com/flash/8/main/wwhelp/wwhimpl/common/html/wwhelp.htm?context=LiveDocs_Parts&file=00002694.html
	 * @default	showAll
	 */
	var scaleMode:String = "showAll";//noScale, html, showAll
	/**
	 * id given by google when you create your free google analytics account.
	 * You can set this value in the website tool box.
	 * Use this to have statistics on your website, the pages and visitors.
	 * @see	http://www.google.com/analytics/
	 * @example	UA-4326762-1
	 */
	var googleAnaliticsAccountNumber:String = "";
	/**
	 * Number given by phpMyVisites when you create a new website
	 * Ycan set this value in the website tool box.
	 * Use this to have statistics on your website, the pages and visitors.
	 * @see	http://www.phpmyvisites.us/
	 * @example	UA-4326762-1
	 */
	var phpmyvisitesSiteNumber:String="";
	var phpmyvisitesURL:String="";
	/**
	 * Layer skin used for a given website.
	 * It contains all fonts and skins for the players (audio / video / image).
	 * @default	ui/layer_skin1.swf
	 */
	var layerSkinUrl:String = "ui/layer_skin1.swf";
	/**
	 * Background color for a given website.
	 * @default	FFFFFF
	 */
	var bgColor:String = "FFFFFF";
	/**
	 * Tools sub-folder to be concidered as the root for the tools for a given website, starting from the tools/ folder of the server.
	 * Use this if you want to have different tools sets available on different websites.
	 */
	var toolsFolderRelativePath:String="";
	/**
	 * Media sub-folder to be concidered as the root for the library tool box for a given website, starting from the media/ folder of the server.
	 * Use this if you want to have different media sets available on different websites.
	 */
	var websiteFtpRelativeUrl:String="";
	/**
	 * Default duration of a "alertSimple" message.
	 * @see silex.core.interpreter::alertSimple command
	 */
	var commonAlertDuration:Number=10000; // in ms
	/**
	 * Minimum duration of a "alertSimple" message.
	 * @see silex.core.interpreter::alertSimple command
	 */
	var minimumAlertDuration:Number=500; // in ms
	
	///////////////////////////////////////////
	// Group: web services
	///////////////////////////////////////////
	/**
	 * Path of the amfPhp gateway on the server.
	 */
	var gatewayRelativePath:String = "cgi/gateway.php";
	/**
	 * Name of the data exchange service of silex.
	 */
	var DataExchangeServiceName:String = "data_exchange";
	/**
	 * Name of the ftp service name of silex.
	 */
	var FtpServiceName:String="ftp_web_service";

	///////////////////////////////////////////
	// Group: php scripts
	///////////////////////////////////////////
//	var SCRIPT_UPLOAD:String="cgi/scripts/upload.php";
//	var SCRIPT_DELETE:String="cgi/scripts/delete.php";
	/**
	 * Path of the log script.
	 * @see	silex.core.interpreter::log command
	 */
	var SCRIPT_LOG:String="cgi/scripts/log_command.php";
	/**
	 * Path of the download script.
	 * @see	silex.core.interpreter::download command
	 */
	var SCRIPT_DOWNLOAD:String="cgi/scripts/download.php";
	/**
	 * URL of the script used to retrieve SILEX latest stable version.
	 * @see	silex.core.Com::getLatestSilexVersion
	 */
	var SCRIPT_LATEST_SILEX_VERSION:String="http://downloads.silexlabs.org/silex/latest_version/latest_silex_version.php";
	
	///////////////////////////////////////////
	// Group: accessors constants
	///////////////////////////////////////////

	/**
	 * Word separator character in page names.
	 * Change this value in conf/silex.ini.
	 * @example	a letter
	 * @example	a digit
	 * @example	_
	 * @example	-
	 * @example	.
	 * @default	_
	 */
	var sepchar:String="_";
	
	/**
	 * Variables separator character for accessors.
	 * Change this value in conf/silex.ini.
	 * @example	/
	 * @example	\
	 * @example	&
	 * @example	@
	 * @example	_
	 * @example	-
	 * @example	.
	 * @default	.
	 */
	var accessorsSepchar:String = ".";
	/**
	 * Left separator for the accessors.
	 */
	var accessorsLeftTag:String="<<";
	/**
	 * Left separator for the accessors - html encoded.
	 */
	var accessorsLeftTagHtml:String="&lt;&lt;";
	/**
	 * Right separator for the accessors.
	 */
	var accessorsRightTag:String=">>";
	/**
	 * Right separator for the accessors - html encoded.
	 */
	var accessorsRightTagHtml:String = "&gt;&gt;";
	
	/**
	 * Separator for the filters in accessors
	 * default value is space char : <<filtername accessorname>>
	 */
	var filterSeparator:String = " ";
	/**
	 * Separator for the filters arguments in accessors
	 * default value is space char : <<filtername:arg1,arg2 accessorname>>
	 */
	var filterArgsSeparator:String = ",";
	
	
	///////////////////////////////////////////
	// Group: sequencer constants
	///////////////////////////////////////////
	var SEQUENCER_STATE_PLAY:String="play";
	var SEQUENCER_STATE_PAUSE:String="pause";
	var SEQUENCER_STATE_STOP:String="stop";
	
	///////////////////////////////////////////
	// Group: debug
	///////////////////////////////////////////
	var DEBUG_LEVEL_ERROR:String="error";
	var DEBUG_LEVEL_WARNING:String="warning";
	var DEBUG_LEVEL_DEBUG:String="debug";

	///////////////////////////////////////////
	// Group: constants for file properties
	///////////////////////////////////////////
	var itemTypeField="item type";
	var itemSizeField="item size";
	var itemNameField="item name";
	var itemModifDateField="item last modification date";
	var itemWidthField="item width";
	var itemHeightField="item height";
	var itemContentField="itemContent";
	//var ="";

	
	/////////////////////////////////////////////
	// Group: UI translation constants (kept here for compatibility reasons)
	/////////////////////////////////////////////
	
	var PROPERTIES_LABEL_PLAYER_NAME="PROPERTIES_LABEL_PLAYER_NAME";
	var PROPERTIES_LABEL_SEO_DESCRIPTION="PROPERTIES_LABEL_SEO_DESCRIPTION";
	var	PROPERTIES_LABEL_SEO_TAGS="PROPERTIES_LABEL_SEO_TAGS";
	var	PROPERTIES_LABEL_X_POSITION="PROPERTIES_LABEL_X_POSITION";
	var	PROPERTIES_LABEL_Y_POSITION="PROPERTIES_LABEL_Y_POSITION";
	var	PROPERTIES_LABEL_WIDTH="PROPERTIES_LABEL_WIDTH";
	var	PROPERTIES_LABEL_HEIGHT="PROPERTIES_LABEL_HEIGHT";
	var	PROPERTIES_LABEL_SCALE="PROPERTIES_LABEL_SCALE";
	var	PROPERTIES_LABEL_ICON_NAME_OF_TARGETED_PAGE="PROPERTIES_LABEL_ICON_NAME_OF_TARGETED_PAGE";
	var	PROPERTIES_LABEL_ICON_DEEPLINK_OF_TARGETED_PAGE="PROPERTIES_LABEL_ICON_DEEPLINK_OF_TARGETED_PAGE";
	var	PROPERTIES_LABEL_ICON_NAME_OF_LAYOUT="PROPERTIES_LABEL_ICON_NAME_OF_LAYOUT";
	var	PROPERTIES_LABEL_ICON_IS_ICON="PROPERTIES_LABEL_ICON_IS_ICON";
	var	PROPERTIES_LABEL_ICON_IS_DEFAULT_ICON="PROPERTIES_LABEL_ICON_IS_DEFAULT_ICON";
	var	PROPERTIES_LABEL_OPACITY="PROPERTIES_LABEL_OPACITY";
	var	PROPERTIES_LABEL_ROTATION="PROPERTIES_LABEL_ROTATION";
	var	PROPERTIES_LABEL_URL="PROPERTIES_LABEL_URL";
	var	PROPERTIES_LABEL_IS_VISIBLE="PROPERTIES_LABEL_IS_VISIBLE";
	var	PROPERTIES_LABEL_TOOLTIP="PROPERTIES_LABEL_TOOLTIP";
	var	PROPERTIES_LABEL_SHOW_HAND_ON_ROLLOVER="PROPERTIES_LABEL_SHOW_HAND_ON_ROLLOVER";
	var	PROPERTIES_LABEL_CLICKABLE="PROPERTIES_LABEL_CLICKABLE";
	var	PROPERTIES_LABEL_CENTERED_H="PROPERTIES_LABEL_CENTERED_H";
	var	PROPERTIES_LABEL_ATTRIBUTES="PROPERTIES_LABEL_ATTRIBUTES";
	var	PROPERTIES_LABEL_LABEL_SELECT="PROPERTIES_LABEL_LABEL_SELECT";
	var	PROPERTIES_LABEL_LABEL_OVER="PROPERTIES_LABEL_LABEL_OVER";
	var	PROPERTIES_LABEL_LABEL_PRESS="PROPERTIES_LABEL_LABEL_PRESS";
	var	PROPERTIES_LABEL_AUTOPLAY="PROPERTIES_LABEL_AUTOPLAY";
	var	PROPERTIES_LABEL_SHOW_UI="PROPERTIES_LABEL_SHOW_UI";
	var	PROPERTIES_LABEL_AUTOSIZE="PROPERTIES_LABEL_AUTOSIZE";
	var	PROPERTIES_LABEL_AUTOREPLAY="PROPERTIES_LABEL_AUTOREPLAY";
	var	PROPERTIES_LABEL_BUFFER_SIZE_MS="PROPERTIES_LABEL_BUFFER_SIZE_MS";
	var	PROPERTIES_LABEL_IS_MUTED="PROPERTIES_LABEL_IS_MUTED";
	var	PROPERTIES_LABEL_VOLUME_LEVEL="PROPERTIES_LABEL_VOLUME_LEVEL";
	var	PROPERTIES_LABEL_LABEL="PROPERTIES_LABEL_LABEL";
	var	PROPERTIES_LABEL_ENABLE_HTML="PROPERTIES_LABEL_ENABLE_HTML";
	var	PROPERTIES_LABEL_ENABLE_EMBEDDED_FONTS="PROPERTIES_LABEL_ENABLE_EMBEDDED_FONTS";
	var	PROPERTIES_LABEL_USE_CSS="PROPERTIES_LABEL_USE_CSS";
	var	PROPERTIES_LABEL_CSS_URL="PROPERTIES_LABEL_CSS_URL";
	var	PROPERTIES_LABEL_TYPE_WRITER_EFFECT_SPEED="PROPERTIES_LABEL_TYPE_WRITER_EFFECT_SPEED";
	var	PROPERTIES_LABEL_ENABLE_SCROLL_BAR="PROPERTIES_LABEL_ENABLE_SCROLL_BAR";
	var	PROPERTIES_LABEL_SCROLL_BAR_WIDTH="PROPERTIES_LABEL_SCROLL_BAR_WIDTH";
	var	PROPERTIES_LABEL_IS_SELECTABLE="PROPERTIES_LABEL_IS_SELECTABLE";
	var	PROPERTIES_LABEL_IS_MULTILINE="PROPERTIES_LABEL_IS_MULTILINE";
	var	PROPERTIES_LABEL_HAS_BORDER="PROPERTIES_LABEL_HAS_BORDER";
	var	PROPERTIES_LABEL_BORDER_COLOR="PROPERTIES_LABEL_BORDER_COLOR";
	var	PROPERTIES_LABEL_HAS_BACKGROUND="PROPERTIES_LABEL_HAS_BACKGROUND";
	var	PROPERTIES_LABEL_BACKGROUND_COLOR="PROPERTIES_LABEL_BACKGROUND_COLOR";
	var	PROPERTIES_LABEL_MAX_NUMBER_OF_CHARACTERS="PROPERTIES_LABEL_MAX_NUMBER_OF_CHARACTERS";
	var	PROPERTIES_LABEL_ENABLE_MOUSE_WHEEL="PROPERTIES_LABEL_ENABLE_MOUSE_WHEEL";
	var	PROPERTIES_LABEL_IS_PASSWORD="PROPERTIES_LABEL_IS_PASSWORD";
	var	PROPERTIES_LABEL_ALLOWED_CHARACTERS="PROPERTIES_LABEL_ALLOWED_CHARACTERS";
	var	PROPERTIES_LABEL_INPUT_TYPE="PROPERTIES_LABEL_INPUT_TYPE";
	var	PROPERTIES_LABEL_WORD_WRAP="PROPERTIES_LABEL_WORD_WRAP";
	var	PROPERTIES_LABEL_NAME_OF_MASK="PROPERTIES_LABEL_NAME_OF_MASK";
	var	PROPERTIES_LABEL_SCALE_MODE="PROPERTIES_LABEL_SCALE_MODE";
	var	PROPERTIES_LABEL_SHOW_LOADING="PROPERTIES_LABEL_SHOW_LOADING";
	var	PROPERTIES_LABEL_SHOW_SHADOW="PROPERTIES_LABEL_SHOW_SHADOW";
	var	PROPERTIES_LABEL_SHADOW_X_POSITION="PROPERTIES_LABEL_SHADOW_X_POSITION";
	var	PROPERTIES_LABEL_SHADOW_Y_POSITION="PROPERTIES_LABEL_SHADOW_Y_POSITION";
	var	PROPERTIES_LABEL_SHOW_FOCUS="PROPERTIES_LABEL_SHOW_FOCUS";
	var	PROPERTIES_LABEL_ENABLE_TABULATION="PROPERTIES_LABEL_ENABLE_TABULATION";
	var	PROPERTIES_LABEL_ENABLE_CHILDREN_TABULATION="PROPERTIES_LABEL_ENABLE_CHILDREN_TABULATION";
	var	PROPERTIES_LABEL_TABULATION_INDEX="PROPERTIES_LABEL_TABULATION_INDEX";
	var	PROPERTIES_LABEL_FADE_IN_STEP="PROPERTIES_LABEL_FADE_IN_STEP";
	var	PROPERTIES_LABEL_TEXT_FORMAT_ARRAY="PROPERTIES_LABEL_TEXT_FORMAT_ARRAY";
	var	PROPERTIES_LABEL_FRAME_IS_BACKGROUND_VISIBLE = "PROPERTIES_LABEL_FRAME_IS_BACKGROUND_VISIBLE";
	var	PROPERTIES_LABEL_FOLLOW_MOUSE = "PROPERTIES_LABEL_FOLLOW_MOUSE";
	var	PROPERTIES_LABEL_EASING_DURATION = "PROPERTIES_LABEL_EASING_DURATION";
	var PROPERTIES_LABEL_DELAYED_APPARITION_MS = "PROPERTIES_LABEL_DELAYED_APPARITION_MS";
	var PROPERTIES_LABEL_IMAGE_URL = "PROPERTIES_LABEL_IMAGE_URL";
	
	
	

	///////////////////////////////////////////
	// Group: characters for strings cleaning function
	///////////////////////////////////////////
	
	/**
	 * UTF-8 lookup table for lower case accented letters
	 * This lookuptable defines replacements for accented characters from the ASCII-7 range. This are lower case letters only.
	 * From dokuwiki inc/utf8.php.
	 */
	/**
	 * UTF-8 lookup table for lower case accented letters
	 * This lookuptable defines replacements for accented characters from the ASCII-7 range. This are lower case letters only.
	 * From dokuwiki inc/utf8.php.
	 */
	var UTF8_LOWER_ACCENTS:Array=
	[
	{accented:'£',ascii:'p'},
	{accented:'¢',ascii:'c'},
	{accented:'€',ascii:'EUR'},
	{accented:'*',ascii:' '},
//	{accented:'&',ascii:'+'},
//	{accented:'/',ascii:'_'},
	{accented:'%',ascii:''},
	{accented:'#',ascii:''},
	{accented:'@',ascii:' at '},
	{accented:'¦',ascii:' '},
	{accented:'|',ascii:' '},
	{accented:'{',ascii:''},
	{accented:'}',ascii:''},
	{accented:'[',ascii:''},
	{accented:']',ascii:''},
	{accented:'(',ascii:''},
	{accented:')',ascii:''},
	{accented:'$',ascii:''},
	{accented:'!',ascii:''},
	{accented:'?',ascii:''},
	{accented:'"',ascii:''},
	{accented:"",ascii:' '},
	{accented:"'",ascii:' '},
	{accented:'´',ascii:''},
	{accented:'à',ascii:'a'},
	{accented:'ô',ascii:'o'},
	{accented:'d',ascii:'d'},
//	{accented:'?',ascii:'m'},
	{accented:'ë',ascii:'e'},
	{accented:'š',ascii:'s'},
//	{accented:'o',ascii:'o'},
	{accented:'ß',ascii:'ss'},
/*	{accented:'a',ascii:'a'},
	{accented:'r',ascii:'r'},
	{accented:'n',ascii:'n'},
	{accented:'k',ascii:'k'},
	{accented:'s',ascii:'s'},
	{accented:'l',ascii:'l'},
	{accented:'h',ascii:'h'},
*/	{accented:'ó',ascii:'o'},
	{accented:'ú',ascii:'u'},
//	{accented:'e',ascii:'e'},
	{accented:'é',ascii:'e'},
	{accented:'ç',ascii:'c'},
//	{accented:'c',ascii:'c'},
	{accented:'õ',ascii:'o'},
	{accented:'ø',ascii:'o'},
//	{accented:'g',ascii:'g'},
//	{accented:'t',ascii:'t'},
	{accented:'î',ascii:'i'},
//	{accented:'u',ascii:'u'},
//	{accented:'w',ascii:'w'},
	{accented:'œ',ascii:'oe'},
	{accented:'ö',ascii:'o'},
	{accented:'è',ascii:'e'},
//	{accented:'y',ascii:'y'},
	{accented:'ƒ',ascii:'f'},
	{accented:'ž',ascii:'z'},
	{accented:'å',ascii:'a'},
	{accented:'ì',ascii:'i'},
	{accented:'ï',ascii:'i'},
	{accented:'ä',ascii:'a'},
	{accented:'í',ascii:'i'},
	{accented:'ê',ascii:'e'},
	{accented:'ü',ascii:'u'},
	{accented:'ò',ascii:'o'},
	{accented:'ñ',ascii:'n'},
//	{accented:'j',ascii:'j'},
	{accented:'ÿ',ascii:'y'},
	{accented:'ý',ascii:'y'},
	{accented:'â',ascii:'a'},
//	{accented:'z',ascii:'z'},
//	{accented:'i',ascii:'i'},
	{accented:'ã',ascii:'a'},
	{accented:'ù',ascii:'u'},
	{accented:'á',ascii:'a'},
	{accented:'û',ascii:'u'},
	{accented:'þ',ascii:'th'},
	{accented:'ð',ascii:'dh'},
	{accented:'æ',ascii:'ae'},
	{accented:'µ',ascii:'u'}];
	
	var UTF8_UPPER_ACCENTS:Array=
	[{accented:'À',ascii:'A'},
	{accented:'Ô',ascii:'O'},
//	{accented:'D',ascii:'D'},
	{accented:'?',ascii:'M'},
	{accented:'Ë',ascii:'E'},
	{accented:'Š',ascii:'S'},
/*	{accented:'O',ascii:'O'},
	{accented:'A',ascii:'A'},
	{accented:'R',ascii:'R'},
	{accented:'N',ascii:'N'},
	{accented:'K',ascii:'K'},
	{accented:'S',ascii:'S'},
	{accented:'L',ascii:'L'},
	{accented:'H',ascii:'H'},
*/	{accented:'Ó',ascii:'O'},
	{accented:'Ú',ascii:'U'},
//	{accented:'E',ascii:'E'},
	{accented:'É',ascii:'E'},
	{accented:'Ç',ascii:'C'},
//	{accented:'C',ascii:'C'},
	{accented:'Õ',ascii:'O'},
	{accented:'Ø',ascii:'O'},
//	{accented:'G',ascii:'G'},
//	{accented:'T',ascii:'T'},
	{accented:'Î',ascii:'I'},
//	{accented:'U',ascii:'U'},
//	{accented:'W',ascii:'W'},
	{accented:'Ö',ascii:'O'},
	{accented:'È',ascii:'E'},
//	{accented:'Y',ascii:'Y'},
	{accented:'ƒ',ascii:'F'},
	{accented:'Ž',ascii:'Z'},
	{accented:'Å',ascii:'A'},
	{accented:'Ì',ascii:'I'},
	{accented:'Ï',ascii:'I'},
	{accented:'Ä',ascii:'A'},
	{accented:'Í',ascii:'I'},
	{accented:'Ê',ascii:'E'},
	{accented:'Ü',ascii:'U'},
	{accented:'Ò',ascii:'O'},
	{accented:'Ñ',ascii:'N'},
	{accented:'Ð',ascii:'Dh'},
//	{accented:'J',ascii:'J'},
	{accented:'Ÿ',ascii:'Y'},
	{accented:'Ý',ascii:'Y'},
	{accented:'Â',ascii:'A'},
//	{accented:'Z',ascii:'Z'},
//	{accented:'I',ascii:'I'},
	{accented:'Ã',ascii:'A'},
	{accented:'Ù',ascii:'U'},
	{accented:'Á',ascii:'A'},
	{accented:'Û',ascii:'U'},
	{accented:'Þ',ascii:'Th'},
	{accented:'Æ',ascii:'A'}];
}