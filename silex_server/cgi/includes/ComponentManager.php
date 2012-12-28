<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	
	require_once ROOTPATH.'cgi/includes/LangManager.php';
	
	/**
	* manages the data for editing the components. Descriptors etc.
	*/
	
	class ComponentManager{
		
		const HOOK_GET_COMPONENT_DESCRIPTORS = "getComponentDescriptors";
		/**
		 * reference to a logger object
		 */
		private $logger = NULL;
		
		public function __construct() {
			$this->logger = new logger("ComponentManager");
		}

                /**
                 * parses a component descriptor xml object to a php ComponentDescriptor object
                 * note: the string casting is because otherwise instead of getting Image" we get "<name>Image</name>" with amfphp serialization
                 * note: a property descriptor is not strongly typed because it can contain many different elements. 
                 * @param <SimpleXMLElement> $componentDescriptorXml
                 * @param <String> $baseUrl something to add to the urls in the descriptor. For example "plugins/baseComponents/" can be added to "as2/Image.swf" 
                 * to make a relative url from the base of silex
				 * @param <array> $localisedStrings an array storing all of the plugin strings, translated to the server language. We use it to replace the
				 * translatable values of the XML (ex: the descriptions of the proeperties)
                 */
		public static function parseDescriptor(SimpleXMLElement $componentDescriptorXml, $baseUrl, array $localisedStrings) {
                    $descriptor = new ComponentDescriptor();
                    $descriptor->componentName = (string) $componentDescriptorXml->componentName;
                    $descriptor->className = (string) $componentDescriptorXml->className;
                    $descriptor->parentDescriptorClassName = (string) $componentDescriptorXml->parentDescriptorClassName;
                    $descriptor->componentRoot = (string) $componentDescriptorXml->componentRoot;
					if($componentDescriptorXml->as2Url){
                    	$descriptor->as2Url = (string) $baseUrl . $componentDescriptorXml->as2Url;
					}

					if($componentDescriptorXml->html5Url){
						$descriptor->html5Url = (string) $baseUrl . $componentDescriptorXml->html5Url;
					}

					if($componentDescriptorXml->specificEditorUrl){
	                    $descriptor->specificEditorUrl = (string) $baseUrl . $componentDescriptorXml->specificEditorUrl;
					}
					
					if ($componentDescriptorXml->metaData)
					{
						$descriptor->metaData = self::parseRecursively($componentDescriptorXml->metaData, $localisedStrings);
					}
					
                    foreach($componentDescriptorXml->properties->children() as $propertyElement){
                        $propertyAttributes = array();
                        foreach($propertyElement->children() as $propertyAttribute){
                            $propertyAttributes[$propertyAttribute->getName()] = self::translateString((string)$propertyAttribute, $localisedStrings);
                        }
                        $descriptor->properties[$propertyElement->getName()] = $propertyAttributes;
                    }
					
                    return $descriptor;
		}
		
		/*
		* check on the translated strings array if the provided string to translated is one of it's keys
		* and returns it's value if it is
		*/
		private static function translateString($stringToTranslate, $localisedStrings)
		{
			if (isset($localisedStrings[$stringToTranslate]))
			{
				//this is a bug fix, if a localised string is in double or more in the
				//same lang file, an Array is returned, so we only take the first value.
				//We need to have a better file parser
				if (is_array($localisedStrings[$stringToTranslate]))
				{
					return $localisedStrings[$stringToTranslate][0];
				}
				else
				{
					return $localisedStrings[$stringToTranslate];
				}
			}
			else
			{
				return $stringToTranslate;
			}
		}
		
		/*
		* parse an XML recursively and stores all the nodes value in an array
		*/
		private static function parseRecursively($xml, $localisedStrings)
		{
			//if the xml is a leaf, return it's value
			if (count($xml->children()) == 0)
			{
				return self::translateString((string)$xml, $localisedStrings);
			}
			
			//else we parse it
			else
			{	
				//stores the returned value
				$ret = array();
				
				//a flag detemining if we must create an assoc or numeric array
				$isNumericArray = false;
				
				//stores the names of all the children of the current node
				$childrenNames = array();
				
				//loop through each children of the given xml
				foreach($xml->children() as $xmlElement)
				{
					//we check if multiple tags share the same name
					//if they do, we must create a numeric array
					//else we create an assoc array
					foreach($childrenNames as $childrenName)
					{
						if ($childrenName == $xmlElement->getName())
						{
							$isNumericArray = true;
							break;
						}
					}	
						
					$childrenNames[] = $xmlElement->getName();
				}
				
				//then for each child, we push the resulting array either with a numerical index
				//or the the name of the node
				foreach($xml->children() as $xmlElement)
				{
					if ($isNumericArray == true)
					{
						$ret[] = self::parseRecursively($xmlElement, $localisedStrings);
					}
						
					else
					{
						$ret[$xmlElement->getName()] =  self::parseRecursively($xmlElement, $localisedStrings);
						$ret[$xmlElement->getName()] =  self::parseRecursively($xmlElement, $localisedStrings);
					}
				}
			
				//we return the result
				return $ret;		
			}
			
		}
		
	/**
	* uses the hook "getComponentDescriptorFolders", and passes an empty array as parameter. This array must be filled by the different plugins that contain components with the path
	* to their descriptor folder. The contents are then listed and parsed.
	*/
		public function getComponentDescriptors(){
			//get the different folders containing the component descriptors
			$hookManager = hookManager::getInstance();		
			$descriptors = array();
			$paramsArray = array(&$descriptors);
			$hookManager->callHooks(self::HOOK_GET_COMPONENT_DESCRIPTORS, $paramsArray);
//			$this->logger->debug("descriptors  " . print_r($paramsArray, true));
			return $descriptors;
		}
	
	
	}

?>