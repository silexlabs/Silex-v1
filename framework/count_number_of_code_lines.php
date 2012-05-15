<?php
 
	/**
	 * Counts the lines of code in this folder and all sub folders
	 * You may not sell this script or remove these header comments
	 * @author Hamid Alipour, http://blog.code-head.com/
	**/
 
	define('SHOW_DETAILS', true);
 
	class Folder {
 
		var $name;
		var $path;
		var $folders;
		var $files;
		var $exclude_extensions;
		var $exclude_files;
		var $exclude_folders;
 
 
		function Folder($path) {
			$this -> path 		= $path;
			$this -> name		= array_pop( array_filter( explode(DIRECTORY_SEPARATOR, $path) ) );
			$this -> folders 	= array();
			$this -> files		= array();
			$this -> exclude_extensions = array('gif', 'jpg', 'jpeg', 'png', 'mp3', 'bmp', 'ico', 'fla', 'flv', 'swf', 'xml', 'txt', 'orig', 'as2proj', 'zinc');
			$this -> exclude_files 	    = array('readme.txt');
			$this -> exclude_folders 	 = array('.svn');
		}
 
		function count_lines() {
			if( defined('SHOW_DETAILS') ) echo "/Folder: {$this -> path}...<BR>\n";
			$total_lines = 0;
			$this -> get_contents();
			foreach($this -> files as $file) {
				if( in_array($file -> ext, $this -> exclude_extensions) || in_array($file -> name, $this -> exclude_files) ) {
					if( defined('SHOW_DETAILS') ) echo "#---Skipping File: {$file -> name};<BR>\n";
					continue;
				}
				$total_lines += $file -> get_num_lines();
			}
			foreach($this -> folders as $folder) {
				if( in_array($folder -> name, $this -> exclude_folders) ) {
					if( defined('SHOW_DETAILS') ) echo "#Skipping Folder: {$folder -> name};<BR>\n";
					continue;
				}
				$total_lines += $folder -> count_lines();
			}
			if( defined('SHOW_DETAILS') ) echo "<BR>\n Total lines in {$this -> name}: $total_lines;<BR>\n<BR>\n";
			return $total_lines;
		}
 
		function get_contents() {
			$contents = $this -> _get_contents();
			foreach($contents as $key => $value) {
				if( $value['type'] == 'Folder' ) {
					$this -> folders[] = new Folder($value['item']);
				} else {
					$this -> files[]   = new File  ($value['item']);
				}
			}
		}
 
		function _get_contents() {
			$folder = $this -> path;
			if( !is_dir($folder) ) {
				return array();
			}
			$return_array = array();
			$count		  = 0;
			if( $dh = opendir($folder) ) {
				while( ($file = readdir($dh)) !== false ) {
					if( $file == '.' || $file == '..' ) continue;
					$return_array[$count]['item']	= $folder .$file .(is_dir($folder .$file) ? DIRECTORY_SEPARATOR : '');
					$return_array[$count]['type']	= is_dir($folder .$file) ? 'Folder' : 'File';
					$count++;
				}
				closedir($dh);
			}
			return $return_array;
		}
 
	} // Class
 
	class File {
 
		var $name;
		var $path;
		var $ext;
 
 
		function File($path) {
			$this -> path = $path;
			$this -> name = basename($path);
			$this -> ext  = array_pop( explode('.', $this -> name) );
		}
 
		function get_num_lines() {
			$count_lines = count(file($this -> path));
			if( defined('SHOW_DETAILS') ) echo "|---File: {$this -> name}, lines: $count_lines;<BR>\n";
			return $count_lines;
		}
 
	} // Class
 
	$path_to_here = dirname(__FILE__) .DIRECTORY_SEPARATOR;
	$folder 		  = new Folder($path_to_here);
	echo 'Total lines of codes: ' .$folder -> count_lines() . "<BR>\n<BR>\n";
 
?>