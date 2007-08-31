import mx.events.DragEvent;
import vdom.components.editor.managers.VdomDragManager;
import vdom.components.editor.managers.DataManager;
import vdom.components.editor.events.DataManagerEvent;
import mx.core.EdgeMetrics;
import flash.events.Event;
import vdom.components.editor.containers.typesClasses.Type;
import vdom.components.editor.containers.Workspace;
import flash.display.DisplayObject;
import mx.managers.PopUpManager;
import vdom.MyLoader;
import mx.containers.Canvas;
import vdom.components.editor.events.ResizeManagerEvent;

[Bindable]
private var selectedElement:String;

private var objectsXML:XML;
[Bindable]
private var editorDataManager:DataManager;
private var currInterfaceType:uint;

private var publicData:Object;

[Bindable]
public var objects:XML;

[Bindable]
public var objectDescription:XML;

[Bindable]
public var typesXML:XML;

[Bindable]
public var help:String;

private var ppm:Canvas;

private function init():void {
	
	ppm = new MyLoader();
	publicData = mx.core.Application.application.publicData;
	editorDataManager = DataManager.getInstance();
	pageList.selectedIndex = 0;
	
	
	
	/*Загрузка типов*/
	
	//editorDataManager.loadTypes();
	//editorDataManager.loadObjects();
	
	addEventListener('objectCreated', objectCreatedHandler);
	
	editorMainCanvas.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
	editorMainCanvas.addEventListener(DragEvent.DRAG_DROP, dropHandler);
	editorMainCanvas.addEventListener('objectChange', objectChangeHandler);
	
	editorDataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, attributesUpdateCompleteHandler);
	
	objectAttributes.addEventListener('propsChanged', attributesChangedHandler);
	editorMainCanvas.addEventListener('propsChanged', attributesChangedHandler);
	//objectProperties.addEventListener('focusChanged', focusChangedHandler);
	
	typesXML = null;
}

private function show():void {
	
	PopUpManager.addPopUp(ppm, this, true);
	PopUpManager.centerPopUp(ppm);
	createPage();
	//trace(publicData['appId']);
	
}

private function createPage():void {
	editorDataManager.addEventListener('initComplete', initCompleteHandler);
	editorDataManager.init(publicData['appId'], publicData['pageId']);
}

private function hide():void {
	editorMainCanvas.visible = false;
}

private function initCompleteHandler(event:Event):void {
	createObjects(editorDataManager.getObjects());
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
	
	editorMainCanvas.destroyElements();
	
	for each(var itemAttrs:XML in objectsXML.Object) {
		
		editorMainCanvas.addObject(itemAttrs);
	}
	
	dispatchEvent(new Event('objectCreated'));
	
	createTypes();
}

private function attributesUpdateCompleteHandler(event:DataManagerEvent):void {
	editorMainCanvas.updateObject(editorDataManager.getAttributes(event.objectId));
	objectDescription = editorDataManager.getFullAttributes(event.objectId);
}

private function attributesChangedHandler(event:Event):void {
	editorDataManager.updateAttributes(objectDescription);
}

/* private function focusChangedHandler(event:Event):void {
	help = editorDataManager.getAttributeHelp(editorMainCanvas.selectedItem.objectId, objectProperties.attributeHelp);
} */

private function typesLoadHandler(event:Event):void {
	typesXML = editorDataManager.types;
}

private function objectsLoadHandler(event:Event):void {
	objectsXML = editorDataManager.objectsXML;
	createObjects(objectsXML);
}

private function objectChangeHandler(event:Event):void {
	
	if(editorMainCanvas.selectedElement) {
		objectDescription = editorDataManager.getFullAttributes(editorMainCanvas.selectedElement);
	} else {
		objectDescription = null;
	}
	toolbar.type = objectDescription;
	//trace(objectDescription);
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
	
	//var objectX:Number = workspace.mouseX - int(type.Attributes.Attribute.(Name == 'width').DefaultValue/2) - bm.left;
	//var objectY:Number = workspace.mouseY - int(type.Attributes.Attribute.(Name == 'height').DefaultValue/2) - bm.top;
	
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