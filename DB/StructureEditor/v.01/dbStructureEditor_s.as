// ActionScript file
import mx.controls.Alert;
import mx.utils.UIDUtil;

private var tableStructure:XML;				/* XML got by vdom IDE (of existing table) */

private var _tableID:String;
private var _tableName:String;
private var _selectedListItem:Object;
private var _manager:*;						/* External Manager */

[Bindable]
private var _columnsProvider:Array = [];	/* of Object */


public function set externalManager(ref:*):void {
	try {
		_manager = ref;
		_manager.addEventListener("callError", rmcErrorHandler);	/* add permanent event listener */
		requestTableStructure();
		__addRemoveBtns.enabled = true;
	}
	catch (err:Error) {
		return;
	}
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
	
	try {
		_manager.remoteMethodCall("get_structure", "");
	}
	catch (err:Error) {
		return;
	}
}

private function rmcErrorHandler(event:*):void {
	var result:XML;
	try {
		result = XML(event.result);
	}
	catch (err:Error) {
		showAlert("Remote Method Call error: " + result.toString(), voidfunc, voidfunc);
	}
}

private function loadXMLData(event:*):void {
	_manager.removeEventListener("callComplete", loadXMLData);
	
	/* Applying structure data after 'get_structure' remote method */
	try {
		var queryResult:XML = new XML(event.result);
		tableStructure = new XML(queryResult.Result.tablestructure);		
	}
	catch (err:Error) {
		showAlert("Unexpected External Manager error: Can not get Structure data", voidfunc, voidfunc);
		return;
	}

	_columnsProvider = []; /* Array of Object */
	_tableID = tableStructure.table.@id;
	_tableName = tableStructure.table.@name;
	
	var columnDef:XML;
	for each (columnDef in tableStructure.table.header.column) {
		var column:Object = {
			label:columnDef.@name.toString(),
			data:columnDef.@id.toString(),
			type:columnDef.@type.toString(),
			primary:columnDef.@primary.toString(),
			aincrement:columnDef.@autoincrement.toString(),
			notnull:columnDef.@notnull.toString(),
			defvalue:columnDef.@default.toString(),
			unique:columnDef.@unique.toString(),
			fnew:false
		}
		
		/* CHecking recieved data */
		if (column.aincrement == "") column.aincrement = "False";
		if (column.notnull == "") column.notnull = "False";
		if (column.primary == "") column.primary = "False";
		if (column.type == "") column.type = "TEXT";
		if (column.unique == "") column.unique = "False";

		_columnsProvider.push(column);		
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
		
		__pKey.selected = _selectedListItem.primary.toLowerCase() == "true";
		__aIncrement.selected = _selectedListItem.aincrement.toLowerCase() == "true";
		__null.selected = _selectedListItem.notnull.toLowerCase() == "true";
		__defValue.text = _selectedListItem.defvalue.toString();
		__unique.selected = _selectedListItem.unique.toLowerCase() == "true";
	}
	enablePropertiesPanel(true);	
}

private function enablePropertiesPanel(value:Boolean):void {
	__name.enabled = value;
	__id.enabled = value;
	__type.enabled = value;
	__pKey.enabled = value;
	__aIncrement.enabled = value;
	__null.enabled = value;
	__unique.enabled = value;
	__defValue.enabled = value;
}

private function controlsEnable(value:Boolean):void {
	__addBtn.enabled = value;
	__removeBtn.enabled = value;
}

private function applyBtnHandler():void {
	/* Check if the column with the same name is already exists */
	var nameExists:Boolean = false;
	for each (var column:Object in _columnsProvider) {
		if (column.label == __name.text)
			nameExists = true; 
	}
	
	if (nameExists) {
		showMessage("The column with the same name is already exists!");
		return;
	}
	
	/* Updating data */
	_selectedListItem.label = __name.text;
	_selectedListItem.type = __type.selectedItem.data;
	_selectedListItem.notnull = Boolean(!__null.selected).toString();
	_selectedListItem.primary = __pKey.selected.toString();
	_selectedListItem.aincrement = __aIncrement.selected.toString();
	_selectedListItem.unique = __unique.selected.toString();
	_selectedListItem.defvalue = __defValue.text;
	__applyBtn.enabled = false;
	controlsEnable(true);

	/* Applying changes */
	
	/* if selected column is new, add it */
	if (_selectedListItem.fnew) {
		_selectedListItem.fnew = false;
		
		var request:XML = 
			<tableStructure>
				<column 
					id={_selectedListItem.data}
					name={_selectedListItem.label}
					type={_selectedListItem.type}
					notnull={_selectedListItem.notnull.toString()}
					primary={_selectedListItem.primary.toString()}
					autoincrement={_selectedListItem.aincrement.toString()}
					unique={_selectedListItem.unique.toString()}
					default={_selectedListItem.defvalue}
				/>
			</tableStructure>;
			
		_manager.addEventListener("callComplete", standartRMCMessageHandler);	
		try {
			_manager.remoteMethodCall("add_column ", request.toXMLString());
		}
		catch (err:Error) {
			return;
		}
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

private function standartRMCMessageHandler(event:*):void {
	try {
		var result:XML = new XML(event.result);
		try {
			var errorXML:XML = new XML(result.Error);
			showMessage(errorXML.toString());
		}
		catch (err:Error) {
			try {
				var resultXML:XML = new XML(result.Result);
				trace("Server response:" + resultXML.toString());				
			}
			catch (err:Error) {
				return;
			}
		}
	}
	catch (err:Error) {
		return;
	}	
}

private function addBtnHandler():void {
	_columnsProvider.push({
		label:'* new',
		data:UIDUtil.createUID().toLowerCase(),
		type:'text',
		aincrement:'False',
		defvalue:'',
		notnull:'False',
		primary:'False',
		unique:'False',
		fnew:true
	});
	
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

//	----- Message processing methods -----------------------------------------------------

private function showMessage(message:String):void {
	alertMessage = message;
	__propList.enabled = false;
	enablePropertiesPanel(false);
	__alertArea.selectedChild = __message;
}

private function messageOkClickHandler():void {
	enablePropertiesPanel(true);
	__propList.enabled = true;
	__alertArea.selectedChild = __normal;
}
