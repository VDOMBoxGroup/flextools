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

[Bindable] private var objects:XML;
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
	publicData = mx.core.Application.application.publicData;
	editorDataManager = DataManager.getInstance();

	/*Загрузка типов*/
	
	addEventListener('objectCreated', objectCreatedHandler);
	
	workArea.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
	workArea.addEventListener(DragEvent.DRAG_DROP, dropHandler);
	
	workArea.addEventListener(WorkAreaEvent.OBJECT_CHANGE, objectChangeHandler);
	workArea.addEventListener(WorkAreaEvent.PROPS_CHANGE, attributesChangedHandler);
	workArea.addEventListener(WorkAreaEvent.DELETE_OBJECT, deleteObjectHandler);
	
	editorDataManager.addEventListener(DataManagerEvent.OBJECT_DELETED, objectDeletedHandler);
	editorDataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, attributesUpdateCompleteHandler);
	
	attributesPanel.addEventListener('propsChanged', attributesChangedHandler);
	
	typesXML = null;
}

private function show():void {
	
	
	
	if(applicationId != publicData['applicationId'] || topLevelObjectId != publicData['topLevelObjectId']) {
		
		applicationId = publicData['applicationId'];
		topLevelObjectId = publicData['topLevelObjectId'];
		PopUpManager.addPopUp(ppm, this, true);
		PopUpManager.centerPopUp(ppm);
		createTopLevelObject();	
	} else {
		workArea.visible = true;
	}
}

private function hide():void {
	
	workArea.visible = false;
}

private function createTopLevelObject():void {
	
	editorDataManager.addEventListener(DataManagerEvent.INIT_COMPLETE, initCompleteHandler);
	editorDataManager.init(applicationId, topLevelObjectId);
}

private function createTypes():void {
	
	typesXML = publicData['types'];
	PopUpManager.removePopUp(ppm);
}

private function topLevelObjectChange():void {
	
	topLevelObjectId = publicData['topLevelObjectId'] = pageList.selectedItem.@ID;
	createTopLevelObject();
}

private function createObjects(objectsXML:XML):void {
	
	workArea.destroyObjects();
	
	for each(var objectAttrs:XML in objectsXML.Object) {
		
		workArea.addObject(objectAttrs);
	}
	
	dispatchEvent(new Event('objectCreated'));	
	createTypes();
}

private function initCompleteHandler(event:Event):void {
	
	pageList.dataProvider = editorDataManager.topLevelObjects.Object;
	createObjects(editorDataManager.getObjects());
}

private function attributesUpdateCompleteHandler(event:DataManagerEvent):void {
	
	workArea.updateObject(editorDataManager.getAttributes(event.objectId));
}

private function attributesChangedHandler(event:Event):void {
	
	editorDataManager.updateAttributes(editorDataManager.objectDescription);
	attributesPanel.dataProvider = editorDataManager.objectDescription; //<-- исправить!!!!!!
}

private function typesLoadHandler(event:Event):void {
	
	typesXML = editorDataManager.types;
}

private function objectsLoadHandler(event:Event):void {
	
	objectsXML = editorDataManager.getObjects();
	createObjects(objectsXML);
}

private function objectChangeHandler(event:Event):void {
	
	if(workArea.selectedObjectId) {
		
		editorDataManager.setActiveObject(workArea.selectedObjectId);
	} else {
		
		editorDataManager.objectDescription = null;
	}
}

private function objectCreatedHandler(event:Event):void {
	
	objects = editorDataManager.getObjects();
	workArea.visible = true;
	PopUpManager.removePopUp(ppm);
}

private function deleteObjectHandler(event:WorkAreaEvent):void {
	
	editorDataManager.deleteObject(event.objectID);
}

private function objectDeletedHandler(event:DataManagerEvent):void {
	
	workArea.deleteObject(event.objectId);
}

private function dragEnterHandler(event:DragEvent):void {
	
	var curr:Canvas = Canvas(event.currentTarget);
	VdomDragManager.acceptDragDrop(curr);
}

private function dropHandler(event:DragEvent):void {
	
	var workArea:WorkArea = WorkArea(event.currentTarget);
	
	var bm:EdgeMetrics = workArea.borderMetrics;
	
	var typeId:String = event.dragSource.dataForFormat('Object').typeId;
	var type:Object = editorDataManager.getType(typeId);
	
	/* Patch: проверка типа родителя */
	if(type.Information.Containers != 'HTML') {
		Alert.show('Not aviable');
		return;
	}
	
	var objectLeft:Number = workArea.mouseX - 25 - bm.left;
	var objectTop:Number = workArea.mouseY - 25 - bm.top;
	
	objectLeft = (objectLeft < 0) ? 0 : objectLeft;
	objectTop = (objectTop < 0) ? 0 : objectTop;
	
	var initProp:Object = {};
	
	initProp.typeId = typeId;
	initProp.left = objectLeft;
	initProp.top = objectTop;
	
	var id:String = editorDataManager.createObject(initProp);
	
	var newItemAtrs:XML = editorDataManager.getAttributes(id);
	
	workArea.addObject(newItemAtrs);
}