import mx.collections.ArrayCollection;
import mx.utils.UIDUtil;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.core.UITextField;
import mx.events.DataGridEvent;
import mx.controls.LinkButton;
import mx.utils.StringUtil;
import mx.controls.Label;

private var AMOUNT:int = 500;

[Bindable]
private var dataGridProvider:ArrayCollection = new ArrayCollection();
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
private var verticalScrollPositionStore:int = 0;

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
	trace (':: Start load script');
	
	__alertArea.selectedChild = __inProgress;
	
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
	
	updateQueueLength();
	
	trace (':: Executing queue (' + String(queue.length) + ')');
	queue.execute();
}

private function queueOnLoadCompleteHandler(message:String):void {
	trace (':: Queue complete handler recieved');
	
	queue.removeEventListener(QueueEvent.QUEUE_COMPLETE, queueOnLoadCompleteHandler);
	__alertArea.selectedChild = __normal;
	updateQueueLength();
}

private function errorHandler(event:QueueEvent):void {
	trace (':: Queue error handler recieved');
	
	showMessage(event.message);
	updateQueueLength();	
}

private function getPageRequest():void {
	trace (':: Adding Get Page request');
	
	__pagesArea.enabled = false;
	
	queue.reset();
	queue.addRequest(
		UIDUtil.createUID(),
		'get_data',
		'<range><limit>' + AMOUNT.toString() + '</limit><offset>' + String(AMOUNT * currentPage) + '</offset></range>',
		getPageResponseHandler, null);
	
	updateQueueLength();
	
	trace (':: Executing Get Page request');
	queue.addEventListener(QueueEvent.QUEUE_COMPLETE, getPageQueueCompleteHandler);
	queue.execute();
}

private function getPageResponseHandler(message:String):void {
	trace (':: Get page Response handler');
	
	try {
		queryResult = new XML(message);
		pages[currentPage] = new XML(queryResult.Result.queryresult.table.data);
		
		showPageData();
	}
	catch (err:Error) {
		trace (':: Exception 01: ' + err.message);	
		queryResult = new XML();
	}
	
	__pagesArea.enabled = true;
}

private function getPageQueueCompleteHandler(event:QueueEvent):void {
	queue.removeEventListener(QueueEvent.QUEUE_COMPLETE, getPageQueueCompleteHandler);
	updateQueueLength();
}

private function showPageData():void {
	trace (':: Show page data function executed');
	if (!pages[currentPage]) {
		getPageRequest();
		return;		
	}
	
	/* Show current page */
	trace (':: Constuct DataGrid data provider');
	dataGridProvider = new ArrayCollection();
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
		dataGridProvider.addItem(tableRow);
	}
	
	buildPagesTickets();
}


private function buildPagesTickets():void {
	trace (':: Building pages tickets');
	
	/* (Re)Build pages tickets */
	__amount.text = AMOUNT.toString();
	__pagesArea.removeAllChildren();

	var lastPageNumber:int = Math.floor(totalRecords / AMOUNT) - 1;
	if (totalRecords % AMOUNT > 0)
		lastPageNumber++;  			
	
	var fp:int;
	var lp:int;
	
	fp = currentPage - 5;
	lp = currentPage + 5;
	
	if (fp < 0 && lp <= lastPageNumber) {
		lp += Math.abs(fp);
		if (lp > lastPageNumber) {
			lp = lastPageNumber;
		}
		fp = 0;
	}
	
	if (fp >= 0 && lp > lastPageNumber) {
		fp -= lp - lastPageNumber;
		if (fp < 0) {
			fp = 0;
		}
		lp = lastPageNumber;
	}
	
	if (fp < 0 && lp > lastPageNumber) {
		fp = 0;
		lp = lastPageNumber;
	}
	
	
	if (fp != 0) {
		var leftShift:LinkButton = new LinkButton();
		leftShift.label = "1";
		leftShift.height = 18;
		leftShift.setStyle("paddingLeft", 1);
		leftShift.setStyle("paddingRight", 1);
		leftShift.addEventListener(MouseEvent.CLICK, pageClickHandler);
		__pagesArea.addChild(leftShift);

		pageItem = new LinkButton();
		pageItem.label = '...';
		pageItem.height = 18;
		pageItem.setStyle("paddingLeft", 1);
		pageItem.setStyle("paddingRight", 1);
		pageItem.enabled = false;
		__pagesArea.addChild(pageItem);
	}

	var pageItem:LinkButton;
	for (var p:int = fp; p <= lp; p++)  {
		pageItem = new LinkButton();
		pageItem.label = (p + 1).toString();
		pageItem.height = 18;
		pageItem.setStyle("paddingLeft", 1);
		pageItem.setStyle("paddingRight", 1);
		if (p == currentPage)
			pageItem.setStyle("textDecoration", "underline");
		else
			pageItem.addEventListener(MouseEvent.CLICK, pageClickHandler);
		
		__pagesArea.addChild(pageItem);
	}

	if (lp != lastPageNumber) {
		pageItem = new LinkButton();
		pageItem.label = '...';
		pageItem.height = 18;
		pageItem.setStyle("paddingLeft", 1);
		pageItem.setStyle("paddingRight", 1);
		pageItem.enabled = false;
		__pagesArea.addChild(pageItem);

		var rightShift:LinkButton = new LinkButton();
		rightShift.label = String(lastPageNumber + 1);
		rightShift.height = 18;
		rightShift.setStyle("paddingLeft", 1);
		rightShift.setStyle("paddingRight", 1);
		rightShift.addEventListener(MouseEvent.CLICK, pageClickHandler);
		__pagesArea.addChild(rightShift);
	}
	
	__commitBtn.enabled = false;
}

private function pageClickHandler(mEvent:MouseEvent):void {
	trace (':: Page click handler executed');
	
	/* Handle page number click */
	currentPage = int(mEvent.currentTarget.label) - 1; 
	showPageData();
}


private function structureResponseHandler(message:String):void {
	trace (':: Structure response handler executed');
	
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

	trace (':: Structure response handler ended');
}

private function setTableHeaders():void {
	trace (':: Set Table headers executed');
	
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
	
	trace (':: Applying DataGrid columns');
	__dg.columns = dataGridColumns;
}


private function countResponseHandler(message:String):void {
	trace (':: Count Response handler executed');
	try {
		queryResult = new XML(message);
		totalRecords = int(queryResult.Result);		
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
	trace (':: On Add row Button mouse click handler executed');
	
	/* Check position of user click */
	if (event.target is UITextField)
		return;
	
	/* Create tableRow object */
	trace (':: Creating table object');
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
	trace (':: Constructing add row request');
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
	
	trace (':: Update visual components [add row]');
	dataGridProvider.addItem(tableRow);
	
	__dg.selectedIndex = dataGridProvider.length - 1;
	__commitBtn.enabled = true;
	
	updateQueueLength();
}

private function itemEditBegin(event:DataGridEvent):void {
	editableValue = dataGridProvider[event.rowIndex][dataGridColumns[event.columnIndex].dataField].toString();
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
		dataGridProvider[event.rowIndex][dataGridColumns[event.columnIndex].dataField] = event.currentTarget.itemEditorInstance.text;

		/* Construct request */
		var requestXMLParam:XML = new XML(<data />);
		var xmlRow:XML = new XML(<row id={dataGridProvider[event.rowIndex]['id']} />);						
		for each (var dataGridCell:Object in dataGridColumns) {
			xmlRow.appendChild(
				<cell name={dataGridCell.dataField}>
					{dataGridProvider[event.rowIndex][dataGridCell.dataField]}
				</cell>);
		}
		
		requestXMLParam.appendChild(xmlRow);
		
		/* Apply reqest to the queue */
		if (dataGridProvider[event.rowIndex]['changed']) {
			
			if (dataGridProvider[event.rowIndex]['fnew']) {

				queue.updateRequest(
					dataGridProvider[event.rowIndex]['GUID'],
					'add_row',
					requestXMLParam.toXMLString());
			} else {
				
				queue.updateRequest(
					dataGridProvider[event.rowIndex]['GUID'],
					'update_row',
					requestXMLParam.toXMLString());
			}
		} else {
			
			/* If new changed item appeared... */
			dataGridProvider[event.rowIndex]['changed'] = true;
			__commitBtn.enabled = true;

			if (dataGridProvider[event.rowIndex]['fnew']) {
				
				queue.updateRequest(
					dataGridProvider[event.rowIndex]['GUID'],
					'add_row',
					requestXMLParam.toXMLString());
			} else {
				
				queue.addRequest(
					dataGridProvider[event.rowIndex]['GUID'],
					'update_row',
					requestXMLParam.toXMLString());
			}
		}
	}
	
	updateQueueLength();
}

private function commitBtnClickHandler():void {
	trace (':: On Commit Button mouse click handler executed');
	trace (':: Adding queue complete event listener');
	queue.addEventListener(QueueEvent.QUEUE_COMPLETE, queueCommitCompleteHandler);
	trace (':: Executing the Queue (' + String(queue.length) + ')');
	__alertArea.selectedChild = __inProgress;
	queue.execute();
	
	updateQueueLength();
}

private function queueCommitCompleteHandler(event:QueueEvent):void {
	trace (':: Queue Commit Queue event handler recieved');
	queue.removeEventListener(QueueEvent.QUEUE_COMPLETE, queueCommitCompleteHandler);
	__commitBtn.enabled = false;
	__alertArea.selectedChild = __normal;
	updateQueueLength();
	
	/* ReRequest rows count */
	trace (':: Resetting the Queue');
	queue.reset();
	trace (':: Adding Get Count request');
	queue.addRequest(UIDUtil.createUID(), 'get_count', '', countResponseHandler, null);
	
	/* ReRequest page */
	trace (':: Adding Get Data request');
	queue.addRequest(
		UIDUtil.createUID(),
		'get_data',
		'<range><limit>' + AMOUNT.toString() + '</limit><offset>' + String(AMOUNT * currentPage) + '</offset></range>',
		refreshDataGrid, null);
	
	trace (':: Storing DataGrid position');	
	verticalScrollPositionStore = __dg.verticalScrollPosition;
	
	trace (':: Executing the Queue (' + String(queue.length) + ')');
	queue.execute();
}

private function refreshDataGrid(message:String):void {
	trace (':: Refresh Data Grid function executed');	
	getPageResponseHandler(message);
	
	trace (':: Scroll Data Grid to stored index');
	__dg.verticalScrollPosition = verticalScrollPositionStore;
}

private function deleteBtnClickHandler():void {
	trace (':: On Delete Button mouse click handler executed');
	var selectedRowIndex:int = 0;
	
	try {
		selectedRowIndex = __dg.selectedIndex;
		if (selectedRowIndex == -1)
			return;
	}
	catch (err:Error) { return; }
	
	if (dataGridProvider[selectedRowIndex]['fnew']) {
		trace (':: Remove request from queue because row is new');
		queue.removeRequest(dataGridProvider[selectedRowIndex]['GUID']);
	} else {
		trace (':: Construct Delete Row request');
		var requestXMLParam:XML = new XML(<data><row id={dataGridProvider[selectedRowIndex]['id']} /></data>);
		
		trace (':: Add Delete Row Request');
		queue.addRequest(
			dataGridProvider[selectedRowIndex]['GUID'].toString(),
			'delete_row',
			requestXMLParam.toXMLString());
	}
	
	trace (':: Remove row from Data Grid collection');
	dataGridProvider.removeItemAt(selectedRowIndex);

	__commitBtn.enabled = true;
	
	updateQueueLength();
}

private function discardBtnClickHandler():void {
	trace (':: On Discard Button mouse click handler executed');
	
	queue.reset();
	delete pages[currentPage];
	getPageRequest();
}

private function updateQueueLength():void {
	if (queue)
		__queueLenght.text = queue.length.toString();
}

private function amountApplyBtnClickHandler():void {
	try {
		AMOUNT = int(__amount.text);
	}
	catch (err:Error) {
		AMOUNT = 500;
	}
	
	AMOUNT = AMOUNT > 2000 ? 2000 : AMOUNT;
	AMOUNT = AMOUNT <= 0 ? 500 : AMOUNT;
		
	pages = [];
	currentPage = 0;
	getPageRequest();
}