
import mx.collections.ArrayCollection;

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
private var currentPage:int;
private var queryResult:XML;
private var editableValue:String = "";
private var rowIndex:int = -1;

private var queue:Array = []; /* of XML */
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
	requestTableStructure();
	manager.addEventListener("callError", remoteMethodCallErrorMsgHandler);
}
