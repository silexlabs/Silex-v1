<?php

class org_silex_htmlGenerator_exceptions_LayerException extends Enum {
	public static function notFound($layerName) { return new org_silex_htmlGenerator_exceptions_LayerException("notFound", 0, array($layerName)); }
	public static function parseError($layerName) { return new org_silex_htmlGenerator_exceptions_LayerException("parseError", 1, array($layerName)); }
	public static $__constructors = array(0 => 'notFound', 1 => 'parseError');
	}
