import vdom.events.DataManagerEvent;
import vdom.managers.DataManager;

private var dataManager:DataManager;

private function creationCompleteHandler():void {
	
	dataManager = DataManager.getInstance();
}

private function showHandler():void {
	
	
}

private function createApplication():void {
	
	var name:String = applicationName.text;
	var description:String = applicationDescription.text;
	
	dataManager.createApplication(name, description);
}