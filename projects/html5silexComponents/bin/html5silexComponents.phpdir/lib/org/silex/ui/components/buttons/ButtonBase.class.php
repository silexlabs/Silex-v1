<?php

class org_silex_ui_components_buttons_ButtonBase extends org_silex_ui_components_ComponentAnimated {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		parent::__construct();
	}}
	function __toString() { return 'org.silex.ui.components.buttons.ButtonBase'; }
}
