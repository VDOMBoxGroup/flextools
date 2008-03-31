import flash.events.Event;

import mx.containers.Canvas;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

import vdom.components.edit.events.WorkAreaEvent;
import vdom.events.DataManagerEvent;
import vdom.managers.DataManager;

//[Bindable] private var objects:XML;
[Bindable] private var help:String;
//[Bindable] private var selectedElement:String;
[Bindable] private var dataManager:DataManager;
	
private var objectsXML:XML;
private var currInterfaceType:uint;
private var publicData:Object;
private var ppm:Canvas;
private var applicationId:String;
private var topLevelObjectId:String;

private function initializeHandler():void {
	
	dataManager = DataManager.getInstance();
}

private function creationCompleteHandler():void {
	
	//dispatchEvent(new FlexEvent(FlexEvent.SHOW));
}

private function showHandler():void {
	
	setListeners(true);
	
	if(dataManager.currentPageId)
		dataManager.loadPageData();
}

private function hideHandler():void {
	
	setListeners(false);
}

private function topLevelObjectChange():void {
	
	topLevelObjectId = publicData['topLevelObjectId'] = pageList.selectedItem.@ID;
	//dataManager.init(applicationId, topLevelObjectId);
}

/* private function createObjects(objectsXML:XML):void {
	
	workArea.createObjects(publicData['applicationId'], publicData['topLevelObjectId']);
	
	dispatchEvent(new Event('objectCreated'));	
	createTypes();
} */

private function setListeners(flag:Boolean):void {
	
	if(flag) {
		
		workArea.addEventListener(WorkAreaEvent.OBJECT_CHANGE, objectChangeHandler);
		workArea.addEventListener(WorkAreaEvent.PROPS_CHANGED, attributesChangedHandler);
		workArea.addEventListener(WorkAreaEvent.DELETE_OBJECT, deleteObjectHandler);
		
		dataManager.addEventListener(DataManagerEvent.PAGE_DATA_LOADED, pageDataLoadedHandler);
		dataManager.addEventListener(DataManagerEvent.OBJECT_DELETED, objectDeletedHandler);
		dataManager.addEventListener(DataManagerEvent.OBJECTS_CREATED, objectCreatedHandler);
		dataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributesCompleteHandler);
		
		attributesPanel.addEventListener('propsChanged', attributesChangedHandler);
		
	} else {
		
		workArea.removeEventListener(WorkAreaEvent.OBJECT_CHANGE, objectChangeHandler);
		workArea.removeEventListener(WorkAreaEvent.PROPS_CHANGED, attributesChangedHandler);
		workArea.removeEventListener(WorkAreaEvent.DELETE_OBJECT, deleteObjectHandler);
		
		dataManager.removeEventListener(DataManagerEvent.PAGE_DATA_LOADED, pageDataLoadedHandler);
		dataManager.removeEventListener(DataManagerEvent.OBJECT_DELETED, objectDeletedHandler);
		dataManager.removeEventListener(DataManagerEvent.OBJECTS_CREATED, objectCreatedHandler);
		dataManager.removeEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributesCompleteHandler);
		
		attributesPanel.removeEventListener('propsChanged', attributesChangedHandler);
	}
}

private function pageDataLoadedHandler(event:Event):void {
	
	//pageList.dataProvider = dataManager.listPages.Object;
	
	//workArea.showTopLevelContainer(dataManager.currentApplicationId, dataManager.currentPageId);
	
	//typesXML = publicData['types'];
	PopUpManager.removePopUp(ppm);
	workArea.visible = true;
	//dispatchEvent(new Event('objectCreated'));
	//createTypes();
	//createObjects(dataManager.getObjects());
}

private function objectCreatedHandler(event:DataManagerEvent):void {
	
	workArea.createObject(event.result);
}

private function attributesChangedHandler(event:Event):void {
	
	dataManager.updateAttributes();
	//attributesPanel.dataProvider = dataManager.currentObject; //<-- исправить!!!!!!
}

private function updateAttributesCompleteHandler(event:DataManagerEvent):void {
	
	workArea.updateObject(event.result);
}

/* private function typesLoadHandler(event:Event):void {
	
	typesXML = dataManager.types;
} */

/* private function objectsLoadHandler(event:Event):void {
	
	objectsXML = dataManager.getObjects();
	createObjects(objectsXML);
} */

private function objectChangeHandler(event:Event):void {
	
	if(workArea.selectedObjectId) {
		
		dataManager.changeCurrentObject(workArea.selectedObjectId);
	} else {
		
		dataManager.changeCurrentObject(null);
	}
}

/* private function objectCreatedHandler(event:Event):void {
	
	//objects = dataManager.getObjects();
	workArea.visible = true;
	PopUpManager.removePopUp(ppm);
} */

private function deleteObjectHandler(event:WorkAreaEvent):void {
	
	dataManager.deleteObject(event.objectID);
}

private function objectDeletedHandler(event:DataManagerEvent):void {
	
	workArea.deleteObject(event.objectId);
}

