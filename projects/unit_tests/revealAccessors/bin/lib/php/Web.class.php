<?php

class php_Web {
	public function __construct(){}
	static function getParams() {
		$GLOBALS['%s']->push("php.Web::getParams");
		$製pos = $GLOBALS['%s']->length;
		$a = array_merge($_GET, $_POST);
		if(get_magic_quotes_gpc()) {
			reset($a); while(list($k, $v) = each($a)) $a[$k] = stripslashes((string)$v);
		}
		{
			$裨mp = php_Lib::hashOfAssociativeArray($a);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getParamValues($param) {
		$GLOBALS['%s']->push("php.Web::getParamValues");
		$製pos = $GLOBALS['%s']->length;
		$reg = new EReg("^" . $param . "(\\[|%5B)([0-9]*?)(\\]|%5D)=(.*?)\$", "");
		$res = new _hx_array(array());
		$explore = array(new _hx_lambda(array(&$param, &$reg, &$res), "php_Web_0"), 'execute');
		call_user_func_array($explore, array(str_replace(";", "&", php_Web::getParamsString())));
		call_user_func_array($explore, array(php_Web::getPostData()));
		if($res->length === 0) {
			$post = php_Lib::hashOfAssociativeArray($_POST);
			$data = $post->get($param);
			$k = 0; $v = "";
			if(is_array($data)) {
				 reset($data); while(list($k, $v) = each($data)) { 
				$res[$k] = $v;
				 } 
			}
		}
		if($res->length === 0) {
			$GLOBALS['%s']->pop();
			return null;
		}
		{
			$GLOBALS['%s']->pop();
			return $res;
		}
		$GLOBALS['%s']->pop();
	}
	static function getHostName() {
		$GLOBALS['%s']->push("php.Web::getHostName");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $_SERVER['SERVER_NAME'];
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getClientIP() {
		$GLOBALS['%s']->push("php.Web::getClientIP");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $_SERVER['REMOTE_ADDR'];
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getURI() {
		$GLOBALS['%s']->push("php.Web::getURI");
		$製pos = $GLOBALS['%s']->length;
		$s = $_SERVER['REQUEST_URI'];
		{
			$裨mp = _hx_array_get(_hx_explode("?", $s), 0);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function redirect($url) {
		$GLOBALS['%s']->push("php.Web::redirect");
		$製pos = $GLOBALS['%s']->length;
		header("Location: " . $url);
		$GLOBALS['%s']->pop();
	}
	static function setHeader($h, $v) {
		$GLOBALS['%s']->push("php.Web::setHeader");
		$製pos = $GLOBALS['%s']->length;
		header($h . ": " . $v);
		$GLOBALS['%s']->pop();
	}
	static function setReturnCode($r) {
		$GLOBALS['%s']->push("php.Web::setReturnCode");
		$製pos = $GLOBALS['%s']->length;
		$code = null;
		switch($r) {
		case 100:{
			$code = "100 Continue";
		}break;
		case 101:{
			$code = "101 Switching Protocols";
		}break;
		case 200:{
			$code = "200 Continue";
		}break;
		case 201:{
			$code = "201 Created";
		}break;
		case 202:{
			$code = "202 Accepted";
		}break;
		case 203:{
			$code = "203 Non-Authoritative Information";
		}break;
		case 204:{
			$code = "204 No Content";
		}break;
		case 205:{
			$code = "205 Reset Content";
		}break;
		case 206:{
			$code = "206 Partial Content";
		}break;
		case 300:{
			$code = "300 Multiple Choices";
		}break;
		case 301:{
			$code = "301 Moved Permanently";
		}break;
		case 302:{
			$code = "302 Found";
		}break;
		case 303:{
			$code = "303 See Other";
		}break;
		case 304:{
			$code = "304 Not Modified";
		}break;
		case 305:{
			$code = "305 Use Proxy";
		}break;
		case 307:{
			$code = "307 Temporary Redirect";
		}break;
		case 400:{
			$code = "400 Bad Request";
		}break;
		case 401:{
			$code = "401 Unauthorized";
		}break;
		case 402:{
			$code = "402 Payment Required";
		}break;
		case 403:{
			$code = "403 Forbidden";
		}break;
		case 404:{
			$code = "404 Not Found";
		}break;
		case 405:{
			$code = "405 Method Not Allowed";
		}break;
		case 406:{
			$code = "406 Not Acceptable";
		}break;
		case 407:{
			$code = "407 Proxy Authentication Required";
		}break;
		case 408:{
			$code = "408 Request Timeout";
		}break;
		case 409:{
			$code = "409 Conflict";
		}break;
		case 410:{
			$code = "410 Gone";
		}break;
		case 411:{
			$code = "411 Length Required";
		}break;
		case 412:{
			$code = "412 Precondition Failed";
		}break;
		case 413:{
			$code = "413 Request Entity Too Large";
		}break;
		case 414:{
			$code = "414 Request-URI Too Long";
		}break;
		case 415:{
			$code = "415 Unsupported Media Type";
		}break;
		case 416:{
			$code = "416 Requested Range Not Satisfiable";
		}break;
		case 417:{
			$code = "417 Expectation Failed";
		}break;
		case 500:{
			$code = "500 Internal Server Error";
		}break;
		case 501:{
			$code = "501 Not Implemented";
		}break;
		case 502:{
			$code = "502 Bad Gateway";
		}break;
		case 503:{
			$code = "503 Service Unavailable";
		}break;
		case 504:{
			$code = "504 Gateway Timeout";
		}break;
		case 505:{
			$code = "505 HTTP Version Not Supported";
		}break;
		default:{
			$code = Std::string($r);
		}break;
		}
		header("HTTP/1.1 " . $code, true, $r);
		$GLOBALS['%s']->pop();
	}
	static function getClientHeader($k) {
		$GLOBALS['%s']->push("php.Web::getClientHeader");
		$製pos = $GLOBALS['%s']->length;
		$k1 = str_replace("-", "_", strtoupper($k));
		if(null == php_Web::getClientHeaders()) throw new HException('null iterable');
		$蜴t = php_Web::getClientHeaders()->iterator();
		while($蜴t->hasNext()) {
			$i = $蜴t->next();
			if($i->header === $k1) {
				$裨mp = $i->value;
				$GLOBALS['%s']->pop();
				return $裨mp;
				unset($裨mp);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return null;
		}
		$GLOBALS['%s']->pop();
	}
	static $_client_headers;
	static function getClientHeaders() {
		$GLOBALS['%s']->push("php.Web::getClientHeaders");
		$製pos = $GLOBALS['%s']->length;
		if(php_Web::$_client_headers === null) {
			php_Web::$_client_headers = new HList();
			$h = php_Lib::hashOfAssociativeArray($_SERVER);
			if(null == $h) throw new HException('null iterable');
			$蜴t = $h->keys();
			while($蜴t->hasNext()) {
				$k = $蜴t->next();
				if(_hx_substr($k, 0, 5) === "HTTP_") {
					php_Web::$_client_headers->add(_hx_anonymous(array("header" => _hx_substr($k, 5, null), "value" => $h->get($k))));
				}
			}
		}
		{
			$裨mp = php_Web::$_client_headers;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getParamsString() {
		$GLOBALS['%s']->push("php.Web::getParamsString");
		$製pos = $GLOBALS['%s']->length;
		if(isset($_SERVER["QUERY_STRING"])) {
			$裨mp = $_SERVER["QUERY_STRING"];
			$GLOBALS['%s']->pop();
			return $裨mp;
		} else {
			$GLOBALS['%s']->pop();
			return "";
		}
		$GLOBALS['%s']->pop();
	}
	static function getPostData() {
		$GLOBALS['%s']->push("php.Web::getPostData");
		$製pos = $GLOBALS['%s']->length;
		$h = fopen("php://input", "r");
		$bsize = 8192;
		$max = 32;
		$data = null;
		$counter = 0;
		while(!(feof($h) && $counter < $max)) {
			$data .= fread($h, $bsize);
			$counter++;
		}
		fclose($h);
		{
			$GLOBALS['%s']->pop();
			return $data;
		}
		$GLOBALS['%s']->pop();
	}
	static function getCookies() {
		$GLOBALS['%s']->push("php.Web::getCookies");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::hashOfAssociativeArray($_COOKIE);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setCookie($key, $value, $expire, $domain, $path, $secure) {
		$GLOBALS['%s']->push("php.Web::setCookie");
		$製pos = $GLOBALS['%s']->length;
		$t = (($expire === null) ? 0 : intval($expire->getTime() / 1000.0));
		if($path === null) {
			$path = "/";
		}
		if($domain === null) {
			$domain = "";
		}
		if($secure === null) {
			$secure = false;
		}
		setcookie($key, $value, $t, $path, $domain, $secure);
		$GLOBALS['%s']->pop();
	}
	static function addPair($name, $value) {
		$GLOBALS['%s']->push("php.Web::addPair");
		$製pos = $GLOBALS['%s']->length;
		if($value === null) {
			$GLOBALS['%s']->pop();
			return "";
		}
		{
			$裨mp = "; " . $name . $value;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getAuthorization() {
		$GLOBALS['%s']->push("php.Web::getAuthorization");
		$製pos = $GLOBALS['%s']->length;
		if(!isset($_SERVER['PHP_AUTH_USER'])) {
			$GLOBALS['%s']->pop();
			return null;
		}
		{
			$裨mp = _hx_anonymous(array("user" => $_SERVER['PHP_AUTH_USER'], "pass" => $_SERVER['PHP_AUTH_PW']));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getCwd() {
		$GLOBALS['%s']->push("php.Web::getCwd");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = dirname($_SERVER["SCRIPT_FILENAME"]) . "/";
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getMultipart($maxSize) {
		$GLOBALS['%s']->push("php.Web::getMultipart");
		$製pos = $GLOBALS['%s']->length;
		$h = new Hash();
		$buf = null;
		$curname = null;
		php_Web::parseMultipart(array(new _hx_lambda(array(&$buf, &$curname, &$h, &$maxSize), "php_Web_1"), 'execute'), array(new _hx_lambda(array(&$buf, &$curname, &$h, &$maxSize), "php_Web_2"), 'execute'));
		if($curname !== null) {
			$h->set($curname, $buf->b);
		}
		{
			$GLOBALS['%s']->pop();
			return $h;
		}
		$GLOBALS['%s']->pop();
	}
	static function parseMultipart($onPart, $onData) {
		$GLOBALS['%s']->push("php.Web::parseMultipart");
		$製pos = $GLOBALS['%s']->length;
		$a = $_POST;
		if(get_magic_quotes_gpc()) {
			reset($a); while(list($k, $v) = each($a)) $a[$k] = stripslashes((string)$v);
		}
		$post = php_Lib::hashOfAssociativeArray($a);
		if(null == $post) throw new HException('null iterable');
		$蜴t = $post->keys();
		while($蜴t->hasNext()) {
			$key = $蜴t->next();
			call_user_func_array($onPart, array($key, ""));
			$v = $post->get($key);
			call_user_func_array($onData, array(haxe_io_Bytes::ofString($v), 0, strlen($v)));
			unset($v);
		}
		if(!isset($_FILES)) {
			$GLOBALS['%s']->pop();
			return;
		}
		$parts = new _hx_array(array_keys($_FILES));
		{
			$_g = 0;
			while($_g < $parts->length) {
				$part = $parts[$_g];
				++$_g;
				$info = $_FILES[$part];
				$tmp = $info["tmp_name"];
				$file = $info["name"];
				$err = $info["error"];
				if($err > 0) {
					switch($err) {
					case 1:{
						throw new HException("The uploaded file exceeds the max size of " . ini_get("upload_max_filesize"));
					}break;
					case 2:{
						throw new HException("The uploaded file exceeds the max file size directive specified in the HTML form (max is" . (ini_get("post_max_size") . ")"));
					}break;
					case 3:{
						throw new HException("The uploaded file was only partially uploaded");
					}break;
					case 4:{
						continue 2;
					}break;
					case 6:{
						throw new HException("Missing a temporary folder");
					}break;
					case 7:{
						throw new HException("Failed to write file to disk");
					}break;
					case 8:{
						throw new HException("File upload stopped by extension");
					}break;
					}
				}
				call_user_func_array($onPart, array($part, $file));
				if("" !== $file) {
					$h = fopen($tmp, "r");
					$bsize = 8192;
					while(!feof($h)) {
						$buf = fread($h, $bsize);
						$size = strlen($buf);
						call_user_func_array($onData, array(haxe_io_Bytes::ofString($buf), 0, $size));
						unset($size,$buf);
					}
					fclose($h);
					unset($h,$bsize);
				}
				unset($tmp,$part,$info,$file,$err);
			}
		}
		$GLOBALS['%s']->pop();
	}
	static function flush() {
		$GLOBALS['%s']->push("php.Web::flush");
		$製pos = $GLOBALS['%s']->length;
		flush();
		$GLOBALS['%s']->pop();
	}
	static function getMethod() {
		$GLOBALS['%s']->push("php.Web::getMethod");
		$製pos = $GLOBALS['%s']->length;
		if(isset($_SERVER['REQUEST_METHOD'])) {
			$裨mp = $_SERVER['REQUEST_METHOD'];
			$GLOBALS['%s']->pop();
			return $裨mp;
		} else {
			$GLOBALS['%s']->pop();
			return null;
		}
		$GLOBALS['%s']->pop();
	}
	static $isModNeko;
	function __toString() { return 'php.Web'; }
}
php_Web::$isModNeko = !php_Lib::isCli();
function php_Web_0(&$param, &$reg, &$res, $data) {
	$製pos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("php.Web::getParamValues@45");
		$製pos2 = $GLOBALS['%s']->length;
		if($data === null || strlen($data) === 0) {
			$GLOBALS['%s']->pop();
			return;
		}
		{
			$_g = 0; $_g1 = _hx_explode("&", $data);
			while($_g < $_g1->length) {
				$part = $_g1[$_g];
				++$_g;
				if($reg->match($part)) {
					$idx = $reg->matched(2);
					$val = urldecode($reg->matched(4));
					if($idx === "") {
						$res->push($val);
					} else {
						$res[Std::parseInt($idx)] = $val;
					}
					unset($val,$idx);
				}
				unset($part);
			}
		}
		$GLOBALS['%s']->pop();
	}
}
function php_Web_1(&$buf, &$curname, &$h, &$maxSize, $p, $_) {
	$製pos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("php.Web::getMultipart@279");
		$製pos2 = $GLOBALS['%s']->length;
		if($curname !== null) {
			$h->set($curname, $buf->b);
		}
		$curname = $p;
		$buf = new StringBuf();
		$maxSize -= strlen($p);
		if($maxSize < 0) {
			throw new HException("Maximum size reached");
		}
		$GLOBALS['%s']->pop();
	}
}
function php_Web_2(&$buf, &$curname, &$h, &$maxSize, $str, $pos, $len) {
	$製pos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("php.Web::getMultipart@287");
		$製pos2 = $GLOBALS['%s']->length;
		$maxSize -= $len;
		if($maxSize < 0) {
			throw new HException("Maximum size reached");
		}
		$buf->b .= _hx_substr($str->toString(), $pos, $len);
		$GLOBALS['%s']->pop();
	}
}
