<?php

class org_silex_ui_Geometry extends org_silex_ui_UiBase {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		parent::__construct();
	}}
	public $TLcornerRadius;
	public $TRcornerRadius;
	public $BRcornerRadius;
	public $BLcornerRadius;
	public $bgColor;
	public $bgAlpha;
	public $fill;
	public $border;
	public $borderColor;
	public $borderAlpha;
	public $lineThickness;
	public $gradientColors;
	public $gradientRatio;
	public $gradientAlpha;
	public $gradientRotation;
	public $shape;
	public $dropShadow;
	public $dropShadowAlpha;
	public $dropShadowColor;
	public $dropShadowDistance;
	public $dropShadowAngle;
	public $dropShadowBlurX;
	public $dropShadowBlurY;
	public $bitmapFillUrl;
	public $bitmapFillRepeat;
	public $jointStyle;
	public $capsStyle;
	public function returnHTML() {
		$aleaCanvasName = "geomCanvas" . Std::string(Math::round(Math::random() * 1000));
		$res = "<canvas id='" . $aleaCanvasName . "' width='" . $this->width . "' height='" . $this->height . "'>";
		$res .= "</canvas>";
		$res .= "<script type='text/javascript'>";
		$res .= "drawShape('";
		$res .= $this->shape . "','";
		$res .= $aleaCanvasName . "',";
		$res .= $this->width . ",";
		$res .= $this->height . ",";
		$res .= "[" . $this->TLcornerRadius . "," . $this->TRcornerRadius . "," . $this->BRcornerRadius . "," . $this->BLcornerRadius . "]" . ",'";
		$res .= $this->fill . "','";
		$res .= $this->getHexColor($this->bgColor) . "',";
		$res .= $this->bgAlpha . ",";
		$res .= $this->getGradientColors() . ",";
		$res .= $this->getGradientAlphas() . ",";
		$res .= $this->getGradientRatio() . ",";
		$res .= $this->gradientRotation . ",";
		$res .= $this->lineThickness . ",'";
		$res .= $this->jointStyle . "','";
		$res .= $this->capsStyle . "','";
		$res .= $this->getHexColor($this->borderColor) . "',";
		$res .= $this->borderAlpha . ",";
		$res .= $this->getBool($this->border) . ",";
		$res .= $this->getBool($this->dropShadow) . ",";
		$res .= $this->getDropShadowOffsetX() . ",";
		$res .= $this->getDropShadowOffsetY() . ",";
		$res .= $this->dropShadowBlurX . ",'";
		$res .= $this->getHexColor($this->dropShadowColor) . "',";
		$res .= $this->dropShadowAlpha . ",'";
		$res .= $this->bitmapFillUrl . "',";
		$res .= $this->getBool($this->bitmapFillRepeat) . ")";
		$res .= "</script>";
		return $res;
	}
	public function getGradientColors() {
		$res = "[";
		if($this->gradientColors !== null) {
			$_g1 = 0; $_g = $this->gradientColors->length;
			while($_g1 < $_g) {
				$i = $_g1++;
				$res .= "'" . $this->getHexColor($this->gradientColors[$i]) . "'";
				if($i < $this->gradientColors->length - 1) {
					$res .= ",";
				}
				unset($i);
			}
		}
		$res .= "]";
		return $res;
	}
	public function getGradientAlphas() {
		$res = "[";
		if($this->gradientAlpha !== null) {
			$_g1 = 0; $_g = $this->gradientAlpha->length;
			while($_g1 < $_g) {
				$i = $_g1++;
				$res .= $this->gradientAlpha[$i];
				if($i < $this->gradientAlpha->length - 1) {
					$res .= ",";
				}
				unset($i);
			}
		}
		$res .= "]";
		return $res;
	}
	public function getGradientRatio() {
		$res = "[";
		if($this->gradientRatio !== null) {
			$_g1 = 0; $_g = $this->gradientRatio->length;
			while($_g1 < $_g) {
				$i = $_g1++;
				$res .= $this->gradientRatio[$i];
				if($i < $this->gradientRatio->length - 1) {
					$res .= ",";
				}
				unset($i);
			}
		}
		$res .= "]";
		return $res;
	}
	public function getHexColor($color) {
		$hexColor = StringTools::hex($color, null);
		while(strlen($hexColor) < 6) {
			$hexColor = "0" . $hexColor;
		}
		return "#" . $hexColor;
	}
	public function getDropShadowOffsetX() {
		return Math::round(Math::cos($this->dropShadowAngle / 180 * Math::$PI) * $this->dropShadowDistance);
	}
	public function getDropShadowOffsetY() {
		return Math::round(Math::sin($this->dropShadowAngle / 180 * Math::$PI) * $this->dropShadowDistance);
	}
	public function getBool($value) {
		if($value === true) {
			return "true";
		} else {
			return "false";
		}
	}
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->»dynamics[$m]) && is_callable($this->»dynamics[$m]))
			return call_user_func_array($this->»dynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call «'.$m.'»');
	}
	function __toString() { return 'org.silex.ui.Geometry'; }
}
