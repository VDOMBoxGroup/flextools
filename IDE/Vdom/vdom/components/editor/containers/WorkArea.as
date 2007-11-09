package vdom.components.editor.containers {

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.containers.Canvas;

import vdom.components.editor.containers.workAreaClasses.Item;
import vdom.components.editor.events.ResizeManagerEvent;
import vdom.components.editor.events.WorkAreaEvent;
import vdom.components.editor.managers.ResizeManager;
import vdom.managers.DataManager;

public class WorkArea extends Canvas {
	
	public var selectedObjectId:String;
	
	private var resizeManager:ResizeManager;
	private var dataManager:DataManager;
	private var _elements:Object;
	private var collection:XML;
	
	public function WorkArea() {
		
		super();
		dataManager = DataManager.getInstance();
		_elements = [];
		resizeManager = new ResizeManager();
		resizeManager.addEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
		
		addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
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
		
		resizeManager.item = object;
	}
	
	/**
	 * Удаление всех объектов из рабочей области.
	 * 
	 */	
	public function destroyObjects():void {
		
		selectedObjectId = null;
		removeAllChildren();
	}
	/**
	 * Удаление объекта по его идентификатору
	 * @param objectId идентификатор объекта
	 * 
	 */	
	public function deleteObject(objectId:String):void {
		
		removeChild(_elements[objectId]);
		setFocus();
		selectedObjectId = null;
		removeChild(resizeManager);
		dispatchEvent(new WorkAreaEvent(WorkAreaEvent.OBJECT_CHANGE));
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
		var objWidth:int = objectAttributes.Attributes.Attribute.(@Name == 'width');
		var objHeight:int = objectAttributes.Attributes.Attribute.(@Name == 'height');
		
		element.width = (objWidth == 0) ? 50 : objWidth;
		element.height = (objHeight == 0) ? 50 : objHeight;
		
		element.x = objectAttributes.Attributes.Attribute.(@Name == 'left');
		element.y = objectAttributes.Attributes.Attribute.(@Name == 'top');
		
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
		
		collection.Attribute.(@Name == 'top')[0] = event.properties['top'];
		collection.Attribute.(@Name == 'left')[0] = event.properties['left'];
		collection.Attribute.(@Name == 'width')[0] = event.properties['width'];
		collection.Attribute.(@Name == 'height')[0] = event.properties['height'];
		
		dispatchEvent(new WorkAreaEvent(WorkAreaEvent.PROPS_CHANGE));
	}
	
	/**
     *  @private
     */
	override protected function keyDownHandler(event:KeyboardEvent):void {
		
		if(!selectedObjectId) return;
		
		switch (event.keyCode) {
			
			case Keyboard.DELETE:
				var we:WorkAreaEvent = new WorkAreaEvent(WorkAreaEvent.DELETE_OBJECT);
				we.objectID = selectedObjectId;
				dispatchEvent(we);
				event.stopPropagation();
			break;
		}
	}
	
	/**
     *  @private
     */
	private function objectClickHandler(event:MouseEvent):void {
		
		if(event.currentTarget.objectId == selectedObjectId) return;
		
		if(selectedObjectId) {
			removeEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
			selectedObjectId = null;
			removeChild(resizeManager);
		}
		
		selectedObjectId = Item(event.currentTarget).objectId;
		_elements[selectedObjectId].content.setFocus();
		
		addEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
		resizeManager.resizeMode = _elements[selectedObjectId].resizeMode;
		resizeManager.moveMode = _elements[selectedObjectId].moveMode;
		resizeManager.item = _elements[selectedObjectId];
		addChild(resizeManager);
		event.stopPropagation();
		dispatchEvent(new WorkAreaEvent(WorkAreaEvent.OBJECT_CHANGE));
	}
	
	/**
     *  @private
     */
	private function mainClickHandler(event:MouseEvent):void {
		
		if(event.target == event.currentTarget && selectedObjectId) {
			setFocus();
			selectedObjectId = null;
			removeChild(resizeManager);
			dispatchEvent(new WorkAreaEvent(WorkAreaEvent.OBJECT_CHANGE));
		}
	}
}
}