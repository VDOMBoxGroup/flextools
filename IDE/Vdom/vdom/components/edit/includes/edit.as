import flash.events.Event;

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;
import mx.containers.Canvas;
import mx.managers.PopUpManager;

import vdom.components.edit.events.EditEvent;
import vdom.events.DataManagerEvent;
import vdom.managers.DataManager;

[Bindable] private var dataManager:DataManager;
[Bindable] private var help:String;
	
private var objectsXML:XML;
//private var currInterfaceType:uint;
private var publicData:Object;
private var ppm:Canvas;
private var applicationId:String;
private var topLevelObjectId:String;
private var watchers:Array;

private function initializeHandler():void {
	
	dataManager = DataManager.getInstance();
}

private function showHandler():void {
	
	watchers = [];
	
	setListeners(true);
	
	watchers.push(
		BindingUtils.bindProperty(pageList, 'dataProvider', dataManager, 'listPages'),
		BindingUtils.bindProperty(pageList, 'currentObject', dataManager, 'currentObject'),
		BindingUtils.bindProperty(workArea, 'pageId', dataManager, 'currentPageId'),
		BindingUtils.bindProperty(attributesPanel, 'dataProvider', dataManager, 'currentObject')
	);
}

private function hideHandler():void {
	
	for each(var watcher:ChangeWatcher in watchers)
		watcher.unwatch();
	
	mainArea.selectedChild = workArea;
	
	setListeners(false);
}

private function setListeners(flag:Boolean):void {
	
	if(flag) {
		
		workArea.addEventListener(EditEvent.OBJECT_CHANGE, objectChangeHandler);
		workArea.addEventListener(EditEvent.PROPS_CHANGED, workAreaAttributeChangedHandler);
		workArea.addEventListener(EditEvent.DELETE_OBJECT, deleteObjectHandler);
		
		dataManager.addEventListener(DataManagerEvent.PAGE_DATA_LOADED, pageDataLoadedHandler);
		dataManager.addEventListener(DataManagerEvent.OBJECT_DELETED, objectDeletedHandler);
		dataManager.addEventListener(DataManagerEvent.OBJECTS_CREATED, objectCreatedHandler);
		dataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributesCompleteHandler);
		
		attributesPanel.addEventListener('propsChanged', attributesChangedHandler);
		attributesPanel.addEventListener(EditEvent.DELETE_OBJECT, deleteObjectHandler);
		
	} else {
		
		workArea.removeEventListener(EditEvent.OBJECT_CHANGE, objectChangeHandler);
		workArea.removeEventListener(EditEvent.PROPS_CHANGED, workAreaAttributeChangedHandler);
		workArea.removeEventListener(EditEvent.DELETE_OBJECT, deleteObjectHandler);
		
		dataManager.removeEventListener(DataManagerEvent.PAGE_DATA_LOADED, pageDataLoadedHandler);
		dataManager.removeEventListener(DataManagerEvent.OBJECT_DELETED, objectDeletedHandler);
		dataManager.removeEventListener(DataManagerEvent.OBJECTS_CREATED, objectCreatedHandler);
		dataManager.removeEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributesCompleteHandler);
		
		attributesPanel.removeEventListener('propsChanged', attributesChangedHandler);
		attributesPanel.removeEventListener(EditEvent.DELETE_OBJECT, deleteObjectHandler);
	}
}

private function pageDataLoadedHandler(event:Event):void {
	
	PopUpManager.removePopUp(ppm);
	workArea.visible = true;
}

private function objectCreatedHandler(event:DataManagerEvent):void {
	
	workArea.createObject(event.result);
}

private function attributesChangedHandler(event:Event):void {
	
	dataManager.updateAttributes();
	//attributesPanel.dataProvider = dataManager.currentObject; //<-- исправить!!!!!!
}

private function workAreaAttributeChangedHandler(event:EditEvent):void {
	
	dataManager.updateAttributes(event.objectId, event.props);
}

private function updateAttributesCompleteHandler(event:DataManagerEvent):void {
	
	workArea.updateObject(event.result);
}

private function objectChangeHandler(event:EditEvent):void {
	
	if(event.objectId) {
		
		dataManager.changeCurrentObject(event.objectId);
	} else {
		
		dataManager.changeCurrentObject(null);
	}
}

private function deleteObjectHandler(event:EditEvent):void {
	
	dataManager.deleteObject(event.objectId);
}

private function objectDeletedHandler(event:DataManagerEvent):void {
	
	workArea.deleteObject(event.objectId);
}
