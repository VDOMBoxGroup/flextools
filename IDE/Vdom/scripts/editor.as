import flash.events.Event;
import flash.display.DisplayObject;
import mx.core.EdgeMetrics;
import mx.events.DragEvent;
import mx.managers.PopUpManager;
import mx.containers.Canvas;
import mx.controls.Alert;

import vdom.components.editor.containers.typesClasses.Type;
import vdom.components.editor.containers.Workspace;
import vdom.components.editor.managers.VdomDragManager;
import vdom.components.editor.events.DataManagerEvent;
import vdom.components.editor.events.ResizeManagerEvent;
import vdom.managers.DataManager;
import vdom.MyLoader;

[Bindable] private var objects:XML;
[Bindable] private var objectDescription:XML;
[Bindable] private var typesXML:XML;
[Bindable] private var help:String;
[Bindable] private var selectedElement:String;
[Bindable] private var editorDataManager:DataManager;

private var objectsXML:XML;
private var currInterfaceType:uint;
private var publicData:Object;
private var ppm:Canvas;

private function init():void {
	
	ppm = new MyLoader();
	publicData = mx.core.Application.application.publicData;
	editorDataManager = DataManager.getInstance();
	pageList.selectedIndex = 0;

	/*Загрузка типов*/
	
	addEventListener('objectCreated', objectCreatedHandler);
	
	editorMainCanvas.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
	editorMainCanvas.addEventListener(DragEvent.DRAG_DROP, dropHandler);
	
	editorMainCanvas.addEventListener('objectChange', objectChangeHandler);
	editorMainCanvas.addEventListener('propsChanged', attributesChangedHandler);
	
	editorDataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, attributesUpdateCompleteHandler);
	
	objectAttributes.addEventListener('propsChanged', attributesChangedHandler);
	
	typesXML = null;
}

private function show():void {
	
	PopUpManager.addPopUp(ppm, this, true);
	PopUpManager.centerPopUp(ppm);
	createPage();	
}

private function createPage():void {
	
	editorDataManager.addEventListener('initComplete', initCompleteHandler);
	editorDataManager.init(publicData['appId'], publicData['pageId']);
}

private function hide():void {
	
	editorMainCanvas.visible = false;
}

private function createTypes():void {
	
	typesXML = publicData['types'];
	PopUpManager.removePopUp(ppm);
}

private function pageChange():void {
	
	publicData['pageId'] = pageList.selectedItem.@ID;
	createPage();
}

private function createObjects(objectsXML:XML):void {
	
	editorMainCanvas.destroyObjects();
	
	for each(var itemAttrs:XML in objectsXML.Object) {
		
		editorMainCanvas.addObject(itemAttrs);
	}
	
	dispatchEvent(new Event('objectCreated'));	
	createTypes();
}

private function initCompleteHandler(event:Event):void {
	
	createObjects(editorDataManager.getObjects());
}

private function attributesUpdateCompleteHandler(event:DataManagerEvent):void {
	
	editorMainCanvas.updateObject(editorDataManager.getAttributes(event.objectId));
	objectDescription = editorDataManager.getFullAttributes(event.objectId);
}

private function attributesChangedHandler(event:Event):void {
	
	editorDataManager.updateAttributes(objectDescription);
}

private function typesLoadHandler(event:Event):void {
	
	typesXML = editorDataManager.types;
}

private function objectsLoadHandler(event:Event):void {
	
	objectsXML = editorDataManager.objectsXML;
	createObjects(objectsXML);
}

private function objectChangeHandler(event:Event):void {
	
	if(editorMainCanvas.selectedObject) {
		objectDescription = editorDataManager.getFullAttributes(editorMainCanvas.selectedObject);
	} else {
		objectDescription = null;
	}
	toolbar.type = objectDescription;
}

private function objectCreatedHandler(event:Event):void {
	
	objects = editorDataManager.getObjects();
	editorMainCanvas.visible = true;
	PopUpManager.removePopUp(ppm);
}

private function dragEnterHandler(event:DragEvent):void {
	
	var curr:Canvas = Canvas(event.currentTarget);
	VdomDragManager.acceptDragDrop(curr);
}

private function dropHandler(event:DragEvent):void {
	
	var workspace:Workspace = Workspace(event.currentTarget);
	
	var bm:EdgeMetrics = workspace.borderMetrics;
	
	var typeId:String = event.dragSource.dataForFormat('Object').typeId;
	var type:Object = editorDataManager.getType(typeId);
	
	/* Patch: проверка типа родителя */
	if(type.Information.Containers != 'HTML') {
		Alert.show('Not aviable');
		return;
	}
	
	var objectLeft:Number = workspace.mouseX - 25 - bm.left;
	var objectTop:Number = workspace.mouseY - 25 - bm.top;
	
	objectLeft = (objectLeft < 0) ? 0 : objectLeft;
	objectTop = (objectTop < 0) ? 0 : objectTop;
	
	var initProp:Object = {};
	
	initProp.typeId = typeId;
	initProp.left = objectLeft;
	initProp.top = objectTop;
	
	var id:String = editorDataManager.createObject(initProp);
	
	var newItemAtrs:XML = editorDataManager.getAttributes(id);
	
	editorMainCanvas.addObject(newItemAtrs);
}