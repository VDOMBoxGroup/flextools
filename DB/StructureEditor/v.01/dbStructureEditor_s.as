// ActionScript file
import mx.controls.Alert;
import mx.utils.UIDUtil;

private var _tableStructure:XML;		/* XML got by vdom IDE (of existing table) */

private var _tableID:String;
private var _tableName:String;
private var _selectedListItem:Object;
private var _manager:*;					/* External Manager */

[Bindable]
private var _columnsProvider:Array = [];


public function set externalManager(ref:*):void {
	_manager = ref;
	requestTableStructure();
	__addRemoveBtns.enabled = true;
}

public function set value(src:String):void {
}

public function get value():String {
	/* Writing new table definition */
	var tableStructure:XML = new XML(<tablestructure />);
	
	var columnDef:Object;
	for each (columnDef in _columnsProvider) {
		if (!columnDef.fnew)
			tableStructure.appendChild(<columndef id={columnDef.data} name={columnDef.label} type={columnDef.type} />);
	}

	return tableStructure.toXMLString();
}


private function requestTableStructure():void {
	/* Init getting data from External Manager */
	_manager.addEventListener("callComplete", loadXMLData);
	_manager.addEventListener("callError", errorTableStructureHandler);
	
	try {
		_manager.remoteMethodCall("get_structure", "");
	}
	catch (err:Error) {
		return;
	}
}

private function errorTableStructureHandler(event:*):void {
	showAlert("Error in reqesting table structure. Try again?", requestTableStructure, voidfunc);
}

private function loadXMLData(resEvent:*):void {
	/* Applying structure data after 'get_structure' remote method */
	try {
		var queryResult:XML = new XML(resEvent.result);
		_tableStructure = new XML(queryResult.Result.tablestructure);
	}
	catch (err:Error) {
		showAlert("Unexpected External Manager error: Can not convert result into XML or result error!", voidfunc, voidfunc);
		return;
	}

	_columnsProvider = new Array();
	_tableID = _tableStructure.TableDef.@id;
	_tableName = _tableStructure.TableDef.@name;
	
	var columnDef:XML;
	for each (columnDef in _tableStructure.table.header.column) {
		_columnsProvider.push(
			{
				label:columnDef.@name.toString(),
				data:columnDef.@id.toString(),
				type:columnDef.@type.toString(),
				pkey:columnDef.@primary.toString(),
				aincrement:columnDef.@autoincrement.toString(),
				notnull:columnDef.@notnull.toString(),
				defvalue:columnDef.@default.toString(),
				fnew:false
			}
		);
	}
	
	__propList.dataProvider = _columnsProvider;
}

private function listChangeHandler():void {
	if (__applyBtn.enabled) {
		__applyBtn.enabled = false;
		showAlert("Save Changes: You should click Apply first. Do you want to save your changes?", applyChanges, listChanger);
	} else {
		listChanger();		
	}
}

private function applyChanges():void {
	applyBtnHandler();
	listChanger();
}

private function listChanger():void {
	__applyBtn.enabled = false;
	__removeBtn.enabled = true;
	controlsEnable(true);
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
	enablePropertiesPanel(true);	
}

private function enablePropertiesPanel(value:Boolean):void {
	__name.enabled = value;
	__id.enabled = value;
	__type.enabled = value;
//	__pKey.enabled = value;
//	__aIncrement.enabled = value;
//	__null.enabled = value;
//	__defValue.enabled = value;
}

private function controlsEnable(value:Boolean):void {
	__addBtn.enabled = value;
	__removeBtn.enabled = value;
}

private function applyBtnHandler():void {
	/* Updating data */
	_selectedListItem.label = __name.text;
	_selectedListItem.type = __type.selectedItem.data;
	__applyBtn.enabled = false;
	controlsEnable(true);

	/* Applying changes */
	if (_selectedListItem.fnew) {
		_selectedListItem.fnew = false;
//		_sourceXML.ChangeLog.appendChild(<ColumnInsert id={_selectedListItem.data} name={_selectedListItem.label} type={_selectedListItem.type} />);
	} else {
//		if (_selectedListItem.label != _sourceXML.TableDef.ColumnDef.(@id == _selectedListItem.data).@name) {
//			_sourceXML.ChangeLog.appendChild(<ColumnRename id={_selectedListItem.data} name={_selectedListItem.label} />);
//		}
//		if (_selectedListItem.type != _sourceXML.tabledef.columndef.(@id == _selectedListItem.data).@type) {
//			_sourceXML.ChangeLog.appendChild(<ColumnChangeType id={_selectedListItem.data} type={_selectedListItem.type} />);
//		}
	}
	
	/* Update List Data Provider */
	__propList.dataProvider = _columnsProvider;
	__propList.selectedItem = _selectedListItem;	
}

private function addBtnHandler():void {
	_columnsProvider.push({label:'* new', data:UIDUtil.createUID().toLowerCase(), type:'text', fnew:true});
	__propList.dataProvider = _columnsProvider;
	__propList.selectedIndex = _columnsProvider.length - 1;
	_selectedListItem = __propList.selectedItem;
	listChangeHandler();
}

private function removeBtnHandler():void {
	showAlert("Remove: You might lose data! Do you really want to remove?", removeSelectedProp, voidfunc);
}

private function removeSelectedProp():void {
	/* Applying changes */
//	_sourceXML.ChangeLog.appendChild(<ColumnDelete id={_selectedListItem.data} />);

	/* Remove the element */
	var newColsProvider:Array = new Array();
	var i:int = 0;
	for each (var item:Object in _columnsProvider) {
		if (i != __propList.selectedIndex) {
			newColsProvider.push(item);
		}
		i++;
	}
	_columnsProvider = newColsProvider;
	__propList.dataProvider = _columnsProvider;
	enablePropertiesPanel(false);
	__removeBtn.enabled = false;
}

//	----- Alert processing methods -------------------------------------------------------

private var alertYesFunc:Function;
private var alertNoFunc:Function;
[Bindable]
private var alertMessage:String = "";

private function showAlert(message:String, yesHandler:Function, noHandler:Function):void {
	alertMessage = message;
	alertNoFunc = noHandler;
	alertYesFunc = yesHandler;
	__propList.enabled = false;
	enablePropertiesPanel(false);
	__alertArea.selectedChild = __alert;
}

private function alertClickHandler(key:String):void {
	enablePropertiesPanel(true);
	__propList.enabled = true;
	__alertArea.selectedChild = __normal;
	if (key == "Yes")
		alertYesFunc();
	else
		alertNoFunc();
}

private function voidfunc():void {}

