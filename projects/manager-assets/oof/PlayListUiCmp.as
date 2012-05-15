import org.oof.ui.PlayListUi;
class PlayListUiCmp extends PlayListUi{
	function _populateProperties() {
		super._populateProperties();

		
		this.editableProperties.unshift(
			{name:'automaticNext', description:'PROPERTIES_LABEL_AUTOMATIC_NEXT', type:'boolean', defaultValue:false, isRegistered:true, group:'attributes'},
			{name:'displayPath', description:'PROPERTIES_LABEL_DISPLAY_PATH', type:'text', defaultValue:'', isRegistered:true, group:'attributes'},
			{name:'isHorizontal', description:'PROPERTIES_LABEL_IS_HORIZONTAL', type:'boolean', defaultValue:false, isRegistered:true, group:'attributes'},
			{name:'listPath', description:'PROPERTIES_LABEL_LIST_PATH', type:'text', defaultValue:'', isRegistered:true, group:'attributes'},
			{name:'loopList', description:'PROPERTIES_LABEL_LOOP_LIST', type:'boolean', defaultValue:false, isRegistered:true, group:'attributes'},
			{name:'scrollStep', description:'PROPERTIES_LABEL_SCROLL_STEP', type:'number', defaultValue:1, isRegistered:true, group:'attributes'}
		);
	}


	
}

