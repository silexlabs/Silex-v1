<?php

class org_silex_core_XmlUtils {
	public function __construct(){}
	static $INDENT_STRING = "\x09";
	static function cleanUp($xml) {
		$GLOBALS['%s']->push("org.silex.core.XmlUtils::cleanUp");
		$»spos = $GLOBALS['%s']->length;
		$xmlCopy = Xml::parse($xml->toString())->firstElement();
		if($xmlCopy !== null) {
			$»tmp = org_silex_core_XmlUtils::cleanUpRecursive($xmlCopy);
			$GLOBALS['%s']->pop();
			return $»tmp;
		} else {
			$GLOBALS['%s']->pop();
			return $xml;
		}
		$GLOBALS['%s']->pop();
	}
	static function cleanUpRecursive($xml) {
		$GLOBALS['%s']->push("org.silex.core.XmlUtils::cleanUpRecursive");
		$»spos = $GLOBALS['%s']->length;
		$whiteSpaceValues = new _hx_array(array("\x0A", "\x0D", "\x09"));
		$childData = null;
		$child = null;
		$cleanedXml = null;
		switch($xml->nodeType) {
		case Xml::$Document:{
			$cleanedXml = Xml::createDocument();
		}break;
		case Xml::$Element:{
			$cleanedXml = Xml::createElement($xml->getNodeName());
			if(null == $xml) throw new HException('null iterable');
			$»it = $xml->attributes();
			while($»it->hasNext()) {
				$attrib = $»it->next();
				$cleanedXml->set($attrib, $xml->get($attrib));
			}
		}break;
		default:{
		}break;
		}
		if(null == $xml) throw new HException('null iterable');
		$»it = $xml->iterator();
		while($»it->hasNext()) {
			$child1 = $»it->next();
			switch($child1->nodeType) {
			case Xml::$Element:{
				$childData = org_silex_core_XmlUtils::cleanUpRecursive($child1);
				$cleanedXml->addChild($childData);
			}break;
			case Xml::$Comment:{
			}break;
			default:{
				$nodeValue = $child1->getNodeValue();
				if(_hx_substr($nodeValue, 0, 4) === "<!--" && _hx_substr($nodeValue, -3, null) === "-->") {
					$nodeValue = "";
				}
				{
					$_g = 0;
					while($_g < $whiteSpaceValues->length) {
						$whiteSpace = $whiteSpaceValues[$_g];
						++$_g;
						$nodeValue = str_replace($whiteSpace, "", $nodeValue);
						unset($whiteSpace);
					}
				}
				while(_hx_substr($nodeValue, 0, 1) === " ") {
					$nodeValue = _hx_substr($nodeValue, 1, null);
				}
				if($nodeValue !== "") {
					$cleanedXml->addChild($child1);
				}
			}break;
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $cleanedXml;
		}
		$GLOBALS['%s']->pop();
	}
	static function stringIndent2Xml($xmlString) {
		$GLOBALS['%s']->push("org.silex.core.XmlUtils::stringIndent2Xml");
		$»spos = $GLOBALS['%s']->length;
		$xml = Xml::parse($xmlString);
		{
			$»tmp = org_silex_core_XmlUtils::cleanUp($xml);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function xml2StringIndent($xml) {
		$GLOBALS['%s']->push("org.silex.core.XmlUtils::xml2StringIndent");
		$»spos = $GLOBALS['%s']->length;
		$firstElement = $xml->firstElement();
		{
			$»tmp = org_silex_core_XmlUtils::xml2StringIndentRecursive($firstElement, "");
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function xml2StringIndentRecursive($xml, $indentationLevel) {
		$GLOBALS['%s']->push("org.silex.core.XmlUtils::xml2StringIndentRecursive");
		$»spos = $GLOBALS['%s']->length;
		if($indentationLevel === null) {
			$indentationLevel = "";
		}
		$toReturn = "";
		$toReturn .= $indentationLevel . "<" . $xml->getNodeName();
		if(null == $xml) throw new HException('null iterable');
		$»it = $xml->attributes();
		while($»it->hasNext()) {
			$attrib = $»it->next();
			$toReturn .= " " . $attrib . "=\"" . $xml->get($attrib) . "\"";
		}
		$toReturn .= ">";
		$firstChild = $xml->firstChild();
		if($firstChild !== null) {
			switch($firstChild->nodeType) {
			case Xml::$CData:{
				$toReturn .= "<![CDATA[" . $firstChild->getNodeValue() . "]]>";
			}break;
			case Xml::$PCData:{
				$toReturn .= $firstChild;
			}break;
			case Xml::$Element:{
				$toReturn .= "\x0A";
				$element = null;
				if(null == $xml) throw new HException('null iterable');
				$»it = $xml->iterator();
				while($»it->hasNext()) {
					$element1 = $»it->next();
					$toReturn .= org_silex_core_XmlUtils::xml2StringIndentRecursive($element1, $indentationLevel . "\x09");
				}
				$toReturn .= $indentationLevel;
			}break;
			default:{
			}break;
			}
		}
		$toReturn .= "</" . $xml->getNodeName() . ">\x0A";
		{
			$GLOBALS['%s']->pop();
			return $toReturn;
		}
		$GLOBALS['%s']->pop();
	}
	static function Xml2Dynamic($xml, $oofLegacyWorkaround) {
		$GLOBALS['%s']->push("org.silex.core.XmlUtils::Xml2Dynamic");
		$»spos = $GLOBALS['%s']->length;
		if($oofLegacyWorkaround === null) {
			$oofLegacyWorkaround = false;
		}
		$firstElement = org_silex_core_XmlUtils::cleanUp($xml);
		$generatedXml = org_silex_core_XmlUtils::xml2DynamicRecursive($firstElement, strtolower($firstElement->getNodeName()) === "rss", $oofLegacyWorkaround);
		{
			$GLOBALS['%s']->pop();
			return $generatedXml;
		}
		$GLOBALS['%s']->pop();
	}
	static function xml2DynamicRecursive($xml, $isRss, $oofLegacyWorkaround) {
		$GLOBALS['%s']->push("org.silex.core.XmlUtils::xml2DynamicRecursive");
		$»spos = $GLOBALS['%s']->length;
		$xmlAsDynamic = null;
		$whiteSpaceValues = new _hx_array(array("\x0A", "\x0D", "\x09"));
		if($xml->firstChild() !== null) {
			if($xml->firstChild()->nodeType == Xml::$PCData) {
				$nodeValue = $xml->firstChild()->getNodeValue();
				{
					$GLOBALS['%s']->pop();
					return $nodeValue;
				}
			}
			if($xml->firstChild()->nodeType == Xml::$CData) {
				$»tmp = $xml->firstChild()->getNodeValue();
				$GLOBALS['%s']->pop();
				return $»tmp;
			}
		}
		$attributes = null;
		$attribHash = new Hash();
		$attributes1 = null;
		if(null == $xml) throw new HException('null iterable');
		$»it = $xml->attributes();
		while($»it->hasNext()) {
			$attrib = $»it->next();
			$xmlAsDynamic->attributes->{$attrib} = $xml->get($attrib);
		}
		$childData = null;
		$nodeValues = new _hx_array(array());
		$processedNodeNames = new _hx_array(array());
		$processed = false;
		$iteration = 0;
		if(null == $xml) throw new HException('null iterable');
		$»it = $xml->iterator();
		while($»it->hasNext()) {
			$child = $»it->next();
			if($child->nodeType == Xml::$Element) {
				{
					$_g = 0;
					while($_g < $processedNodeNames->length) {
						$name = $processedNodeNames[$_g];
						++$_g;
						if(_hx_equal($child->getNodeName(), $name)) {
							$processed = true;
							break;
						}
						unset($name);
					}
					unset($_g);
				}
				if(!$processed) {
					$processedNodeNames->push($child->getNodeName());
					$iteration = 0;
					if(null == $xml) throw new HException('null iterable');
					$»it2 = $xml->iterator();
					while($»it2->hasNext()) {
						$currentChild = $»it2->next();
						if($child->getNodeName() === $currentChild->getNodeName()) {
							$childData = org_silex_core_XmlUtils::xml2DynamicRecursive($currentChild, $isRss, $oofLegacyWorkaround);
							$nodeValues->push($childData);
							$iteration++;
						}
					}
					if($iteration !== 1 || $isRss && $child->getNodeName() === "item") {
						if(!$oofLegacyWorkaround) {
							$xmlAsDynamic->{$child->getNodeName()} = $nodeValues;
						} else {
							$i = 0;
							{
								$_g = 0;
								while($_g < $nodeValues->length) {
									$elt = $nodeValues[$_g];
									++$_g;
									$xmlAsDynamic->{Std::string($i)} = $elt;
									$i++;
									unset($elt);
								}
								unset($_g);
							}
							unset($i);
						}
					} else {
						$xmlAsDynamic->{$child->getNodeName()} = $childData;
					}
					$nodeValues = new _hx_array(array());
				}
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $xmlAsDynamic;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'org.silex.core.XmlUtils'; }
}
