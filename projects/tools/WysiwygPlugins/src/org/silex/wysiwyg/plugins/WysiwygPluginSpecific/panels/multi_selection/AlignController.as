package org.silex.wysiwyg.plugins.WysiwygPluginSpecific.panels.multi_selection
{		
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.adminApi.listedObjects.Property;
	import org.silex.wysiwyg.event.PluginEvent;
	import org.silex.wysiwyg.plugins.WysiwygPluginSpecific.SpecificPluginController;
	
	public class AlignController extends EventDispatcher
	{
		/**
		 * static const variable for align up or distribute up 
		 */
		public static const UP:String = "up";			
		/**
		 *static const variable for align down or distribute down 
		 */
		public static const DOWN:String = "down";			
		/**
		 *static const variable for align horiCenter or distribute horiCenter 
		 */	
		public static const HORIZONTAL_CENTER:String = "horiCenter";						
		/**
		 *static const variable for align left or distribute left 
		 */
		public static const LEFT:String = "left";		
		/**
		 *static const variable for align right or distribute right 
		 */
		public static const RIGHT:String = "right";			
		/**
		 *static const variable for align vertiCenter or distribute vertiCenter 
		 */
		public static const VERTI_CENTER:String = "vertiCenter";	
		/**
		 *parameter for function adjustWidth Handler
		 */	
		public static const ADJUST_WIDTH:String = "adjustWidth";
		/**
		 *parameter for function adjustHeight Handler
		 */	
		public static const ADJUST_HEIGHT:String = "adjustHeight";
		/**
		 *parameter for function adjustSize Handler
		 */	
		public static const ADJUST_SIZE:String = "adjustSize";	
		/**
		 *parameter for function spaceHori Handler
		 */
		public static const SPACE_HORIZONTAL:String = "spaceHorizontal";
		/**
		 *parameter for function spaceVerti Handler
		 */
		public static const SPACE_VERTICAL:String = "spaceVertical";
		/**
		 * parameter _x
		 * */
		public static const PROPNAME_X = "x";
		/**
		 * parameter _y
		 * */
		public static const PROPNAME_Y = "y";
		/**
		 * parameter width
		 * */
		public static const PROPNAME_WIDTH = "width";
		/**
		 * parameter height
		 * */
		public static const PROPNAME_HEIGHT = "height";	
		/**
		 * silex conf information obj
		 */
		private var conf:Object = SilexAdminApi.getInstance().publicationModel.getConf();
		/**
		 *layout stage width
		 */
		var layoutStageWidth:int = conf['layoutStageWidth'];
		/**
		 * layout stage height
		 */
		var layoutStageHeight:int = conf['layoutStageHeight'];
		
		/**
		 *distribution function return Updated Property array to MultiSlection.mxml, to distribute selected objects LEFT RIGHT Vertical-Center UP Down Horisontal-Center depend on the stage or objects
		 *propetyArr is the array of properties as selected objects 
		 * distributionState is disttribution mode
		 * stageState is boolean value ,  depend on selected object or stage
		 **/
		public function distribution(propetyArr:Array,distributionState:String, stageState:Boolean):void
		{
			if(stageState)
			{
			
				distributionUpOrLeftStage(propetyArr,layoutStageWidth,layoutStageHeight,distributionState);
				
			}else
			{
			
				distributionUpOrLeftIproperty(propetyArr,distributionState);
			}
		}
		
		public function distributionUpOrLeftStage(propetyArr:Array,stageWidth:int, stageHeight:int, distributionState:String):void
		{
			var minReferencePoint:int;
			var mxmReferencePoint:int;					
			var distance : int;		
			var referencePoint:int;
			var selectionSortArr:Array = new Array();
			var IpropertyArray:Array = new Array();
			switch(distributionState)
			{
				case LEFT:
					selectionSortArr = compareIPropertyArray(propetyArr, PROPNAME_X);
					mxmReferencePoint =stageWidth-selectionSortArr[selectionSortArr.length-1][PROPNAME_WIDTH].currentValue;
					minReferencePoint = 0;	
					distance = (mxmReferencePoint-minReferencePoint)/(selectionSortArr.length-1);
					for(var i:int=0; i<selectionSortArr.length; i++)
					{
						referencePoint = minReferencePoint+distance*i;	
						(selectionSortArr[i][PROPNAME_X] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
					}
					break;
				case RIGHT:
					selectionSortArr = compareIPropertyArray(propetyArr, PROPNAME_X, PROPNAME_WIDTH);
					mxmReferencePoint = stageWidth;	
					minReferencePoint = selectionSortArr[0][PROPNAME_WIDTH].currentValue;	
					distance = (mxmReferencePoint-minReferencePoint)/(selectionSortArr.length-1);
					for(var i:int=0; i<selectionSortArr.length; i++)
					{
					referencePoint = mxmReferencePoint-distance*(selectionSortArr.length-1-i)-selectionSortArr[i][PROPNAME_WIDTH].currentValue;
					(selectionSortArr[i][PROPNAME_X] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
					}
					break;
				case VERTI_CENTER:
					selectionSortArr = compareIPropertyArray(propetyArr, PROPNAME_X, PROPNAME_WIDTH);
					mxmReferencePoint = stageWidth-selectionSortArr[selectionSortArr.length-1][PROPNAME_WIDTH].currentValue;	
					minReferencePoint = selectionSortArr[0][PROPNAME_WIDTH].currentValue/2;	
					distance = (mxmReferencePoint-minReferencePoint)/(selectionSortArr.length-1);
					for(var i:int=0; i<selectionSortArr.length; i++)
					{
						referencePoint = mxmReferencePoint-distance*(selectionSortArr.length-1-i)-selectionSortArr[i][PROPNAME_WIDTH].currentValue/2;
						(selectionSortArr[i][PROPNAME_X] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
					}
					break;
				case UP:
					selectionSortArr = compareIPropertyArray(propetyArr, PROPNAME_Y);
					mxmReferencePoint =stageHeight-selectionSortArr[selectionSortArr.length-1][PROPNAME_HEIGHT].currentValue;
					minReferencePoint = 0;	
					distance = (mxmReferencePoint-minReferencePoint)/(selectionSortArr.length-1);
					for(var i:int=0; i<selectionSortArr.length; i++)
					{
						referencePoint = minReferencePoint+distance*i;	
						(selectionSortArr[i][PROPNAME_Y] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
					}
					break;
				case DOWN:
					selectionSortArr = compareIPropertyArray(propetyArr, PROPNAME_Y, PROPNAME_HEIGHT);
					mxmReferencePoint = stageHeight;	
					minReferencePoint = selectionSortArr[0][PROPNAME_HEIGHT].currentValue;	
					distance = (mxmReferencePoint-minReferencePoint)/(selectionSortArr.length-1);
					for(var i:int=0; i<selectionSortArr.length; i++)
					{
						referencePoint = mxmReferencePoint-distance*(selectionSortArr.length-1-i)-selectionSortArr[i][PROPNAME_HEIGHT].currentValue;
						(selectionSortArr[i][PROPNAME_Y] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
					}
					break;
				case HORIZONTAL_CENTER:
					selectionSortArr = compareIPropertyArray(propetyArr, PROPNAME_Y, PROPNAME_HEIGHT);
					mxmReferencePoint = stageHeight-selectionSortArr[selectionSortArr.length-1][PROPNAME_HEIGHT].currentValue;	
					minReferencePoint = selectionSortArr[0][PROPNAME_HEIGHT].currentValue/2;	
					distance = (mxmReferencePoint-minReferencePoint)/(selectionSortArr.length-1);
					for(var i:int=0; i<selectionSortArr.length; i++)
					{
						referencePoint = mxmReferencePoint-distance*(selectionSortArr.length-1-i)-selectionSortArr[i][PROPNAME_HEIGHT].currentValue/2;
						(selectionSortArr[i][PROPNAME_Y] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
					}
					break;
			
			}
			
		}
		/**
		 * return updated property Array about selected objects
		 * * distributionState is disttribution mode
		 * minReferencePoint is the minmum value of selected objects
		 * mxmReferencePoint is the maxmim value of selected objects
		 * IpropertyArray is the updated property array to envoye to MultiSlection.mxml
		 * */
		public function distributionUpOrLeftIproperty(propetyArr:Array,distributionState:String):void
		{
			var minReferencePoint:int;
			var mxmReferencePoint:int;					
			var distance : int;		
			var referencePoint:int;
			var selectionSortArr:Array = new Array();
			var IpropertyArray:Array = new Array();
			
			
			switch(distributionState)
			{
				case LEFT:
					selectionSortArr = compareIPropertyArray(propetyArr, PROPNAME_X);
					mxmReferencePoint =selectionSortArr[selectionSortArr.length-1][PROPNAME_X].currentValue;
					minReferencePoint = selectionSortArr[0][PROPNAME_X].currentValue;									
					break;
				case RIGHT:
					selectionSortArr = compareIPropertyArray(propetyArr, PROPNAME_X, PROPNAME_WIDTH);
					mxmReferencePoint = selectionSortArr[selectionSortArr.length-1][PROPNAME_X].currentValue+selectionSortArr[selectionSortArr.length-1][PROPNAME_WIDTH].currentValue;	
					minReferencePoint = selectionSortArr[0][PROPNAME_X].currentValue+selectionSortArr[0][PROPNAME_WIDTH].currentValue;									
					break;
				case VERTI_CENTER:
					selectionSortArr = compareIPropertyArray(propetyArr, PROPNAME_X, PROPNAME_WIDTH);
					mxmReferencePoint = selectionSortArr[selectionSortArr.length-1][PROPNAME_X].currentValue+selectionSortArr[selectionSortArr.length-1][PROPNAME_WIDTH].currentValue/2;	
					minReferencePoint = selectionSortArr[0][PROPNAME_X].currentValue+selectionSortArr[0][PROPNAME_WIDTH].currentValue/2;										
					break;
				
				case UP:
					selectionSortArr = compareIPropertyArray(propetyArr, PROPNAME_Y);
					mxmReferencePoint = selectionSortArr[selectionSortArr.length-1][PROPNAME_Y].currentValue;
					minReferencePoint = selectionSortArr[0][PROPNAME_Y].currentValue;	
					break;
				case DOWN:
					selectionSortArr = compareIPropertyArray(propetyArr, PROPNAME_Y, PROPNAME_HEIGHT);
					mxmReferencePoint = selectionSortArr[selectionSortArr.length-1][PROPNAME_Y].currentValue+selectionSortArr[selectionSortArr.length-1][PROPNAME_HEIGHT].currentValue;		
					minReferencePoint = selectionSortArr[0][PROPNAME_Y].currentValue+selectionSortArr[0][PROPNAME_HEIGHT].currentValue;								
					break;
				case HORIZONTAL_CENTER:
					selectionSortArr = compareIPropertyArray(propetyArr, PROPNAME_Y, PROPNAME_HEIGHT);	
					mxmReferencePoint = selectionSortArr[selectionSortArr.length-1][PROPNAME_Y].currentValue+selectionSortArr[selectionSortArr.length-1][PROPNAME_HEIGHT].currentValue/2;
					minReferencePoint = selectionSortArr[0][PROPNAME_Y].currentValue+selectionSortArr[0][PROPNAME_HEIGHT].currentValue/2;									
					break;
					
			}
			var selectionSortArrl:int = selectionSortArr.length ;
			distance = (mxmReferencePoint-minReferencePoint)/(selectionSortArrl-1);
			
			for(var i:int=0; i<selectionSortArr.length; i++)
			{
				var dataObject:Object = new Object();
				switch(distributionState)
				{	
					case LEFT:
						referencePoint = minReferencePoint+distance*i;	
						(selectionSortArr[i][PROPNAME_X] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
						break;
					case RIGHT:
						referencePoint = mxmReferencePoint-distance*(selectionSortArrl-1-i)-selectionSortArr[i][PROPNAME_WIDTH].currentValue;
						(selectionSortArr[i][PROPNAME_X] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
						break;  
					case VERTI_CENTER: 	
						referencePoint = mxmReferencePoint-distance*(selectionSortArrl-1-i)-selectionSortArr[i][PROPNAME_WIDTH].currentValue/2;
						(selectionSortArr[i][PROPNAME_X] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
						break;	
					
					case UP:				
						referencePoint = minReferencePoint+distance*i;
						(selectionSortArr[i][PROPNAME_Y] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
						break;
					case DOWN:
						referencePoint = mxmReferencePoint-distance*(selectionSortArrl-1-i)-selectionSortArr[i][PROPNAME_HEIGHT].currentValue;
						(selectionSortArr[i][PROPNAME_Y] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
						break;
					case HORIZONTAL_CENTER: 	
						referencePoint = mxmReferencePoint-distance*(selectionSortArr.length-1-i)-selectionSortArr[i][PROPNAME_HEIGHT].currentValue/2;
						(selectionSortArr[i][PROPNAME_Y] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
						break;	
					
				}
			}
		}
		/**
		 *ajust function return Updated Property array to MultiSlection.mxml, to adjust selected objects have same width or height or size depend on the stage or objects
		 *adjustState is ADJUST_WIDTH ADJUST_HEIGHT or ADJUST_SIZE
		 */
		public function adjust(propertyArr:Array, adjustState:String, stageState:Boolean):void
		{	
			var adjustArray:Array = new Array;
			if(stageState)
			{
				adjustPropertyStage(propertyArr,layoutStageWidth,layoutStageHeight,adjustState);
			}else
			{
				adjustPropertyArray(propertyArr, adjustState);
			}	
		}
		/**
		 * adjust the size of component depends on size of stage
		 * */		
		public function adjustPropertyStage(propetyArr:Array,stageWidth:int, stageHeight:int, adjustState:String):void
		{
			for (var i:int=0; i<propetyArr.length; i++)
			{
				switch(adjustState)
				{
					case ADJUST_WIDTH:			
						(propetyArr[i][PROPNAME_WIDTH] as Property).updateCurrentValue(stageWidth, SpecificPluginController.SPECIFIC_PLUGIN_ID);
						break;
					case ADJUST_HEIGHT:
						(propetyArr[i][PROPNAME_HEIGHT] as Property).updateCurrentValue(stageHeight, SpecificPluginController.SPECIFIC_PLUGIN_ID);
						break;
					case ADJUST_SIZE:
						
						(propetyArr[i][PROPNAME_WIDTH] as Property).updateCurrentValue(stageWidth, SpecificPluginController.SPECIFIC_PLUGIN_ID);
						(propetyArr[i][PROPNAME_HEIGHT] as Property).updateCurrentValue(stageHeight, SpecificPluginController.SPECIFIC_PLUGIN_ID);								
				}
			}	
		}
		/**
		 * adjust the size of component depends on components
		 * */
		public function adjustPropertyArray(propertyArr:Array, adjustState:String):void
		{
			var selectionArray:Array = new Array;
			var widthReferencePoint:int;	
			var heightReferencePoint:int;
			
			switch(adjustState)
			{
				case ADJUST_WIDTH:
					selectionArray = compareIPropertyArray(propertyArr, PROPNAME_WIDTH);		
					break;
				case ADJUST_HEIGHT:
					selectionArray = compareIPropertyArray(propertyArr,PROPNAME_HEIGHT);		
					break;
				case ADJUST_SIZE:					
					selectionArray = compareIPropertyArray(propertyArr, PROPNAME_WIDTH,PROPNAME_HEIGHT);
					break;
			}	
			var selectionArrLength:int = selectionArray.length;
			
			widthReferencePoint = selectionArray[selectionArray.length-1][PROPNAME_WIDTH].currentValue;
			heightReferencePoint = selectionArray[selectionArray.length-1][PROPNAME_HEIGHT].currentValue;		
			
			var dataArray:Array = new Array();
			for (var i:int=0; i<selectionArrLength; i++)
			{
				switch(adjustState)
				{
					case ADJUST_WIDTH:			
						(selectionArray[i][PROPNAME_WIDTH] as Property).updateCurrentValue(widthReferencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
						break;
					case ADJUST_HEIGHT:
						(selectionArray[i][PROPNAME_HEIGHT] as Property).updateCurrentValue(heightReferencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
						break;
					case ADJUST_SIZE:
						
						(selectionArray[i][PROPNAME_WIDTH] as Property).updateCurrentValue(widthReferencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
						(selectionArray[i][PROPNAME_HEIGHT] as Property).updateCurrentValue(heightReferencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);								
				}
			}
		}
		/**
		 *ajust function return Updated Property array to MultiSlection.mxml, about selected object have hortically ou vertical regular according to the stage ou selected object
		 */
		public function space(propertyArr:Array, spaceState:String, stageState:Boolean):void
		{
			switch(spaceState)
			{
				case SPACE_HORIZONTAL:
					spaceHorisontal(propertyArr, stageState);
					break;
				case SPACE_VERTICAL:
					spaceVerti(propertyArr, stageState);
					break;
			}
		}
		/**
		 *function return array about selecetd objects have the same hortically regular space
		 **/
		public function spaceHorisontal(propertyArr:Array,stageState:Boolean):void
		{				
			var spaceIpropertyArray:Array = new Array;
			if(stageState)
			{			
				onSpaceHoriOrVertiStage(propertyArr,PROPNAME_Y,PROPNAME_HEIGHT);
			}else
			{				
				onSpaceHoriOrVerti(propertyArr,PROPNAME_Y,PROPNAME_HEIGHT);
			}
			
		}
		/**
		 *function return array about selecetd objects have the same vertical regular space
		 **/
		public function spaceVerti(propertyArr:Array,stageState:Boolean):void
		{						
			var spaceIpropertyArray:Array = new Array;			
			if(stageState)
			{	
				onSpaceHoriOrVertiStage(propertyArr,PROPNAME_X,PROPNAME_WIDTH);		
				
			}else
			{						
				onSpaceHoriOrVerti(propertyArr,PROPNAME_X,PROPNAME_WIDTH);
			}
		}
		/**
		 * return property array about selected objects space horizontal or vertical
		 * propXY is PROPNAME_X or PROPNAME_Y
		 * propWH is PROPNAME_WIDTH or PROPNAME_HEIGHT
		 * */
		public function onSpaceHoriOrVertiStage(propertyArr:Array,propXY:String,propWH:String):void
		{
			var selectionSortArr:Array = new Array();
			var minReferencePoint:int;			
			var mxmReferenceSize:int;			
			var mxmReferencePoint:int;			
			var distance : int;			
			var sizeTotal:int;				
			var objectDistance:int;	
			var referencePoint:int;
			
			selectionSortArr = compareIPropertyArray(propertyArr, propXY);
			
			mxmReferencePoint =layoutStageWidth-selectionSortArr[selectionSortArr.length-1][propWH].currentValue ;
			mxmReferenceSize = selectionSortArr[selectionSortArr.length-1][propWH].currentValue ;
			minReferencePoint= 0 ;
			for( var n:int =0; n<selectionSortArr.length; n++)
			{
				sizeTotal += selectionSortArr[n][propWH].currentValue;
			}	
			distance = (mxmReferencePoint - minReferencePoint - sizeTotal + mxmReferenceSize)/(selectionSortArr.length-1);
			for(var i:int=0; i<selectionSortArr.length; i++)
			{
				objectDistance += selectionSortArr[i][propWH].currentValue;
				referencePoint = minReferencePoint + objectDistance + distance*i - selectionSortArr[i][propWH].currentValue;	
				(selectionSortArr[i][propXY] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
			}
		}
		/**
		 * return property array about selected objects space horizontal or vertical
		 * propXY is PROPNAME_X or PROPNAME_Y
		 * propWH is PROPNAME_WIDTH or PROPNAME_HEIGHT
		 * */
		public function onSpaceHoriOrVerti(propertyArr:Array,propXY:String,propWH:String):void
		{
			var selectionSortArr:Array = new Array();
			var minReferencePoint:int;			
			var mxmReferenceSize:int;			
			var mxmReferencePoint:int;			
			var distance : int;			
			var sizeTotal:int;				
			var objectDistance:int;	
			var referencePoint:int;
			
			selectionSortArr = compareIPropertyArray(propertyArr, propXY);
			
			mxmReferencePoint = selectionSortArr[selectionSortArr.length-1][propXY].currentValue ;
			mxmReferenceSize = selectionSortArr[selectionSortArr.length-1][propWH].currentValue ;
			minReferencePoint= selectionSortArr[0][propXY].currentValue ;
			for( var n:int =0; n<selectionSortArr.length; n++)
			{
				sizeTotal += selectionSortArr[n][propWH].currentValue;
			}	
			distance = (mxmReferencePoint - minReferencePoint - sizeTotal + mxmReferenceSize)/(selectionSortArr.length-1);
			for(var i:int=0; i<selectionSortArr.length; i++)
			{
				objectDistance += selectionSortArr[i][propWH].currentValue;
				referencePoint = minReferencePoint + objectDistance + distance*i - selectionSortArr[i][propWH].currentValue;	
				(selectionSortArr[i][propXY] as Property).updateCurrentValue(referencePoint, SpecificPluginController.SPECIFIC_PLUGIN_ID);
			}
		}

		/**
		 *compare fucntion like sortOn at actionscript3, Bulle sort
		 */
		public function compareIPropertyArray(propertyArray:Array,propname:String,propToAdd:String=null):Array
		{
			var propArrLength:Number = propertyArray.length;
			var firstTempNumber:Number;
			var secondeTempNumber:Number;
			var proptyArr:Array = new Array();
			for (var i : int = 0;i < propArrLength - 1; i++) { 
				for (var j : int = 0;j < propArrLength - i - 1; j++) { 
					firstTempNumber = propertyArray[j][propname].currentValue + ( propToAdd !== null ? propertyArray[j][propToAdd].currentValue : 0 );
					secondeTempNumber = propertyArray[j+1][propname].currentValue + ( propToAdd !== null ? propertyArray[j+1][propToAdd].currentValue : 0 );
					if ( firstTempNumber> secondeTempNumber) {
						var tempValue = propertyArray[j];
						propertyArray[j] = propertyArray[j+1];
						propertyArray[j+1] = tempValue;
					}
				}
			}
			proptyArr = propertyArray;
			return proptyArr;
		}
	}
}