import flash.events.Event;

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;
import mx.events.ListEvent;

import vdom.events.DataManagerEvent;
import vdom.events.SearchPanelEvent;
import vdom.events.SearchResultEvent;
import vdom.managers.DataManager;

[Bindable]
private var dataManager:DataManager;

private var watchers:Array;

private var moduleReady:Boolean;

private function creationCompleteHandler():void
{	
	dataManager = DataManager.getInstance();
}

private function showHandler():void
{	
	registerEvent(true);
	
	watchers = [];
	
	watchers.push(
		BindingUtils.bindProperty(searchPanel, 'listApplication', dataManager, 'listApplication'),
		BindingUtils.bindProperty(listApplicationContainer, 'dataProvider', dataManager, 'listApplication'),
		BindingUtils.bindProperty(listApplicationContainer, 'applicationId', dataManager, 'currentApplicationId')
	);
	
	selectedChild = components;
	
	if(listApplicationContainer.applicationId)
		mainViewStack.selectedChild = applicationProperties;
	else
		mainViewStack.selectedIndex = 0;
}

private function hideHandler():void
{
	registerEvent(false);
	
	for each(var watcher:ChangeWatcher in watchers){
		watcher.unwatch();
	}
	
	mainViewStack.selectedIndex = 0;
	selectedChild = initModule;
}

private function registerEvent(flag:Boolean):void
{	
	if(flag) {
		
		createApplication.addEventListener('createApplication', createApplicationHandler);
		createApplication.addEventListener('applicationCreated', switchToProperties);
		
		searchPanel.addEventListener(SearchPanelEvent.SEARCH_PARAM_CHANGED, searchPanel_searchHandler);
		searchResult.addEventListener(SearchResultEvent.SEARCH_OBJECT_SELECTED, searchResult_searchHandler);
		
		listApplicationContainer.addEventListener('applicationChanged', applicationChangedHandler);
		
		applicationProperties.addEventListener('editCurrentApplication', switchToEdit);
		editApplication.addEventListener('applicationEdited', switchToProperties);
	} else {
		
		createApplication.removeEventListener('createApplication', createApplicationHandler);
		createApplication.removeEventListener('applicationCreated', switchToProperties);
		
		searchPanel.removeEventListener(SearchPanelEvent.SEARCH_PARAM_CHANGED, searchPanel_searchHandler);
		searchResult.removeEventListener(SearchResultEvent.SEARCH_OBJECT_SELECTED, searchResult_searchHandler);
		
		listApplicationContainer.removeEventListener('applicationChanged', applicationChangedHandler);
		
		applicationProperties.removeEventListener('editCurrentApplication', switchToEdit);
		editApplication.removeEventListener('applicationEdited', switchToProperties);
	}
}

private function switchToCreate():void
{
	listApplicationContainer.enabled = false;
	mainViewStack.selectedChild = createApplication
}

private function switchToEdit(event:Event):void
{
	listApplicationContainer.enabled = false;
	mainViewStack.selectedChild = editApplication;
}

private function switchToProperties(event:Event):void
{
	listApplicationContainer.enabled = true;
	mainViewStack.selectedChild = applicationProperties;
}

private function createApplicationHandler(event:Event):void
{	
	mainViewStack.selectedChild = mainCanvas;
}

private function applicationChangedHandler(event:ListEvent):void
{	
	dataManager.changeCurrentApplication(listApplicationContainer.applicationId);
}

private function searchPanel_searchHandler(event:SearchPanelEvent):void
{
	dataManager.addEventListener(DataManagerEvent.SEARCH_COMPLETE, dataManager_searchCompleteHandler);
	dataManager.search(event.applicationId, event.searchString);
}

private function searchResult_searchHandler():void
{
	
}

private function dataManager_searchCompleteHandler(event:DataManagerEvent):void
{
	dataManager.removeEventListener(DataManagerEvent.SEARCH_COMPLETE, dataManager_searchCompleteHandler);
	searchResult.dataProvider = event.result.*;
	mainViewStack.selectedChild = searchResult;
}