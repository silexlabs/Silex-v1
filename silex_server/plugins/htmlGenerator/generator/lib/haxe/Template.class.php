<?php

class haxe_Template {
	public function __construct($str) {
		if(!php_Boot::$skip_constructor) {
		$tokens = $this->parseTokens($str);
		$this->expr = $this->parseBlock($tokens);
		if(!$tokens->isEmpty()) {
			throw new HException("Unexpected '" . $tokens->first()->s . "'");
		}
	}}
	public $expr;
	public $context;
	public $macros;
	public $stack;
	public $buf;
	public function execute($context, $macros) {
		$this->macros = haxe_Template_0($this, $context, $macros);
		$this->context = $context;
		$this->stack = new HList();
		$this->buf = new StringBuf();
		$this->run($this->expr);
		return $this->buf->b;
	}
	public function resolve($v) {
		if(_hx_has_field($this->context, $v)) {
			return Reflect::field($this->context, $v);
		}
		if(null == $this->stack) throw new HException('null iterable');
		$»it = $this->stack->iterator();
		while($»it->hasNext()) {
			$ctx = $»it->next();
			if(_hx_has_field($ctx, $v)) {
				return Reflect::field($ctx, $v);
			}
		}
		if($v === "__current__") {
			return $this->context;
		}
		return Reflect::field(haxe_Template::$globals, $v);
	}
	public function parseTokens($data) {
		$tokens = new HList();
		while(haxe_Template::$splitter->match($data)) {
			$p = haxe_Template::$splitter->matchedPos();
			if($p->pos > 0) {
				$tokens->add(_hx_anonymous(array("p" => _hx_substr($data, 0, $p->pos), "s" => true, "l" => null)));
			}
			if(_hx_char_code_at($data, $p->pos) === 58) {
				$tokens->add(_hx_anonymous(array("p" => _hx_substr($data, $p->pos + 2, $p->len - 4), "s" => false, "l" => null)));
				$data = haxe_Template::$splitter->matchedRight();
				continue;
			}
			$parp = $p->pos + $p->len;
			$npar = 1;
			while($npar > 0) {
				$c = _hx_char_code_at($data, $parp);
				if($c === 40) {
					$npar++;
				} else {
					if($c === 41) {
						$npar--;
					} else {
						if($c === null) {
							throw new HException("Unclosed macro parenthesis");
						}
					}
				}
				$parp++;
				unset($c);
			}
			$params = _hx_explode(",", _hx_substr($data, $p->pos + $p->len, $parp - ($p->pos + $p->len) - 1));
			$tokens->add(_hx_anonymous(array("p" => haxe_Template::$splitter->matched(2), "s" => false, "l" => $params)));
			$data = _hx_substr($data, $parp, strlen($data) - $parp);
			unset($parp,$params,$p,$npar);
		}
		if(strlen($data) > 0) {
			$tokens->add(_hx_anonymous(array("p" => $data, "s" => true, "l" => null)));
		}
		return $tokens;
	}
	public function parseBlock($tokens) {
		$l = new HList();
		while(true) {
			$t = $tokens->first();
			if($t === null) {
				break;
			}
			if(!$t->s && ($t->p === "end" || $t->p === "else" || _hx_substr($t->p, 0, 7) === "elseif ")) {
				break;
			}
			$l->add($this->parse($tokens));
			unset($t);
		}
		if($l->length === 1) {
			return $l->first();
		}
		return haxe__Template_TemplateExpr::OpBlock($l);
	}
	public function parse($tokens) {
		$t = $tokens->pop();
		$p = $t->p;
		if($t->s) {
			return haxe__Template_TemplateExpr::OpStr($p);
		}
		if($t->l !== null) {
			$pe = new HList();
			{
				$_g = 0; $_g1 = $t->l;
				while($_g < $_g1->length) {
					$p1 = $_g1[$_g];
					++$_g;
					$pe->add($this->parseBlock($this->parseTokens($p1)));
					unset($p1);
				}
			}
			return haxe__Template_TemplateExpr::OpMacro($p, $pe);
		}
		if(_hx_substr($p, 0, 3) === "if ") {
			$p = _hx_substr($p, 3, strlen($p) - 3);
			$e = $this->parseExpr($p);
			$eif = $this->parseBlock($tokens);
			$t1 = $tokens->first();
			$eelse = null;
			if($t1 === null) {
				throw new HException("Unclosed 'if'");
			}
			if($t1->p === "end") {
				$tokens->pop();
				$eelse = null;
			} else {
				if($t1->p === "else") {
					$tokens->pop();
					$eelse = $this->parseBlock($tokens);
					$t1 = $tokens->pop();
					if($t1 === null || $t1->p !== "end") {
						throw new HException("Unclosed 'else'");
					}
				} else {
					$t1->p = _hx_substr($t1->p, 4, strlen($t1->p) - 4);
					$eelse = $this->parse($tokens);
				}
			}
			return haxe__Template_TemplateExpr::OpIf($e, $eif, $eelse);
		}
		if(_hx_substr($p, 0, 8) === "foreach ") {
			$p = _hx_substr($p, 8, strlen($p) - 8);
			$e = $this->parseExpr($p);
			$efor = $this->parseBlock($tokens);
			$t1 = $tokens->pop();
			if($t1 === null || $t1->p !== "end") {
				throw new HException("Unclosed 'foreach'");
			}
			return haxe__Template_TemplateExpr::OpForeach($e, $efor);
		}
		if(haxe_Template::$expr_splitter->match($p)) {
			return haxe__Template_TemplateExpr::OpExpr($this->parseExpr($p));
		}
		return haxe__Template_TemplateExpr::OpVar($p);
	}
	public function parseExpr($data) {
		$l = new HList();
		$expr = $data;
		while(haxe_Template::$expr_splitter->match($data)) {
			$p = haxe_Template::$expr_splitter->matchedPos();
			$k = $p->pos + $p->len;
			if($p->pos !== 0) {
				$l->add(_hx_anonymous(array("p" => _hx_substr($data, 0, $p->pos), "s" => true)));
			}
			$p1 = haxe_Template::$expr_splitter->matched(0);
			$l->add(_hx_anonymous(array("p" => $p1, "s" => _hx_index_of($p1, "\"", null) >= 0)));
			$data = haxe_Template::$expr_splitter->matchedRight();
			unset($p1,$p,$k);
		}
		if(strlen($data) !== 0) {
			$l->add(_hx_anonymous(array("p" => $data, "s" => true)));
		}
		$e = null;
		try {
			$e = $this->makeExpr($l);
			if(!$l->isEmpty()) {
				throw new HException($l->first()->p);
			}
		}catch(Exception $»e) {
			$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
			if(is_string($s = $_ex_)){
				throw new HException("Unexpected '" . $s . "' in " . $expr);
			} else throw $»e;;
		}
		return array(new _hx_lambda(array(&$data, &$e, &$expr, &$l, &$s), "haxe_Template_1"), 'execute');
	}
	public function makeConst($v) {
		haxe_Template::$expr_trim->match($v);
		$v = haxe_Template::$expr_trim->matched(1);
		if(_hx_char_code_at($v, 0) === 34) {
			$str = _hx_substr($v, 1, strlen($v) - 2);
			return array(new _hx_lambda(array(&$str, &$v), "haxe_Template_2"), 'execute');
		}
		if(haxe_Template::$expr_int->match($v)) {
			$i = Std::parseInt($v);
			return array(new _hx_lambda(array(&$i, &$v), "haxe_Template_3"), 'execute');
		}
		if(haxe_Template::$expr_float->match($v)) {
			$f = Std::parseFloat($v);
			return array(new _hx_lambda(array(&$f, &$v), "haxe_Template_4"), 'execute');
		}
		$me = $this;
		return array(new _hx_lambda(array(&$me, &$v), "haxe_Template_5"), 'execute');
	}
	public function makePath($e, $l) {
		$p = $l->first();
		if($p === null || $p->p !== ".") {
			return $e;
		}
		$l->pop();
		$field = $l->pop();
		if($field === null || !$field->s) {
			throw new HException($field->p);
		}
		$f = $field->p;
		haxe_Template::$expr_trim->match($f);
		$f = haxe_Template::$expr_trim->matched(1);
		return $this->makePath(array(new _hx_lambda(array(&$e, &$f, &$field, &$l, &$p), "haxe_Template_6"), 'execute'), $l);
	}
	public function makeExpr($l) {
		return $this->makePath($this->makeExpr2($l), $l);
	}
	public function makeExpr2($l) {
		$p = $l->pop();
		if($p === null) {
			throw new HException("<eof>");
		}
		if($p->s) {
			return $this->makeConst($p->p);
		}
		switch($p->p) {
		case "(":{
			$e1 = $this->makeExpr($l);
			$p1 = $l->pop();
			if($p1 === null || $p1->s) {
				throw new HException($p1->p);
			}
			if($p1->p === ")") {
				return $e1;
			}
			$e2 = $this->makeExpr($l);
			$p2 = $l->pop();
			if($p2 === null || $p2->p !== ")") {
				throw new HException($p2->p);
			}
			return haxe_Template_7($this, $e1, $e2, $l, $p, $p1, $p2);
		}break;
		case "!":{
			$e = $this->makeExpr($l);
			return array(new _hx_lambda(array(&$e, &$l, &$p), "haxe_Template_8"), 'execute');
		}break;
		case "-":{
			$e = $this->makeExpr($l);
			return array(new _hx_lambda(array(&$e, &$l, &$p), "haxe_Template_9"), 'execute');
		}break;
		}
		throw new HException($p->p);
	}
	public function run($e) {
		$»t = $e;
		switch($»t->index) {
		case 0:
		$v = $»t->params[0];
		{
			$this->buf->b .= Std::string($this->resolve($v));
		}break;
		case 1:
		$e1 = $»t->params[0];
		{
			$this->buf->b .= Std::string(call_user_func($e1));
		}break;
		case 2:
		$eelse = $»t->params[2]; $eif = $»t->params[1]; $e1 = $»t->params[0];
		{
			$v = call_user_func($e1);
			if($v === null || _hx_equal($v, false)) {
				if($eelse !== null) {
					$this->run($eelse);
				}
			} else {
				$this->run($eif);
			}
		}break;
		case 3:
		$str = $»t->params[0];
		{
			$this->buf->b .= $str;
		}break;
		case 4:
		$l = $»t->params[0];
		{
			if(null == $l) throw new HException('null iterable');
			$»it = $l->iterator();
			while($»it->hasNext()) {
				$e1 = $»it->next();
				$this->run($e1);
			}
		}break;
		case 5:
		$loop = $»t->params[1]; $e1 = $»t->params[0];
		{
			$v = call_user_func($e1);
			try {
				if(_hx_field($v, "hasNext") === null) {
					$x = $v->iterator();
					if(_hx_field($x, "hasNext") === null) {
						throw new HException(null);
					}
					$v = $x;
				}
			}catch(Exception $»e) {
				$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
				$e2 = $_ex_;
				{
					throw new HException("Cannot iter on " . $v);
				}
			}
			$this->stack->push($this->context);
			$v1 = $v;
			$»it = $v1;
			while($»it->hasNext()) {
				$ctx = $»it->next();
				$this->context = $ctx;
				$this->run($loop);
			}
			$this->context = $this->stack->pop();
		}break;
		case 6:
		$params = $»t->params[1]; $m = $»t->params[0];
		{
			$v = Reflect::field($this->macros, $m);
			$pl = new _hx_array(array());
			$old = $this->buf;
			$pl->push((isset($this->resolve) ? $this->resolve: array($this, "resolve")));
			if(null == $params) throw new HException('null iterable');
			$»it = $params->iterator();
			while($»it->hasNext()) {
				$p = $»it->next();
				$»t2 = $p;
				switch($»t2->index) {
				case 0:
				$v1 = $»t2->params[0];
				{
					$pl->push($this->resolve($v1));
				}break;
				default:{
					$this->buf = new StringBuf();
					$this->run($p);
					$pl->push($this->buf->b);
				}break;
				}
			}
			$this->buf = $old;
			try {
				$this->buf->b .= Std::string(Reflect::callMethod($this->macros, $v, $pl));
			}catch(Exception $»e) {
				$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
				$e1 = $_ex_;
				{
					$plstr = haxe_Template_10($this, $e, $e1, $m, $old, $params, $pl, $v);
					$msg = "Macro call " . $m . "(" . $plstr . ") failed (" . Std::string($e1) . ")";
					throw new HException($msg);
				}
			}
		}break;
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
	static $splitter;
	static $expr_splitter;
	static $expr_trim;
	static $expr_int;
	static $expr_float;
	static function globals() { $»args = func_get_args(); return call_user_func_array(self::$globals, $»args); }
	static $globals;
	function __toString() { return 'haxe.Template'; }
}
haxe_Template::$splitter = new EReg("(::[A-Za-z0-9_ ()&|!+=/><*.\"-]+::|\\\$\\\$([A-Za-z0-9_-]+)\\()", "");
haxe_Template::$expr_splitter = new EReg("(\\(|\\)|[ \x0D\x0A\x09]*\"[^\"]*\"[ \x0D\x0A\x09]*|[!+=/><*.&|-]+)", "");
haxe_Template::$expr_trim = new EReg("^[ ]*([^ ]+)[ ]*\$", "");
haxe_Template::$expr_int = new EReg("^[0-9]+\$", "");
haxe_Template::$expr_float = new EReg("^([+-]?)(?=\\d|,\\d)\\d*(,\\d*)?([Ee]([+-]?\\d+))?\$", "");
haxe_Template::$globals = _hx_anonymous(array());
function haxe_Template_0(&$»this, &$context, &$macros) {
	if($macros === null) {
		return _hx_anonymous(array());
	} else {
		return $macros;
	}
}
function haxe_Template_1(&$data, &$e, &$expr, &$l, &$s) {
	{
		try {
			return call_user_func($e);
		}catch(Exception $»e) {
			$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
			$exc = $_ex_;
			{
				throw new HException("Error : " . Std::string($exc) . " in " . $expr);
			}
		}
	}
}
function haxe_Template_2(&$str, &$v) {
	{
		return $str;
	}
}
function haxe_Template_3(&$i, &$v) {
	{
		return $i;
	}
}
function haxe_Template_4(&$f, &$v) {
	{
		return $f;
	}
}
function haxe_Template_5(&$me, &$v) {
	{
		return $me->resolve($v);
	}
}
function haxe_Template_6(&$e, &$f, &$field, &$l, &$p) {
	{
		return Reflect::field(call_user_func($e), $f);
	}
}
function haxe_Template_7(&$»this, &$e1, &$e2, &$l, &$p, &$p1, &$p2) {
	switch($p1->p) {
	case "+":{
		return array(new _hx_lambda(array(&$e1, &$e2, &$l, &$p, &$p1, &$p2), "haxe_Template_11"), 'execute');
	}break;
	case "-":{
		return array(new _hx_lambda(array(&$e1, &$e2, &$l, &$p, &$p1, &$p2), "haxe_Template_12"), 'execute');
	}break;
	case "*":{
		return array(new _hx_lambda(array(&$e1, &$e2, &$l, &$p, &$p1, &$p2), "haxe_Template_13"), 'execute');
	}break;
	case "/":{
		return array(new _hx_lambda(array(&$e1, &$e2, &$l, &$p, &$p1, &$p2), "haxe_Template_14"), 'execute');
	}break;
	case ">":{
		return array(new _hx_lambda(array(&$e1, &$e2, &$l, &$p, &$p1, &$p2), "haxe_Template_15"), 'execute');
	}break;
	case "<":{
		return array(new _hx_lambda(array(&$e1, &$e2, &$l, &$p, &$p1, &$p2), "haxe_Template_16"), 'execute');
	}break;
	case ">=":{
		return array(new _hx_lambda(array(&$e1, &$e2, &$l, &$p, &$p1, &$p2), "haxe_Template_17"), 'execute');
	}break;
	case "<=":{
		return array(new _hx_lambda(array(&$e1, &$e2, &$l, &$p, &$p1, &$p2), "haxe_Template_18"), 'execute');
	}break;
	case "==":{
		return array(new _hx_lambda(array(&$e1, &$e2, &$l, &$p, &$p1, &$p2), "haxe_Template_19"), 'execute');
	}break;
	case "!=":{
		return array(new _hx_lambda(array(&$e1, &$e2, &$l, &$p, &$p1, &$p2), "haxe_Template_20"), 'execute');
	}break;
	case "&&":{
		return array(new _hx_lambda(array(&$e1, &$e2, &$l, &$p, &$p1, &$p2), "haxe_Template_21"), 'execute');
	}break;
	case "||":{
		return array(new _hx_lambda(array(&$e1, &$e2, &$l, &$p, &$p1, &$p2), "haxe_Template_22"), 'execute');
	}break;
	default:{
		throw new HException("Unknown operation " . $p1->p);
	}break;
	}
}
function haxe_Template_8(&$e, &$l, &$p) {
	{
		$v = call_user_func($e);
		return $v === null || _hx_equal($v, false);
	}
}
function haxe_Template_9(&$e, &$l, &$p) {
	{
		return -call_user_func($e);
	}
}
function haxe_Template_10(&$»this, &$e, &$e1, &$m, &$old, &$params, &$pl, &$v) {
	try {
		return $pl->join(",");
	}catch(Exception $»e) {
		$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
		$e2 = $_ex_;
		{
			return "???";
		}
	}
}
function haxe_Template_11(&$e1, &$e2, &$l, &$p, &$p1, &$p2) {
	{
		return _hx_add(call_user_func($e1), call_user_func($e2));
	}
}
function haxe_Template_12(&$e1, &$e2, &$l, &$p, &$p1, &$p2) {
	{
		return call_user_func($e1) - call_user_func($e2);
	}
}
function haxe_Template_13(&$e1, &$e2, &$l, &$p, &$p1, &$p2) {
	{
		return call_user_func($e1) * call_user_func($e2);
	}
}
function haxe_Template_14(&$e1, &$e2, &$l, &$p, &$p1, &$p2) {
	{
		return call_user_func($e1) / call_user_func($e2);
	}
}
function haxe_Template_15(&$e1, &$e2, &$l, &$p, &$p1, &$p2) {
	{
		return call_user_func($e1) > call_user_func($e2);
	}
}
function haxe_Template_16(&$e1, &$e2, &$l, &$p, &$p1, &$p2) {
	{
		return call_user_func($e1) < call_user_func($e2);
	}
}
function haxe_Template_17(&$e1, &$e2, &$l, &$p, &$p1, &$p2) {
	{
		return call_user_func($e1) >= call_user_func($e2);
	}
}
function haxe_Template_18(&$e1, &$e2, &$l, &$p, &$p1, &$p2) {
	{
		return call_user_func($e1) <= call_user_func($e2);
	}
}
function haxe_Template_19(&$e1, &$e2, &$l, &$p, &$p1, &$p2) {
	{
		return _hx_equal(call_user_func($e1), call_user_func($e2));
	}
}
function haxe_Template_20(&$e1, &$e2, &$l, &$p, &$p1, &$p2) {
	{
		return !_hx_equal(call_user_func($e1), call_user_func($e2));
	}
}
function haxe_Template_21(&$e1, &$e2, &$l, &$p, &$p1, &$p2) {
	{
		return call_user_func($e1) && call_user_func($e2);
	}
}
function haxe_Template_22(&$e1, &$e2, &$l, &$p, &$p1, &$p2) {
	{
		return call_user_func($e1) || call_user_func($e2);
	}
}
