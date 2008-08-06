import flash.net.URLRequest;
import flash.net.navigateToURL;

import mx.managers.PopUpManager;

import vdom.MyLoader;
import vdom.events.DataManagerEvent;
import vdom.managers.AlertManager;
import vdom.managers.AuthenticationManager;
import vdom.managers.DataManager;

private var dataManager:DataManager = DataManager.getInstance();
private var authenticationManager:AuthenticationManager = AuthenticationManager.getInstance();
private var alertManager:AlertManager = AlertManager.getInstance();

private function showPreview():void
{	
	var ip:String = authenticationManager.ip;
	var applicationId:String = dataManager.currentApplicationId;
	var pageId:String = dataManager.currentPageId;
	navigateToURL(new URLRequest('http://' + ip + '/' + applicationId + '/' + pageId), '_blank');
}

private function registerEvent(flag:Boolean):void 
{
	if(flag)
	{
		dataManager.addEventListener(
			DataManagerEvent.APPLICATION_DATA_LOADED,
			dataManager_applicationDataLoaded
		);
		
		dataManager.addEventListener(
			DataManagerEvent.CURRENT_PAGE_CHANGED,
			dataManager_pageChanged
		);
		
		dataManager.addEventListener(
			DataManagerEvent.CURRENT_OBJECT_CHANGED,
			dataManager_objectChanged
		);
	}
	else
	{
		dataManager.removeEventListener(
			DataManagerEvent.APPLICATION_DATA_LOADED,
			dataManager_applicationDataLoaded
		);
		
		dataManager.removeEventListener(
			DataManagerEvent.CURRENT_PAGE_CHANGED,
			dataManager_pageChanged
		);
		
		dataManager.removeEventListener(
			DataManagerEvent.CURRENT_OBJECT_CHANGED,
			dataManager_objectChanged
		);
	}
}

private function switchToEdit():void
{	
	alertManager.showMessage('');
	registerEvent(false);
	selectedChild = components;
	placeCanvas.selectedIndex = 1;
}

private function showHandler():void
{	
	registerEvent(true);
	
	var applicationId:String = dataManager.currentApplicationId;
	
	if(!applicationId)
		return;
	
	if(!dataManager.applicationStatus(applicationId))
	{
		loadApplicationData();
		return;
	}
	
	var pageId:String = dataManager.currentPageId;
	
	if(!pageId && !dataManager.pageStatus(applicationId, pageId))
	{
		selectPage();
		return;
	}
	
	var objectId:String = dataManager.currentObjectId;
	
	if(!objectId)
	{
		selectObject();
		return;
	}
	
	switchToEdit();
}

private function hideHandler():void {
	
	placeCanvas.selectedIndex = 0;
	selectedChild = initModule;
	registerEvent(false);
}

private function loadApplicationData():void
{
	alertManager.showMessage("Load Application Data");
	dataManager.loadApplication(dataManager.currentApplicationId);
}

private function selectPage():void
{	
	if(dataManager.listPages.length() > 0)
	{
		var page:XML = dataManager.listPages[0]
		dataManager.changeCurrentPage(page.@ID);
	}
	else
	{
		switchToEdit();
	}
}

private function selectObject():void
{	
	if(dataManager.currentPageId)
		dataManager.changeCurrentObject(dataManager.currentPageId);
}

private function dataManager_applicationDataLoaded(event:DataManagerEvent):void
{	
	alertManager.showMessage("Load Page Data");
	selectPage();
}

private function dataManager_pageChanged(event:DataManagerEvent):void
{	
	selectObject();
}

private function dataManager_objectChanged(event:DataManagerEvent):void
{	
	switchToEdit();
}