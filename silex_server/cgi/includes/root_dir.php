<?php
class root_dir
{
	public static function getRootPath()
	{
		return real_path(dirname(__FILE__) . DIRECTORY_SEPARATOR . ".." . DIRECTORY_SEPARATOR . "..") . DIRECTORY_SEPARATOR;
	}
}
?>