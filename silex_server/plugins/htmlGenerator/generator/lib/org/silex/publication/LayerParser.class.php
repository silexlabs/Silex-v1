<?php

class org_silex_publication_LayerParser {
	public function __construct(){}
	static function layer2XML($layer) {
		$xml = Xml::createDocument();
		$layerNode = Xml::createElement("layer");
		$xml->addChild($layerNode);
		$subNode = Xml::createElement("subLayers");
		$layerNode->addChild($subNode);
		if(null == $layer->subLayers) throw new HException('null iterable');
		$»it = $layer->subLayers->iterator();
		while($»it->hasNext()) {
			$subLayer = $»it->next();
			$subLayerNode = Xml::createElement("subLayer");
			$subLayerNode->set("id", $subLayer->id);
			$subLayerNode->set("zIndex", Std::string($subLayer->zIndex));
			$componentsNode = Xml::createElement("components");
			if(null == $subLayer->components) throw new HException('null iterable');
			$»it2 = $subLayer->components->iterator();
			while($»it2->hasNext()) {
				$comp = $»it2->next();
				$compNode = Xml::createElement("component");
				if($comp->as2Url !== null) {
					$compNode->addChild(org_silex_publication_LayerParser::generateXml($comp->as2Url, "as2Url", null));
				}
				if($comp->html5Url !== null) {
					$compNode->addChild(org_silex_publication_LayerParser::generateXml($comp->html5Url, "html5Url", null));
				}
				if($comp->className !== null) {
					$compNode->addChild(org_silex_publication_LayerParser::generateXml($comp->className, "className", null));
				}
				if($comp->componentRoot !== null) {
					$compNode->addChild(org_silex_publication_LayerParser::generateXml($comp->componentRoot, "componentRoot", null));
				}
				$propNode = Xml::createElement("properties");
				$compNode->addChild($propNode);
				if(null == $comp->properties) throw new HException('null iterable');
				$»it3 = $comp->properties->keys();
				while($»it3->hasNext()) {
					$prop = $»it3->next();
					$propNode->addChild(org_silex_publication_LayerParser::generateXml($comp->properties->get($prop), $prop, true));
				}
				$actionsNode = Xml::createElement("actions");
				$compNode->addChild($actionsNode);
				if(null == $comp->actions) throw new HException('null iterable');
				$»it3 = $comp->actions->iterator();
				while($»it3->hasNext()) {
					$action = $»it3->next();
					$actionNode = Xml::createElement("action");
					$actionNode->addChild(org_silex_publication_LayerParser::generateXml($action->functionName, "functionName", true));
					$actionNode->addChild(org_silex_publication_LayerParser::generateXml($action->modifier, "modifier", true));
					$parametersNode = Xml::createElement("parameters");
					if(null == $action->parameters) throw new HException('null iterable');
					$»it4 = $action->parameters->iterator();
					while($»it4->hasNext()) {
						$parameter = $»it4->next();
						$parametersNode->addChild(org_silex_publication_LayerParser::generateXml($parameter, "parameter", true));
					}
					$actionNode->addChild($parametersNode);
					$actionsNode->addChild($actionNode);
					unset($parametersNode,$actionNode);
				}
				$componentsNode->addChild($compNode);
				unset($propNode,$compNode,$actionsNode);
			}
			$subLayerNode->addChild($componentsNode);
			$subNode->addChild($subLayerNode);
			unset($subLayerNode,$componentsNode);
		}
		return $xml;
	}
	static function adaptAs2Url($url) {
		if(_hx_index_of($url, "media/components/oof", null) !== -1) {
			$url = str_replace("media/components/oof/", "plugins/oofComponents/as2/", $url);
			$url = str_replace("cmp.", "", $url);
		} else {
			if(_hx_index_of($url, "media/components/", null) !== -1) {
				if(_hx_index_of($url, "media/components/SRTPlayer.cmp.swf", null) !== -1) {
					$url = str_replace("media/components/SRTPlayer.cmp.swf", "plugins/silexComponents/as2/SRTPlayer/SRTPlayer.swf", $url);
				} else {
					if(_hx_index_of($url, "media/components/buttons/label_button.cmp.swf", null) !== -1) {
						$url = str_replace("media/components/buttons/label_button.cmp.swf", "plugins/silexComponents/as2/labelButton/labelButton.swf", $url);
					} else {
						if(_hx_index_of($url, "media/components/buttons/label_button2.cmp.swf", null) !== -1) {
							$url = str_replace("media/components/buttons/label_button2.cmp.swf", "plugins/silexComponents/as2/labelButton/labelButton2.swf", $url);
						} else {
							if(_hx_index_of($url, "media/components/buttons/label_button3.cmp.swf", null) !== -1) {
								$url = str_replace("media/components/buttons/label_button3.cmp.swf", "plugins/silexComponents/as2/labelButton/labelButton3.swf", $url);
							} else {
								if(_hx_index_of($url, "media/components/buttons/label_button4.cmp.swf", null) !== -1) {
									$url = str_replace("media/components/buttons/label_button4.cmp.swf", "plugins/silexComponents/as2/labelButton/labelButton4.swf", $url);
								} else {
									if(_hx_index_of($url, "media/components/buttons/futurist_button.cmp.swf", null) !== -1) {
										$url = str_replace("media/components/buttons/futurist_button.cmp.swf", "plugins/silexComponents/as2/futuristButton/futuristButton.swf", $url);
									} else {
										if(_hx_index_of($url, "media/components/buttons/scale9_button1.cmp.swf", null) !== -1) {
											$url = str_replace("media/components/buttons/scale9_button1.cmp.swf", "plugins/silexComponents/as2/simpleFlashButton/scale9Button1.swf", $url);
										} else {
											if(_hx_index_of($url, "media/components/buttons/simple_flash_button1.cmp.swf", null) !== -1) {
												$url = str_replace("media/components/buttons/simple_flash_button1.cmp.swf", "plugins/silexComponents/as2/simpleFlashButton/simpleFlashButton1.swf", $url);
											} else {
												if(_hx_index_of($url, "media/components/buttons/simple_flash_button2.cmp.swf", null) !== -1) {
													$url = str_replace("media/components/buttons/simple_flash_button2.cmp.swf", "plugins/silexComponents/as2/simpleFlashButton/simpleFlashButton2.swf", $url);
												} else {
													if(_hx_index_of($url, "plugins/silexComponents/as2/simpleFlashButton/button.swf", null) !== -1) {
														$url = str_replace("plugins/silexComponents/as2/simpleFlashButton/button.swf", "plugins/silexComponents/as2/labelButton/button.swf", $url);
													} else {
														if(_hx_index_of($url, "media/components/Geometry.cmp.swf", null) !== -1) {
															$url = str_replace("media/components/Geometry.cmp.swf", "plugins/baseComponents/as2/Geometry.swf", $url);
														} else {
															if(_hx_index_of($url, "media/components/buttons/button.cmp.swf", null) !== -1) {
																$url = str_replace("media/components/buttons/button.cmp.swf", "plugins/silexComponents/as2/labelButton/button.swf", $url);
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		return $url;
	}
	static function xml2Layer($xml) {
		$layer = new org_silex_publication_LayerModel();
		if($xml->firstElement()->elementsNamed("subLayers")->hasNext()) {
			if(null == $xml->firstElement()->elementsNamed("subLayers")->next()) throw new HException('null iterable');
			$»it = $xml->firstElement()->elementsNamed("subLayers")->next()->elementsNamed("subLayer");
			while($»it->hasNext()) {
				$subNode = $»it->next();
				$subLayer = new org_silex_publication_SubLayerModel();
				$subLayer->id = $subNode->get("id");
				$subLayer->zIndex = Std::parseInt($subNode->get("zIndex"));
				if($subNode->elementsNamed("components")->hasNext()) {
					if(null == $subNode->elementsNamed("components")->next()) throw new HException('null iterable');
					$»it2 = $subNode->elementsNamed("components")->next()->elementsNamed("component");
					while($»it2->hasNext()) {
						$componentNode = $»it2->next();
						$comp = new org_silex_publication_ComponentModel();
						if($componentNode->elementsNamed("className")->hasNext()) {
							$comp->className = $componentNode->elementsNamed("className")->next()->firstChild()->toString();
						}
						if($componentNode->elementsNamed("as2Url")->hasNext()) {
							$comp->as2Url = $componentNode->elementsNamed("as2Url")->next()->firstChild()->toString();
							$comp->as2Url = org_silex_publication_LayerParser::adaptAs2Url($comp->as2Url);
						}
						if($componentNode->elementsNamed("html5Url")->hasNext()) {
							$comp->html5Url = $componentNode->elementsNamed("html5Url")->next()->firstChild()->toString();
						}
						if($componentNode->elementsNamed("componentRoot")->hasNext()) {
							$comp->componentRoot = $componentNode->elementsNamed("componentRoot")->next()->firstChild()->toString();
						}
						if($componentNode->elementsNamed("properties")->hasNext()) {
							if(null == $componentNode->elementsNamed("properties")->next()) throw new HException('null iterable');
							$»it3 = $componentNode->elementsNamed("properties")->next()->elements();
							while($»it3->hasNext()) {
								$prop = $»it3->next();
								$comp->properties->set($prop->getNodeName(), org_silex_publication_LayerParser::parseObject($prop));
							}
						}
						if($componentNode->elementsNamed("actions")->hasNext()) {
							if(null == $componentNode->elementsNamed("actions")->next()) throw new HException('null iterable');
							$»it3 = $componentNode->elementsNamed("actions")->next()->elementsNamed("action");
							while($»it3->hasNext()) {
								$actionNode = $»it3->next();
								$actionModel = new org_silex_publication_ActionModel();
								$actionModel->functionName = org_silex_publication_LayerParser::parseObject($actionNode->elementsNamed("functionName")->next());
								$actionModel->modifier = org_silex_publication_LayerParser::parseObject($actionNode->elementsNamed("modifier")->next());
								if(null == $actionNode->elementsNamed("parameters")->next()) throw new HException('null iterable');
								$»it4 = $actionNode->elementsNamed("parameters")->next()->elementsNamed("parameter");
								while($»it4->hasNext()) {
									$parameterNode = $»it4->next();
									$actionModel->parameters->add(org_silex_publication_LayerParser::parseObject($parameterNode));
								}
								$comp->actions->add($actionModel);
								unset($actionModel);
							}
						}
						$subLayer->components->add($comp);
						unset($comp);
					}
				}
				$layer->subLayers->add($subLayer);
				unset($subLayer);
			}
		}
		return $layer;
	}
	static function parseObject($node) {
		switch($node->get("type")) {
		case null:{
			$toRet = "";
			if(null == $node) throw new HException('null iterable');
			$»it = $node->iterator();
			while($»it->hasNext()) {
				$nv = $»it->next();
				$toRet .= $nv->getNodeValue();
			}
			return $toRet;
		}break;
		case "Integer":{
			return Std::parseInt($node->firstChild()->getNodeValue());
		}break;
		case "Boolean":{
			return $node->firstChild()->getNodeValue() !== "false";
		}break;
		case "Float":{
			return Std::parseFloat($node->firstChild()->getNodeValue());
		}break;
		case "Array":{
			$arr = new _hx_array(array());
			if(null == $node) throw new HException('null iterable');
			$»it = $node->elementsNamed("item");
			while($»it->hasNext()) {
				$item = $»it->next();
				$arr->push(org_silex_publication_LayerParser::parseObject($item));
			}
			return $arr;
		}break;
		case "Object":{
			$hashTable = new Hash();
			if(null == $node) throw new HException('null iterable');
			$»it = $node->elements();
			while($»it->hasNext()) {
				$el = $»it->next();
				$hashTable->set($el->getNodeName(), org_silex_publication_LayerParser::parseObject($el));
			}
			return $hashTable;
		}break;
		default:{
			$toRet = "";
			if(null == $node) throw new HException('null iterable');
			$»it = $node->iterator();
			while($»it->hasNext()) {
				$nv = $»it->next();
				$toRet .= $nv->getNodeValue();
			}
			return $toRet;
		}break;
		}
		return null;
	}
	static function generateXml($obj, $name, $useCData) {
		if($useCData === null) {
			$useCData = false;
		}
		$e = Xml::createElement($name);
		if(Std::is($obj, _hx_qtype("String"))) {
			if($useCData === false) {
				$n = Xml::createPCData($obj);
				$e->addChild($n);
			} else {
				$n = Xml::createCData($obj);
				$e->addChild($n);
			}
			return $e;
		} else {
			if(Std::is($obj, _hx_qtype("Int"))) {
				$e->set("type", "Integer");
				$n = Xml::createPCData(Std::string($obj));
				$e->addChild($n);
				return $e;
			} else {
				if(Std::is($obj, _hx_qtype("Bool"))) {
					$e->set("type", "Boolean");
					$n = Xml::createPCData(Std::string($obj));
					$e->addChild($n);
					return $e;
				} else {
					if(Std::is($obj, _hx_qtype("Float"))) {
						$e->set("type", "Float");
						$n = Xml::createPCData(Std::string($obj));
						$e->addChild($n);
						return $e;
					} else {
						if(Std::is($obj, _hx_qtype("Array"))) {
							$e->set("type", "Array");
							{
								$_g = 0; $_g1 = $obj;
								while($_g < $_g1->length) {
									$item = $_g1[$_g];
									++$_g;
									$n = org_silex_publication_LayerParser::generateXml($item, "item", true);
									$e->addChild($n);
									unset($n,$item);
								}
							}
							return $e;
						} else {
							if(Std::is($obj, _hx_qtype("Hash"))) {
								$e->set("type", "Object");
								if(null == ($obj)) throw new HException('null iterable');
								$»it = _hx_deref(($obj))->keys();
								while($»it->hasNext()) {
									$k = $»it->next();
									$n = org_silex_publication_LayerParser::generateXml($obj->get($k), $k, null);
									$e->addChild($n);
									unset($n);
								}
								return $e;
							}
						}
					}
				}
			}
		}
		return null;
	}
	static function layer2XMLString($layer, $indent) {
		$layerXml = org_silex_publication_LayerParser::layer2XML($layer);
		if($indent === true) {
			return org_silex_core_XmlUtils::xml2StringIndent($layerXml);
		} else {
			return $layerXml->toString();
		}
	}
	function __toString() { return 'org.silex.publication.LayerParser'; }
}
