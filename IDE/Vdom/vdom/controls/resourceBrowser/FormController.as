// ActionScript file
import mx.controls.Alert;
import mx.managers.PopUpManager;

import vdom.events.FileManagerEvent;
import vdom.managers.FileManager;

[Bindable]
public var dataProvider:String;

private var fileManager:FileManager = FileManager.getInstance();

private function creationComplete():void {
	PopUpManager.centerPopUp(this);
	listResourcesQuery();
}

private function listResourcesQuery():void {
	fileManager.addEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, getResourcesList);
	fileManager.getListResources();
}

private function getResourcesList(fmEvent:FileManagerEvent):void {	
	Alert.show(fmEvent.result.toXMLString(), "Resources list");
}

private function showResource(resourceID:String):void {
	
}