import flash.events.Event;

import vdom.managers.DataManager;

private var dataManager:DataManager;

private function creationCompleteHandler():void {
	
	dataManager = DataManager.getInstance();
}

private function showHandler():void {
	
	
}

private function hideHandler():void {
	
	applicationName.text = '';
	applicationDescription.text = '';
}

private function createApplication():void {
	
	var name:String = applicationName.text;
	var description:String = applicationDescription.text;
	
	dataManager.createApplication(name, description);
	
	dispatchEvent(new Event('createApplication'));
}