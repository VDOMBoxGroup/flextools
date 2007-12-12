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
[Bindable] private var editorDataManager:DataManager;

private var objectsXML:XML;
private var currInterfaceType:uint;
private var publicData:Object;
private var ppm:Canvas;
private var applicationId:String;
private var topLevelObjectId:String;

private function creationCompleteHandler():void {
	
	ppm = new MyLoader();
	publicData = Application.application.publicData;
	editorDataManager = DataManager.getInstance();

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
		editorDataManager.init(applicationId, topLevelObjectId);	
	} else {
		
		workArea.visible = true;
	}
	
	workArea.addEventListener(WorkAreaEvent.OBJECT_CHANGE, objectChangeHandler);
	workArea.addEventListener(WorkAreaEvent.PROPS_CHANGE, attributesChangedHandler);
	workArea.addEventListener(WorkAreaEvent.DELETE_OBJECT, deleteObjectHandler);
	
	editorDataManager.addEventListener(DataManagerEvent.INIT_COMPLETE, initCompleteHandler);
	editorDataManager.addEventListener(DataManagerEvent.OBJECT_DELETED, objectDeletedHandler);
	editorDataManager.addEventListener(DataManagerEvent.OBJECTS_CREATED, objectCreatedHandler);
	editorDataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributesCompleteHandler);
	
	attributesPanel.addEventListener('propsChanged', attributesChangedHandler);
}

private function hideHandler():void {
	
	workArea.removeEventListener(WorkAreaEvent.OBJECT_CHANGE, objectChangeHandler);
	workArea.removeEventListener(WorkAreaEvent.PROPS_CHANGE, attributesChangedHandler);
	workArea.removeEventListener(WorkAreaEvent.DELETE_OBJECT, deleteObjectHandler);
	
	editorDataManager.removeEventListener(DataManagerEvent.INIT_COMPLETE, initCompleteHandler);
	editorDataManager.removeEventListener(DataManagerEvent.OBJECT_DELETED, objectDeletedHandler);
	editorDataManager.removeEventListener(DataManagerEvent.OBJECTS_CREATED, objectCreatedHandler);
	editorDataManager.removeEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributesCompleteHandler);
	
	attributesPanel.removeEventListener('propsChanged', attributesChangedHandler);
	
	workArea.visible = false;
}

/* private function createTypes():void {
	
	typesXML = publicData['types'];
	PopUpManager.removePopUp(ppm);
} */

private function topLevelObjectChange():void {
	
	topLevelObjectId = publicData['topLevelObjectId'] = pageList.selectedItem.@ID;
	editorDataManager.init(applicationId, topLevelObjectId);
}

/* private function createObjects(objectsXML:XML):void {
	
	workArea.createObjects(publicData['applicationId'], publicData['topLevelObjectId']);
	
	dispatchEvent(new Event('objectCreated'));	
	createTypes();
} */

private function initCompleteHandler(event:Event):void {
	
	pageList.dataProvider = editorDataManager.topLevelObjects.Object;
	workArea.createObjects(publicData['applicationId'], publicData['topLevelObjectId']);
	typesXML = publicData['types'];
	PopUpManager.removePopUp(ppm);
	workArea.visible = true;
	//dispatchEvent(new Event('objectCreated'));
	//createTypes();
	//createObjects(editorDataManager.getObjects());
}

private function objectCreatedHandler(event:DataManagerEvent):void {
	
	workArea.createObject(event.result);
}

private function attributesChangedHandler(event:Event):void {
	
	editorDataManager.updateAttributes(editorDataManager.objectDescription);
	attributesPanel.dataProvider = editorDataManager.objectDescription; //<-- исправить!!!!!!
}

private function updateAttributesCompleteHandler(event:DataManagerEvent):void {
	
	workArea.updateObject(event.result);
}

private function typesLoadHandler(event:Event):void {
	
	typesXML = editorDataManager.types;
}

/* private function objectsLoadHandler(event:Event):void {
	
	objectsXML = editorDataManager.getObjects();
	createObjects(objectsXML);
} */

private function objectChangeHandler(event:Event):void {
	
	if(workArea.selectedObjectId) {
		
		editorDataManager.setActiveObject(workArea.selectedObjectId);
	} else {
		
		editorDataManager.objectDescription = null;
	}
}

/* private function objectCreatedHandler(event:Event):void {
	
	//objects = editorDataManager.getObjects();
	workArea.visible = true;
	PopUpManager.removePopUp(ppm);
} */

private function deleteObjectHandler(event:WorkAreaEvent):void {
	
	editorDataManager.deleteObject(event.objectID);
}

private function objectDeletedHandler(event:DataManagerEvent):void {
	
	workArea.deleteObject(event.objectId);
}

