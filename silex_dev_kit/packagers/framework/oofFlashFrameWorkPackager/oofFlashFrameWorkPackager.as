/**
 * This is a utils classes used to compiled all of the Silex As2 Framework
 * classes into a SWC, we need an instance of each class in As2, else the classes won't be
 * compiled into the SWF
 */
class oofFlashFrameWorkPackager
{
	var api:org.silex.core.Api;
	var ContentConnector:org.oof.dataConnectors.remoting.ContentConnector;
	var EmailConnector:org.oof.dataConnectors.remoting.EmailConnector;
	var LoginConnector:org.oof.dataConnectors.remoting.LoginConnector;
	var ExcelConnector:org.oof.dataConnectors.ExcelConnector;
	var RssConnector:org.oof.dataConnectors.RssConnector;
	var XmlConnector:org.oof.dataConnectors.XmlConnector;
	var AudioDisplay:org.oof.dataIos.displays.AudioDisplay;
	var ImageDisplay:org.oof.dataIos.displays.ImageDisplay;
	var RichTextDisplay:org.oof.dataIos.displays.RichTextDisplay;
	var VideoDisplay:org.oof.dataIos.displays.VideoDisplay;
	var TextFieldIo:org.oof.dataIos.stringIos.TextFieldIo;
	var RecordCreator:org.oof.dataUsers.recordWriters.RecordCreator;
	var RecordUpdater:org.oof.dataUsers.recordWriters.RecordUpdater;
	var DataSelector:org.oof.dataUsers.DataSelector;
	var EmailSender:org.oof.dataUsers.EmailSender;
	var LockedIcon:org.oof.dataUsers.LockedIcon;
	var RecordDeleter:org.oof.dataUsers.RecordDeleter;
	var RecordWriter:org.oof.dataUsers.RecordWriter;
	var DraggableRichTextCellRenderer:org.oof.lists.cellRenderers.DraggableRichTextCellRenderer;
	var MediaCellRenderer:org.oof.lists.cellRenderers.MediaCellRenderer;
	var MixedCellRenderer:org.oof.lists.cellRenderers.MixedCellRenderer;
	var RichTextCellRenderer:org.oof.lists.cellRenderers.RichTextCellRenderer;
	var StripeCellRenderer:org.oof.lists.cellRenderers.StripeCellRenderer;
	var ThumbCellRenderer:org.oof.lists.cellRenderers.ThumbCellRenderer;
	var ToggleCellRenderer:org.oof.lists.cellRenderers.ToggleCellRenderer;
	var ListRow:org.oof.lists.ListRow;
	var MediaList:org.oof.lists.MediaList;
	var ReorderableRichTextList:org.oof.lists.ReorderableRichTextList;
	var RichTextList:org.oof.lists.RichTextList;
	var RiszeList:org.oof.lists.RiszeList;
	var RollOverMenuList:org.oof.lists.RollOverMenuList;
	var SlideMenu:org.oof.lists.SlideMenu;
	var SlideMenu2:org.oof.lists.SlideMenu2;
	var ThumbList:org.oof.lists.ThumbList;
	var CheckBox:org.oof.ui.CheckBox;
	var ListScrollBar:org.oof.ui.ListScrollBar;
	var ListUi:org.oof.ui.ListUi;
	var PlayListUi:org.oof.ui.PlayListUi;
	var VisualTimer:org.oof.ui.VisualTimer;
	var CookieComponent:org.oof.util.CookieComponent;
	
	function oofFlashFrameWorkPackager()
	{
		
	}
	
}