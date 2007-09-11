package vdom.components.editor.containers {

import flash.events.MouseEvent;
import flash.events.Event;
import mx.containers.Canvas;

import vdom.components.editor.events.ResizeManagerEvent;
import vdom.components.editor.containers.workspaceClasses.Item;
import vdom.components.editor.managers.ResizeManager;
import vdom.managers.DataManager;

public class Workspace extends Canvas {
	
	public var selectedObject:String;
	
	private var resizer:ResizeManager;
	private var dataManager:DataManager;
	private var _elements:Object;
	private var collection:XML;
	
	public function Workspace() {
		
		super();
		dataManager = DataManager.getInstance();
		_elements = [];
		resizer = new ResizeManager();
		resizer.addEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
		addEventListener(MouseEvent.CLICK, mainClickHandler, false);
	}
	
	/**
	 * Обновление отображения объекта.
	 * @param objectAttributes аттрибуты объекта.
	 * 
	 */	
	public function updateObject(objectAttributes:XML):void {
		
		var objectId:String = objectAttributes.@ID;
		
		var object:Item = _elements[objectId];
		
		var objWidth:int = objectAttributes.Attributes.Attribute.(@Name == 'width')[0];
		var objHeight:int = objectAttributes.Attributes.Attribute.(@Name == 'height')[0];
		
		object.width = (objWidth == 0) ? 50 : objWidth;
		object.height = (objHeight == 0) ? 50 : objHeight;
		
		object.x = objectAttributes.Attributes.Attribute.(@Name == 'left')[0];
		object.y = objectAttributes.Attributes.Attribute.(@Name == 'top')[0];
		
		resizer.item = object;
	}
	
	/**
	 * Удаление всех объектов из рабочей области.
	 * 
	 */	
	public function destroyObjects():void {
		
		selectedObject = null;
		removeAllChildren();
	}
	
	public function set dataProvider(attributes:XML):void {
		
        collection = attributes.Attributes[0];
	}
	
	public function get dataProvider():XML {
		
		return XML(collection);
	}
	
	/**
	 * Добавление нового объекта в рабочую область
	 * @param objectAttributes аттрибуты объекта.
	 * 
	 */	
	public function addObject(objectAttributes:XML):void {
		
		var objectId:String = objectAttributes.@ID;
		var element:Item = new Item(objectId);
		var objWidth:int = objectAttributes.Attributes.Attribute.(@Name == 'width')[0];
		var objHeight:int = objectAttributes.Attributes.Attribute.(@Name == 'height')[0];
		
		element.width = (objWidth == 0) ? 50 : objWidth;
		element.height = (objHeight == 0) ? 50 : objHeight;
		
		element.x = objectAttributes.Attributes.Attribute.(@Name == 'left')[0];
		element.y = objectAttributes.Attributes.Attribute.(@Name == 'top')[0];
		
		var resizable:int = objectAttributes.Type.Information.Resizable;
		var movable:int = objectAttributes.Type.Information.Moveable;
		
		switch (resizable) {
			case 0:
				element.resizeMode = ResizeManager.RESIZE_NONE;
			break;
			case 1:
				element.resizeMode = ResizeManager.RESIZE_WIDTH;
			break;
			case 2:
				element.resizeMode = ResizeManager.RESIZE_HEIGHT;
			break;
			case 3:
				element.resizeMode = ResizeManager.RESIZE_ALL;
			break;
		}
		switch (movable) {
			case 0:
				element.moveMode = false;
			break;
			case 1:
				element.moveMode = true
			break;
		}
		
		element.addEventListener(MouseEvent.CLICK, objectClickHandler);
		_elements[objectAttributes.@ID] = element;
		
		addChild(element);
	}
	
	public function addNewObject(objectAttributes:XML):void {
		
		var objectId:String = objectAttributes.@ID;
		var element:Item = new Item(objectId);
		var objWidth:int = objectAttributes.Attributes.Attribute.(Name == 'width').Value;
		var objHeight:int = objectAttributes.Attributes.Attribute.(Name == 'height').Value;
		
		element.width = (objWidth == 0) ? 50 : objWidth;
		element.height = (objHeight == 0) ? 50 : objHeight;
		
		element.x = objectAttributes.Attributes.Attribute.(Name == 'left').Value;
		element.y = objectAttributes.Attributes.Attribute.(Name == 'top').Value;
		
		var resizable:int = objectAttributes.Type.Information.Resizable;
		var movable:int = objectAttributes.Type.Information.Moveable;
		
		switch (resizable) {
			case 0:
				element.resizeMode = ResizeManager.RESIZE_NONE;
			break;
			case 1:
				element.resizeMode = ResizeManager.RESIZE_WIDTH;
			break;
			case 2:
				element.resizeMode = ResizeManager.RESIZE_HEIGHT;
			break;
			case 3:
				element.resizeMode = ResizeManager.RESIZE_ALL;
			break;
		}
		switch (movable) {
			case 0:
				element.moveMode = false;
			break;
			case 1:
				element.moveMode = true
			break;
		}
		
		element.addEventListener(MouseEvent.CLICK, objectClickHandler);
		_elements[objectAttributes.@ID] = element;
		
		addChild(element);
	}
	
	/**
     *  @private
     */
	private function resizeCompleteHandler(event:ResizeManagerEvent):void {
		
		collection.Attribute.(Name == 'top').Value = event.properties['top'];
		collection.Attribute.(Name == 'left').Value = event.properties['left'];
		collection.Attribute.(Name == 'width').Value = event.properties['width'];
		collection.Attribute.(Name == 'height').Value = event.properties['height'];
		
		dispatchEvent(new Event('propsChanged'));
	}
	/**
     *  @private
     */
	private function objectClickHandler(event:MouseEvent):void {
		
		if(event.currentTarget.objectId == selectedObject) return;
		
		if(selectedObject) {
			removeEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
			selectedObject = null;
			removeChild(resizer);
		}
		
		selectedObject = Item(event.currentTarget).objectId;
		_elements[selectedObject].content.setFocus();
		
		addEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
		resizer.resizeMode = _elements[selectedObject].resizeMode;
		resizer.moveMode = _elements[selectedObject].moveMode;
		resizer.item = _elements[selectedObject];
		addChild(resizer);
		event.stopPropagation();
		dispatchEvent(new Event('objectChange'));
	}
	
	/**
     *  @private
     */
	private function mainClickHandler(event:MouseEvent):void {
		
		if(event.target == event.currentTarget && selectedObject) {
			setFocus();
			selectedObject = null;
			removeChild(resizer);
			dispatchEvent(new Event('objectChange'));
		}
	}
}
}