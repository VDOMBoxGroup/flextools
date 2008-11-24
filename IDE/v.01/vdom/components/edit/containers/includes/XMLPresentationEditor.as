import mx.controls.Alert;

import vdom.events.DataManagerErrorEvent;
import vdom.events.DataManagerEvent;
import vdom.events.SOAPEvent;
import vdom.managers.DataManager;

private var _objectId:String

public function set objectId(value:String):void
{
	_objectId = value;
	
	if(!visible)
		return;
		
	if(_objectId)
	{
		enableElement(false);
		loadXMLPresentation();
	}
}

private var dataManager:DataManager = DataManager.getInstance();

private var _enabledElements:Boolean;

private function initalizeHandler():void
{	
	_enabledElements = true;
}

private function loadXMLPresentation():void
{
	if(_objectId)
		dataManager.getObjectXMLScript();
}

private function registerEvent(flag:Boolean):void
{	
	if(flag)
	{	
		dataManager.addEventListener(
			DataManagerEvent.SET_OBJECT_XML_SCRIPT_COMPLETE, 
			saveXMLScriptHandler
		);
		
		dataManager.addEventListener(
			DataManagerErrorEvent.OBJECT_XML_SCRIPT_SAVE_ERROR, 
			saveXMLScriptErrorHandler
		);
			
		dataManager.addEventListener(
			DataManagerEvent.GET_OBJECT_XML_SCRIPT_COMPLETE, 
			objectXMLScriptHandler
		);
	}
	else 
	{	
		dataManager.removeEventListener(
			DataManagerEvent.SET_OBJECT_XML_SCRIPT_COMPLETE, 
			saveXMLScriptHandler
		);
		
		dataManager.addEventListener(
			DataManagerErrorEvent.OBJECT_XML_SCRIPT_SAVE_ERROR, 
			saveXMLScriptErrorHandler
		);
		
		dataManager.removeEventListener(
			DataManagerEvent.GET_OBJECT_XML_SCRIPT_COMPLETE, 
			objectXMLScriptHandler
		);
	}
}

private function showHandler():void {
	
	enableElement(false);
	registerEvent(true);
	scriptEditor.enabled = true;
	if(_objectId)
	{
		saveButton.label = 'Loading...'
		scriptEditor.enabled = false;
		loadXMLPresentation();
	}
}

private function hideHandler():void {
	
	registerEvent(false);
	enableElement(false);
	scriptEditor.code = '';
}

private function objectXMLScriptHandler(event:DataManagerEvent):void {
	
	XML.prettyPrinting = true;
	XML.prettyIndent = 4;
	var result:String = event.result[0].toXMLString();
	scriptEditor.code = result;
	saveButton.label = 'Save';
	scriptEditor.enabled = true;
	enableElement(true);
}

private function saveXMLScriptErrorHandler(event:DataManagerErrorEvent):void
{
	Alert.show("Wrong data", "Alert");
	if(_objectId)
	{
		saveButton.label = 'Loading...'
		scriptEditor.enabled = false;
		loadXMLPresentation();
	}
	else
	{
		scriptEditor.code = '';
	}
	
}

private function saveXMLScript():void {
	
	if(!scriptEditor.code)
	{
		Alert.show("Empty description", "Alert");
		return;
	}
	enableElement(false);
	saveButton.label = 'Saving...';
	var code:String = scriptEditor.code;
	dataManager.setObjectXMLScript(code);
}

private function saveXMLScriptHandler(event:Event):void {
	
	if(event is SOAPEvent && SOAPEvent(event).result.Error[0])
		Alert.show("Data not saved.", "Description Error");
	
	enableElement(true);
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