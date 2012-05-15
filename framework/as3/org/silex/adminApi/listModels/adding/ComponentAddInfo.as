package org.silex.adminApi.listModels.adding
{
	/**
	 * pass this to add item on Components
	 * */
	public class ComponentAddInfo
	{
		public static const TYPE_AUDIO:String = "Audio";
		public static const TYPE_VIDEO:String = "Video";
		public static const TYPE_IMAGE:String = "Image";
		public static const TYPE_TEXT:String = "Text";
		public static const TYPE_FRAMED_LOCATION:String = "FramedLocation";
		public static const TYPE_FRAMED_EMBEDDED_OBJECT:String = "FramedEmbeddedObject";
		public static const TYPE_FRAMED_HTML_TEXT:String = "FramedHtmlText";
		public static const TYPE_COMPONENT:String = "Component";
		
		
		public static const TEXT_COMPONENT_URL:String = "plugins/baseComponents/as2/org.silex.ui.players.Text.swf";
		
		public static const IMAGE_COMPONENT_URL:String = "plugins/baseComponents/as2/org.silex.ui.players.Image.swf";
		
		public static const VIDEO_COMPONENT_URL:String = "plugins/baseComponents/as2/org.silex.ui.players.Video.swf";
		
		public static const AUDIO_COMPONENT_URL:String = "plugins/baseComponents/as2/org.silex.ui.players.Audio.swf";
		
		public static const ASFRAME_COMPONENT_URL:String = "plugins/baseComponents/as2/org.silex.ui.players.AsFrame.swf";
		
		/**
		 * the name of the player instance, that will appear in the component list and that will be used for reference in actions
		 * */
		public var playerName:String;
		
		/**
		 * type of component. see consts above
		 * */
		public var type:String;
		
		/**
		 * meta data. For audio, video, image the url. For framed info the html
		 * 
		 * */
		public var metaData:String;
	}
}