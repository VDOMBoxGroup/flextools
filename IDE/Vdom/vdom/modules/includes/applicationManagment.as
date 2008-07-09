import flash.events.Event;

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;
import mx.events.ListEvent;

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
		BindingUtils.bindProperty(listApplicationContainer, 'dataProvider', dataManager, 'listApplication')
	);
	
	selectedChild = components;
	
	if(listApplicationContainer.applicationID)
		mainViewStack.selectedChild = applicationProperties;
	else
		mainViewStack.selectedIndex = 0;
}

private function registerEvent(flag:Boolean):void
{	
	if(flag) {
		
		createApplication.addEventListener('createApplication', createApplicationHandler);
		createApplication.addEventListener('applicationCreated', switchToProperties);
		listApplicationContainer.addEventListener('applicationChanged', applicationChangedHandler);
		applicationProperties.addEventListener('editCurrentApplication', switchToEdit);
		editApplication.addEventListener('applicationEdited', switchToProperties);
	} else {
		
		createApplication.removeEventListener('createApplication', createApplicationHandler);
		createApplication.removeEventListener('applicationCreated', switchToProperties);
		listApplicationContainer.removeEventListener('applicationChanged', applicationChangedHandler);
		applicationProperties.removeEventListener('editCurrentApplication', switchToEdit);
		editApplication.removeEventListener('applicationEdited', switchToProperties);
	}
}

private function hideHandler():void
{	
	for each(var watcher:ChangeWatcher in watchers){
		watcher.unwatch();
	}
	
	registerEvent(false);
	
	mainViewStack.selectedIndex = 0;
	selectedChild = initModule;
}

private function createApplicationHandler(event:Event):void
{	
	mainViewStack.selectedChild = mainCanvas;
}

private function applicationChangedHandler(event:ListEvent):void
{	
	dataManager.changeCurrentApplication(listApplicationContainer.applicationID);
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