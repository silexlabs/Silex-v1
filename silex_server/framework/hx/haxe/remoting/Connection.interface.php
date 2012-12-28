<?php

interface haxe_remoting_Connection {
	function call($params);
	function resolve($name);
}
