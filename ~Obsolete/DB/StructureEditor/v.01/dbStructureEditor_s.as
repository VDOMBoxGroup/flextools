// ActionScript file
import mx.controls.Alert;
import mx.utils.UIDUtil;

private var tableStructure:XML;			/* XML got by vdom IDE (of existing table) */

private var tableID:String;
private var tableName:String;
private var selectedListItem:Object;
private var manager:*;					/* External Manager */
private var externalValue:String;

[Bindable]
private var columnsProvider:Array = [];	/* of Object */
private var thereAreGlobalChanges:Boolean = false;
private var validName:Boolean = false;

public function set externalManager(ref:*):void {
	manager = ref;
	requestTableStructure();
	__addRemoveBtns.enabled = true;
}

public function set value(value:String):void {
	externalValue = value;
}

public function get value():String {
	if (thereAreGlobalChanges)
		return "modified";
	else
		return externalValue;
}

private function requestTableStructure():void {
	/* Init getting data from External Manager */
	manager.addEventListener("callComplete", getTableStructureHandler);
	manager.remoteMethodCall("get_structure", "");
}

private function getTableStructureHandler(event:*):void {
	manager.removeEventListener("callComplete", getTableStructureHandler);
	
	/* Applying structure data after 'get_structure' remote method */
	var queryResult:XML = new XML(event.result);
	tableStructure = new XML(queryResult.Result.tablestructure);		

	columnsProvider = []; /* Array of Object */
	tableID = tableStructure.table.@id;
	tableName = tableStructure.table.@name;
	
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

		columnsProvider.push(column);		
	}
	
	__propList.dataProvider = columnsProvider;
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
	applyBtnClickHandler();
	listChanger();
}

private function discardChanges():void {
	__applyBtn.enabled = false;
	listChanger();
}

private function listChanger():void {
	__attentionImg.visible = false;
	__removeBtn.enabled = true;
	addRemoveButtonsEnable(true);
	enablePropertiesPanel(false);
	
	selectedListItem = __propList.selectedItem;
	if (selectedListItem != null) {
		/* Prevent editing of "id" field */
		if (selectedListItem.label.toLowerCase() != "id")
			enablePropertiesPanel(true);

		__name.text	= selectedListItem.label;
		__id.text	= selectedListItem.data;
		
		switch (selectedListItem.type.toLowerCase()) {	
			case "text":	__type.selectedIndex = 0; break;
			case "integer":	__type.selectedIndex = 1; break;
			case "real":	__type.selectedIndex = 2; break;
			case "blob":	__type.selectedIndex = 3; break;
			default:
				/* error03 */
				showMessage("Unexpected error! (03)| Unknown column type in table definition XML");
		}
		
		__pKey.selected = selectedListItem.primary.toLowerCase() == "true";
		__aIncrement.selected = selectedListItem.aincrement.toLowerCase() == "true";
		__notNull.selected = selectedListItem.notnull.toLowerCase() == "true";
		__defValue.text = selectedListItem.defvalue.toString();
		__unique.selected = selectedListItem.unique.toLowerCase() == "true";
	}
}

private function enablePropertiesPanel(value:Boolean):void {
	__name.enabled = value;
	__id.enabled = value;
	__type.enabled = value;
	__pKey.enabled = value;
	__aIncrement.enabled = value;
	__notNull.enabled = value;
	__unique.enabled = value;
	__defValue.enabled = value;
}

private function addRemoveButtonsEnable(value:Boolean):void {
	__addBtn.enabled = value;
	__removeBtn.enabled = value;
}

private function applyBtnClickHandler():void {
	if (!validName)
		return;
	
	/* Lock controls during operation */
	__propList.enabled = false;
	addRemoveButtonsEnable(false);
	 
	if (selectedListItem.fnew) {
		/* Check if the column with the same name is already exists */
		var nameExists:Boolean = false;
		for each (var column:Object in columnsProvider) {
			if (column.label == __name.text)
				nameExists = true; 
		}
		
		if (nameExists) {
			showMessage("The column with the same name is already exists!");
			return;
		}
	}

	/* trying to Apply changes */
	
	/* if selected column is new, add it */
	var requestXML:XML =
			<tableStructure>
				<column 
					id={selectedListItem.data}
					name={__name.text}
					type={__type.selectedItem.data}
					notnull={Boolean(__notNull.selected).toString()}
					primary={__pKey.selected.toString()}
					autoincrement={__aIncrement.selected.toString()}
					unique={__unique.selected.toString()}
					default={__defValue.text}
				/>
			</tableStructure>;


	manager.addEventListener("callComplete", remoteMethodCallStandartMsgHandler);
	remoteMethodCallOkFunction = applyChangesOkHandler;

	if (selectedListItem.fnew)
		manager.remoteMethodCall("add_column", requestXML.toXMLString());
	else
		manager.remoteMethodCall("update_column ", requestXML.toXMLString());
		
}

private function applyChangesOkHandler():void {
	/* UnLock controls  */
	__propList.enabled = true;
	addRemoveButtonsEnable(true);
	__applyBtn.enabled = false;

	/* Updating data */
	selectedListItem.label = __name.text;
	selectedListItem.type = __type.selectedItem.data;
	selectedListItem.notnull = Boolean(__notNull.selected).toString();
	selectedListItem.primary = __pKey.selected.toString();
	selectedListItem.aincrement = __aIncrement.selected.toString();
	selectedListItem.unique = __unique.selected.toString();
	selectedListItem.defvalue = __defValue.text;

	selectedListItem.fnew = false;

	/* Update List Data Provider */
	__propList.dataProvider = columnsProvider;
	__propList.selectedItem = selectedListItem;	
	thereAreGlobalChanges = true;
}

private function addBtnHandler():void {
	columnsProvider.push( {
		label:'New Column',
		data:UIDUtil.createUID().toLowerCase(),
		type:'text',
		aincrement:'False',
		defvalue:'',
		notnull:'False',
		primary:'False',
		unique:'False',
		fnew:true
	} );
	
	__propList.dataProvider = columnsProvider;
	__propList.selectedIndex = columnsProvider.length - 1;
	selectedListItem = __propList.selectedItem;
	listChangeHandler();
}

private function removeBtnHandler():void {
	if (selectedListItem.label == "id")
		return;
		
	showAlert("Remove: You might lose data! Do you really want to remove?", removeSelectedColRequest, voidfunc);
}

private function removeSelectedColRequest():void {
	/* Applying changes */
	manager.addEventListener("callComplete", remoteMethodCallStandartMsgHandler);
	remoteMethodCallOkFunction = removeSelectedColOkHandler;
	manager.remoteMethodCall("delete_column", "<delete><column id='" + selectedListItem.data + "' /></delete>");
}

private function removeSelectedColOkHandler():void {
	/* Remove the element */
	var newColsProvider:Array = [];
	var i:int = 0;
	for each (var item:Object in columnsProvider) {
		if (i != __propList.selectedIndex) {
			newColsProvider.push(item);
		}
		i++;
	}
	columnsProvider = newColsProvider;
	
	__propList.dataProvider = columnsProvider;
	enablePropertiesPanel(false);
	__removeBtn.enabled = false;
}

// ----- Server Messages processing methods ---------------------------------------------

private var remoteMethodCallOkFunction:Function;

private function remoteMethodCallStandartMsgHandler(event:*):void {
	trace ("Remote Method Call standart msg Handler executed");
	
	manager.removeEventListener("callComplete", remoteMethodCallStandartMsgHandler);
	
	var xmlResult:XML;
	xmlResult = new XML(event.result);

	trace ("Server response:");
	trace (xmlResult);
	if (remoteMethodCallOkFunction != null)
		remoteMethodCallOkFunction();
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
