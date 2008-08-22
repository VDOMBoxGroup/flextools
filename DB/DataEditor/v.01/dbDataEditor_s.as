import mx.collections.ArrayCollection;
import mx.utils.UIDUtil;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.core.UITextField;
import mx.events.DataGridEvent;
import mx.controls.LinkButton;
import mx.utils.StringUtil;

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
private var editableValue:String = '';
private var queue:QueueManager; /* of XML */
private var thereAreGlobalChanges:Boolean = false;
private var selectedRowIndexStore:int = -1;

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
	
	/* Permanent event listener */
	queue.addEventListener(QueueEvent.QUEUE_INTERRUPT, errorHandler);	

	queue.reset();
	queue.addRequest(UIDUtil.createUID(), 'get_structure', '', structureResponseHandler, null);
	queue.addRequest(UIDUtil.createUID(), 'get_count', '', countResponseHandler, null);
	
	/* Request first page */
	currentPage = 0;
	queue.addRequest(
		UIDUtil.createUID(),
		'get_data',
		'<range><limit>' + AMOUNT.toString() + '</limit><offset>' + String(AMOUNT * currentPage) + '</offset></range>',
		getPageResponseHandler, null);
	
	queue.addEventListener(QueueEvent.QUEUE_COMPLETE, queueOnLoadCompleteHandler);
	updateQueueLenght();
	queue.execute();
}

private function queueOnLoadCompleteHandler(message:String):void {
	queue.removeEventListener(QueueEvent.QUEUE_COMPLETE, queueOnLoadCompleteHandler);
	updateQueueLenght();
}

private function errorHandler(event:QueueEvent):void {
	showMessage(event.message);
	updateQueueLenght();	
}

private function getPageRequest():void {
	queue.reset();
	queue.addRequest(
		UIDUtil.createUID(),
		'get_data',
		'<range><limit>' + AMOUNT.toString() + '</limit><offset>' + String(AMOUNT * currentPage) + '</offset></range>',
		getPageResponseHandler, null);
	
	updateQueueLenght();
	queue.execute();
}

private function getPageResponseHandler(message:String):void {
	try {
		queryResult = new XML(message);
		pages[currentPage] = new XML(queryResult.Result.queryresult.table.data);
		
		showPageData();
	}
	catch (err:Error) {	queryResult = new XML(); }
	
	queue.reset();
	updateQueueLenght();
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

	updateQueueLenght();
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
		
		/* Checking recieved data */
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
	
	updateQueueLenght();
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
	/* Check position of user click */
	if (event.target is UITextField)
		return;
	
	/* Create tableRow object */
	var tableRow:Object = new Object();
	var columnIndex:int = 0;
	for each (var dgColumn:DataGridColumn in dataGridColumns) {
		if (dataGridColumnsProps[columnIndex].autoincrement.toLowerCase() == 'false') {
			if (dataGridColumnsProps[columnIndex].notnull.toLowerCase() == 'true')
				tableRow[dgColumn.dataField] = 'REQUIRED';
			else
				tableRow[dgColumn.dataField] = 'NULL';
		} else {
			tableRow[dgColumn.dataField] = 'NULL';
		}
		columnIndex++;
	}

	tableRow['fnew'] = true;
	tableRow['changed'] = false;
	tableRow['GUID'] = UIDUtil.createUID();

	/* Construct request */
	var requestXMLParam:XML = new XML(<data />);
	var xmlRow:XML = new XML(<row id='NULL' />);						
	for each (var dataGridCell:Object in dataGridColumns) {
		xmlRow.appendChild(
			<cell name={dataGridCell.dataField}>
				{tableRow[dataGridCell.dataField]}
			</cell>);
	}
	requestXMLParam.appendChild(xmlRow);

	queue.addRequest(
		tableRow['GUID'],
		'add_row',
		requestXMLParam.toXMLString());
	
	dataGridCollection.addItem(tableRow);
	__dg.selectedIndex = dataGridCollection.length;
	__commitBtn.enabled = true;
	updateQueueLenght();
}

private function itemEditBegin(event:DataGridEvent):void {
	editableValue = dataGridCollection[event.rowIndex][dataGridColumns[event.columnIndex].dataField].toString();
}

private function itemEditEnd(event:DataGridEvent):void {
	if (event.currentTarget.itemEditorInstance.text != editableValue) {

		/* check entered data over database integrity */
		if (dataGridColumnsProps[event.columnIndex]['autoincrement'].toLowerCase() == 'true') {
			event.currentTarget.itemEditorInstance.text = editableValue;
		} else {
			if (StringUtil.trim(event.currentTarget.itemEditorInstance.text) == '') {
				if (dataGridColumnsProps[event.columnIndex]['notnull'].toLowerCase() == 'true')
					event.currentTarget.itemEditorInstance.text = 'REQUIRED';
				else
					event.currentTarget.itemEditorInstance.text = '';
			}
		}

		/* Apply changed data */		
		dataGridCollection[event.rowIndex][dataGridColumns[event.columnIndex].dataField] = event.currentTarget.itemEditorInstance.text;

		/* Construct request */
		var requestXMLParam:XML = new XML(<data />);
		var xmlRow:XML = new XML(<row id={dataGridCollection[event.rowIndex]['id']} />);						
		for each (var dataGridCell:Object in dataGridColumns) {
			xmlRow.appendChild(
				<cell name={dataGridCell.dataField}>
					{dataGridCollection[event.rowIndex][dataGridCell.dataField]}
				</cell>);
		}
		
		requestXMLParam.appendChild(xmlRow);
		
		/* Apply reqest to the queue */
		if (dataGridCollection[event.rowIndex]['changed']) {
			
			if (dataGridCollection[event.rowIndex]['fnew']) {

				queue.updateRequest(
					dataGridCollection[event.rowIndex]['GUID'],
					'add_row',
					requestXMLParam.toXMLString());
			} else {
				
				queue.updateRequest(
					dataGridCollection[event.rowIndex]['GUID'],
					'update_row',
					requestXMLParam.toXMLString());
			}
		} else {
			
			/* If new changed item appeared... */
			dataGridCollection[event.rowIndex]['changed'] = true;
			__commitBtn.enabled = true;

			if (dataGridCollection[event.rowIndex]['fnew']) {
				
				queue.updateRequest(
					dataGridCollection[event.rowIndex]['GUID'],
					'add_row',
					requestXMLParam.toXMLString());
			} else {
				
				queue.addRequest(
					dataGridCollection[event.rowIndex]['GUID'],
					'update_row',
					requestXMLParam.toXMLString());
			}
		}
	}
	
	updateQueueLenght();
}

private function commitBtnClickHandler():void {
	queue.addEventListener(QueueEvent.QUEUE_COMPLETE, queueCommitCompleteHandler);
	queue.execute();
}

private function queueCommitCompleteHandler(event:QueueEvent):void {
	queue.removeEventListener(QueueEvent.QUEUE_COMPLETE, queueCommitCompleteHandler);
	__commitBtn.enabled = false;
	
	/* ReRequest rows count */
	queue.reset();
	queue.addRequest(UIDUtil.createUID(), 'get_count', '', countResponseHandler, null);
	
	/* ReRequest page */
	queue.addRequest(
		UIDUtil.createUID(),
		'get_data',
		'<range><limit>' + AMOUNT.toString() + '</limit><offset>' + String(AMOUNT * currentPage) + '</offset></range>',
		refreshDataGrid, null);
	
	selectedRowIndexStore = __dg.selectedIndex;
	
	queue.execute();
}

private function refreshDataGrid(message:String):void {
	getPageResponseHandler(message);
	__dg.scrollToIndex(selectedRowIndexStore);

	updateQueueLenght();
}

private function deleteBtnClickHandler():void {
	var selectedRowIndex:int = 0;
	
	try {
		selectedRowIndex = __dg.selectedIndex;
		if (selectedRowIndex == -1)
			return;
	}
	catch (err:Error) { return; }
	
	if (dataGridCollection[selectedRowIndex]['fnew']) {
		queue.removeRequest(dataGridCollection[selectedRowIndex]['GUID']);
	} else {
		var requestXMLParam:XML = new XML(<data><row id={dataGridCollection[selectedRowIndex]['id']} /></data>);

		queue.addRequest(
			dataGridCollection[selectedRowIndex]['GUID'].toString(),
			'delete_row',
			requestXMLParam.toXMLString());
	}
		
	dataGridCollection.removeItemAt(selectedRowIndex);
	updateQueueLenght();
	__commitBtn.enabled = true;
}

private function discardBtnClickHandler():void {
	
}

private function updateQueueLenght():void {
	__queueLenght.text = queue.length.toString();
}