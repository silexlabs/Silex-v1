import org.oof.lists.RichTextList;
class RichTextListCmp extends RichTextList{
	function _populateProperties() {
		super._populateProperties();

		
		this.editableProperties.unshift(
			{name:'autoSize', description:'PROPERTIES_LABEL_AUTOSIZE', type:'text', defaultValue:'', isRegistered:true, group:'attributes'},
			{name:'embedFonts', description:'PROPERTIES_LABEL_ENABLE_EMBEDDED_FONTS', type:'boolean', defaultValue:false, isRegistered:true, group:'attributes'},
			{name:'html', description:'PROPERTIES_LABEL_ENABLE_HTML', type:'boolean', defaultValue:true, isRegistered:true, group:'attributes'},
			{name:'_useHandCursor', description:'PROPERTIES_LABEL_USE_HAND_CURSOR', type:'boolean', defaultValue:false, isRegistered:true, group:'attributes'},
			{name:'wordWrap', description:'PROPERTIES_LABEL_WORD_WRAP', type:'boolean', defaultValue:true, isRegistered:true, group:'attributes'},
			{name:'cellMarginX', description:'PROPERTIES_LABEL_CELL_MARGIN_X', type:'number', defaultValue:10, isRegistered:true, group:'attributes'},
			{name:'cellMarginY', description:'PROPERTIES_LABEL_CELL_MARGIN_Y', type:'number', defaultValue:10, isRegistered:true, group:'attributes'},
			{name:'cellRenderer', description:'PROPERTIES_LABEL_CELL_RENDERER', type:'text', defaultValue:'', isRegistered:true, group:'attributes'},
			{name:'data', description:'PROPERTIES_LABEL_DATA', type:'array', defaultValue:[], isRegistered:true, group:'attributes'},
			{name:'easingDuration', description:'PROPERTIES_LABEL_EASING_DURATION', type:'number', defaultValue:0.5, isRegistered:true, group:'attributes'},
			{name:'rowHeight', description:'PROPERTIES_LABEL_ROW_HEIGHT', type:'number', defaultValue:50, isRegistered:true, group:'attributes'},
			{name:'icons', description:'PROPERTIES_LABEL_ICONS', type:'array', defaultValue:[], isRegistered:true, group:'attributes'},
			{name:'itemsPerRow', description:'PROPERTIES_LABEL_ITEMS_PER_ROW', type:'number', defaultValue:1, isRegistered:true, group:'attributes'},
			{name:'labels', description:'PROPERTIES_LABEL_LABELS', type:'array', defaultValue:[], isRegistered:true, group:'attributes'},
			{name:'isHorizontal', description:'PROPERTIES_LABEL_IS_HORIZONTAL', type:'boolean', defaultValue:false, isRegistered:true, group:'attributes'},
			{name:'multipleSelection', description:'PROPERTIES_LABEL_MULTIPLE_SELECTION', type:'boolean', defaultValue:false, isRegistered:true, group:'attributes'},
			{name:'useVariableRowHeight', description:'PROPERTIES_LABEL_USE_VARIABLE_ROW_HEIGHT', type:'boolean', defaultValue:false, isRegistered:true, group:'attributes'},
			{name:'enabled', description:'PROPERTIES_LABEL_ENABLED', type:'boolean', defaultValue:true, isRegistered:true, group:'attributes'},
			{name:'visible', description:'PROPERTIES_LABEL_IS_VISIBLE', type:'boolean', defaultValue:true, isRegistered:true, group:'attributes'},
			{name:'minHeight', description:'PROPERTIES_LABEL_MIN_HEIGHT', type:'number', defaultValue:0, isRegistered:true, group:'attributes'},
			{name:'minWidth', description:'PROPERTIES_LABEL_MIN_WIDTH', type:'number', defaultValue:0, isRegistered:true, group:'attributes'}										
		);
	}


	
}

