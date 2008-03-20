import mx.events.ListEvent;

import vdom.managers.DataManager;

[Bindable]
private var dataManager:DataManager;

private var moduleReady:Boolean;


private function preinitializeHandler():void {
	
	dataManager = DataManager.getInstance();
}

private function creationCompleteHandler():void {
	
	
}

private function showHandler():void {
	
	listApplicationContainer.applicationID;
}

private function hideHandler():void {
	
	
}

private function applicationChangedHandler(event:ListEvent):void {
	
	dataManager.changeCurrentApplication(listApplicationContainer.applicationID);
}