// ActionScript file
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.utils.UIDUtil;

/*
import vdom.events.DBEditorEvent;
*/

private var _sourceXML:XML;		// XML got by vdom IDE (of existing table)

private var _tableID:String;
private var _tableName:String;

private var _selectedListItem:Object;

[Bindable]
private var _columnsProvider:Array = [];

private function creationComplete():void {
	this.addEventListener(CloseEvent.CLOSE, closeHandler);
	this.XMLData = 
				<TableStructure>
					<TableDef id="ac73b296-d4f0-4a3e-b64c-19fe3fde0a5b" name="dbtable_ac73b296_d4f0_4a3e_b64c_19fe3fde0a5b">
						<ColumnDef id="djhgfkshdgfkjds" name="id" type="text"/>
						<ColumnDef id="iueyhri843rhskj" name="name" type="text"/>
						<ColumnDef id="dkjhgkdjfhgkjfv" name="pic" type="blob"/>
					</TableDef>
					<ChangeLog />
				</TableStructure>;
}

public function set XMLData(src:XML):void {
	_sourceXML = src;
	loadXMLData();
	__addRemoveBtns.enabled = true;
}

public function get XMLData():XML {
	return _sourceXML;
}

private function loadXMLData():void {
	_columnsProvider = new Array();
	
	_tableID = _sourceXML.TableDef.@id;
	_tableName = _sourceXML.TableDef.@name;
	
	/*
	this.title = this.title + " - " + _tableName;
	*/
	
	var columnDef:XML;
	for each (columnDef in _sourceXML.TableDef.ColumnDef) {
		_columnsProvider.push({label:columnDef.@name.toString(), data:columnDef.@id.toString(), type:columnDef.@type.toString(), fnew:false});
	}
	
	__propList.dataProvider = _columnsProvider;
}

private function listChangeHandler():void {
	if (__applyBtn.enabled) {
		Alert.show("Do you want to save your changes?", "Save Changes", 3, this, applyAlertClickHandler);
	} else {
		listChanger();		
	}
}

private function applyAlertClickHandler(event:CloseEvent):void {
	if (event.detail == Alert.YES) {
		applyBtnHandler();
		listChanger();
	} else {
		listChanger();	
	}
}

private function listChanger():void {
	__applyBtn.enabled = false;
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
	__propDetailsPanel.enabled = true;	
}

private function controlsEnable(value:Boolean):void {
	__doneBtn.enabled = value;
	__addBtn.enabled = value;
	__removeBtn.enabled = value;
}

private function applyBtnHandler():void {
	/* Checking data */
	/* ... */
	
	/* Updating data */
	_selectedListItem.label = __name.text;
	_selectedListItem.type = __type.selectedItem.data;
	__applyBtn.enabled = false;
	controlsEnable(true);

	/* Write changelog */
	if (_selectedListItem.fnew) {
		_selectedListItem.fnew = false;
		_sourceXML.ChangeLog.appendChild(<ColumnInsert id={_selectedListItem.data} name={_selectedListItem.label} type={_selectedListItem.type} />);
	} else {
		if (_selectedListItem.label != _sourceXML.TableDef.ColumnDef.(@id == _selectedListItem.data).@name) {
			_sourceXML.ChangeLog.appendChild(<ColumnRename id={_selectedListItem.data} name={_selectedListItem.label} />);
		}
		if (_selectedListItem.type != _sourceXML.tabledef.columndef.(@id == _selectedListItem.data).@type) {
			_sourceXML.ChangeLog.appendChild(<ColumnChangeType id={_selectedListItem.data} type={_selectedListItem.type} />);
		}
	}
	
	/* Update List Data Provider */
	__propList.dataProvider = _columnsProvider;
	__propList.selectedItem = _selectedListItem;	
}

private function doneHandler():void {
	/* Writing new table definition */
	_sourceXML.TableDef = new XML();
	var columnDef:Object;
	for each (columnDef in _columnsProvider) {
		if (!columnDef.fnew)
			_sourceXML.TableDef.appendChild(<ColumnDef id={columnDef.data} name={columnDef.label} type={columnDef.type} />);
	}
	
	var cEvent:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
	this.dispatchEvent(cEvent);
	
	/*
	this.dispatchEvent(DBEditorEvent(new DBEditorEvent(DBEditorEvent.DONE, _sourceXML)));
	*/
}

private function addBtnHandler():void {
	_columnsProvider.push({label:'* new', data:UIDUtil.createUID().toLowerCase(), type:'text', fnew:true});
	__propList.dataProvider = _columnsProvider;
	__propList.selectedIndex = _columnsProvider.length - 1;
	_selectedListItem = __propList.selectedItem;
	listChangeHandler();
}

private function removeBtnHandler():void {
	Alert.show("You might lose data! Do you really want to remove?", "Remove", 3, this, removeAlertClickHandler);
}

private function removeAlertClickHandler(event:CloseEvent):void {
	if (event.detail == Alert.YES)
		removeSelectedProp();
}

private function removeSelectedProp():void {
	/* Writing changelog */
	_sourceXML.ChangeLog.appendChild(<ColumnDelete id={_selectedListItem.data} />);

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
	__propDetailsPanel.enabled = false;
}

private function closeHandler(cEvent:CloseEvent):void {
	PopUpManager.removePopUp(this);
}