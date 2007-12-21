import flash.display.DisplayObject;
import flash.events.Event;

import mx.containers.Canvas;
import mx.controls.Alert;
import mx.core.EdgeMetrics;
import mx.events.DragEvent;
import mx.managers.PopUpManager;

import vdom.MyLoader;
import vdom.components.editor.containers.WorkArea;
import vdom.components.editor.containers.typesClasses.Type;
import vdom.components.editor.events.ResizeManagerEvent;
import vdom.components.editor.events.WorkAreaEvent;
import vdom.events.DataManagerEvent;
import vdom.managers.DataManager;
import vdom.managers.VdomDragManager;
import vdom.components.editor.containers.workAreaClasses.Item;
import mx.core.Application;

//[Bindable] private var objects:XML;
[Bindable] private var typesXML:XML;
[Bindable] private var help:String;
[Bindable] private var selectedElement:String;
[Bindable] private var dataManager:DataManager;

private var objectsXML:XML;
private var currInterfaceType:uint;
private var publicData:Object;
private var ppm:Canvas;
private var applicationId:String;
private var topLevelObjectId:String;

private function creationCompleteHandler():void {
	
	ppm = new MyLoader();
	publicData = Application.application.publicData;
	dataManager = DataManager.getInstance();

	/*Загрузка типов*/
	
	//addEventListener('objectCreated', objectCreatedHandler);
	
	//workArea.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
	//workArea.addEventListener(DragEvent.DRAG_DROP, dropHandler);
	
	
	
	//typesXML = null;
}

private function showHandler():void {
	
	if(applicationId != publicData['applicationId'] || topLevelObjectId != publicData['topLevelObjectId']) {
		
		applicationId = publicData['applicationId'];
		topLevelObjectId = publicData['topLevelObjectId'];
		PopUpManager.addPopUp(ppm, this, true);
		PopUpManager.centerPopUp(ppm);
		dataManager.init(applicationId, topLevelObjectId);	
	} else {
		
		workArea.visible = true;
	}
	
	workArea.addEventListener(WorkAreaEvent.OBJECT_CHANGE, objectChangeHandler);
	workArea.addEventListener(WorkAreaEvent.PROPS_CHANGE, attributesChangedHandler);
	workArea.addEventListener(WorkAreaEvent.DELETE_OBJECT, deleteObjectHandler);
	
	dataManager.addEventListener(DataManagerEvent.INIT_COMPLETE, initCompleteHandler);
	dataManager.addEventListener(DataManagerEvent.OBJECT_DELETED, objectDeletedHandler);
	dataManager.addEventListener(DataManagerEvent.OBJECTS_CREATED, objectCreatedHandler);
	dataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributesCompleteHandler);
	
	attributesPanel.addEventListener('propsChanged', attributesChangedHandler);
}

private function hideHandler():void {
	
	workArea.removeEventListener(WorkAreaEvent.OBJECT_CHANGE, objectChangeHandler);
	workArea.removeEventListener(WorkAreaEvent.PROPS_CHANGE, attributesChangedHandler);
	workArea.removeEventListener(WorkAreaEvent.DELETE_OBJECT, deleteObjectHandler);
	
	dataManager.removeEventListener(DataManagerEvent.INIT_COMPLETE, initCompleteHandler);
	dataManager.removeEventListener(DataManagerEvent.OBJECT_DELETED, objectDeletedHandler);
	dataManager.removeEventListener(DataManagerEvent.OBJECTS_CREATED, objectCreatedHandler);
	dataManager.removeEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributesCompleteHandler);
	
	attributesPanel.removeEventListener('propsChanged', attributesChangedHandler);
	
	workArea.visible = false;
}

/* private function createTypes():void {
	
	typesXML = publicData['types'];
	PopUpManager.removePopUp(ppm);
} */

private function topLevelObjectChange():void {
	
	topLevelObjectId = publicData['topLevelObjectId'] = pageList.selectedItem.@ID;
	dataManager.init(applicationId, topLevelObjectId);
}

/* private function createObjects(objectsXML:XML):void {
	
	workArea.createObjects(publicData['applicationId'], publicData['topLevelObjectId']);
	
	dispatchEvent(new Event('objectCreated'));	
	createTypes();
} */

private function initCompleteHandler(event:Event):void {
	
	pageList.dataProvider = dataManager.topLevelObjects.Object;
	workArea.createObjects(publicData['applicationId'], publicData['topLevelObjectId']);
	typesXML = publicData['types'];
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
	
	dataManager.updateAttributes(dataManager.objectDescription);
	attributesPanel.dataProvider = dataManager.objectDescription; //<-- исправить!!!!!!
}

private function updateAttributesCompleteHandler(event:DataManagerEvent):void {
	
	workArea.updateObject(event.result);
}

private function typesLoadHandler(event:Event):void {
	
	typesXML = dataManager.types;
}

/* private function objectsLoadHandler(event:Event):void {
	
	objectsXML = dataManager.getObjects();
	createObjects(objectsXML);
} */

private function objectChangeHandler(event:Event):void {
	
	if(workArea.selectedObjectId) {
		
		dataManager.setActiveObject(workArea.selectedObjectId);
	} else {
		
		dataManager.objectDescription = null;
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

