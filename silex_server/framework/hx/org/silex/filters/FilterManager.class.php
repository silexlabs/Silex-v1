<?php

class org_silex_filters_FilterManager {
	public function __construct(){}
	static $filterChains;
	static function applyFilters($value, $context, $chainID) {
		if(org_silex_filters_FilterManager::$filterChains->exists($chainID)) {
			return org_silex_filters_FilterManager::$filterChains->get($chainID)->applyFilters($value, $context);
		} else {
			return $value;
		}
	}
	static function addFilter($chainID, $filter, $priority) {
		if(!org_silex_filters_FilterManager::$filterChains->exists($chainID)) {
			org_silex_filters_FilterManager::$filterChains->set($chainID, new org_silex_filters_FilterChain());
		}
		org_silex_filters_FilterManager::$filterChains->get($chainID)->addFilter($filter, $priority);
	}
	static function removeFilter($chainID, $filter) {
		if(org_silex_filters_FilterManager::$filterChains->exists($chainID)) {
			org_silex_filters_FilterManager::$filterChains->get($chainID)->removeFilter($filter);
		}
	}
	function __toString() { return 'org.silex.filters.FilterManager'; }
}
org_silex_filters_FilterManager::$filterChains = new Hash();
