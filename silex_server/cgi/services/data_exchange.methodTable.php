<?php 
	$this->methodTable = array(
		"listToolsFolderContent" => array(
			"description" => "list tools folder content",
			"arguments" => array("path" => array("type" => "string","required" => true)),
			"access" => "remote",
			"returns" => "array"
		),
		"listFtpFolderContent" => array(
			"description" => "list ftp folder content",
			"arguments" => array("path" => array("type" => "string","required" => true),"isRecursive" => array("type" => "boolean","required" => false)),
			"access" => "remote",
			"returns" => "array"
		),
		"createFtpFolder" => array(
			"description" => "create a new folder in given path",
			"arguments" => array("path" => array("type" => "string","required" => true), "newFolderName"=>array("type" => "string","required" => true) ),
			"access" => "remote",
			"returns" => "string"
		),
		"renameFtpItem" => array(
			"description" => "rename a folder or file in given path",
			"arguments" => array("path" => array("type" => "string","required" => true), "oldItemName"=>array("type" => "string","required" => true) , "newItemName"=>array("type" => "string","required" => true) ),
			"access" => "remote",
			"returns" => "string"
		),
		"deleteFtpItem" => array(
			"description" => "delete a folder or file in given path",
			"arguments" => array("path" => array("type" => "string","required" => true) , "item" => array("type" => "string","required" => true) ),
			"access" => "remote",
			"returns" => "string"
		),
		"uploadFtpItem" => array(
			"description" => "upload a file",
			"arguments" => array("path" => array("type" => "string","required" => true),"filename" => array("type" => "string","required" => true)),
			"access" => "remote",
			"returns" => "string"
		),
		"listWebsiteFolderContent" => array(
			"description" => "list all xml files in the current website's content folder",
			"arguments" => array("id_site" => array("type" => "string","required" => true)),
			"access" => "remote",
			"returns" => "array"
		),
		"getLanguagesList" => array(
			"description" => "list all files in the lang folder and returns it as a string. used by the manager and by index.php",
			"access" => "remote",
			"returns" => "string"
		),
		"listLanguageFolderContent" => array(
			"description" => "list all files in the lang folder",
			"access" => "remote",
			"returns" => "array"
		),
		"listFolderContent" => array(
			"description" => "list a folder content",
			"arguments" => array("path" => array("type" => "string","required" => true), "isRecursive" => array("type" => "boolean","required" => false), 
							"filter" => array("type" => "array", "required" => false ), "orderBy" => array("type" => "string", "required" => false), 
							"reverseOrder" => array("type" => "boolean", "required" => false)),
			"access" => "remote",
			"returns" => "array"
		),
		"getFolderSize" => array(
			"description" => "returns the size of a folder in a readable form",
			"arguments" => array("path" => array("type" => "string","required" => true)),
			"access" => "remote",
			"returns" => "string"
		),
		"getDynData" => array(
			"description" => "returns an array containing the data corresponding to the apps . The data returned could be passed through javascript setVariable but it would result in a huge index.php file. Which is not good for SEO and for user experience.",
			"arguments" => array("wesiteInfo" => array("type" => "object","required" => true),"filesList" => array("type" => "array","required" => false)),
			"access" => "remote",//"private",//
			"returns" => "array"
		),
		"getWebsiteConfig" => array(
			"description" => "read a website config file and the server config",
			"arguments" => array("id_site" => array("type" => "string","required" => true),"mergeWithServerConfig" => array("type" => "string","required" => false)),
			"access" => "remote",
			"returns" => "array"
		),
		"deleteWebsite" => array(
			"description" => "delete a website",
			"arguments" => array("id_site"),
			"access" => "remote",
			"roles" => AUTH_ROLE_USER,
			"returns" => "boolean"
		),
		"renameWebsite" => array(
			"description" => "rename a website",
			"arguments" => array("old_id_site","new_id_site"),
			"access" => "remote",
			"roles" => AUTH_ROLE_USER,
			"returns" => "boolean"
		),
		"createWebsite" => array(
			"description" => "create a website",
			"arguments" => array("id_site"),
			"access" => "remote",
			"roles" => AUTH_ROLE_USER,
			"returns" => "boolean"
		),
		"writeWebsiteConfig" => array(
			"description" => "write into a website config file or to create a website",
			"arguments" => array("websiteInfo", "id_site"),
			"access" => "remote",
			"roles" => AUTH_ROLE_USER,
			"returns" => "boolean"
		),
		"duplicateWebsite" => array(
			"description" => "No description given.",
			"arguments" => array("id_site", "newName"),
			"access" => "remote",
			"roles" => AUTH_ROLE_USER,
			"returns" => "string"
		),
		"moveWebsiteInThemes" => array(
			"description" => "No description given.",
			"arguments" => array("id_site", "themeName"),
			"access" => "remote",
			"roles" => AUTH_ROLE_USER,
			"returns" => "string"
		),
		"doDuplicateWebsite" => array(
			"description" => "duplicate a website folder",
			"arguments" => array("folder", "newFolder"),
			"access" => "private"
		),
		"writeSectionData" => array(
			"description" => "write xml data to a file and store html data in db",
			"arguments" => array("xmlData", "xmlFileName", "sectionName", "id_site", "seoObject", "domObject"),
			"access" => "remote",//"private",//
			"roles" => AUTH_ROLE_USER,
			"returns" => "string"
		), 
		"renameSection" => array(
			"description" => "rename all files corresponding to a site's section",
			"arguments" => array("siteName" => array("type" => "string","required" => true), "oldSectionName" => array("type" => "string","required" => true), "newSectionName" => array("type" => "string","required" => true)),
			"access" => "remote",//"private",//
			"roles" => AUTH_ROLE_USER
		), 
		"duplicateSection" => array(
			"description" => "duplicate all files corresponding to a site's section",
			"arguments" => array("siteName" => array("type" => "string","required" => true), "oldSectionName" => array("type" => "string","required" => true), "newSectionName" => array("type" => "string","required" => true)),
			"access" => "remote",//"private",//
			"roles" => AUTH_ROLE_USER
		), 
		"createSection" => array(
			"description" => "create an empty xml file or duplicate from existing template",
			"arguments" => array("siteName" => array("type" => "string","required" => true), "newSectionName" => array("type" => "string","required" => true)),
			"access" => "remote",//"private",//
			"roles" => AUTH_ROLE_USER
		), 
		"deleteSection" => array(
			"description" => "delete a page - delete the preview of the page if there is one (jpg or png)",
			"arguments" => array("siteName" => array("type" => "string","required" => true), "sectionName" => array("type" => "string","required" => true)),
			"access" => "remote",//"private",//
			"roles" => AUTH_ROLE_USER
		), 
		"savePublicationStructure" => array(
			"description" => "save the structure of the publication<br />usually XML data comes from the PublicationStructureEditor (flex) directly<br />save a .draft.xml (structure with the deactivated pages) and a .xml (structure without the deactivated pages)",
			"arguments" => array("siteName" => array("type" => "string","required" => true), "xmlContent" => array("type" => "string","required" => true), "xmlContentPublished" => array("type" => "string","required" => true)),
			"access" => "remote",//"private",//
			"roles" => AUTH_ROLE_USER
		), 
		"loadPublicationStructure" => array(
			"description" => "returns the .draft.xml (structure with the deactivated pages)",
			"arguments" => array("siteName" => array("type" => "string","required" => true),"isPublishedVersion" => array("type" => "boolean","required" => false)),
			"access" => "remote",//"private",//
		), 
		"readConfigFile" => array(
			"description" => "read a config file",
			"arguments" => array("filePath" => array("type" => "string","required" => true), "fileFormat" => array("type" => "string","required" => true)),
			"access" => "remote",
			"returns" => "array"
		),
		"updateConfigFile" => array(
			"description" => "update a config file. doesn't create it(yet?)",
			"arguments" => array("filePath" => array("type" => "string","required" => true), "fileFormat" => array("type" => "string","required" => true),"dataToMerge" => array("type" => "array","required" => true)),
			"access" => "remote",
			"roles" => AUTH_ROLE_USER,
			"returns" => "boolean"
		),
		"getLogins" => array(
			"description" => "get logins array, data provider",
			"access" => "remote",
			"roles" => AUTH_ROLE_USER,
			"returns" => "array"
		),
		"setPassword" => array(
			"description" => "set a password",
			"arguments" => array("login" => array("type" => "string","required" => true), "password" => array("type" => "string","required" => true)),
			"access" => "remote",
			"roles" => AUTH_ROLE_USER
		),
		"deleteAccount" => array(
			"description" => "delete an account",
			"arguments" => array("login" => array("type" => "string","required" => true)),
			"access" => "remote",
			"roles" => AUTH_ROLE_USER
		),
		"doLogin" => array(
			"description" => "check login and read role in silex_users database",
			"access" => "remote",
			"roles" => AUTH_ROLE_USER,
			"returns" => "boolean"
		),
		"doLogout" => array(
			"description" => "logout",
			"access" => "remote",
			"returns" => "boolean"
		),
		"getSiteThumb" => array(
			"description" => "returns the preview image of a site",
			"arguments" => array("siteName" => array("type" => "string","required" => true)),
			"access" => "remote",
			"returns" => "array"
		),
		"getPluginParameters" => array(
			"description" => "returns the information about the configuration parameters for a given plugin",
			"arguments" => array("pluginName" => array("type" => "string","required" => true), "conf" => array("type" => "array","required" => true)),
			"access" => "remote",
			"returns" => "array"
		),
		"getPluginAdminPage" => array(
			"description" => "returns the html code to use/administrate a plugin",
			"arguments" => array("pluginName" => array("type" => "string","required" => true), "conf" => array("type" => "array","required" => true), "siteName" => array("type" => "string","required" => false)),
			"access" => "remote",
			"returns" => "string"
		),
		"getInstalledPluginsList" => array(
			"description" => "returns the list of installed plugins for a given scope",
			"arguments" => array("scope" => array("type" => "integer","required" => true), "conf" => array("type" => "array","required" => false)),
			"access" => "remote",
			"returns" => "array"
		),
		"getComponentDescriptors" => array(
			"description" => "get all the component descriptors for the components available in the active plugins",
			"access" => "remote",
			"returns" => "array"
		),
		"getFonts" => array(
			"description" => "get the list of fonts installed on the server",
			"access" => "remote",
			"returns" => "array"
		)
	);
?>