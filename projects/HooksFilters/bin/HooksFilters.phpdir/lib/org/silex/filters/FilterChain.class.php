<?php

class org_silex_filters_FilterChain {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("org.silex.filters.FilterChain::new");
		$»spos = $GLOBALS['%s']->length;
		$this->filters = new _hx_array(array());
		$GLOBALS['%s']->pop();
	}}
	public $filters;
	public function applyFilters($value, $context) {
		$GLOBALS['%s']->push("org.silex.filters.FilterChain::applyFilters");
		$»spos = $GLOBALS['%s']->length;
		{
			$_g = 0; $_g1 = $this->filters;
			while($_g < $_g1->length) {
				$filterRecord = $_g1[$_g];
				++$_g;
				$value = $filterRecord->filter($value, $context);
				unset($filterRecord);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $value;
		}
		$GLOBALS['%s']->pop();
	}
	public function addFilter($filter, $priority) {
		$GLOBALS['%s']->push("org.silex.filters.FilterChain::addFilter");
		$»spos = $GLOBALS['%s']->length;
		{
			$_g1 = 0; $_g = $this->filters->length;
			while($_g1 < $_g) {
				$i = $_g1++;
				if(_hx_array_get($this->filters, $i)->priority >= $priority) {
					$this->filters->insert($i, _hx_anonymous(array("priority" => $priority, "filter" => $filter)));
					{
						$GLOBALS['%s']->pop();
						return;
					}
				}
				unset($i);
			}
		}
		$this->filters->push(_hx_anonymous(array("priority" => $priority, "filter" => $filter)));
		$GLOBALS['%s']->pop();
	}
	public function removeFilter($filter) {
		$GLOBALS['%s']->push("org.silex.filters.FilterChain::removeFilter");
		$»spos = $GLOBALS['%s']->length;
		$_g = 0; $_g1 = $this->filters;
		while($_g < $_g1->length) {
			$filterRecord = $_g1[$_g];
			++$_g;
			if($filterRecord->filter === $filter || Reflect::compareMethods((isset($filterRecord->filter) ? $filterRecord->filter: array($filterRecord, "filter")), $filter)) {
				$this->filters->remove($filterRecord);
			}
			unset($filterRecord);
		}
		$GLOBALS['%s']->pop();
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
	function __toString() { return 'org.silex.filters.FilterChain'; }
}
