import mx.containers.Canvas;

import vdom.events.DataManagerEvent;
import vdom.managers.DataManager;

private var dataManager:DataManager;
private var defaultComponent:Canvas;

private function creationCompleteHandler():void {
	
	dataManager = DataManager.getInstance();
}

private function showHandler():void {
	
	if(!dataManager.typeLoaded) {
		
		dataManager.addEventListener(DataManagerEvent.TYPES_LOADED, loadTypesHandler);
		dataManager.loadTypes();
		
	} else {
		
		dataManager.addEventListener(DataManagerEvent.APPLICATION_DATA_LOADED, applicationDataLoadedHandler);
		dataManager.loadApplicationData();
	}
}

private function hideHandler():void {
	
	placeCanvas.selectedIndex = 0;
	selectedChild = initModule;
}

private function loadTypesHandler(event:DataManagerEvent):void {
	
	dataManager.removeEventListener(DataManagerEvent.TYPES_LOADED, loadTypesHandler);
	
	dataManager.addEventListener(DataManagerEvent.APPLICATION_DATA_LOADED, applicationDataLoadedHandler);
	dataManager.loadApplicationData();
}

private function applicationDataLoadedHandler(event:DataManagerEvent):void {
	
	dataManager.removeEventListener(DataManagerEvent.APPLICATION_DATA_LOADED, applicationDataLoadedHandler);
	
	selectedChild = components;
	placeCanvas.selectedIndex = 1;
}