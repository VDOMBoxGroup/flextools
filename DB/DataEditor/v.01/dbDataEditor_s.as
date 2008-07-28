// ActionScript file
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.LinkButton;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.events.DataGridEvent;

private const AMOUNT:int = 500;
private const MAX_PAGES:int = 10;

private var dataGridCollection:ArrayCollection = new ArrayCollection();
private var dataGridColumns:Array = []; /* of DataGridColumns */
private var dataGridColumnsProps:Array = [];
private var manager:*;	/* SuperManager */
private var _value:String;
private var structureXML:XML;

[Bindable]
private var totalRecords:int = 0;
private var pages:Array = []; /* of XML */
private var currentPage:int = 0;
private var pageOffset:int = 0;
private var queryResult:XML;
private var editableValue:String = "";
private var editableValueColumn:int = 0;
private var editableValueRow:int = 0;

private var queue:XMLList;

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

public function set value(_value:String):void {
	this._value = _value;
}

public function get value():String {
	return this._value;
}

private function onLoadInit():void {
	requestTableStructure();
	manager.addEventListener("callError", errorRMCHandler);
}


// ----- Table get Rows count processing methods ----------------------------------------

private function requestRowsCount():void {
	manager.addEventListener("callComplete", resultTableRowsHandler);
	
	try {
		manager.remoteMethodCall("get_count", "");
	}
	catch (err:Error) {
		showAlert("External Manager error: Specified method haven't found on the externalManager!", voidfunc, voidfunc);		
	}
}

private function resultTableRowsHandler(event:*):void {
	manager.removeEventListener("callComplete", resultTableRowsHandler);

	try {
		queryResult = new XML(event.result);
		totalRecords = queryResult.Result;
		
		/* Trying to open first page */
		showPageData(1);
	}
	catch (err:Error) {
		Alert.show("Can not convert result into XML or result error!", "External Manager error");
		queryResult = new XML();
		totalRecords = 0;
	}
}

// ----- Table Structure processing methods ---------------------------------------------

private function requestTableStructure():void {
	manager.addEventListener("callComplete", resultTableStructureHandler);
	
	try {
		manager.remoteMethodCall("get_structure", "");
	}
	catch (err:Error) {
		showAlert("External Manager error: Specified method haven't found on the externalManager!", voidfunc, voidfunc);		
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
		Alert.show("Can not convert result into XML or result error!", "External Manager error");
		queryResult = new XML();
	}
}

private function setTableHeaders():void {
	dataGridColumns = new Array();
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

// ----- Default RMC error processing ---------------------------------------------------

private function errorRMCHandler(event:*):void {
	try {
		showAlert("RMC error: " + event.result.Error.toString(), voidfunc, voidfunc);
	}
	catch (err:Error) {
		showAlert("Specified error occur: " + err.message, voidfunc, voidfunc);
	}
}

// ----- Get data methods ---------------------------------------------------------------

private function getPageRequest(page:int):void {
	manager.addEventListener("callComplete", getPageHandler);

	try {
		manager.remoteMethodCall("get_data", "<range><limit>" + AMOUNT.toString() + "</limit><offset>" + String(AMOUNT * (page - 1)) + "</offset></range>");
	}
	catch (err:Error) {
		showAlert("External Manager error: Specified method haven't found on the externalManager!", voidfunc, voidfunc);		
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
		Alert.show("Can not convert result into XML or result error!", "External Manager error");
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
		if (p == currentPage)
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

private function shiftPagesToRight():void {
	
}

private function shiftPagesToLeft():void {
	
}

private function pageClickHandler(mEvent:MouseEvent):void {
	/* Handle page number click */
	showPageData(int(mEvent.currentTarget.label));
}

// ----- Edit data processing methods ---------------------------------------------------

private function itemEditBegin(event:DataGridEvent):void {
	editableValue = dataGridCollection[event.rowIndex][dataGridColumns[event.columnIndex].dataField].toString();
	editableValueColumn = event.columnIndex;
	editableValueRow = event.rowIndex;
	trace ("--> Stored value: " + editableValue + " at " + editableValueRow + "x" + editableValueColumn);
}

private function itemEditEnd(event:DataGridEvent):void {
	trace ("--> New value: " + dataGridCollection[editableValueRow][dataGridColumns[editableValueColumn].dataField] + " at " + editableValueRow + "x" + editableValueColumn);	
	if (dataGridCollection[editableValueRow][dataGridColumns[editableValueColumn].dataField].toString() != editableValue) {
		dataGridCollection[editableValueRow].changed = true;
		__commitBtn.enabled = true;
	}
}

private function addRow():void {
	/* Create tableRow object */
	var tableRow:Object = new Object();
	var columnIndex:int = 0;
	for each (var dgColumn:DataGridColumn in dataGridColumns) {
		if (dataGridColumnsProps[columnIndex].autoincrement.toLowerCase() == "false") {
			if (dataGridColumnsProps[columnIndex].notnull.toLowerCase() == "true")
				tableRow[dgColumn.dataField] = "Required";
			else
				tableRow[dgColumn.dataField] = "Null";
		}
		columnIndex++;
	}
	
	tableRow["fnew"] = true;
	tableRow["changed"] = false;
	dataGridCollection.addItem(tableRow);
	__dg.selectedIndex = dataGridCollection.length;
	__commitBtn.enabled = true;
}

private function commitBtnClickHandler():void {
	var requestXMLParam:XML = new XML("<data />");
	var thereAreChanges:Boolean = false;
	for each (var dataGridRow:Object in dataGridCollection) {
		if (dataGridRow.changed) {
			thereAreChanges = true;
			var xmlRow:XML = new XML("<row />");
			
			for each (var dataGridCell:Object in dataGridColumns) {
				xmlRow.appendChild(<cell>{dataGridRow[dataGridCell.dataField]}</cell>);
			}
			requestXMLParam.appendChild(xmlRow);
		}
	}
	trace (requestXMLParam);
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
