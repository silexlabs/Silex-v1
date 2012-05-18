<?php

if(version_compare(PHP_VERSION, '5.1.0', '<')) {
    exit('Your current PHP version is: ' . PHP_VERSION . '. haXe/PHP generates code for version 5.1.0 or later. Try running <a href="./install/">Silex installer</a> to solve the problem.');
}
;
require_once dirname(__FILE__).'/framework/hx/php/Boot.class.php';

org_silex_html_SilexIndex::main();

?>