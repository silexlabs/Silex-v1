<?php
/*
This file is part of Silex: RIA developement tool - see http://silex-ria.org/

Silex is (c) 2007-2012 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html


File: PluginComponentLibraryBase.php
This file contains the components plugin base

*/

require_once ROOTPATH.'cgi/includes/plugin_base.php';
require_once ROOTPATH.'cgi/includes/ComponentDescriptor.php';
require_once ROOTPATH.'cgi/includes/LangManager.php';

/*
Class: PluginComponentLibraryBase
This class extends the base plugin class, adding method for component plugins to retrieve data from
the component descriptors
*/
class PluginComponentLibraryBase extends plugin_base
{

	/**
	* the url of the folder containing the descriptors
	*/
	const DESCRIPTORS_FOLDER = "/descriptors";
	
	/*
	* the url of the folder containing the as2 swf
	*/
	const AS2_FOLDER = "/as2";
	
	/*
	* the url of the button adding the new component
	*/
	const ADD_ITEM_BUTTON_URL = "plugins/wysiwyg/addButton/addItemButton.swf";
	
	/**
	* the value of the "action" tag in the component descriptor metadata
	* when the user wants to simply add a component
	*/
	const ACTION_ADD_COMPONENT = "addComponent";
	
	/**
	* the value of the "action" tag in the component descriptor metadata
	* when the user wants to simply add a media component
	*/
	const ACTION_ADD_MEDIA_COMPONENT = "addMediaComponent";
	
	/**
	* the value of the "action" tag in the component descriptor metadata
	* when the user wants to simply add a skinnable component
	*/
	const ACTION_ADD_SKINNABLE_COMPONENT = "addSkinnableComponent";
	
	/**
	* the value of the "action" tag in the component descriptor metadata
	* when the user wants to add a component in the old way. Allow for retro-compatibility
	* . The added component must have editable properties
	*/
	const ACTION_ADD_LEGACY_COMPONENT = "addLegacyComponent";
	
	/**
	* the name of the tag in the component descriptor containing the data for adding components
	*/
	const ADD_COMPONENT_PARAMS = "addComponentParams";
	
	/**
	* the list of all the tags required to create a toolItem
	*/
	const REQUIRED_TAGS = "label,description,iconUrl,toolUid,groupUid,level,name";
	
	/**
	* the url of the folder in which user skins are located
	*/
	const SKIN_THEME_FOLDER = "skins/default_as2/";
	
	/**
	* the authorized file extension for skins
	*/
	const SKIN_EXTENSION = ".swf";
	
		/**
		* override the initHooks method of plugin_base, to add a callback to the hook called
		* when the component descriptors are required and one when silex is done initialising, to add
		* the toolbar items
		*/ 
		public function initHooks(HookManager $hookManager)
		{
			parent::initHooks($hookManager);
			$hookManager->addHook(ComponentManager::HOOK_GET_COMPONENT_DESCRIPTORS, array($this, 'getComponentDescriptors'));
			$hookManager->addHook('admin-body-end', array($this, 'pluginComponentIndexBodyEnd'));
		}
		
		function initDefaultParamTable()
		{
		$this->paramTable = array( 
			array(
				"name" => "debug_mode",
				"label" => "debug activated",
				"description" => "activate/desactivate debug mode displaying error message",
				"value" => "false",
				"restrict" => "",
				"type" => "string",
				"maxChars" => "200"
			)
		);
		}
		
		/**
		* add the descriptors of this plugin to the total descriptors array,
		* passed by reference
		*
		* @param descriptors the total descriptors array
		*/
		public function getComponentDescriptors(array &$descriptors)
		{
			$descriptors = array_merge($descriptors, $this->getDescriptors());
		}
		
		/*
		* parse all the descriptors XML of the plugin and create one ComponentDescriptor object for each,
		* which are returned
		*/
		protected function getDescriptors()
		{
			$fullDescriptorsFolderPath = ROOTPATH . $this->pluginRelativeUrl . self::DESCRIPTORS_FOLDER;
			$folderContent = scandir($fullDescriptorsFolderPath);
			
			$pluginDescriptors = array();
						 
			foreach($folderContent as $filePath){
				if(strpos($filePath, ".xml") != false){
				    try{
	                   $xml = simplexml_load_file($fullDescriptorsFolderPath . "/" . $filePath);
					   
					   //we retrieve the plugin's translation files and parse it
					   $langManager = LangManager::getInstance();
					   $localisedStrings = $langManager->getLangObject($this->pluginName);
					   //if there are no translation file, we create an empty array
					   if ($localisedStrings == false)
					   {
							$localisedStrings = array();
					   }
					   
			            $descriptor = ComponentManager::parseDescriptor($xml, $this->pluginRelativeUrl . "/", $localisedStrings);
			            array_push($pluginDescriptors, $descriptor);
					}catch(Exception $e){
						$fakeDescriptor = array("componentName" => "couldn't parse descriptor at " . $fullDescriptorsFolderPath . "/" . $filePath);
						array_push($pluginDescriptors, $fakeDescriptor);
					}                 
				}
             }
			 
			 return $pluginDescriptors;
		}
		
	/*
	* When silex is done initialising, add the javaScript script tag that will
	* add each of the toolItems needed to add components on the stage with the wysiwyg, using
	* methods from the SilexAdminApi
	*/
	public function pluginComponentIndexBodyEnd()
	{
		//we retrieve all of the descriptors of this plugin
		$descriptors = $this->getDescriptors();
		
		//the string that will hold the JavaScript to print
		$JsToPrint = "";
		
		//return a string of all the toolbar groups that needs to be added
		$JsToPrint .= $this->addToolBarGroups();
		
		//we loop in each descriptors, to retrieve the ToolItem data
		//from the metaData
		foreach($descriptors as $descriptor)
		{
			
			//a flag determining if enough info was given to add the toolItem
			$doAddToolItem = true;
					
			//check if a addComponentParams tag exist on the descriptor and use it if it does
			if (isset($descriptor->metaData[self::ADD_COMPONENT_PARAMS]))
			{
				//we store the array containing the params for adding a component from the descriptor object
				$descriptorAddComponentParams = $descriptor->metaData[self::ADD_COMPONENT_PARAMS];	
					
				//we check if an "action" tag exists
				if (isset($descriptorAddComponentParams['action']))
				{
					//if it does we use it's value
					$action = $descriptorAddComponentParams['action'];
				}
							
				//else we use the default value and inform the user
				else
				{
					$action = self::ACTION_ADD_COMPONENT;
					$this->displayMessage(
					'no action tag was defined in the '.$descriptor->componentName.'component descriptor metaData. The default action has been set',
					'missing action', 'warning');
				}
				
				//we check if all the required parameters are defined in the component descriptor	
				$missingTags = $this->checkRequiredParameters($descriptorAddComponentParams);
				//if the missingTags string is set, it means one or many paramters are missing
				if ($missingTags != "")
				{
					//we cancel the toolItem creation then display an error
					$doAddToolItem = false;
					$this->displayMessage(
					'the following tag(s) are missing : '.$missingTags.' for the '.$descriptor->componentName.' component. The toolItem creation was canceled',
					'missing tags', 'error');
				}
							
				//if the toolItem creation wasn't canceled
				if ($doAddToolItem == true)
				{	
					
					//we store all the required parameters common to all actions types
					$requiredParameters = $this->addRequiredParameters($descriptor);
					
					//we check which action must be executed on click and deduce from it the optionnal paramters to add
					$addedParameters = $this->checkAction($descriptor, $action);	


					//if the addedParamters var is set
					//threr was no problem during the JavaScript string generation
					if ($addedParameters != "")
					{
						//so we add all the new JavaScript to our string then call the method
						//echoing the string
						$JsToPrint .= $requiredParameters;
						$JsToPrint .= $addedParameters;
						
						$JsToPrint .= "}]);";
					}
									
				}
			}
						
			//if no tag was found, we cancel the toolItem creation and display an error message
			else
			{
				$doAddToolItem = false;
				$this->displayMessage(
				'\'no '.self::ADD_COMPONENT_PARAMS.' tag was defined in the '.$descriptor->componentName.' component descriptor metaData. The toolItem won t be added\'',
				'\'missing tag\'', '\'error\'');
			}
			
			
		}			
		
		//when we looked in all descriptors, we print the resulting JavaScript
		$this->printJS($JsToPrint);
				
	}
	
	/**
	* an abstract method overrided by plugins that which to add their own group to the toolbar
	* returns the JavaScript string necessary to add a group
	*/
	protected function addToolBarGroups()
	{
		return "";
	}
	
	/**
	* print the JS script tag containing the function called when the user logs in
	*/
	protected function printJS($Js)
	{
	?>
	<script type="text/javascript">
		
		//check if silex namespace exists
		if (! silexNS)
		{
			silexNS = new Object();
		}
		
		//check if the plugins var exists on the namespace
		if (! silexNS.plugins)
		{
			silexNS.plugins = new Object();
		}
		
		//check if a namespace exists for the curretn plugin
		if (! silexNS.plugins.<?php echo $this->pluginName ?>)
		{
			silexNS.plugins.<?php echo $this->pluginName ?> = new Object();
		}
		
		//define the method adding the toolItems when silexAdminApi is ready
		silexNS.plugins.<?php echo $this->pluginName ?>.initDescriptorsToolItems = function()
		{
			<?php echo $Js ?>
		}
	
		//we add a hook for the "silexAdminApiReady" hook, called when the user logs in
		//silexNS.HookManager.addHook("silexAdminApiReady", silexNS.plugins.<?php echo $this->pluginName ?>.initDescriptorsToolItems);
		silexNS.plugins.<?php echo $this->pluginName ?>.initDescriptorsToolItems();
	
		
	</script>	
	<?php	
	}
		
	/**
	* check if all the base required parameters are present and returns their name(s) if missing
	*/
	protected function checkRequiredParameters(array $addComponentParams)
	{
		//the string that will contain the missing tags names
		$missingTags = "";
		
		//we form the required tags array from the constant
		//holding all of our required tags names
		$requiredTags = explode("," , self::REQUIRED_TAGS);
		
		//we loop in each required tags
		foreach($requiredTags as $tag)
		{
			//if the tag is not found on the descriptor addComponentParams array
			if (! isset($addComponentParams[$tag]))
			{
				//if the missing tags string was not set, add the missing tag name
				if (! isset ($missingTags))
				{
					$missingTags = $tag;
				}
					
				//else add a comma first then the missing tag name	
				else
				{
					$missingTags .= ", ".$tag;
				}
					
			}
		}
		
		//returns the complete formatted missing tags string
		return $missingTags;
	}	
	
	/**
	* parses the data of the "skins" tag when the descriptor adds
	* a button for a skinnable component and check if skins are in the theme folder
	* of the component
	* then return the result as a JavaScript
	* object
	*/
	protected function concatenateSkinsInfo($skinsInfo, $componentUID)
	{
		//a flag determining if enough info was given to construct
		//the return object
		$skinsInfoComplete = true;
		
		//we initizalise the string that will represent
		//the JavaScript object
		$skinsInfoString = "[";
		//we loop through each "skin" tag of the "skins" tag
		foreach($skinsInfo as $skinInfo)
		{
			//we check if the required "url", "description" and "label" info are present
			if (!isset($skinInfo['url'])|| !isset($skinInfo['description'])|| !isset($skinInfo['label']))
			{
				//if one of them is missing, we cancel the creation of the button and display a message for the user
				$skinsInfoComplete = false;
				$this->displayMessage('parameter missing on the skins, the url, label and description must be defined for each skin','skin tag missing', 'error');
				break;
			}
			
			else
			{	
				//if all the required info are present, we add them as a JavaScript object parameter
				$skinsInfoString .='{label:\''.$skinInfo['label'].'\',description:\''.$skinInfo['description'].'\',url:\''.$this->pluginRelativeUrl.'/'.$skinInfo['url'].'\'';
				
				//check if the optionnal preview url parameters has been defined
				if (isset($skinInfo['previewUrl']))
				{
					$skinsInfoString .=',previewUrl:\''.$this->pluginRelativeUrl.'/'.$skinInfo['previewUrl'].'\'';
				}
				
				$skinsInfoString .='},';
			}
		}
		
		//scan the theme folder of the current component, it is located
		//in the theme folder, in the folder sporting the name of the component
		$skinThemeFolder = self::SKIN_THEME_FOLDER.$componentUID."/";
		
		//if the folder exist
		if (file_exists($skinThemeFolder))
		{
			//for each file with the skin extension, we add the file to the skin data,
			//the file name is used as label (minus extension), it has no description and we contruct it's url
			//with the previous theme folder variable
			$dir = dir($skinThemeFolder);
			while($name =  $dir->read())
			{
				if (substr($name, -4) == self::SKIN_EXTENSION)
				{
					//remove file extension
					$nameWtihoutExtension = str_replace(self::SKIN_EXTENSION, '', $name);
					
					$skinsInfoString .='{label:\''.$nameWtihoutExtension.'\',description:\'\',url:\''.$skinThemeFolder.$name.'\'';
					$skinsInfoString .='},';
				}
			}
		}
	
		
		//if one of the skins info was wrong, we cancel the button creation
		if ($skinsInfoComplete == false)
		{
			return false;
		}
		
		//else we close the JavaScript object and return it
		else
		{
			substr($skinsInfoString, strlen($skinsInfoString)-1);
			$skinsInfoString .= "]";
		}
		
		return $skinsInfoString;
		
	}
	
	/**
	* returns a string containing all the required parameters to add to the JavaScript toolItem
	*/
	protected function addRequiredParameters(ComponentDescriptor $descriptor)
	{
		//stores the addComponentParams array from the descriptor
		$descriptorAddComponentParams = $descriptor->metaData[self::ADD_COMPONENT_PARAMS];
			
		$ret = "silexNS.SilexAdminApi.callApiFunction('toolBarItems', 'addItem', [{";
		$ret .= "name:'".$descriptorAddComponentParams['name']."',";
		$ret .= "uid:'".$descriptorAddComponentParams['uid']."',";
		$ret .= "groupUid:'".$descriptorAddComponentParams['groupUid']."',";
		$ret .= "toolUid:'".$descriptorAddComponentParams['toolUid']."',";
		$ret .= "label:'".addslashes($descriptorAddComponentParams['label'])."',";
		$ret .= "description:'".addslashes($descriptorAddComponentParams['description'])."',";
		$ret .= "level:'".$descriptorAddComponentParams['level']."',";
		$ret .= "className:'".$descriptor->className."',";
		$ret .= 'iconUrl:$rootUrl+\''.$this->pluginRelativeUrl.'/'.$descriptorAddComponentParams['iconUrl'].'\',';
		$ret .= 'url:$rootUrl+\''.self::ADD_ITEM_BUTTON_URL.'\',';
		
			
		return $ret;
	}
	
	/**
	* displays a message when the user logs in, by calling a method on the JavaScript SilexAdminApi
	*/	
	protected function displayMessage( $text, $title ="Info" , $status = "info" , $duration = 10000)
	{
		//we don't display the message if we are not in debug mode
		if ($this->paramTable[0]['value'] == 'false')
		{
			return;
		}
	
		?>
		
		
		
		<script type="text/javascript">
		
		//check if the silex namespace exists and create it if not
		if (! silexNS)
		{
			silexNS = new Object();
		}
		
		//check if the plugins var exists on the silex namespace
		if (! silexNS.plugins)
		{
			silexNS.plugins = new Object();
		}
		
		//add the displayMessage on the plugins namespace if it does'nt exists
		if (! silexNS.plugins.displayMessage)
		{
			silexNS.plugins.displayMessage = function(event, params)
			{
				silexNS.SilexAdminApi.callApiFunction("messages", "addItem", [{text:params.text, title:params.title, status:params.status, time:params.time}]);
			};
		}
		
		//then add a hook which will call the method when silexAdminApi is ready
		//silexNS.HookManager.addHook("silexAdminApiReady", silexNS.plugins.displayMessage,{text:<?php echo $text ?>,title:<?php echo $title ?>,status:<?php echo $status ?>,time:<?php echo $duration ?>});
		silexNS.plugins.displayMessage({text:<?php echo $text ?>,title:<?php echo $title ?>,status:<?php echo $status ?>,time:<?php echo $duration ?>});

		</script>
		<?php	
	}
		
	/**
	* check the "action" param tag and determine which optionnal paramters to retrieve from the descriptor
	*/
	protected function checkAction(ComponentDescriptor $descriptor, $action)
	{
		$descriptorAddComponentParams = $descriptor->metaData['addComponentParams'];
		
		//the JS string that will be returned
		$ret = "action:'".$action."',";
		
		//we check which action must be executed on click
		switch ($action)
		{
			//if the component is non-visual, it is simply
			//added with it's url on click
			case self::ACTION_ADD_COMPONENT:
				$ret .= 'componentUrl:\''.$descriptor->as2Url.'\'';
			break;
								
			//if the component is a media, we provide an array
			//of extensions of the type of media that can be used with this 
			//component. We also add the name of the property that needs to be initialised with the component
			//ex: for an Image component, we need to initialise the "url" property value on creation, and we need
			//to filter allowed image type (.gif, .jpg and .png)
			case self::ACTION_ADD_MEDIA_COMPONENT:
								
				//if an initPropertyName has been defined we use it to retrieve the extensions from the init property and add it to the returned JS string
				if (isset($descriptorAddComponentParams['initPropertyName']))
				{
					$initPropertyName = $descriptorAddComponentParams['initPropertyName'];
					$extensions = $descriptor->properties[$initPropertyName]['extensions'];
					$ret .= 'initPropertyName:\''.$initPropertyName.'\',';
				}
								
				//else we inform the user that there was an error in toolItem adding process
				else
				{
					$extensions = '';
					$this->displayMessage(
					'no initPropertyName tag was defined in the '.$descriptor->componentName.'component descriptor metaData. The added components won t be initialised',
					'missing tag',
					'warning');
								
				}
					
				$ret .= 'componentUrl:\''.$descriptor->as2Url.'\',';
				$ret .= "filters:'".$extensions."'";
				break;
								
			//if the component is skinnable, we provide an array of info of skinned
			//components, defined in the component descriptor
			case self::ACTION_ADD_SKINNABLE_COMPONENT:
				//we retrieve the skins info from the descriptor
				$skinsInfo = $descriptorAddComponentParams['skins'];
				$skinsInfoString = $this->concatenateSkinsInfo($skinsInfo, substr($descriptor->className, strripos($descriptor->className, ".")+1));
				
				if ($skinsInfoString  == false)
				{
					$ret = "";
				}
				
				else
				{
					$ret .="skins:".$skinsInfoString;
				}
				
			break;
			
			//if the user wants to add a legacy component
			//we only need the component url
			//we don't need to add anything
			case self::ACTION_ADD_LEGACY_COMPONENT:
			break;
		}
		
		return $ret;
	}

}