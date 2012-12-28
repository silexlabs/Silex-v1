<?php

class org_silex_serverApi_FileSystemItem {
	public function __construct() {
		;
	}
	public $itemName;
	public $itemNameNoExtension;
	public $itemLastModificationDate;
	public $itemSize;
	public $itemReadableSize;
	public $itemType;
	public $itemWidth;
	public $itemHeight;
	public $imageType;
	public $ext;
	public $itemContent;
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
	static function parseItem($fileNative) {
		$res = new org_silex_serverApi_FileSystemItem();
		$file = php_Lib::hashOfAssociativeArray($fileNative);
		$res->itemName = $file->get("item name");
		$res->itemType = org_silex_serverApi_FileSystemItem_0($file, $fileNative, $res);
		$»t = $res->itemType;
		switch($»t->index) {
		case 0:
		{
			$res->itemNameNoExtension = $file->get("item name no extension");
			$res->itemLastModificationDate = $file->get("item last modification date");
			$res->itemSize = $file->get("item size");
			$res->itemReadableSize = $file->get("item readable size");
			$res->itemWidth = $file->get("item width");
			$res->itemHeight = $file->get("item height");
			$res->imageType = $file->get("item type");
			$res->ext = $file->get("ext");
		}break;
		case 1:
		{
			$res->itemContent = org_silex_serverApi_FileSystemItem::parseFolderContent($file->get("itemContent"));
		}break;
		}
		return $res;
	}
	static function parseFolderContent($folderContent) {
		$res = new _hx_array(array());
		$folderContent1 = array_values($folderContent);
		$hxFolderContent = new _hx_array($folderContent1);
		{
			$_g = 0;
			while($_g < $hxFolderContent->length) {
				$item = $hxFolderContent[$_g];
				++$_g;
				$res->push(org_silex_serverApi_FileSystemItem::parseItem($item));
				unset($item);
			}
		}
		return $res;
	}
	function __toString() { return 'org.silex.serverApi.FileSystemItem'; }
}
function org_silex_serverApi_FileSystemItem_0(&$file, &$fileNative, &$res) {
	if(_hx_equal($file->get("item type"), "folder")) {
		return org_silex_serverApi_FileSystemItemType::$folder;
	} else {
		return org_silex_serverApi_FileSystemItemType::$file;
	}
}
