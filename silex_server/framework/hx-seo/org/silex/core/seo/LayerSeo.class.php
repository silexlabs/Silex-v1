<?php

class org_silex_core_seo_LayerSeo {
	public function __construct(){}
	static $SEO_DATA_NODE_NAME = "seoData";
	static $VERSION_ATTRIBUTE_NAME = "version";
	static $VERSION_ATTRIBUTE_VALUE = "2";
	static $LAYER_SEO_NODE_NAME = "layerSeo";
	static $DEEPLINK_ATTRIBUTE_NAME = "deeplink";
	static $COMPONENTS_NODE_NAME = "components";
	static $CONTENT_NODE_NAME = "content";
	static $COMPONENT_NODE_NAME = "component";
	static $LINKS_NODE_NAME = "links";
	static $LINK_NODE_NAME = "link";
	static function read($fileName, $deeplink) {
		if($deeplink === null) {
			$deeplink = "";
		}
		$layerSeoModel = null;
		$layerSeoNativeArray = null;
		$layerSeoModel = org_silex_core_seo_LayerSeo::readLayerSeoModel($fileName, $deeplink);
		$layerSeoNativeArray = org_silex_core_seo_LayerSeo::layerSeoModel2PhpArray($layerSeoModel);
		return $layerSeoNativeArray;
	}
	static function readLayerSeoModel($fileName, $deeplink) {
		if($deeplink === null) {
			$deeplink = "";
		}
		$layerSeoXml = org_silex_core_seo_LayerSeo::readXml($fileName, $deeplink);
		$layerSeoModel = null;
		$layerSeoNativeArray = null;
		$layerSeoModel = org_silex_core_seo_LayerSeo::xml2LayerSeoModel($layerSeoXml);
		return $layerSeoModel;
	}
	static function readXml($fileName, $deeplink) {
		if($deeplink === null) {
			$deeplink = "";
		}
		if(file_exists($fileName)) {
			$layerSeoXml = Xml::createElement("root");
			$layerSeoString = null;
			$layerSeoString = php_io_File::getContent($fileName);
			if(_hx_index_of(strtolower($layerSeoString), "<element", null) === -1) {
				if($layerSeoString !== "" && $layerSeoString !== "<>" && $layerSeoString !== "</>") {
					$layerSeoXml = Xml::parse($layerSeoString);
					$layerSeoXml = org_silex_core_XmlUtils::cleanUp($layerSeoXml->firstElement());
					$childElement = null;
					if($layerSeoXml->getNodeName() === org_silex_core_seo_LayerSeo::$SEO_DATA_NODE_NAME && $layerSeoXml->get(org_silex_core_seo_LayerSeo::$VERSION_ATTRIBUTE_NAME) === org_silex_core_seo_LayerSeo::$VERSION_ATTRIBUTE_VALUE) {
						$emptyDeeplinkNode = Xml::createElement("root");
						if(null == $layerSeoXml) throw new HException('null iterable');
						$»it = $layerSeoXml->elementsNamed(org_silex_core_seo_LayerSeo::$LAYER_SEO_NODE_NAME);
						while($»it->hasNext()) {
							$childElement1 = $»it->next();
							if($childElement1->get(org_silex_core_seo_LayerSeo::$DEEPLINK_ATTRIBUTE_NAME) === $deeplink) {
								return $childElement1;
							}
							if($childElement1->get(org_silex_core_seo_LayerSeo::$DEEPLINK_ATTRIBUTE_NAME) === "") {
								$emptyDeeplinkNode = $childElement1;
							}
						}
						return $emptyDeeplinkNode;
					}
				}
			}
		}
		return null;
	}
	static function xml2LayerSeoModel($xml) {
		$layerSeoModel = org_silex_core_seo_Utils::createLayerSeoModel();
		$componentSeoModel = null;
		$componentSeoLinkModel = null;
		if($xml !== null) {
			if(null == $xml) throw new HException('null iterable');
			$»it = $xml->elements();
			while($»it->hasNext()) {
				$layerSeoProp = $»it->next();
				if($layerSeoProp->getNodeName() !== "components") {
					if($layerSeoProp->firstChild() !== null) {
						$layerSeoModel->{$layerSeoProp->getNodeName()} = $layerSeoProp->firstChild()->getNodeValue();
					}
				} else {
					if(null == $layerSeoProp) throw new HException('null iterable');
					$»it2 = $layerSeoProp->elements();
					while($»it2->hasNext()) {
						$component = $»it2->next();
						$componentSeoModel = null;
						$componentSeoModel->specificProperties = new Hash();
						$componentSeoModel->links = new _hx_array(array());
						if(null == $component) throw new HException('null iterable');
						$»it3 = $component->elements();
						while($»it3->hasNext()) {
							$componentProp = $»it3->next();
							if($componentProp->getNodeName() !== org_silex_core_seo_LayerSeo::$LINKS_NODE_NAME) {
								if($componentProp->firstChild() !== null) {
									$isGenericProperty = false;
									if(null == new _hx_array(array("playerName", "className", "iconIsIcon", "htmlEquivalent", "tags", "description"))) throw new HException('null iterable');
									$»it4 = _hx_deref(new _hx_array(array("playerName", "className", "iconIsIcon", "htmlEquivalent", "tags", "description")))->iterator();
									while($»it4->hasNext()) {
										$componentGenericPropertyName = $»it4->next();
										if($componentProp->getNodeName() === $componentGenericPropertyName) {
											$componentSeoModel->{$componentGenericPropertyName} = $componentProp->firstChild()->getNodeValue();
											$isGenericProperty = true;
											break;
										}
									}
									if(!$isGenericProperty && $componentProp->getNodeName() !== "links") {
										$componentSeoModel->specificProperties->set($componentProp->getNodeName(), $componentProp->firstChild()->getNodeValue());
									}
									unset($isGenericProperty);
								}
							} else {
								if(null == $componentProp) throw new HException('null iterable');
								$»it4 = $componentProp->elements();
								while($»it4->hasNext()) {
									$link = $»it4->next();
									$componentSeoLinkModel = null;
									if(null == $link) throw new HException('null iterable');
									$»it5 = $link->elements();
									while($»it5->hasNext()) {
										$componentSeoLinkProp = $»it5->next();
										if($componentSeoLinkProp->firstChild() !== null) {
											$componentSeoLinkModel->{$componentSeoLinkProp->getNodeName()} = $componentSeoLinkProp->firstChild()->getNodeValue();
										}
									}
									$componentSeoModel->links->push($componentSeoLinkModel);
								}
							}
						}
						$layerSeoModel->components->push($componentSeoModel);
					}
				}
			}
		}
		return $layerSeoModel;
	}
	static function layerSeoModel2PhpArray($layerSeoModel) {
		$layerSeoHash = new Hash();
		$layerSeoNativeArray = null;
		$componentsArray = new _hx_array(array());
		$componentsNativeArray = null;
		$componentHash = null;
		$componentNativeArray = null;
		$linksArray = null;
		$linksNativeArray = null;
		$linkHash = null;
		$linkNativeArray = null;
		if(null == new _hx_array(array("title", "description", "pubDate"))) throw new HException('null iterable');
		$»it = _hx_deref(new _hx_array(array("title", "description", "pubDate")))->iterator();
		while($»it->hasNext()) {
			$layerSeoModelProp = $»it->next();
			$layerSeoHash->set($layerSeoModelProp, Reflect::field($layerSeoModel, $layerSeoModelProp));
		}
		if($layerSeoModel->components->length !== 0) {
			$_g = 0; $_g1 = $layerSeoModel->components;
			while($_g < $_g1->length) {
				$component = $_g1[$_g];
				++$_g;
				$componentHash = new Hash();
				if(null == new _hx_array(array("playerName", "className", "iconIsIcon", "htmlEquivalent", "tags", "description"))) throw new HException('null iterable');
				$»it = _hx_deref(new _hx_array(array("playerName", "className", "iconIsIcon", "htmlEquivalent", "tags", "description")))->iterator();
				while($»it->hasNext()) {
					$componentProp = $»it->next();
					if(Reflect::field($component, $componentProp) !== null) {
						$componentHash->set($componentProp, Reflect::field($component, $componentProp));
					}
				}
				if(null == $component->specificProperties) throw new HException('null iterable');
				$»it = $component->specificProperties->keys();
				while($»it->hasNext()) {
					$specificProp = $»it->next();
					if($component->specificProperties->get($specificProp) !== null) {
						$componentHash->set($specificProp, $component->specificProperties->get($specificProp));
					}
				}
				if($component->links->length !== 0) {
					$linksArray = new _hx_array(array());
					{
						$_g2 = 0; $_g3 = $component->links;
						while($_g2 < $_g3->length) {
							$link = $_g3[$_g2];
							++$_g2;
							$linkHash = new Hash();
							if(null == new _hx_array(array("title", "link", "deeplink", "description"))) throw new HException('null iterable');
							$»it = _hx_deref(new _hx_array(array("title", "link", "deeplink", "description")))->iterator();
							while($»it->hasNext()) {
								$linkProp = $»it->next();
								if(Reflect::field($link, $linkProp) !== null) {
									$linkHash->set($linkProp, Reflect::field($link, $linkProp));
								}
							}
							$linkNativeArray = php_Lib::associativeArrayOfHash($linkHash);
							$linksArray->push($linkNativeArray);
							$linksNativeArray = php_Lib::toPhpArray($linksArray);
							unset($link);
						}
						unset($_g3,$_g2);
					}
					$componentHash->set(org_silex_core_seo_LayerSeo::$LINKS_NODE_NAME, $linksNativeArray);
				}
				$componentNativeArray = php_Lib::associativeArrayOfHash($componentHash);
				$componentsArray->push($componentNativeArray);
				$componentsNativeArray = php_Lib::toPhpArray($componentsArray);
				unset($component);
			}
		}
		$layerSeoHash->set("components", $componentsNativeArray);
		$layerSeoNativeArray = php_Lib::associativeArrayOfHash($layerSeoHash);
		return $layerSeoNativeArray;
	}
	static function write($fileName, $deeplink, $layerSeoModelArray, $indent) {
		$layerSeoModel = org_silex_core_seo_LayerSeo::phpArray2LayerSeoModel($layerSeoModelArray, $deeplink);
		$layerSeoModelXml = org_silex_core_seo_LayerSeo::layerSeoModel2Xml($layerSeoModel, $deeplink);
		org_silex_core_seo_LayerSeo::writeXml($fileName, $deeplink, $layerSeoModelXml, $indent);
	}
	static function writeLayerSeoModel($fileName, $deeplink, $layerSeoModel, $indent) {
		$layerSeoModelXml = org_silex_core_seo_LayerSeo::layerSeoModel2Xml($layerSeoModel, $deeplink);
		org_silex_core_seo_LayerSeo::writeXml($fileName, $deeplink, $layerSeoModelXml, $indent);
	}
	static function phpArray2LayerSeoModel($layerSeoArray, $deeplink) {
		$layerSeoModel = null;
		$layerSeoModel->components = new _hx_array(array());
		$layerSeoModelHash = php_Lib::hashOfAssociativeArray($layerSeoArray);
		if(null == new _hx_array(array("title", "description", "pubDate"))) throw new HException('null iterable');
		$»it = _hx_deref(new _hx_array(array("title", "description", "pubDate")))->iterator();
		while($»it->hasNext()) {
			$prop = $»it->next();
			$layerSeoModel->{$prop} = $layerSeoModelHash->get($prop);
		}
		$componentsArray = new _hx_array($layerSeoModelHash->get(org_silex_core_seo_LayerSeo::$CONTENT_NODE_NAME));
		$componentHash = new Hash();
		{
			$_g = 0;
			while($_g < $componentsArray->length) {
				$component = $componentsArray[$_g];
				++$_g;
				$componentSeoModel = null;
				$componentSeoModel->specificProperties = new Hash();
				$componentSeoModel->links = new _hx_array(array());
				$componentHash = php_Lib::hashOfAssociativeArray($component);
				$componentGenericPropertyName = null;
				if(null == $componentHash) throw new HException('null iterable');
				$»it = $componentHash->keys();
				while($»it->hasNext()) {
					$phpNativeArrayComponentPropertyName = $»it->next();
					$isGenericProperty = false;
					if(null == new _hx_array(array("playerName", "className", "iconIsIcon", "htmlEquivalent", "tags", "description"))) throw new HException('null iterable');
					$»it2 = _hx_deref(new _hx_array(array("playerName", "className", "iconIsIcon", "htmlEquivalent", "tags", "description")))->iterator();
					while($»it2->hasNext()) {
						$componentGenericPropertyName1 = $»it2->next();
						if($phpNativeArrayComponentPropertyName === $componentGenericPropertyName1) {
							$componentSeoModel->{$componentGenericPropertyName1} = $componentHash->get($componentGenericPropertyName1);
							$isGenericProperty = true;
							break;
						}
					}
					if(!$isGenericProperty && $phpNativeArrayComponentPropertyName !== "links") {
						$componentSeoModel->specificProperties->set($phpNativeArrayComponentPropertyName, $componentHash->get($phpNativeArrayComponentPropertyName));
					}
					unset($isGenericProperty);
				}
				$linksArray = new _hx_array($componentHash->get(org_silex_core_seo_LayerSeo::$LINKS_NODE_NAME));
				$linkHash = new Hash();
				{
					$_g1 = 0;
					while($_g1 < $linksArray->length) {
						$link = $linksArray[$_g1];
						++$_g1;
						$componentSeoLinkModel = null;
						if(null == new _hx_array(array("title", "link", "deeplink", "description"))) throw new HException('null iterable');
						$»it = _hx_deref(new _hx_array(array("title", "link", "deeplink", "description")))->iterator();
						while($»it->hasNext()) {
							$index = $»it->next();
							$linkHash = php_Lib::hashOfAssociativeArray($link);
							$componentSeoLinkModel->{$index} = $linkHash->get($index);
						}
						$componentSeoModel->links->push($componentSeoLinkModel);
						unset($link,$componentSeoLinkModel);
					}
					unset($_g1);
				}
				$layerSeoModel->components->push($componentSeoModel);
				unset($linksArray,$linkHash,$componentSeoModel,$componentGenericPropertyName,$component);
			}
		}
		return $layerSeoModel;
	}
	static function layerSeoModel2Xml($layerSeoModel, $deeplink) {
		$layerSeoModelXml = Xml::createElement(org_silex_core_seo_LayerSeo::$LAYER_SEO_NODE_NAME);
		$layerSeoModelXml->set(org_silex_core_seo_LayerSeo::$DEEPLINK_ATTRIBUTE_NAME, $deeplink);
		$tempXml = null;
		$propertiesXml = null;
		$value = null;
		if(null == new _hx_array(array("title", "description", "pubDate"))) throw new HException('null iterable');
		$»it = _hx_deref(new _hx_array(array("title", "description", "pubDate")))->iterator();
		while($»it->hasNext()) {
			$prop = $»it->next();
			if(Reflect::field($layerSeoModel, $prop) !== null && !_hx_equal(Reflect::field($layerSeoModel, $prop), "")) {
				$propertiesXml = Xml::createElement($prop);
				$value = _hx_string_call(Reflect::field($layerSeoModel, $prop), "toString", array());
				$propertiesXml->addChild(Xml::createCData($value));
				$layerSeoModelXml->addChild($propertiesXml);
			}
		}
		$tempXml = Xml::createElement("components");
		$component = null;
		$link = null;
		$componentXml = null;
		$componentPropertiesXml = null;
		$linksXml = null;
		$linkXml = null;
		$linkPropertiesXml = null;
		if($layerSeoModel->components->length !== 0) {
			{
				$_g = 0; $_g1 = $layerSeoModel->components;
				while($_g < $_g1->length) {
					$component1 = $_g1[$_g];
					++$_g;
					$componentXml = Xml::createElement("component");
					if(null == new _hx_array(array("playerName", "className", "iconIsIcon", "htmlEquivalent", "tags", "description"))) throw new HException('null iterable');
					$»it = _hx_deref(new _hx_array(array("playerName", "className", "iconIsIcon", "htmlEquivalent", "tags", "description")))->iterator();
					while($»it->hasNext()) {
						$index = $»it->next();
						if(Reflect::field($component1, $index) !== null && !_hx_equal(Reflect::field($component1, $index), "")) {
							$componentPropertiesXml = Xml::createElement($index);
							$value = _hx_string_call(Reflect::field($component1, $index), "toString", array());
							$componentPropertiesXml->addChild(Xml::createCData($value));
							$componentXml->addChild($componentPropertiesXml);
						}
					}
					if(null == $component1->specificProperties) throw new HException('null iterable');
					$»it = $component1->specificProperties->keys();
					while($»it->hasNext()) {
						$index = $»it->next();
						if($component1->specificProperties->get($index) !== null && $component1->specificProperties->get($index) !== "") {
							$componentPropertiesXml = Xml::createElement($index);
							$value = Std::string($component1->specificProperties->get($index));
							$componentPropertiesXml->addChild(Xml::createCData($value));
							$componentXml->addChild($componentPropertiesXml);
						}
					}
					if($component1->links->length !== 0) {
						$linksXml = Xml::createElement(org_silex_core_seo_LayerSeo::$LINKS_NODE_NAME);
						{
							$_g2 = 0; $_g3 = $component1->links;
							while($_g2 < $_g3->length) {
								$link1 = $_g3[$_g2];
								++$_g2;
								$linkXml = Xml::createElement("link");
								if(null == new _hx_array(array("title", "link", "deeplink", "description"))) throw new HException('null iterable');
								$»it = _hx_deref(new _hx_array(array("title", "link", "deeplink", "description")))->iterator();
								while($»it->hasNext()) {
									$index = $»it->next();
									if(Reflect::field($link1, $index) !== null && !_hx_equal(Reflect::field($link1, $index), "")) {
										$linkPropertiesXml = Xml::createElement($index);
										$value = _hx_string_call(Reflect::field($link1, $index), "toString", array());
										$linkPropertiesXml->addChild(Xml::createCData($value));
										$linkXml->addChild($linkPropertiesXml);
									}
								}
								$linksXml->addChild($linkXml);
								unset($link1);
							}
							unset($_g3,$_g2);
						}
						$componentXml->addChild($linksXml);
					}
					$tempXml->addChild($componentXml);
					unset($component1);
				}
			}
			$layerSeoModelXml->addChild($tempXml);
		}
		return $layerSeoModelXml;
	}
	static function writeXml($fileName, $deeplink, $xmlContent, $indent) {
		$layerSeoXmlFinal = Xml::createDocument();
		$layerSeoXmlTemp = Xml::createElement(org_silex_core_seo_LayerSeo::$SEO_DATA_NODE_NAME);
		$layerSeoXmlTemp->set(org_silex_core_seo_LayerSeo::$VERSION_ATTRIBUTE_NAME, org_silex_core_seo_LayerSeo::$VERSION_ATTRIBUTE_VALUE);
		$xmlContent = org_silex_core_XmlUtils::cleanUp($xmlContent);
		$layerSeoXmlTemp->addChild($xmlContent);
		$layerSeoXmlOriginal = null;
		$stringContent = null;
		if(file_exists($fileName)) {
			$fileContent = php_io_File::getContent($fileName);
			try {
				$layerSeoXmlOriginal = org_silex_core_XmlUtils::stringIndent2Xml($fileContent);
			}catch(Exception $»e) {
				$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
				$e = $_ex_;
				{
					$layerSeoXmlOriginal = null;
				}
			}
			if($layerSeoXmlOriginal !== null) {
				$childElement = null;
				if($layerSeoXmlOriginal->getNodeName() === org_silex_core_seo_LayerSeo::$SEO_DATA_NODE_NAME && $layerSeoXmlOriginal->get(org_silex_core_seo_LayerSeo::$VERSION_ATTRIBUTE_NAME) === org_silex_core_seo_LayerSeo::$VERSION_ATTRIBUTE_VALUE) {
					$layerSeoXmlTemp = $layerSeoXmlOriginal;
					if(null == $layerSeoXmlOriginal) throw new HException('null iterable');
					$»it = $layerSeoXmlOriginal->elementsNamed(org_silex_core_seo_LayerSeo::$LAYER_SEO_NODE_NAME);
					while($»it->hasNext()) {
						$childElement1 = $»it->next();
						if($childElement1->get(org_silex_core_seo_LayerSeo::$DEEPLINK_ATTRIBUTE_NAME) === $deeplink) {
							$layerSeoXmlTemp->removeChild($childElement1);
						}
						$layerSeoXmlTemp->addChild($xmlContent);
					}
				} else {
					haxe_Log::trace("Publication layer seo file is not in the v2 format for deeplink: " . $deeplink . ". Please save it manually via the Wysiwyg", _hx_anonymous(array("fileName" => "LayerSeo.hx", "lineNumber" => 608, "className" => "org.silex.core.seo.LayerSeo", "methodName" => "writeXml")));
				}
			}
		} else {
			haxe_Log::trace("Seo file does not exists", _hx_anonymous(array("fileName" => "LayerSeo.hx", "lineNumber" => 614, "className" => "org.silex.core.seo.LayerSeo", "methodName" => "writeXml")));
		}
		$layerSeoXmlFinal->addChild($layerSeoXmlTemp);
		if($indent) {
			$stringContent = "\x0A" . org_silex_core_XmlUtils::xml2StringIndent($layerSeoXmlFinal);
		} else {
			$stringContent = $layerSeoXmlFinal->toString();
		}
		$stringContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" . $stringContent;
		php_io_File::putContent($fileName, $stringContent);
	}
	function __toString() { return 'org.silex.core.seo.LayerSeo'; }
}
