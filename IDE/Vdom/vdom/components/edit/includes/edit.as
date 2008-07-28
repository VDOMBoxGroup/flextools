import flash.events.Event;

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;
import mx.containers.Canvas;
import mx.managers.PopUpManager;

import vdom.events.AttributesPanelEvent;
import vdom.events.DataManagerEvent;
import vdom.events.WorkAreaEvent;
import vdom.managers.DataManager;

[Bindable] private var dataManager:DataManager;
[Bindable] private var help:String;
	
private var objectsXML:XML;
private var publicData:Object;
private var applicationId:String;
private var topLevelObjectId:String;
private var watchers:Array;

override protected function updateDisplayList(unscaledWidth:Number, 
													unscaledHeight:Number):void
{
	super.updateDisplayList(unscaledWidth, unscaledHeight);
	types.height = unscaledHeight;
	mainArea.height = unscaledHeight;
	panelContainer.height = unscaledHeight;
}

private function initializeHandler():void
{	
	dataManager = DataManager.getInstance();
}

private function showHandler():void
{	
	watchers = [];
	
	registerEvent(true);
	
	watchers.push(
		BindingUtils.bindProperty(pageList, 'dataProvider', dataManager, 'listPages'),
		BindingUtils.bindProperty(pageList, 'currentObject', dataManager, 'currentObject'),
		BindingUtils.bindProperty(workArea, 'pageId', dataManager, 'currentPageId'),
		BindingUtils.bindProperty(workArea, 'objectId', dataManager, 'currentObjectId'),
		BindingUtils.bindProperty(attributesPanel, 'dataProvider', dataManager, 'currentObject')
	);
}

private function hideHandler():void
{	
	for each(var watcher:ChangeWatcher in watchers)
		watcher.unwatch();
	
	mainArea.selectedChild = workArea;
	
	registerEvent(false);
}

private function registerEvent(flag:Boolean):void
{	
	if(flag)
	{
		workArea.addEventListener(WorkAreaEvent.CREATE_OBJECT, workArea_createObjectHandler);
		workArea.addEventListener(WorkAreaEvent.CHANGE_OBJECT, workArea_changeObjectHandler);
		workArea.addEventListener(WorkAreaEvent.PROPS_CHANGED, workArea_attributeChangedHandler);
		
		dataManager.addEventListener(DataManagerEvent.PAGE_DATA_LOADED, pageDataLoadedHandler);
		
		dataManager.addEventListener(DataManagerEvent.OBJECTS_CREATED, dataManager_objectCreatedHandler);
		dataManager.addEventListener(DataManagerEvent.CURRENT_OBJECT_CHANGED, dataManager_objectChangedHandler);
		dataManager.addEventListener(DataManagerEvent.OBJECT_DELETED, dataManager_objectDeletedHandler);
		
		dataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_BEGIN, updateAttributesBeginHandler);
		dataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributesCompleteHandler);
		dataManager.addEventListener(DataManagerEvent.RESOURCE_MODIFIED, updateAttributesCompleteHandler);
		
		attributesPanel.addEventListener('propsChanged', attributesChangedHandler);
		attributesPanel.addEventListener(AttributesPanelEvent.DELETE_OBJECT, deleteObjectHandler);
	}
	else 
	{	
		workArea.removeEventListener(WorkAreaEvent.CREATE_OBJECT, workArea_createObjectHandler);
		workArea.removeEventListener(WorkAreaEvent.CHANGE_OBJECT, workArea_changeObjectHandler);
		workArea.removeEventListener(WorkAreaEvent.PROPS_CHANGED, workArea_attributeChangedHandler);
		
		dataManager.removeEventListener(DataManagerEvent.PAGE_DATA_LOADED, pageDataLoadedHandler);
		
		dataManager.removeEventListener(DataManagerEvent.OBJECTS_CREATED, dataManager_objectCreatedHandler);
		dataManager.removeEventListener(DataManagerEvent.CURRENT_OBJECT_CHANGED, dataManager_objectChangedHandler);
		dataManager.removeEventListener(DataManagerEvent.OBJECT_DELETED, dataManager_objectDeletedHandler);
		
		dataManager.removeEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_BEGIN, updateAttributesBeginHandler);
		dataManager.removeEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributesCompleteHandler);
		
		attributesPanel.removeEventListener('propsChanged', attributesChangedHandler);
		attributesPanel.removeEventListener(AttributesPanelEvent.DELETE_OBJECT, deleteObjectHandler);
	}
}

private function pageDataLoadedHandler(event:Event):void
{
	workArea.visible = true;
}

private function attributesChangedHandler(event:Event):void
{	
	dataManager.updateAttributes();
	//attributesPanel.dataProvider = dataManager.currentObject; //<-- исправить!!!!!!
}

private function updateAttributesBeginHandler(event:DataManagerEvent):void
{
	var attrName:String;
	
	for each(var attr:XML in event.result.*)
	{
		attrName = attr.@Name;
		if(attrName == "top" || attrName  == "left")
			continue;
		
		workArea.lockItem(dataManager.currentObjectId);
		break;
	}
}

private function updateAttributesCompleteHandler(event:DataManagerEvent):void
{	
	workArea.updateObject(event.result);
}

private function workArea_createObjectHandler(event:Event):void
{	
	var evt:WorkAreaEvent = WorkAreaEvent(event);
	dataManager.createObject(evt.typeId, evt.objectId, '', evt.props);
}

private function workArea_changeObjectHandler(event:WorkAreaEvent):void
{	
	if(event.objectId) {
		
		dataManager.changeCurrentObject(event.objectId);
	} else {
		
		dataManager.changeCurrentObject(null);
	}
}

private function workArea_attributeChangedHandler(event:WorkAreaEvent):void
{	
	dataManager.updateAttributes(event.objectId, event.props);
}

private function deleteObjectHandler(event:AttributesPanelEvent):void
{	
	if(event.objectId);
		dataManager.deleteObject(event.objectId);
}

private function dataManager_objectCreatedHandler(event:DataManagerEvent):void
{	
	workArea.createObject(event.result);
}

private function dataManager_objectChangedHandler(event:DataManagerEvent):void
{
	if(!dataManager.currentPageId)
		return;
	
	if(!dataManager.currentObjectId)
		dataManager.changeCurrentObject(dataManager.currentPageId);
}

private function dataManager_objectDeletedHandler(event:DataManagerEvent):void
{	
	workArea.deleteObject(event.objectId);
}
