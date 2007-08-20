import mx.events.DragEvent;
import vdom.components.editor.managers.VdomDragManager;
import vdom.components.editor.managers.DataManager;
import vdom.components.editor.events.DataManagerEvent;
import vdom.components.editor.containers.Item;
import vdom.components.editor.containers.Workflow;
import mx.core.EdgeMetrics;
import flash.events.Event;
import vdom.components.editor.containers.typesClasses.Type;

[Bindable]
private var selectedItem:Item;

private var objectsXML:XML;
private var editorDataManager:DataManager;
private var currInterfaceType:uint;

[Bindable]
public var objects:Object;

[Bindable]
public var element:XML;

[Bindable]
public var typesXML:XML;

[Bindable]
public var help:String;

private function init():void {
	
	/*Загрузка типов*/
	editorDataManager = DataManager.getInstance();
	
	editorDataManager.addEventListener(DataManagerEvent.TYPES_LOADED, typesLoadHandler);
	editorDataManager.addEventListener(DataManagerEvent.OBJECTS_LOADED, objectsLoadHandler);
	
	editorDataManager.loadTypes();
	editorDataManager.loadObjects();
	
	addEventListener('objectCreated', objectCreatedHandler);
	
	editorMainCanvas.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
	editorMainCanvas.addEventListener(DragEvent.DRAG_DROP, dropHandler);
	editorMainCanvas.addEventListener('objectChange', objectChangeHandler);
	objectProperties.addEventListener('propsChanged', propsChangedHandler);
	//objectProperties.addEventListener('focusChanged', focusChangedHandler);
	
	typesXML = null;
}

private function propsChangedHandler(event:Event):void {
	
	/* if(attributes.Attributes.Attribute.(@Name == 'x')[0]) selectedItem.x = attributes.Attributes.Attribute.(@Name == 'x')[0];
	if(attributes.Attributes.Attribute.(@Name == 'y')[0]) selectedItem.y = attributes.Attributes.Attribute.(@Name == 'y')[0];
	if(attributes.Attributes.Attribute.(@Name == 'width')[0]) selectedItem.width = attributes.Attributes.Attribute.(@Name == 'width')[0];
	if(attributes.Attributes.Attribute.(@Name == 'height')[0]) selectedItem.height = attributes.Attributes.Attribute.(@Name == 'height')[0]; */
	//resizer.item = selectedItem;
	
	element = new XML(element);
	editorMainCanvas.updateElement(element);
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

private function createObjects(objectsXML:XML):void {
	
	for each(var itemAttrs:Object in objectsXML.Object) {
		
		editorMainCanvas.addItem(itemAttrs);
	}
	
	dispatchEvent(new Event('objectCreated'));
}

private function objectChangeHandler(event:Event):void {

	if(editorMainCanvas.selectedItem) {
		element = editorDataManager.getFullAttributes(editorMainCanvas.selectedItem.elementId);
	} else {
		element = null;
	}
	toolbar.type = element;
}

private function createTypes(typesXML:XML):void {
	
}

private function objectCreatedHandler(event:Event):void {
	
	objects = editorDataManager.getObjects();
}

private function dragEnterHandler(event:DragEvent):void {
	
	var curr:Canvas = Canvas(event.currentTarget);
	VdomDragManager.acceptDragDrop(curr);
}

private function dropHandler(event:DragEvent):void {
	
	var workflow:Workflow = Workflow(event.currentTarget);
	
	var bm:EdgeMetrics = workflow.borderMetrics;
	
	var typeId:uint = event.dragSource.dataForFormat('Object').typeId;
	var type:Object = editorDataManager.getType(typeId);
	
	var objectX:Number = workflow.mouseX - int(type.Attributes.Attribute.(Name == 'width').DefaultValue/2) - bm.left;
	var objectY:Number = workflow.mouseY - int(type.Attributes.Attribute.(Name == 'height').DefaultValue/2) - bm.top;
	
	objectX = (objectX < 0) ? 0 : objectX;
	objectY = (objectY < 0) ? 0 : objectY;
	
	var initProp:Object = {};
	
	initProp.typeId = typeId;
	initProp.x = objectX;
	initProp.y = objectY;
	
	
	var id:uint = editorDataManager.createObject(initProp);
	
	var newItemAtrs:Object = editorDataManager.getProperties(id);
	
	editorMainCanvas.addItem(newItemAtrs);
}