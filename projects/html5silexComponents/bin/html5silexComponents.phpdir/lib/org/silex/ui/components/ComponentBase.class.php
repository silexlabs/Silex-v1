<?php

class org_silex_ui_components_ComponentBase extends org_silex_ui_UiBase {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		parent::__construct();
	}}
	function __toString() { return 'org.silex.ui.components.ComponentBase'; }
}
