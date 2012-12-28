<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
//define ("tab_char","\t");
define ("tab_char","");
//define ("newline_char","\n");
define ("newline_char","");
// **
// patch xml dom of php4 to php5
if (version_compare(PHP_VERSION,'5','>='))
	require_once('domxml-php4-to-php5.php');
// **
function arrayToXML($array)
{
	$newline=newline_char;
	$temp="<?xml version=\"1.0\" encoding=\"UTF-8\"?><element type_str=\"object\" name_str=\"root\">$newline";
	$temp.=do_arrayToXML($array);
	$temp.="$newline</element>";
	return $temp;
}
function do_arrayToXML($array,$tabs=tab_char)
{
	$newline=newline_char;
	$temp="";
//	$numElem = count($array);
//	for ($k=0;$k<$numElem;$k++)
	foreach ($array as $k => $value)
	{
		//if (!is_array($value)) $encoded_val=urlencode($value);
		//$encoded_val=urlencode($value);
		$encoded_val=$value;

		if (is_string($value))
		{
			if ($value!="") $temp.="$newline$tabs<element type_str=\"string\" name_str=\"$k\">$newline$tabs<![CDATA[".urlencode($encoded_val)."]]>$newline$tabs</element>";
		}
		else 
		{
			if(is_bool($value))
			{
				$temp.="$newline$tabs<element type_str=\"boolean\" name_str=\"$k\">$newline$tabs".$encoded_val."$newline$tabs</element>";
			}
			else 
			{
				if(is_numeric($value))
				{
					$temp.="$newline$tabs<element type_str=\"number\" name_str=\"$k\">$newline$tabs".$encoded_val."$newline$tabs</element>";
				}
				else
				{
					if (is_array($value))
					{
						$temp.="$newline$tabs<element type_str=\"object\" name_str=\"$k\">".do_arrayToXML($value,$tabs.tab_char)."$newline$tabs</element>";
					}
				}
			}
		}
	}
	return $temp;
}
// XML_to_array wrapper for compatibility with previous versions of SILEX
function XML_to_array($data_xml){
	return xmlToArray($data_xml);
}
function xmlToArray($data_xml)
{
	//$data_xml="<element type_str='object'><element name_str='mailing_list_subscription' type_str='string'>no</element><element name_str='password' type_str='string'>lex%40silex%2Etv</element><element name_str='email' type_str='string'>lex%40silex%2Etv</element><element name_str='telephone' type_str='string'>a</element><element name_str='country' type_str='string'>France</element><element name_str='city' type_str='string'>a</element><element name_str='zipcode' type_str='string'>a</element><element name_str='adress' type_str='string'>a</element><element name_str='lastname' type_str='string'>a</element><element name_str='firstname' type_str='string'>a</element><element name_str='affiliate_website' type_str='string'>01test</element></element>";
	// read the xml data and extract usful info
	//echo "<br>INPUT :<br>".htmlentities($data_xml)."<br>";
	$xml = domxml_open_mem($data_xml, DOMXML_LOAD_DONT_KEEP_BLANKS, $errors); // new DOMDocument('1.0', 'UTF-8');
	if (!$xml)
	{
		/*$err_str="&error=";
		foreach ($errors as $error)
			$err_str.="- ".$error."<br>";
		echo $err_str."&";*/
		return null;
	}
	$root=$xml->document_element();
	
	return do_XML_to_array($root);
}
function do_XML_to_array($root)
{	
	$res_array=array();

	//echo "COMPUTING ".$res_array."<br>";
	foreach ($root->child_nodes() as $element)
	{
		$tmp_value = $element->get_content();

		//echo "do_XML_to_array debug1 ".$tmp_value." - ".$element->get_attribute('type_str')."<br>";

		//$query_str.=$element->get_attribute('name_str')."='".$element->get_content()."'";
		switch ($element->get_attribute('type_str'))
		{
			case "string":
				$res_array[$element->get_attribute('name_str')]=urldecode($tmp_value);
				break;
			case "number":
				if (is_float($tmp_value)==TRUE)
					settype($tmp_value,"float");
				else
					settype($tmp_value,"int");

				$res_array[$element->get_attribute('name_str')]=$tmp_value;
				break;
			case "boolean":
				settype($tmp_value,"bool");
				$res_array[$element->get_attribute('name_str')]=$tmp_value;
				break;
			case "object":
				//$res_array[$element->get_attribute('name_str')]=array();
				//do_XML_to_array($tmp_value,$res_array[$element->get_attribute('name_str')]);
				$res_array[$element->get_attribute('name_str')]=do_XML_to_array($element);
				break;
			default:
				settype($tmp_value,gettype($tmp_value));
				$res_array[$element->get_attribute('name_str')]=$tmp_value;
		}
	}
	return $res_array;
	
	/* LOCAL : voir register.php */
}
?>