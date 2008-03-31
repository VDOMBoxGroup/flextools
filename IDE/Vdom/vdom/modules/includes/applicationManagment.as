import flash.events.Event;

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;
import mx.events.ListEvent;

import vdom.managers.DataManager;

[Bindable]
private var dataManager:DataManager;

private var watchers:Array;

private var moduleReady:Boolean;

private function creationCompleteHandler():void {
	
	dataManager = DataManager.getInstance();
}

private function showHandler():void {
	
	watchers = [];
	
	listApplicationContainer.applicationID;
	
	watchers.push(
		BindingUtils.bindProperty(listApplicationContainer, 'dataProvider', dataManager, 'listApplication')
	);
	
	
	createApplicationCanvas.addEventListener('createApplication', createApplicationHandler);
	
	selectedChild = components;
	mainViewStack.selectedIndex = 0;
}

private function hideHandler():void {
	
	for each(var watcher:ChangeWatcher in watchers)
		watcher.unwatch();
	
	mainViewStack.selectedIndex = 0;
	selectedChild = initModule;
}

private function createApplicationHandler(event:Event):void {
	
	mainViewStack.selectedChild = mainCanvas;
}

private function applicationChangedHandler(event:ListEvent):void {
	
	dataManager.changeCurrentApplication(listApplicationContainer.applicationID);
}