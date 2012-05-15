import flash.geom.Matrix;
import org.silex.tools.selectionTool.ui.uis.uiComponents.AssetBase;
/**
 * This is a base class for graphical asset containers. for instance there is the selected components container and
 * the highlighted components container. This class manages the setting/hiding/updating of those graphical assets
 * @author Yannick DOMINGUEZ
 */
class org.silex.tools.selectionTool.ui.uis.uiComponents.AssetContainersBase extends MovieClip
{
	/////////////////////////////////////
	// ATTRIBUTES
	////////////////////////////////////
	
	/**
	 * An array containing the movieClips representing the graphical assets of the
	 * target components
	 */
	private var _assetsInstances:Array;
	
	/**
	 * The identifier of the asset to attach to the container of the Flash library
	 */
	private var _assetLibraryID:String;
	
	/**
	 * The name to give to an instance of the graphical asset. It is completed with a random number
	 */
	private var _assetInstanceName:String;
	
	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	public function AssetContainersBase() 
	{
		
	}
	
	/////////////////////////////////////
	// PUBLIC METHODS
	////////////////////////////////////
	
	/**
	 * set the visual assets around the given components coords, and store the reference to the MovieClips
	 * in an array, to easily retrieve them later
	 * @param	componentsCoords contains all of the target components coords
	 */
	public function setAssets(componentsCoords:Array):Void
	{
		//first we clean up the previously used assets movieclip
		unsetAssets();
		_assetsInstances = new Array();
		
		//for each targeted component
		for (var i:Number = 0; i < componentsCoords.length; i++)
		{
			var componentCoords:Object = componentsCoords[i].componentCoords;
			
			//we attach a graphical asset to the asset container
			var assetInstance:MovieClip = this.attachMovie(
			_assetLibraryID, _assetInstanceName + Math.round((Math.random() * 1000)).toString(),
			this.getNextHighestDepth()
			);
			
			//then place it accordingly to the current component coord
			assetInstance._x = 0;
			assetInstance._y = 0;
			assetInstance._width = componentCoords.width;
			assetInstance._height = componentCoords.height;
			assetInstance.uid = componentsCoords[i].componentUid;
			
			setAssetInstanceListeners(assetInstance);
			
			//we use a Flash Matrix to rotate the asset
			var rotationMatrix:Matrix = assetInstance.transform.matrix;
			rotationMatrix.rotate((componentCoords.rotation * Math.PI) / 180);
			assetInstance.transform.matrix = rotationMatrix;
			
			//then we translate the asset
			assetInstance._x = componentCoords.x;
			assetInstance._y = componentCoords.y;
			
			//we then store a reference to the attached movieClip
			_assetsInstances.push(assetInstance);
		}
	}
	

	
	/**
	 * Update the coords of all or some of the currently attached assets MovieClips, 
	 * retrieved with their uid
	 * @param	componentsCoords contains all of the targeted components coords
	 */
	public function updateAssets(componentsCoords:Array):Void
	{
		var componentCoordsLength:Number = componentsCoords.length;
		var assetInstancesLength:Number = _assetsInstances.length;
		
		for (var i:Number = 0; i < componentCoordsLength; i++)
		{
			var componentCoords:Object = componentsCoords[i].componentCoords;
			
			var assetInstance:MovieClip;
			//retrieve the instance with it's uid
			for (var j:Number = 0; j < assetInstancesLength; j++)
			{
				if (_assetsInstances[j].uid == componentsCoords[i].componentUid)
				{
					assetInstance = _assetsInstances[j];
					break;
				}
			}
			
			assetInstance._x = 0;
			assetInstance._y = 0;
			assetInstance._width = componentCoords.width;
			assetInstance._height = componentCoords.height;
			assetInstance.uid = componentsCoords[i].componentUid;
			
			var rotationMatrix:Matrix = assetInstance.transform.matrix;
			rotationMatrix.rotate((componentCoords.rotation * Math.PI) / 180);
			assetInstance.transform.matrix = rotationMatrix;
			
			assetInstance._x = componentCoords.x;
			assetInstance._y = componentCoords.y;
		}
	}
	
	/**
	 * Unload all the movieClip displayed in the asset container
	 */
	public function unsetAssets():Void
	{
		var attachedAssetsLength:Number = this.getNextHighestDepth();
		
		for (var i:Number = 0; i < attachedAssetsLength; i++)
		{
			var assetInstance:MovieClip = this.getInstanceAtDepth(i);
			removeAssetInstanceListeners(assetInstance);
			assetInstance.removeMovieClip();
		}
	}
	
	/////////////////////////////////////
	// PROTECTED METHODS
	////////////////////////////////////
	
	/**
	 * method to add listeners to an asset after it is created
	 * @param	assetInstance the asset instance to listen
	 */
	private function setAssetInstanceListeners(assetInstance:MovieClip):Void
	{
		//abstract
	}
	
	/**
	 * method to remove listeners from an asset about to be removed
	 * @param	assetInstance the asset to remove listeners from
	 */
	private function removeAssetInstanceListeners(assetInstance:MovieClip):Void
	{
		//abstract
	}
	
}