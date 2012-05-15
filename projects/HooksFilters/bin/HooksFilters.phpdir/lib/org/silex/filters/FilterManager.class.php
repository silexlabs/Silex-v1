<?php

class org_silex_filters_FilterManager {
	public function __construct(){}
	static $filterChains;
	static function applyFilters($value, $context, $chainID) {
		$GLOBALS['%s']->push("org.silex.filters.FilterManager::applyFilters");
		$»spos = $GLOBALS['%s']->length;
		if(org_silex_filters_FilterManager::$filterChains->exists($chainID)) {
			{
				$»tmp = org_silex_filters_FilterManager::$filterChains->get($chainID)->applyFilters($value, $context);
				$GLOBALS['%s']->pop();
				return $»tmp;
			}
		} else {
			{
				$GLOBALS['%s']->pop();
				return $value;
			}
		}
		$GLOBALS['%s']->pop();
	}
	static function addFilter($chainID, $filter, $priority) {
		$GLOBALS['%s']->push("org.silex.filters.FilterManager::addFilter");
		$»spos = $GLOBALS['%s']->length;
		if(!org_silex_filters_FilterManager::$filterChains->exists($chainID)) {
			org_silex_filters_FilterManager::$filterChains->set($chainID, new org_silex_filters_FilterChain());
		}
		org_silex_filters_FilterManager::$filterChains->get($chainID)->addFilter($filter, $priority);
		$GLOBALS['%s']->pop();
	}
	static function removeFilter($chainID, $filter) {
		$GLOBALS['%s']->push("org.silex.filters.FilterManager::removeFilter");
		$»spos = $GLOBALS['%s']->length;
		if(org_silex_filters_FilterManager::$filterChains->exists($chainID)) {
			org_silex_filters_FilterManager::$filterChains->get($chainID)->removeFilter($filter);
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'org.silex.filters.FilterManager'; }
}
{
	org_silex_filters_FilterManager::$filterChains = new Hash();
}
