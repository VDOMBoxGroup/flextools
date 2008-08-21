import mx.collections.ArrayCollection;
import mx.utils.UIDUtil;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.core.UITextField;
import mx.events.DataGridEvent;
import mx.controls.LinkButton;

private const AMOUNT:int = 500;
private const MAX_PAGES:int = 10;

private var dataGridCollection:ArrayCollection = new ArrayCollection();
private var dataGridColumns:Array = []; /* of DataGridColumns */
private var dataGridColumnsProps:Array = [];

private var manager:*;	/* SuperManager */
private var externalValue:String;
private var tableStructureXML:XML;

[Bindable]
private var totalRecords:int = 0;
private var pages:Array = []; /* of XML */
private var currentPage:int;
private var queryResult:XML;
private var editableValue:String = "";
private var rowIndex:int = -1;

private var queue:QueueManager; /* of XML */
private var thereAreGlobalChanges:Boolean = false;

/* -------------------- Public properties --------------------------------------------------------- */

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

/* ------------------------------------------------------------------------------------------------ */

private function onLoadInit():void {
	queue = new QueueManager(manager);
	
	queue.addRequest(UIDUtil.createUID(), 'get_structure', '', structureResponseHandler, null);
	queue.addRequest(UIDUtil.createUID(), 'get_count', '', countResponseHandler, null);
	
	/* Request first page */
	currentPage = 0;
	queue.addRequest(
		UIDUtil.createUID(),
		'get_data',
		'<range><limit>' + AMOUNT.toString() + '</limit><offset>' + String(AMOUNT * currentPage) + '</offset></range>',
		getPageResponseHandler, null);
	
	queue.execute();
}

private function getPageRequest():void {
	queue.clear();
	queue.addRequest(
		UIDUtil.createUID(),
		'get_data',
		'<range><limit>' + AMOUNT.toString() + '</limit><offset>' + String(AMOUNT * currentPage) + '</offset></range>',
		getPageResponseHandler, null);
		
	queue.execute();
}

private function getPageResponseHandler(message:String):void {
	try {
		queryResult = new XML(message);
		pages[currentPage] = new XML(queryResult.Result.queryresult.table.data);
		
		showPageData();
	}
	catch (err:Error) {
		/* error08 */
		showMessage("External Manager error (08): Can not convert result into XML or result error!");
		queryResult = new XML();
	}
} 

private function showPageData():void {
	if (!pages[currentPage]) {
		getPageRequest();
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
		tableRow["GUID"] = UIDUtil.createUID(); 
		dataGridCollection.addItem(tableRow);
	}
	__dg.dataProvider = dataGridCollection;
	
	buildPagesTickets();
}


private function buildPagesTickets():void {
	/* (Re)Build pages tickets */
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
	currentPage = int(mEvent.currentTarget.label) - 1; 
	showPageData();
}


private function structureResponseHandler(message:String):void {
	try {
		queryResult = new XML(message);
		tableStructureXML = new XML(queryResult.Result.tablestructure);
		
		setTableHeaders();
	}
	catch (err:Error) {
		/* error04 */
		showMessage("External Manager error (04): Can not convert result into XML or result error!");
		queryResult = new XML();
	}
	
}

private function setTableHeaders():void {
	dataGridColumns = [];
	for each (var xmlHeader:XML in tableStructureXML.table.header.column) {
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


private function countResponseHandler(message:String):void {
	try {
		queryResult = new XML(message);
		totalRecords = queryResult.Result;		
	}
	catch (err:Error) { return;	}
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

// ----- Message processing methods -----------------------------------------------------

private function showMessage(message:String):void {
	alertMessage = message;
	__alertArea.selectedChild = __message;
}

private function messageOkClickHandler():void {
	__alertArea.selectedChild = __normal;
}

// ----- Visual components handlers -----------------------------------------------------

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

private function itemEditBegin(event:DataGridEvent):void {
	editableValue = dataGridCollection[event.rowIndex][dataGridColumns[event.columnIndex].dataField].toString();
}

private function itemEditEnd(event:DataGridEvent):void {
	if (event.currentTarget.itemEditorInstance.text != editableValue) {

		/* Construct request */
		var requestXMLParam:XML = new XML(<update />);
		var xmlRow:XML = new XML(<row id={dataGridCollection[event.rowIndex]['id']} />);						
		for each (var dataGridCell:Object in dataGridColumns) {
			xmlRow.appendChild(
				<cell name={dataGridCell.dataField}>
					{dataGridCollection[event.rowIndex][dataGridCell.dataField]}
				</cell>);
		}
		requestXMLParam.appendChild(xmlRow);
		
		if (dataGridCollection[event.rowIndex].changed) {
			
			queue.updateRequest(
				dataGridCollection[event.rowIndex]['GUID'],
				'update_row',
				requestXMLParam.toXMLString());
		} else {
			
			dataGridCollection[event.rowIndex].changed = true;
			__commitBtn.enabled = true;
			queue.addRequest(
				dataGridCollection[event.rowIndex]['GUID'],
				'update_row',
				requestXMLParam.toXMLString());
		}
	}
}

private function commitBtnClickHandler():void {
}

private function deleteBtnClickHandler():void {
}

private function discardBtnClickHandler():void {
}