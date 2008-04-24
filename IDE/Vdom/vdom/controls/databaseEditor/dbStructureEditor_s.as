// ActionScript file
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.utils.UIDUtil;

private var _sourceXML:XML;		// XML got by vdom IDE (of existing table)

private var _tableID:String;
private var _tableName:String;

[Bindable]
private var _propertiesProvider:Array = [];

private function creationComplete():void {
	this.addEventListener(CloseEvent.CLOSE, closeHandler);
	
	_sourceXML = 
	<tableStructure>
		<tabledef id="ac73b296-d4f0-4a3e-b64c-19fe3fde0a5b" name="dbtable_ac73b296_d4f0_4a3e_b64c_19fe3fde0a5b">
			<columndef id="" name="id" type="text"/>
			<columndef id="" name="name" type="text"/>
			<columndef id="" name="pic" type="blob"/>
		</tabledef>
		<changelog><datainsert values="1, 'a'"/></changelog>
	</tableStructure>;
	
	loadXMLData();
}

public function set source(src:XML):void {
	_sourceXML = src;
	loadXMLData();
}

public function get source():XML {
	return _sourceXML;
}

private function loadXMLData():void {
	_propertiesProvider = new Array();
	
	_tableID = _sourceXML.tabledef.@id;
	_tableName = _sourceXML.tabledef.@name;
	
	this.title = this.title + " - " + _tableName;
	
	var columnDef:XML;
	for each (columnDef in _sourceXML.tabledef.columndef) {
		_propertiesProvider.push({label:columnDef.@name.toString(), data:columnDef.@id.toString(), type:columnDef.@type.toString()});
	}
	
	__propList.dataProvider = _propertiesProvider;
}

private function listChangeHandler():void {
	__apply.enabled = false;
	if (__propList.selectedItem != null) {
		__name.text	= __propList.selectedItem.label;
		__id.text	= __propList.selectedItem.data;
		
		switch (__propList.selectedItem.type.toLowerCase()) {
			case "text":	__type.selectedIndex = 0; break;	
			case "integer":	__type.selectedIndex = 1; break;
			case "real":	__type.selectedIndex = 2; break;
			case "blob":	__type.selectedIndex = 3; break;
			default:
				Alert.show("Unknown column type in table definition XML", "Unexpected error!");
		}
	}
} 

private function doneHandler():void {
	//this.dispatchEvent(ResourceBrowserEvent(new ResourceBrowserEvent(ResourceBrowserEvent.RESOURCE_SELECTED, _selectedItemID)));
	var cEvent:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
	this.dispatchEvent(cEvent);
}

private function applyBtnHandler():void {
	/* Checking data */
	
	
	/* Updating data */
	
			
}

private function addBtnHandler():void {
	trace ("UIDUtil: ", UIDUtil.createUID());
	_propertiesProvider.push({label:'new', data:UIDUtil.createUID().toLowerCase(), type:'text'});
	__propList.dataProvider = _propertiesProvider;
}

private function removeBtnHandler():void {
	
}

private function closeHandler(cEvent:CloseEvent):void {
	PopUpManager.removePopUp(this);
}