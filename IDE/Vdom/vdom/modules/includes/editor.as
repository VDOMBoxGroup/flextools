import flash.net.URLRequest;
import flash.net.navigateToURL;

import mx.containers.Canvas;

import vdom.events.DataManagerEvent;
import vdom.managers.AuthenticationManager;
import vdom.managers.DataManager;

private var dataManager:DataManager = DataManager.getInstance();
private var authenticationManager:AuthenticationManager = AuthenticationManager.getInstance();
private var defaultComponent:Canvas;

private function showPreview():void
{	
	var ip:String = authenticationManager.ip;
	var applicationId:String = dataManager.currentApplicationId;
	var pageId:String = dataManager.currentPageId;
	navigateToURL(new URLRequest('http://' + ip + '/' + applicationId + '/' + pageId), '_blank');
}

private function showHandler():void
{		
	dataManager.addEventListener(
		DataManagerEvent.APPLICATION_DATA_LOADED,
		dataManager_applicationDataLoadedHandler
	);
	
	dataManager.loadApplicationData();
}

private function hideHandler():void {
	
	placeCanvas.selectedIndex = 0;
	selectedChild = initModule;
}

private function dataManager_applicationDataLoadedHandler(event:DataManagerEvent):void
{	
	dataManager.removeEventListener(
		DataManagerEvent.APPLICATION_DATA_LOADED, 
		dataManager_applicationDataLoadedHandler
	);
	
	selectedChild = components;
	placeCanvas.selectedIndex = 1;
}