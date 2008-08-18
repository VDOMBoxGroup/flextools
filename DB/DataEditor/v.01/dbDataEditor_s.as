// ActionScript file
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.LinkButton;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.events.DataGridEvent;
import mx.formatters.SwitchSymbolFormatter;
import flash.events.MouseEvent;
import mx.core.UITextField;

private const AMOUNT:int = 500;
private const MAX_PAGES:int = 10;

private var dataGridCollection:ArrayCollection = new ArrayCollection();
private var dataGridColumns:Array = []; /* of DataGridColumns */
private var dataGridColumnsProps:Array = [];
private var manager:*;	/* SuperManager */
private var externalValue:String;
private var structureXML:XML;

[Bindable]
private var totalRecords:int = 0;
private var pages:Array = []; /* of XML */
private var currentPage:int = 0;
private var pageOffset:int = 0;
private var queryResult:XML;
private var editableValue:String = "";
private var rowIndex:int = -1;

private var queue:XMLList;
private var thereAreGlobalChanges:Boolean = false;

/**
 * Async connection needs the folowing functions to be executed in specified way:
 * 
 * [Init] --> requestTableStructure --> [resultTableStructureHandler] -->
 * --> requestRowsCount --> [resultTableRowsHandler] --> showPageData(1)
 * 
 * Otherwise you will never know of what request you have recievet the result.
 **/

/* Public properties */
public function set externalManager(ref:*):void {
	manager = ref;
	onLoadInit();
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

private function onLoadInit():void {
	requestTableStructure();
	manager.addEventListener("callError", remoteMethodCallErrorMsgHandler);
}


// ----- Table Structure processing methods ---------------------------------------------

private function requestTableStructure():void {
	try {
		manager.addEventListener("callComplete", resultTableStructureHandler);
		manager.remoteMethodCall("get_structure", "");
	}
	catch (err:Error) {
		/* error03 */
		showMessage("External Manager error (03)");		
	}
}

private function resultTableStructureHandler(event:*):void {
	manager.removeEventListener("callComplete", resultTableStructureHandler);
	
	try {
		queryResult = new XML(event.result);
		structureXML = new XML(queryResult.Result.tablestructure);
		
		setTableHeaders();
		requestRowsCount();
	}
	catch (err:Error) {
		/* error04 */
		showMessage("External Manager error (04): Can not convert result into XML or result error!");
		queryResult = new XML();
	}
}

// ----- Table get Rows count processing methods ----------------------------------------

private function requestRowsCount():void {
	try {
		manager.addEventListener("callComplete", resultTableRowsHandler);
		manager.remoteMethodCall("get_count", "");
	}
	catch (err:Error) {
		/* error01 */
		showMessage("External Manager error (01)");		
	}
}

private function resultTableRowsHandler(event:*):void {
	manager.removeEventListener("callComplete", resultTableRowsHandler);

	try {
		queryResult = new XML(event.result);
		totalRecords = queryResult.Result;		
	}
	catch (err:Error) {
		/* error02 */
		showMessage("Server response error (02)");
		return;
	}

	/* Open first page */
	showPageData(currentPage);
}

// --------------------------------------------------------------------------------------

private function setTableHeaders():void {
	dataGridColumns = [];
	for each (var xmlHeader:XML in structureXML.table.header.column) {
		var _header:DataGridColumn = new DataGridColumn();
		var columnProps:Object = {
			id:xmlHeader.@id.toString(),
			name:xmlHeader.@name.toString(),
			type:xmlHeader.@type.toString(),
			notnull:xmlHeader.@notnull.toString(),
			primary:xmlHeader.@primary.toString(),
			autoincrement:xmlHeader.@autoincrement.toString(),
			unique:xmlHeader.@unique.toString(),
			defvalue:xmlHeader.@default.toString()
		};
		
		/* CHecking recieved data */
		if (columnProps.autoincrement == "") columnProps.autoincrement = "False";
		if (columnProps.notnull == "") columnProps.notnull = "False";
		if (columnProps.primary == "") columnProps.primary = "False";
		if (columnProps.type == "")	columnProps.type = "TEXT";
		if (columnProps.unique == "") columnProps.unique = "False";
		
		dataGridColumnsProps.push(columnProps);
		_header.dataField = xmlHeader.@name;
		dataGridColumns.push(_header);
	}
	__dg.columns = dataGridColumns;
}

// ----- Get data methods ---------------------------------------------------------------

private function getPageRequest(page:int):void {
	currentPage = page;
	try {
		manager.addEventListener("callComplete", getPageHandler);
		manager.remoteMethodCall("get_data", "<range><limit>" + AMOUNT.toString() + "</limit><offset>" + String(AMOUNT * page) + "</offset></range>");
	}
	catch (err:Error) {
		/* error07 */
		showMessage("External Manager error (07): Specified method haven't found on the externalManager!");		
	}
}

private function getPageHandler(event:*):void {
	manager.removeEventListener("callComplete", getPageHandler);

	try {
		queryResult = new XML(event.result);
		pages[currentPage] = new XML(queryResult.Result.queryresult.table.data);
		
		showPageData(currentPage);
	}
	catch (err:Error) {
		/* error08 */
		showMessage("External Manager error (08): Can not convert result into XML or result error!");
		queryResult = new XML();
	}
} 

private function showPageData(page:int):void {
	currentPage = page;
	if (!pages[page]) {
		getPageRequest(page);
		return;		
	}
	
	/* Show current page */
	dataGridCollection = new ArrayCollection();
	for each (var xmlRow:XML in pages[currentPage].row) {
		/* Create tableRow object */
		var tableRow:Object = new Object();
		var cellIndex:int = 0;
		for each (var xmlCell:XML in xmlRow.cell) {
			tableRow[dataGridColumns[cellIndex].dataField] = xmlCell.toString();
			cellIndex++;
		}
		
		tableRow["fnew"] = false;
		tableRow["changed"] = false;
		dataGridCollection.addItem(tableRow);
	}
	__dg.dataProvider = dataGridCollection;
	
	
	/* (Re)Build pages */
	__pagesArea.removeAllChildren();
	var p:int = 1;
	var pagesCount:int = int(totalRecords / AMOUNT); 			
	var pageItem:LinkButton;
	while (p <= pagesCount && p <= MAX_PAGES) {
		pageItem = new LinkButton();
		pageItem.label = p.toString();
		pageItem.height = 18;
		pageItem.setStyle("paddingLeft", 1);
		pageItem.setStyle("paddingRight", 1);
		if (p - 1 == currentPage)
			pageItem.setStyle("textDecoration", "underline");
		else
			pageItem.addEventListener(MouseEvent.CLICK, pageClickHandler);
		
		__pagesArea.addChild(pageItem);
		p++;
	}
	
	/* If Just one page exists */
	if (totalRecords < AMOUNT) {
		pageItem = new LinkButton();
		pageItem.label = "1";
		pageItem.height = 18;
		pageItem.setStyle("paddingLeft", 1);
		pageItem.setStyle("paddingRight", 1);
		pageItem.setStyle("textDecoration", "underline");
		
		__pagesArea.addChild(pageItem);
	}
	
	__commitBtn.enabled = false;
	
/*
	if (pagesCount > MAX_PAGES) {
		pageItem = new LinkButton();
		pageItem.label = "...";
		pageItem.height = 18;
		pageItem.setStyle("paddingLeft", 1);
		pageItem.setStyle("paddingRight", 1);
		pageItem.setStyle("fontWeight", "bold");
		pageItem.addEventListener(MouseEvent.CLICK, shiftPagesToRight);				
		__pagesArea.addChild(pageItem);
	}
*/

}

private function pageClickHandler(mEvent:MouseEvent):void {
	/* Handle page number click */
	showPageData(int(mEvent.currentTarget.label) - 1);
}

// ----- Edit data processing methods ---------------------------------------------------

private function itemEditBegin(event:DataGridEvent):void {
	editableValue = dataGridCollection[event.rowIndex][dataGridColumns[event.columnIndex].dataField].toString();
}

private function itemEditEnd(event:DataGridEvent):void {
	if (event.currentTarget.itemEditorInstance.text != editableValue) {
		dataGridCollection[event.rowIndex].changed = true;
		__commitBtn.enabled = true;
	}
}

private function addRowBtnClickHandler(event:MouseEvent):void {
	if (event.target is UITextField)
		return;
	
	/* Create tableRow object */
	var tableRow:Object = new Object();
	var columnIndex:int = 0;
	for each (var dgColumn:DataGridColumn in dataGridColumns) {
		if (dataGridColumnsProps[columnIndex].autoincrement.toLowerCase() == "false") {
			if (dataGridColumnsProps[columnIndex].notnull.toLowerCase() == "true")
				tableRow[dgColumn.dataField] = "Required";
			else
				tableRow[dgColumn.dataField] = "NULL";
		} else {
			tableRow[dgColumn.dataField] = "NULL";
		}
		columnIndex++;
	}
	
	tableRow["fnew"] = true;
	tableRow["changed"] = false;
	dataGridCollection.addItem(tableRow);
	__dg.selectedIndex = dataGridCollection.length;
	__commitBtn.enabled = true;
}


private var thereAreChangedRows:Boolean = false;
private var thereAreNewRows:Boolean = false;

private function commitBtnClickHandler():void {
	/* Check for new and changed objects. First - for changes, then for new */

	var requestXMLParam:XML = new XML(<update />);

	/* Update rows */
	for each (var dataGridRow:Object in dataGridCollection) {
		if (dataGridRow.changed && !dataGridRow.fnew) {
			thereAreChangedRows = true;
			var xmlRow:XML = new XML(<row id={dataGridRow["id"]} />);
			
			for each (var dataGridCell:Object in dataGridColumns) {
				xmlRow.appendChild("<cell name='" + dataGridCell.dataField + "'>" + dataGridRow[dataGridCell.dataField] + "</cell>");
			}
			requestXMLParam.appendChild(xmlRow);
		}
		
		if (dataGridRow.fnew)
			thereAreNewRows = true;
	}
	
	if (thereAreChangedRows) {
		try {
			manager.addEventListener("callComplete", remoteMethodCallStandartMsgHandler);
			remoteMethodCallOkFunction = updateRowsOkHandler;
			manager.remoteMethodCall("update_row", requestXMLParam.toXMLString());
		}
		catch (err:Error) {
			/* error090 */
			showMessage("External Manager error (090)");		
		}
	} else {
		if (thereAreNewRows) {
			addNewRowsRequest();
		} else {
			__commitBtn.enabled = false;
		}
	}
}

private function updateRowsOkHandler():void {
	__commitBtn.enabled = false;
	
	/* Remove "changed" label from rows */
	for each (var dataGridRow:Object in dataGridCollection) {
		dataGridRow.changed = false;	
	}
	
	thereAreGlobalChanges = true;
	if (thereAreNewRows) {
		addNewRowsRequest();
	} else {
		delete pages[currentPage];
		requestRowsCount();
	}
}

private function addNewRowsRequest():void {
	/* Check for new objects */
	var requestXMLParam:XML = new XML(<insert />);

	/* Insert rows | Conctruct XML request */
	for each (var dataGridRow:Object in dataGridCollection) {
		if (dataGridRow.fnew) {
			var xmlRow:XML = new XML(<row />);
			
			for each (var dataGridCell:Object in dataGridColumns) {
				xmlRow.appendChild(<cell>{dataGridRow[dataGridCell.dataField]}</cell>);
			}
			requestXMLParam.appendChild(xmlRow);
		}
	}
	
	if (thereAreNewRows) {
		/* Turn on "Commit" button again in case if errors will occur */
		__commitBtn.enabled = true;
		
		try {
			manager.addEventListener("callComplete", remoteMethodCallStandartMsgHandler);
			remoteMethodCallOkFunction = addRowsOkHandler;
			manager.remoteMethodCall("add_row", requestXMLParam.toXMLString());
		}
		catch (err:Error) {
			/* error009 */
			showMessage("External Manager error (009)");		
		}
	}
}

private function addRowsOkHandler():void {
	__commitBtn.enabled = false;

	/* Remove "new" label from rows */
	for each (var dataGridRow:Object in dataGridCollection) {
		dataGridRow.fnew = false;	
	}
	
	thereAreGlobalChanges = true;
	
	/* Update visual components data */
	delete pages[currentPage];
	requestRowsCount();
}

private function deleteBtnClickHandler():void {
	if (__dg.selectedIndex == -1 || !dataGridCollection[__dg.selectedIndex])
		return;
		
	if (dataGridCollection[__dg.selectedIndex]["fnew"]) {
		dataGridCollection.removeItemAt(__dg.selectedIndex);
		return;
	}
	
	/* Lock Data Grid control */
	__dg.enabled = false;
	
	try {
		rowIndex = __dg.selectedIndex;
		__deleteBtn.enabled = false; 
		manager.addEventListener("callComplete", remoteMethodCallStandartMsgHandler);
		remoteMethodCallOkFunction = deleteSelectedDGRowOk;
	
		var requestXMLParam:XML = new XML(<delete />);
		requestXMLParam.appendChild(<row id={dataGridCollection[__dg.selectedIndex]["id"]} />);
		
		manager.remoteMethodCall("delete_row", requestXMLParam.toXMLString());
	}
	catch (err:Error) {
		/* error091 */
		showMessage("External Manager error (091)");		
	}
}

private function deleteSelectedDGRowOk():void {
	dataGridCollection.removeItemAt(rowIndex);
	__deleteBtn.enabled = true;
	
	thereAreGlobalChanges = true;
	__dg.enabled = true;
	totalRecords--;
}

private function discardBtnClickHandler():void {
	/* Update visual table Data */
	delete pages[currentPage];
	requestRowsCount();
	__dg.enabled = true;
}

// ----- Server Messages processing methods ---------------------------------------------

private var remoteMethodCallOkFunction:Function;

private function remoteMethodCallStandartMsgHandler(event:*):void {
/*
	There are may be 2 responses from server in this section: response that
	everything is OK and standart error message (something wrong with remote
	method parameters).
*/

	manager.removeEventListener("callComplete", remoteMethodCallStandartMsgHandler);
	
	var xmlResult:XML;
	try { 
		xmlResult = new XML(event.result);
	}
	catch (err:Error) {	return;	}
	
	switch (xmlResult.name().toString()) {
		case "Result":
			trace (xmlResult);
			if (remoteMethodCallOkFunction != null)
				remoteMethodCallOkFunction();
			break;
		case "Error":
			showMessage("ERROR: " + xmlResult);
			break;
	}
}

private function remoteMethodCallErrorMsgHandler(event:*):void {
/*
	This function handles responses displaying that method could not be executed
	for some reason(s) (may be privilegies reason or method is absent?). 
*/
	var xmlResult:XML;
	try { 
		xmlResult = new XML(event.result);
	}
	catch (err:Error) {	return;	}
	
	if (xmlResult.name().toString() == "Result") {
		try {
			showMessage("SOAP EXCEPTION: " + xmlResult.Error);
		}
		catch (err:Error) {
			showMessage("UNKNOWN SOAP EXCEPTION: " + xmlResult);
		}
	} else {
		showMessage("UNKNOWN ERROR OCCURED: " + xmlResult.toString());
	}
}

// ----- Alert processing methods -------------------------------------------------------

private var alertYesFunc:Function;
private var alertNoFunc:Function;
[Bindable]
private var alertMessage:String = "";

private function showAlert(message:String, yesHandler:Function, noHandler:Function):void {
	alertMessage = message;
	alertNoFunc = noHandler;
	alertYesFunc = yesHandler;
	__alertArea.selectedChild = __alert;
}

private function alertClickHandler(key:String):void {
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
	__alertArea.selectedChild = __message;
}

private function messageOkClickHandler():void {
	__alertArea.selectedChild = __normal;
}