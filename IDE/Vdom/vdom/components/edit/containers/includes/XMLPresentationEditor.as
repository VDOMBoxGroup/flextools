
import vdom.events.DataManagerEvent;
import vdom.managers.DataManager;

private var dataManager:DataManager

private function initalizeHandler():void {
	
	dataManager = DataManager.getInstance();
	scriptEditor.enabled = false;
}

private function showHandler():void {
	
	dataManager.addEventListener(DataManagerEvent.OBJECT_XML_SCRIPT_LOADED, objectXMLScriptHandler); 
	dataManager.getObjectXMLScript();
}

private function objectXMLScriptHandler(event:DataManagerEvent):void {
	
	XML.prettyPrinting = true;
	XML.prettyIndent = 4;
	var result:String = event.result[0].toXMLString();
	scriptEditor.code = result;
	scriptEditor.enabled = true;
}

private function hideHandler():void {
	
	scriptEditor.code = '';
	scriptEditor.enabled = false;
}