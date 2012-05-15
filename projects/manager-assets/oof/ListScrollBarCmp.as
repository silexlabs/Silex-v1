import org.oof.ui.ListScrollBar;
class ListScrollBarCmp extends ListScrollBar{
	function _populateProperties() {
		super._populateProperties();

		
		this.editableProperties.unshift(
			{name:'isHorizontal', description:'PROPERTIES_LABEL_IS_HORIZONTAL', type:'boolean', defaultValue:false, isRegistered:true, group:'attributes'},
			{name:'listPath', description:'PROPERTIES_LABEL_LIST_PATH', type:'text', defaultValue:'list', isRegistered:true, group:'attributes'},
			{name:'scrollStep', description:'PROPERTIES_LABEL_SCROLL_STEP', type:'number', defaultValue:1, isRegistered:true, group:'attributes'}		
		);
	}


	
}

