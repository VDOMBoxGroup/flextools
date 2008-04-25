// ActionScript file
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.utils.UIDUtil;

private var _sourceXML:XML;		// XML got by vdom IDE (of existing table)

private var _tableID:String;
private var _tableName:String;

private var _selectedListItem:Object;

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
	if (__applyBtn.enabled) {
		Alert.show("Do you want to save your changes?", "Save Changes", 3, this, alertClickHandler);
	} else {
		listChanger();		
	}
}

private function alertClickHandler(event:CloseEvent):void {
	if (event.detail == Alert.YES) {
		applyBtnHandler();
		listChanger();
	} else {
		listChanger();	
	}
}

private function listChanger():void {
	__applyBtn.enabled = false;
	_selectedListItem = __propList.selectedItem;
	if (_selectedListItem != null) {
		__name.text	= _selectedListItem.label;
		__id.text	= _selectedListItem.data;
		
		switch (_selectedListItem.type.toLowerCase()) {
			case "text":	__type.selectedIndex = 0; break;	
			case "integer":	__type.selectedIndex = 1; break;
			case "real":	__type.selectedIndex = 2; break;
			case "blob":	__type.selectedIndex = 3; break;
			default:
				Alert.show("Unknown column type in table definition XML", "Unexpected error!");
		}
	}	
}

private function applyBtnHandler():void {
	/* Checking data */
	/* ... */
	
	/* Updating data */
	_selectedListItem.label = __name.text;
	_selectedListItem.type = __type.selectedItem.data;
	__applyBtn.enabled = false;
	
	/* Update List Data Provider */
	_selectedListItem = __propList.selectedItem;
	__propList.dataProvider = _propertiesProvider;
	__propList.selectedItem = _selectedListItem;
}

private function doneHandler():void {
	//this.dispatchEvent(ResourceBrowserEvent(new ResourceBrowserEvent(ResourceBrowserEvent.RESOURCE_SELECTED, _selectedItemID)));
	var cEvent:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
	this.dispatchEvent(cEvent);
}

private function addBtnHandler():void {
	_propertiesProvider.push({label:'new', data:UIDUtil.createUID().toLowerCase(), type:'text'});
	__propList.dataProvider = _propertiesProvider;
	__propList.selectedIndex = _propertiesProvider.length - 1;
	listChangeHandler();
}

private function removeBtnHandler():void {
	var newPropProvider:Array = new Array();
	var i:int = 0;
	for each (var item:Object in _propertiesProvider) {
		if (i != __propList.selectedIndex) {
			newPropProvider.push(item);
		}
		i++;
	}
	_propertiesProvider = newPropProvider;
	__propList.dataProvider = _propertiesProvider;
}

private function closeHandler(cEvent:CloseEvent):void {
	PopUpManager.removePopUp(this);
}