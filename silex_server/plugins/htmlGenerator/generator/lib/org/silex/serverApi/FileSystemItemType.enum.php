<?php

class org_silex_serverApi_FileSystemItemType extends Enum {
	public static $file;
	public static $folder;
	public static $__constructors = array(0 => 'file', 1 => 'folder');
	}
org_silex_serverApi_FileSystemItemType::$file = new org_silex_serverApi_FileSystemItemType("file", 0);
org_silex_serverApi_FileSystemItemType::$folder = new org_silex_serverApi_FileSystemItemType("folder", 1);
