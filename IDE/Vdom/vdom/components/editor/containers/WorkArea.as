package vdom.components.editor.containers {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.getQualifiedClassName;

import mx.containers.Canvas;
import mx.core.Application;
import mx.core.UIComponent;
import mx.events.DragEvent;
import mx.managers.IFocusManagerComponent;

import vdom.components.editor.containers.workAreaClasses.Item;
import vdom.components.editor.events.ResizeManagerEvent;
import vdom.components.editor.events.WorkAreaEvent;
import vdom.components.editor.managers.ResizeManager;
import vdom.events.RenderManagerEvent;
import vdom.managers.DataManager;
import vdom.managers.RenderManager;
import vdom.managers.ResourceManager;
import vdom.managers.VdomDragManager;
import mx.events.FlexEvent;

public class WorkArea extends Canvas /* implements IFocusManagerComponent */ {
	
	public var selectedObjectId:String;
	
	private var resizeManager:ResizeManager;
	private var resourceManager:ResourceManager;
	private var renderManager:RenderManager;
	private var dataManager:DataManager;
	
	private var itemStack:Array;
	private var selectedItem:DisplayObject;
	private var selectedIndex:int;
	private var resetItemStack:Boolean;
	
	private var _elements:Object;
	private var collection:XML;
	//private var soap:Soap;
	private var container:Canvas;
	
	private var applicationId:String;
	private var topLevelObjectId:String;
	
	private var _images:Object;
	private var loader:Loader;
	
	private var focusedItem:Item;
	
	public function WorkArea() {
		
		super();
		
		//tabEnabled = true;
		
		dataManager = DataManager.getInstance();
		resourceManager = ResourceManager.getInstance();
		renderManager = RenderManager.getInstance();
		
		selectedItem = null;
		selectedIndex = -1;
		itemStack = [];
		
		renderManager.addEventListener(RenderManagerEvent.RENDER_COMPLETE, renderCompleteHandler);
		
		addEventListener(MouseEvent.CLICK, mouseClickHandler, false);
		addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
	}
	/**
	 * Удаление всех объектов из рабочей области.
	 * 
	 */
	
	public function deleteObjects():void {
		
		selectedObjectId = null;
		removeAllChildren();
	}
	
	/**
	 * Удаление объекта по его идентификатору
	 * @param objectId идентификатор объекта
	 * 
	 */	
	public function deleteObject(objectId:String):void {
		
		resizeManager.visible = false;
		selectedObjectId = null;
		createObjects(applicationId, topLevelObjectId, '');
		
		dispatchEvent(new WorkAreaEvent(WorkAreaEvent.OBJECT_CHANGE));
	}
	
	public function updateObject(result:XML):void {
		
		renderManager.updateItem(result.Object.@ID, result.Parent);
	}
	
	public function set dataProvider(attributes:XML):void {
		
        collection = attributes.Attributes[0];
	}
	
	public function get dataProvider():XML {
		
		return XML(collection);
	}
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		if(!container) {
			
			container = new Canvas();
			container.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
			container.addEventListener(DragEvent.DRAG_OVER, dragOverHandler);
			container.addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
			addChild(container);
		}
		
		if(!resizeManager) {
			
			resizeManager = new ResizeManager();
			resizeManager.visible = false;
			resizeManager.addEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
			
			addChild(resizeManager);
		}
		
	}
	
	public function createObjects(applicationId:String, topLevelObjectId:String, objectId:String = ''):void {
		
		resizeManager.visible = false;
		
		this.applicationId = applicationId;
		this.topLevelObjectId = topLevelObjectId;
		
		var parentId:String = '';
		//if(objectId == '') objectId = topLevelObjectId;
		
		renderManager.addEventListener(RenderManagerEvent.RENDER_COMPLETE, renderCompleteHandler);
		renderManager.init(container);
		renderManager.updateItem(topLevelObjectId, '');
	}
	
	public function createObject(result:XML):void {

		renderManager.addItem(result.Object.@ID, result.Parent);
	}
	
	private function renderCompleteHandler(event:RenderManagerEvent):void {
		
		container.removeAllChildren();
		container.addChild(event.result);
		if(selectedItem) {
			
			resizeManager.item = selectedItem;
		}
	}
	
	/**
     *  @private
     */
	private function resizeCompleteHandler(event:ResizeManagerEvent):void {
		
		collection.Attribute.(@Name == 'top')[0] = event.properties['top'];
		collection.Attribute.(@Name == 'left')[0] = event.properties['left'];
		collection.Attribute.(@Name == 'width')[0] = event.properties['width'];
		collection.Attribute.(@Name == 'height')[0] = event.properties['height'];
		trace('top: '+event.properties['top']+' left: '+event.properties['left']);
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
	/* private function objectClickHandler(event:MouseEvent):void {
		
		var item:Item = Item(event.currentTarget);
		if(item.guid == selectedObjectId) return;
		
		if(selectedObjectId) {
			
			removeEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
			selectedObjectId = null;
			
		}
		
		selectedObjectId = item.guid;
		
		addEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
		resizeManager.resizeMode = _elements[selectedObjectId].resizeMode;
		resizeManager.moveMode = _elements[selectedObjectId].moveMode;
		resizeManager.item = _elements[selectedObjectId];
		resizeManager.visible = true;
		item.setFocus();
		event.stopPropagation();
		dispatchEvent(new WorkAreaEvent(WorkAreaEvent.OBJECT_CHANGE));
	} */
	
	/* private function getNearestItem(element:Object):* {
		
		if(element is Item) return element;
		if(!element.parent) return false
			else element = getNearestItem(element.parent);
		return element;
	} */
	
	/* private function mainClickHandler(event:MouseEvent):void {
		
		if(resetItemStack || itemStack.length == 0) {
		
			resetItemStack = false;
			var contentPoint:Point = container.globalToContent(new Point(event.stageX, event.stageY));
			//var contentPoint:Point = new Point(event.stageX, event.stageY);
			var rawItemStack:Array = container.getObjectsUnderPoint(contentPoint);
			//var ddd:* = container.areInaccessibleObjectsUnderPoint(new Point(1, 1));
			
			selectedItem = null;
			itemStack = [];
			selectedIndex = 0;
			
			container.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			
			for(var i:uint = 0; i < rawItemStack.length; i++) {
			
				var item:DisplayObject = getNearestItem(rawItemStack[i]);
				itemStack.push(item);
				
				if(item == selectedItem) selectedIndex = i;
			}
		}
		
		var itemStackLength:uint = itemStack.length;
		
		if(itemStackLength == 0) return;
		
		selectedIndex = selectedIndex ? selectedIndex : 0;
		
		if(selectedIndex == 0) selectedIndex = itemStack.length - 1;
			else selectedIndex = selectedIndex - 1;
		trace(itemStack[selectedIndex]);
	}*/
	
	/* private function mouseMoveHandler(event:MouseEvent):void {
		
		container.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);	
		resetItemStack = true;
	} */
	
	
	
	private function getObjectsUnderMouse(rootContainer:DisplayObjectContainer, targetClassName:String):Array {
		
		var app:Application = Application.application as Application;
	
		var allObjectUnderPoint:Array = app.stage.getObjectsUnderPoint( 
				new Point(app.stage.mouseX, app.stage.mouseY )
		);
			
		var stack:Array = new Array();
		
		for (var i:int = allObjectUnderPoint.length-1; i >= 0; i--) {
			
			var target:DisplayObject = allObjectUnderPoint[i];
			
			if (!rootContainer.contains(target))
				continue
			
			while (target) {
				
				var currentClassName:String = getQualifiedClassName(target);
					
				if(currentClassName == targetClassName)
					break;
					
				if(target.hasOwnProperty('parent'))
					target = target.parent;
									
				else
					target = null;
			}
			
			if (target && stack[stack.length - 1] != target)
				stack.push(target);
		}
		//trace(stack.join('\n'));
		return stack;
	}
	private function dragEnterHandler(event:DragEvent):void {
		
		VdomDragManager.acceptDragDrop(UIComponent(event.currentTarget));
	}
	
	private function dragOverHandler(event:DragEvent):void {
		
		var stack:Array = getObjectsUnderMouse(container, 'vdom.components.editor.containers.workAreaClasses::Item');
		var currentItem:Item = stack[0];
		
		if(focusedItem == currentItem) {
			//trace('same');
			return;
		}
		focusedItem = currentItem;
		var typeDescription:Object = event.dragSource.dataForFormat('typeDescription');
		trace(typeDescription.aviableContainers.split(',').join('\n'))
		currentItem.drawFocus(true);
		
		
	}
	
	private function dragDropHandler(event:DragEvent):void {
		
		var typeDescription:Object = event.dragSource.dataForFormat('typeDescription');
		var currentContainer:Item = focusedItem;
		
		var currentItemName:String = 
			dataManager.getTypeByObjectId(currentContainer.objectID).Information.Name;;
		var aviableContainers:Array = typeDescription.aviableContainers.split(',');
		
		if(aviableContainers.indexOf(currentItemName) != -1) {
			
			var objectLeft:Number = currentContainer.mouseX - 25;// - bm.left;
			var objectTop:Number = currentContainer.mouseY - 25;// - bm.top;
		
			objectLeft = (objectLeft < 0) ? 0 : objectLeft;
			objectTop = (objectTop < 0) ? 0 : objectTop;
			
			var attributes:XML = 
				<Attributes>
        			<Attribute Name="top">{objectTop}</Attribute>
        			<Attribute Name="left">{objectLeft}</Attribute>
    			</Attributes>
			
/* 			var initProp:Object = {};
			
			initProp.typeId = typeDescription.typeId
			initProp.parentId = currentContainer.objectID;
			initProp.left = objectLeft;
			initProp.top = objectTop; */
			
			dataManager.createObject(
				typeDescription.typeId,
				currentContainer.objectID,
				'',
				attributes);
		}
	}
	private function mouseClickHandler(event:MouseEvent):void {
		
		if(!container.contains(DisplayObject(event.target)))
			return;
		if(resetItemStack || itemStack.length == 0) {
			
			resetItemStack = false;
			selectedItem = null;
			itemStack = getObjectsUnderMouse(this, 'vdom.components.editor.containers.workAreaClasses::Item');
			selectedIndex = -1;
				
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		var itemStackLength:uint = itemStack.length;
		
		if(itemStackLength == 0) return;
		
		if(selectedIndex >= itemStackLength - 1 || selectedIndex == -1)
			selectedIndex = 0;
		else
			selectedIndex = selectedIndex + 1;
		
		selectedObjectId = Item(itemStack[selectedIndex]).objectID;
		Item(itemStack[selectedIndex]).setFocus();
		
		var objectType:XML = dataManager.getTypeByObjectId(selectedObjectId);
		
		resizeManager.moveMode = objectType.Information.Moveable;
		resizeManager.resizeMode = objectType.Information.Resizable;
		
		resizeManager.item = itemStack[selectedIndex];
		resizeManager.visible = true;
		
		dispatchEvent(new WorkAreaEvent(WorkAreaEvent.OBJECT_CHANGE));
	}
	
	private function mouseMoveHandler(event:MouseEvent):void {
		
		this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);	
		resetItemStack = true;
	}
}
}