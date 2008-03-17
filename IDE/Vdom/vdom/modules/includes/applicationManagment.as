import mx.events.ListEvent;

import vdom.managers.DataManager;

private var dataManager:DataManager;

private function initalizeHandler():void {
	
	dataManager = DataManager.getInstance();
}

private function showHandler():void {
	
	
}

private function hideHandler():void {
	
	
}

private function applicationChangedHandler(event:ListEvent):void {
	
	dataManager.changeApplication(listApplicationContainer.applicationID);
}