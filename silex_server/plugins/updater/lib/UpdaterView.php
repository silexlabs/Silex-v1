<?php
/*
	Class: UpdaterView
	This is the View class, containing all functions useful and reusable in the views
*/
require_once "./lib/lib_updater.php";

class UpdaterView
{
	/*
		Variable: view
		The phtml file to render
	*/
	private $view;
	
	private $logger;
	
	private $localisedStrings;
	
	/*
		Function: __construct
		Constructor for the view class.
	*/
	function __construct($newView)
	{
		$this->logger = new logger("UpdaterView");
		
		$this->view = $newView;
		
		$langManager = LangManager::getInstance();
		$localisedFileUrl = $langManager->getLangFile($_POST["plugin_name"], "en");
		$this->localisedStrings = $langManager->getLangObject($_POST["plugin_name"], $localisedFileUrl);
	}
	
	/*
		Function: render
		Render the view
	*/
	public function render()
	{
		include("./view/".$this->getView().".phtml");
	}
	
	/*
	   Function: generateForwarding
	   Prints the Ajax code necessary to creates a forwarding (to use in a link, button, or a <script> tag for automatic forwarding)

	   Parameters:
		$parameters - optional, an array containing parameters (name & value) to forward in POST.
		$pageParams - optional, an array containing the params to extract from the page. This array should contain references to dom objects that should be serializable by JQuery (forms, inputs...). This function makes the call to the serialize method and just need the name of class or id of form/dom element to serialize.
		$loadingMessage - optional, a message that will be printed during the loading of the next action/page. All the ' chars will be removed from it in this function. If $loadingMessage === false, no loading message is printed
	*/
	public function generateForwarding($parameters=null, $pageParams=null, $loadingMessage=null)
	{
		// the plugin's parameters are passed by default
		$params = "'plugin_name=".$_POST["plugin_name"]."&update_server_address=".$_POST["update_server_address"]."&exchange_platform_address=".$_POST["exchange_platform_address"]."'";
		
		if(!empty($parameters))
			foreach($parameters as $paramName => $paramValue)
				$params .= "+'&$paramName=".urlencode($paramValue)."'";
		
		if(!empty($pageParams))
			foreach($pageParams as $pageParam)
				$params .= "+'&'+$('".$pageParam."').serialize()";
		
		$forwarding = "$.post( 'plugins/".$_POST["plugin_name"]."/updater.php', ".$params." , function(data) { $('#".$_POST["plugin_name"]."').html(data); } ); $('#headers_".$_POST["plugin_name"]."').html('');";
		
		if($loadingMessage !== false)
		{
			$loadingScreenMessage = "<span class=updater_text>".$this->localisedStrings["GENERAL_LOADING_MSG"]."</span>";
			if(isset($loadingMessage))
				$loadingScreenMessage = $loadingMessage;
			
			$forwarding .= " $('#".$_POST["plugin_name"]."').html('<div class=loading_screen>".str_replace("'", "", $loadingScreenMessage)."</div>');";
		}
		
		print $forwarding;
	}
	
	/*
	   Function: addToHeaders
	   Print the javascript code to add stuff in updater's headers area (important messages...)

	   Parameters:
		$headerString - the HTML code you want to add in the updater's headers zone. All the ' chars will be removed from it in this function.
	*/
	public static function addToHeaders($headerString)
	{
		print "<script type='text/javascript'>$('#headers_".$_POST["plugin_name"]."').append('".str_replace("'", "", $headerString)."');</script>";
	}
	
	/*
	   Function: displayFileToUpdate
	   Prints a line corresponding to a file in the pre update report

	   Parameters:
		  &$fileCount - a reference to the current file count
		  $itemToUpdate - A FileModel object to be printed
		  $userModifiedFiles - optional, a list of FileModels that should be marked as modifyied by the user
		  $customArgs - optional, an associative array of custom args to include in the "file to update" information
	*/
	function displayFileToUpdate(&$fileCount, $itemToUpdate, $userModifiedFiles=null, $customArgs=null, $checkBoxChoice=true)
	{
		$fileCount++; $userModified = ""; $updateCheckbox = "";
		
		if($userModifiedFiles != null)
		{
			$i = 0;
			$userModifiedFilesCount = count($userModifiedFiles);
			while($i < $userModifiedFilesCount && $userModifiedFiles[$i]->path.$userModifiedFiles[$i]->name != $itemToUpdate->path.$itemToUpdate->name)
				$i++;
			
			if($i < $userModifiedFilesCount)
				$userModified = "listUserModifyied ";
		}
		
		if($checkBoxChoice)
		{
			if($itemToUpdate->updateRequired == "false")
				$updateCheckbox = "<input class='update' name='".$fileCount."_file_update' type='checkbox' value='1' title='uncheck it if you do not want to update ".$itemToUpdate->path.$itemToUpdate->name."' checked />";
			else
				$updateCheckbox = "<input class='update' type='hidden' name='".$fileCount."_file_update' value='1' /><input type='checkbox' checked disabled />";
		}
		
		$itemPath = "<input class='update' type='hidden' name='".$fileCount."_file_signature' value='".$itemToUpdate->signature."' />";
		
		$itemPath .= "<input class='update' type='hidden' name='".$fileCount."_file_path' value='".$itemToUpdate->path.$itemToUpdate->name."' />".$itemToUpdate->path.$itemToUpdate->name;
		
		if(!empty($customArgs))
			foreach( $customArgs as $key => $value )
				$itemPath .= "<input class='update' type='hidden' name='".$fileCount."_file_".$key."' value='".$value."' />";
		
		print "<div class='updater_listLine $userModified'>".
				"<div class='updater_listPath updater_listPathLine'><span><img src='plugins/updater/img/file_01.png' alt='file ' /></span> $itemPath</div>".
				"<div class='updater_listCheckbox'>$updateCheckbox</div>".
				"<div class='updater_clearBoth'></div>".
			"</div>";
	}

	/*
	   Function: displayFolderToUpdate
	   Prints the lines corresponding to a folder in the pre update report

	   Parameters:
		  &$folderCount - a reference to the current folder count
		  &$fileCount - a reference to the current file count
		  $itemToUpdate - A FolderModel object to be printed
		  $userModifiedFiles - optional, a list of FileModels that should be marked as modifyied by the user
		  $customArgs - optional, an associative array of custom args to include in the "folder to update" information
	*/
	function displayFolderToUpdate(&$folderCount, &$fileCount, $itemToUpdate, $userModifiedFiles=null, $customArgs=null, $checkBoxChoice=true)
	{
		$folderCount++;
		
		$itemPath = "<input class='update' type='hidden' name='".$folderCount."_folder_path' value='".$itemToUpdate->path.$itemToUpdate->name."' />".$itemToUpdate->path.$itemToUpdate->name;
		
		if(!empty($customArgs))
			foreach( $customArgs as $key => $value )
				$itemPath .= "<input class='update' type='hidden' name='".$folderCount."_folder_".$key."' value='".$value."' />";
		
		print "<div>".
					"<div class='updater_listPath updater_listPathLine'><span><img src='plugins/updater/img/directory_01.png' alt='directory ' /></span> $itemPath</div>".
					"<div class='updater_clearBoth'></div>".
				"</div>";
		
		if(!empty($itemToUpdate->folders))
			foreach($itemToUpdate->folders as $innerFolder)
				$this->displayFolderToUpdate($folderCount, $fileCount, $innerFolder, $userModifiedFiles, $customArgs, $checkBoxChoice);
		
		if(!empty($itemToUpdate->files))
			foreach($itemToUpdate->files as $innerFile)
				$this->displayFileToUpdate($fileCount, $innerFile, $userModifiedFiles, $customArgs, $checkBoxChoice);
	}

	/*
	   Function: displayFileToDelete
	   Prints a line corresponding to a file to delete in the pre update report

	   Parameters:
		  &$deleteCount - a reference to the current item to delete count
		  $itemToDelete - A FileModel object to be printed
	*/
	function displayFileToDelete(&$deleteCount, $itemToDelete, $checkBoxChoice=true)
	{
		$deleteCount++;
		
		$fileToDelete = "<div>".
			"<div class='updater_listPath updater_listPathLine'><input class='delete' name='".$deleteCount."_delete_path' value='".$itemToDelete->path.$itemToDelete->name."' type='hidden' ><span><img src='plugins/updater/img/file_04.png' alt='file ' /></span> ".$itemToDelete->path.$itemToDelete->name."</div>";
		
		if($checkBoxChoice)
			$fileToDelete .= "<div class='updater_listCheckbox'><input class='delete' name='".$deleteCount."_keep' type='checkbox' value='1' title='check it if you want to keep ".$itemToDelete->path.$itemToDelete->name."' ></div>";
		
		$fileToDelete .= "<div class='updater_clearBoth'></div>".
			"</div>";
		
		print $fileToDelete;
	}

	/*
	   Function: displayFolderToDelete
	   Prints the lines corresponding to a folder to delete in the pre update report

	   Parameters:
		  &$deleteCount - a reference to the current item to delete count
		  $itemToDelete - A FolderModel object to be printed
	*/
	function displayFolderToDelete(&$deleteCount, $itemToDelete, $checkBoxChoice=true)
	{
		$deleteCount++;
		
		$folderTodelete = "<div>".
			"<div class='updater_listPath updater_listPathLine'><input class='delete' name='".$deleteCount."_delete_path' value='".$itemToDelete->path.$itemToDelete->name."' type='hidden' ><span><img src='plugins/updater/img/directory_04.png' alt='directory ' /></span> ".$itemToDelete->path.$itemToDelete->name."</div>";
			
		if($checkBoxChoice)
			$folderTodelete .= "<div class='updater_listCheckbox'><input class='delete' name='".$deleteCount."_keep' type='checkbox' value='1' title='check it if you want to keep ".$itemToDelete->path.$itemToDelete->name."' ></div>";
		
		$folderTodelete .= "<div class='updater_clearBoth'></div>".
			"</div>";
		
		print $folderTodelete;
		
		foreach($itemToDelete->folders as $folderToDelete)
		{
			$this->displayFolderToDelete($deleteCount, $folderToDelete, $checkBoxChoice);
		}
		foreach($itemToDelete->files as $fileToDelete)
		{
			$this->displayFileToDelete($deleteCount, $fileToDelete, $checkBoxChoice);
		}
	}
	
	/*
	   Function: generateProgressBar
	   Prints a progress bar

	   Parameters:
		  $progressLevel - the percentage of progress to show
		  $progressLabel - optional, the message appearing within the bar
		  $message - optional, the message appearing above the bar 
	*/
	function generateProgressBar( $progressLevel, $progressLabel=null, $message=null )
	{
		if($message != null)
			print "<div class='updater_progressBarMessage'>".$message."</div>";
				
		print "<div class='updater_progressBar'>".
				"<div class='updater_innerProgressBar' style='width:".$progressLevel."%;'></div>".
				"<div class='updater_progressBarLabel'>".$progressLabel."</div>".
			"</div>";
	}

	
	public function setView($newView)
	{
		$this->view = $newView;
	}
	
	public function getView()
	{
		return $this->view;
	}
	
}

?>