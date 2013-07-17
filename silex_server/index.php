<?php

if(version_compare(PHP_VERSION, '5.1.0', '<')) {
    exit('Your current PHP version is: ' . PHP_VERSION . '. haXe/PHP generates code for version 5.1.0 or later. Try running <a href="./install/">Silex installer</a> to solve the problem.');
}
if(!version_compare(PHP_VERSION, '5.4.0', '<')) {
    exit('Your current PHP version is: ' . PHP_VERSION . '. Silex v1 is compatible with versions prior to 5.4.0. We are sorry about that, look for <a href="http://www.silexlabs.org/silex/">Silex v2 on Silex Labs</a> to solve the problem.');
}

require_once dirname(__FILE__).'/framework/hx/php/Boot.class.php';

org_silex_html_SilexIndex::main();

?>