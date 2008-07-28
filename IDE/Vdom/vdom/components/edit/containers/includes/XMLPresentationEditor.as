import mx.controls.Alert;

import vdom.events.DataManagerEvent;
import vdom.managers.DataManager;

private var dataManager:DataManager

private var _enabledElements:Boolean;

private function initalizeHandler():void {
	
	dataManager = DataManager.getInstance();
	_enabledElements = true;
}

private function showHandler():void {
	
	enableElement(false)
	saveButton.label = 'Loading...'
	dataManager.addEventListener(DataManagerEvent.OBJECT_XML_SCRIPT_LOADED, objectXMLScriptHandler);
	dataManager.getObjectXMLScript();
}

private function hideHandler():void {
	
	setListeners(false);
	enableElement(false);
	scriptEditor.code = '';
}

private function objectXMLScriptHandler(event:DataManagerEvent):void {
	
	dataManager.removeEventListener(DataManagerEvent.OBJECT_XML_SCRIPT_LOADED, objectXMLScriptHandler);
	
	XML.prettyPrinting = true;
	XML.prettyIndent = 4;
	var result:String = event.result[0].toXMLString();
	scriptEditor.code = result;
	saveButton.label = 'Save';
	enableElement(true);
}

private function saveXMLScript():void {
	
	if(!scriptEditor.code)
	{
		Alert.show("Empty description", "Alert");
		return;
	}
	enableElement(false);
	saveButton.label = 'Saving...';
	dataManager.addEventListener(DataManagerEvent.OBJECT_XML_SCRIPT_SAVED, saveXMLScriptHandler);
	var code:String = scriptEditor.code;
	dataManager.setObjectXMLScript(code);
}

private function saveXMLScriptHandler(event:DataManagerEvent):void {
	
	enableElement(true);
	dataManager.removeEventListener(DataManagerEvent.OBJECT_XML_SCRIPT_SAVED, saveXMLScriptHandler);
	saveButton.label = 'Save';
}

private function enableElement(flag:Boolean):void {
	
	if(flag ) {
		
		saveButton.enabled = true;
		scriptEditor.enabled = true;
		
	} else {
		
		saveButton.enabled = false;
		scriptEditor.enabled = false;
	} 
}

private function setListeners(flag:Boolean):void {
	
	if(flag) {
		
		
		
	} else {
		
		dataManager.removeEventListener(DataManagerEvent.OBJECT_XML_SCRIPT_SAVED, saveXMLScriptHandler);
		dataManager.removeEventListener(DataManagerEvent.OBJECT_XML_SCRIPT_LOADED, objectXMLScriptHandler);
	}
}