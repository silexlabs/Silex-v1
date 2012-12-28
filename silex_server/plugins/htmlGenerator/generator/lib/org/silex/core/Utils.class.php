<?php

class org_silex_core_Utils {
	public function __construct(){}
	static function getTarget($source_mc, $path_str, $separator) {
		if($path_str === null || $path_str === "" || $path_str === ".") {
			return $source_mc;
		}
		$tmp_source_mc = null;
		if($separator === null) {
			$separator = ".";
		}
		$path_array = _hx_explode($separator, $path_str);
		$firstInPathArray = $path_array[0];
		switch($firstInPathArray) {
		case "_global":{
			$tmp_source_mc = org_silex_htmlGenerator_InterpreterContext::$components;
			$path_array->shift();
		}break;
		case "_root":{
			$tmp_source_mc = org_silex_htmlGenerator_InterpreterContext::$components;
			$path_array->shift();
		}break;
		case "silex":{
			$tmp_source_mc = org_silex_htmlGenerator_InterpreterContext::$components;
			$path_array->shift();
		}break;
		case "layout":{
			$tmp_source_mc = org_silex_htmlGenerator_InterpreterContext::$components;
			$path_array->shift();
		}break;
		case "plugins":{
			$tmp_source_mc = org_silex_htmlGenerator_InterpreterContext::$components;
			$path_array->shift();
		}break;
		default:{
			$playerTmp = org_silex_htmlGenerator_InterpreterContext::$components->get($firstInPathArray);
			if($playerTmp !== null) {
				$tmp_source_mc = $playerTmp;
				$path_array->shift();
			} else {
				if(Reflect::field($source_mc, $firstInPathArray) !== null) {
					$tmp_source_mc = $source_mc;
				} else {
					$tmp_source_mc = $source_mc;
				}
			}
		}break;
		}
		{
			$_g1 = 0; $_g = $path_array->length;
			while($_g1 < $_g) {
				$i = $_g1++;
				switch($path_array[$i]) {
				case "_x":{
				}break;
				case "_y":{
				}break;
				default:{
					if(Std::is($tmp_source_mc, _hx_qtype("Hash"))) {
						$tmp_source_mc = $tmp_source_mc->get($path_array[$i]);
					} else {
						if(Reflect::field($tmp_source_mc, $path_array[$i]) !== null) {
							$tmp_source_mc = Reflect::field($tmp_source_mc, $path_array[$i]);
						} else {
							return null;
						}
					}
				}break;
				}
				unset($i);
			}
		}
		return $tmp_source_mc;
	}
	static function revealAccessors($input_str, $source_mc, $separator) {
		$_array = null;
		$idx = null;
		$hasStringInIt = false;
		if($separator === null) {
			$separator = ".";
		}
		if($input_str === null) {
			return "";
		}
		if(!Std::is($input_str, _hx_qtype("String"))) {
			$input_str = $input_str;
		}
		$_array = org_silex_core_Utils::splitTags($input_str, "((", "))");
		{
			$_g1 = 0; $_g = $_array->length;
			while($_g1 < $_g) {
				$idx1 = $_g1++;
				$ltgt_length_num = 2;
				$start_idx = _hx_index_of($_array[$idx1], "<<", null);
				if($start_idx === -1) {
					$ltgt_length_num = 8;
					$start_idx = _hx_index_of($_array[$idx1], ">>", null);
				}
				if($start_idx === -1) {
					$hasStringInIt = true;
				}
				if($start_idx === -1 && $idx1 % 2 !== 0) {
					$_array[$idx1] = "((" . $_array[$idx1] . "))";
				}
				while($start_idx >= 0) {
					$ltgt_length_num = 2;
					$end_idx = _hx_index_of($_array[$idx1], ">>", null);
					if($end_idx === -1) {
						$ltgt_length_num = 8;
						$end_idx = _hx_index_of($_array[$idx1], ">>", null);
					}
					if($end_idx <= $start_idx) {
						break;
					}
					$accessor_name = _hx_substr($_array[$idx1], $start_idx + $ltgt_length_num, $end_idx - ($start_idx + $ltgt_length_num));
					$hasFilter = false;
					$filter_name = null;
					$args = null;
					$filter_separator_index = _hx_index_of($accessor_name, ",", null);
					if($filter_separator_index > 0) {
						$filter_name = _hx_substr($accessor_name, 0, $filter_separator_index);
						$argsArray = _hx_explode(":", $filter_name);
						$filter_name = $argsArray[0];
						$args = _hx_explode(",", $argsArray[1]);
						$accessor_name = _hx_substr($accessor_name, $filter_separator_index + 1, null);
						unset($argsArray);
					}
					$value_obj = org_silex_core_Utils::getTarget($source_mc, $accessor_name, $separator);
					if($value_obj !== null) {
						$value_str = null;
						if(!Std::is($value_obj, _hx_qtype("String"))) {
							$_array[$idx1] = $value_obj;
							break;
						} else {
							if(Std::is($value_obj, _hx_qtype("String"))) {
								$hasStringInIt = true;
								$value_str = _hx_string_call($value_obj, "toString", array());
								$_array[$idx1] = _hx_substr($_array[$idx1], 0, $start_idx) . $value_str . _hx_substr($_array[$idx1], $end_idx + $ltgt_length_num, null);
							} else {
								$_array[$idx1] = $value_obj;
								break;
							}
						}
						unset($value_str);
					} else {
						$_array[$idx1] = "";
						$hasStringInIt = true;
					}
					$ltgt_length_num = 2;
					$start_idx = _hx_index_of($_array[$idx1], "<<", null);
					if($start_idx === -1) {
						$ltgt_length_num = 8;
						$start_idx = _hx_index_of($_array[$idx1], ">>", null);
					}
					unset($value_obj,$hasFilter,$filter_separator_index,$filter_name,$end_idx,$args,$accessor_name);
				}
				unset($start_idx,$ltgt_length_num,$idx1);
			}
		}
		$res = null;
		if($hasStringInIt === true) {
			$res = $_array->join("");
		} else {
			if($_array->length > 1) {
				$res = $_array;
			} else {
				$res = $_array[0];
			}
		}
		return $res;
	}
	static function splitTags($input_str, $leftTag, $rightTag) {
		if($leftTag === null) {
			$leftTag = "((";
		}
		if($rightTag === null) {
			$rightTag = "))";
		}
		$tmp_array = null;
		$_array = new _hx_array(array());
		$tmp_array = _hx_explode("((", $input_str);
		{
			$_g1 = 0; $_g = $tmp_array->length;
			while($_g1 < $_g) {
				$idx = $_g1++;
				if($tmp_array[$idx] !== "") {
					$tmp_idx = _hx_index_of($tmp_array[$idx], "))", null);
					if($tmp_idx !== null && $tmp_idx >= 0) {
						$_array->push(_hx_substr($tmp_array[$idx], 0, $tmp_idx + 1));
						if($tmp_idx + 2 < strlen($tmp_array[$idx])) {
							$_array->push(_hx_substr($tmp_array[$idx], $tmp_idx + 2, null));
						}
					} else {
						$_array->push($tmp_array[$idx]);
					}
					unset($tmp_idx);
				}
				unset($idx);
			}
		}
		return $_array;
	}
	function __toString() { return 'org.silex.core.Utils'; }
}
