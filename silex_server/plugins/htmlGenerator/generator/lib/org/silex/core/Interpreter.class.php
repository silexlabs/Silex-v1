<?php

class org_silex_core_Interpreter {
	public function __construct() { 
	}
	public function openUrl($context, $url, $target) {
		if($target === null) {
			$target = "_blank";
		}
		if(_hx_has_field($context, "__silex__actionshref__")) {
			$context->__silex__actionshref__ = $url;
		}
	}
	public function http($context, $url, $target) {
		if($target === null) {
			$target = "_blank";
		}
		$this->openUrl($context, "http:" . $url, $target);
	}
	public function mailto($context, $address) {
		$this->openUrl($context, "mailto:" . $address, "_self");
	}
	public function download($context, $initialFileName, $finalFileName) {
		if($finalFileName !== null) {
			$finalFileName = _hx_explode("/", $initialFileName)->pop();
		}
	}
	public function set($context, $propertyName, $valueStr) {
	}
	public function del($context, $propertyName) {
	}
	public function hide($context, $targetObjectPath) {
	}
	public function alert($context, $text) {
	}
	public function traceMe($context) {
		haxe_Log::trace("traceMe:" . Std::string($context), _hx_anonymous(array("fileName" => "Interpreter.hx", "lineNumber" => 366, "className" => "org.silex.core.Interpreter", "methodName" => "traceMe")));
	}
	public function open($context, $sectionName) {
		if(_hx_char_at($sectionName, 0) === "/") {
			$sectionName = _hx_substr($sectionName, 1, strlen($sectionName) - 1);
		}
		$layers = null;
		$layers = _hx_explode("/", $sectionName);
		$startLayer = "start";
		$startLayer = org_silex_htmlGenerator_InterpreterContext::$websiteConfig->get("CONFIG_START_SECTION");
		if($layers[0] !== $startLayer) {
			$layers->insert(0, $startLayer);
		}
		$publicationName = "";
		$publicationName = org_silex_htmlGenerator_Utils::$deeplink->publication;
		$this->openUrl($context, "?/" . $publicationName . "/" . $layers->join("/") . "&format=html", "_self");
	}
	static $actions;
	static $interpreter;
	static function exec($command, $initialSource) {
		if($command === null || $command === "") {
			return false;
		}
		$equalOperatorIndex = _hx_index_of($command, "=", null);
		$columnOperatorIndex = _hx_index_of($command, ":", null);
		if($equalOperatorIndex >= 0 && $columnOperatorIndex < 0 || $equalOperatorIndex > 0 && $equalOperatorIndex < $columnOperatorIndex) {
			$res_str = "";
			$targetVariablePath_str = null;
			$targetVariablePath_str = _hx_substr($command, 0, $equalOperatorIndex);
			$targetVariableIdx = null;
			$targetVariableIdx = _hx_last_index_of($targetVariablePath_str, ".", null) + 1;
			if($targetVariableIdx > 0) {
				$res_str = _hx_substr($targetVariablePath_str, 0, $targetVariableIdx);
			}
			$res_str .= "set:" . _hx_substr($targetVariablePath_str, $targetVariableIdx, null) . ",";
			$value_str = _hx_substr($command, $equalOperatorIndex + 1, null);
			$res_str .= $value_str;
			$command = $res_str;
		}
		$command_array = null;
		$command_array = org_silex_core_Interpreter::extract($command);
		$methodName_str = null;
		$source_mc = null;
		$source_mc = org_silex_htmlGenerator_InterpreterContext::$components;
		$lastDotIndex = _hx_last_index_of($command_array[0], ".", null);
		if($lastDotIndex > 0) {
			$relativePath_str = _hx_substr($command_array[0], 0, $lastDotIndex);
			$methodName_str = _hx_substr($command_array[0], $lastDotIndex + 1, null);
			$source_mc = org_silex_core_Interpreter::updateSource($initialSource, $relativePath_str);
		} else {
			$methodName_str = $command_array[0];
			$source_mc = $initialSource;
		}
		{
			$_g1 = 0; $_g = $command_array->length;
			while($_g1 < $_g) {
				$idx = $_g1++;
				$command_array[$idx] = org_silex_core_Utils::revealAccessors($command_array[$idx], $source_mc, null);
				unset($idx);
			}
		}
		$params_array = null;
		$params_array = $command_array;
		$params_array->shift();
		if(_hx_has_field($source_mc, $methodName_str)) {
			return Reflect::callMethod($source_mc, Reflect::field($source_mc, $methodName_str), $params_array);
		}
		if(Lambda::has(Type::getInstanceFields(_hx_qtype("org.silex.core.Interpreter")), $methodName_str, null)) {
			$params_array->insert(0, $source_mc);
			$classRefl = new ReflectionClass('org_silex_core_Interpreter');
			$neededParams = $classRefl->getMethod($methodName_str)->getNumberOfRequiredParameters();
			{
				$_g1 = 0; $_g = $neededParams - $params_array->length;
				while($_g1 < $_g) {
					$i = $_g1++;
					$params_array->push(null);
					unset($i);
				}
			}
			return Reflect::callMethod(org_silex_core_Interpreter::$interpreter, Reflect::field(org_silex_core_Interpreter::$interpreter, $methodName_str), $params_array);
		}
		return null;
	}
	static function updateSource($source_mc, $path_str) {
		if($path_str !== null) {
			$tmp_mc = null;
			$tmp_mc = org_silex_core_Utils::getTarget($source_mc, $path_str, null);
			if($tmp_mc !== null) {
				$source_mc = $tmp_mc;
			}
		}
		return $source_mc;
	}
	static function extract($command) {
		$ret_array = null;
		$ret_array = new _hx_array(array());
		if($command === null || $command === "") {
			return null;
		}
		$indice_num = _hx_index_of($command, ":", null);
		if($indice_num >= 0) {
			$ret_array[0] = _hx_substr($command, 0, $indice_num);
			$tmp_array = null;
			$tmp_array = _hx_explode(",", _hx_substr($command, $indice_num + 1, null));
			{
				$_g1 = 0; $_g = $tmp_array->length;
				while($_g1 < $_g) {
					$i = $_g1++;
					$ret_array[$i + 1] = $tmp_array[$i];
					unset($i);
				}
			}
		} else {
			$ret_array[0] = $command;
		}
		return $ret_array;
	}
	static function javascript($context, $code) {
	}
	static function show($context, $targetObjectPath) {
	}
	static function alertSimple($context, $text) {
	}
	static function openWebsite($context, $idSite) {
	}
	static function initActions() {
		$_g = 0; $_g1 = org_silex_core_Interpreter::$actions;
		while($_g < $_g1->length) {
			$action = $_g1[$_g];
			++$_g;
			switch($action->modifier) {
			case "onRelease":case "onPress":{
				org_silex_core_Interpreter::handleEvent($action->modifier, $action->component);
			}break;
			default:{
			}break;
			}
			unset($action);
		}
	}
	static function handleEvent($event, $component) {
		$_g = 0; $_g1 = org_silex_core_Interpreter::$actions;
		while($_g < $_g1->length) {
			$action = $_g1[$_g];
			++$_g;
			if($event === $action->modifier && $component === $action->component) {
				$silexCode = $action->functionName;
				{
					$_g3 = 0; $_g2 = $action->parameters->length;
					while($_g3 < $_g2) {
						$i = $_g3++;
						$action->parameters[$i] = htmlspecialchars_decode($action->parameters[$i]);
						unset($i);
					}
					unset($_g3,$_g2);
				}
				if($action->parameters->length > 0) {
					$silexCode .= ":" . $action->parameters->join(",");
				}
				org_silex_core_Interpreter::exec($silexCode, org_silex_htmlGenerator_InterpreterContext::$components->get($action->component));
				unset($silexCode);
			}
			unset($action);
		}
	}
	function __toString() { return 'org.silex.core.Interpreter'; }
}
org_silex_core_Interpreter::$actions = new _hx_array(array());
org_silex_core_Interpreter::$interpreter = new org_silex_core_Interpreter();
