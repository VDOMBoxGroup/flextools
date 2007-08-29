import mx.events.DragEvent;
import vdom.components.editor.managers.VdomDragManager;
import vdom.components.editor.managers.DataManager;
import vdom.components.editor.events.DataManagerEvent;
import vdom.components.editor.containers.Item;
import mx.core.EdgeMetrics;
import flash.events.Event;
import vdom.components.editor.containers.typesClasses.Type;
import vdom.components.editor.containers.Workspace;
import flash.display.DisplayObject;
import mx.managers.PopUpManager;
import vdom.MyLoader;
import mx.containers.Canvas;

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
public var elementDescription:XML;

[Bindable]
public var typesXML:XML;

[Bindable]
public var help:String;

private var ppm:Canvas;

private function init():void {
	
	ppm = new MyLoader();
	publicData = mx.core.Application.application.publicData;
	editorDataManager = DataManager.getInstance();
	
	
	
	/*Загрузка типов*/
	
	
	
	
	
	
	//editorDataManager.loadTypes();
	//editorDataManager.loadObjects();
	
	addEventListener('objectCreated', objectCreatedHandler);
	
	editorMainCanvas.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
	editorMainCanvas.addEventListener(DragEvent.DRAG_DROP, dropHandler);
	editorMainCanvas.addEventListener('objectChange', objectChangeHandler);
	objectProperties.addEventListener('propsChanged', propsChangedHandler);
	//objectProperties.addEventListener('focusChanged', focusChangedHandler);
	
	typesXML = null;
}

private function show():void {
	
	PopUpManager.addPopUp(ppm, this, true);
	PopUpManager.centerPopUp(ppm);
	//trace(publicData['appId']);
	editorDataManager.addEventListener('initComplete', initCompleteHandler);
	editorDataManager.init(publicData['appId']);
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

private function createObjects(objectsXML:XML):void {
	
	editorMainCanvas.destroyElements();
	
	for each(var itemAttrs:XML in objectsXML.Object) {
		
		editorMainCanvas.addItem(itemAttrs);
	}
	
	dispatchEvent(new Event('objectCreated'));
	
	createTypes();
}

private function propsChangedHandler(event:Event):void {
	
	/* if(attributes.Attributes.Attribute.(@Name == 'x')[0]) selectedItem.x = attributes.Attributes.Attribute.(@Name == 'x')[0];
	if(attributes.Attributes.Attribute.(@Name == 'y')[0]) selectedItem.y = attributes.Attributes.Attribute.(@Name == 'y')[0];
	if(attributes.Attributes.Attribute.(@Name == 'width')[0]) selectedItem.width = attributes.Attributes.Attribute.(@Name == 'width')[0];
	if(attributes.Attributes.Attribute.(@Name == 'height')[0]) selectedItem.height = attributes.Attributes.Attribute.(@Name == 'height')[0]; */
	//resizer.item = selectedItem;
	
	elementDescription = new XML(elementDescription);
	editorMainCanvas.updateElement(elementDescription);
	//trace(attributes.@ID);
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
		elementDescription = editorDataManager.getFullAttributes(editorMainCanvas.selectedElement);
	} else {
		elementDescription = null;
	}
	toolbar.type = elementDescription;
	//trace(elementDescription);
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
	
	var newItemAtrs:XML = editorDataManager.getProperties(id);
	
	editorMainCanvas.addItem(newItemAtrs);
}