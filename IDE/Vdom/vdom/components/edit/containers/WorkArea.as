package vdom.components.edit.containers {
	
import flash.events.MouseEvent;

import mx.containers.Canvas;
import mx.controls.HTML;
import mx.controls.Label;
import mx.core.Container;
import mx.core.UIComponent;
import mx.events.DragEvent;

import vdom.components.edit.events.EditEvent;
import vdom.containers.IItem;
import vdom.events.RenderManagerEvent;
import vdom.events.ResizeManagerEvent;
import vdom.managers.DataManager;
import vdom.managers.FileManager;
import vdom.managers.RenderManager;
import vdom.managers.ResizeManager;
import vdom.managers.VdomDragManager;
import vdom.utils.DisplayUtil;

public class WorkArea extends Canvas {
	
	private var resizeManager:ResizeManager;
	private var fileManager:FileManager;
	private var renderManager:RenderManager;
	private var dataManager:DataManager;
	
	private var itemStack:Array;

	private var selectedIndex:int;
	private var resetItemStack:Boolean;
	
	//private var collection:XML;
	
	//private var applicationId:String;
	
	private var _pageId:String;
	//private var topLevelItem:Container;
	private var _selectedObject:Container;
	
	private var focusedItem:Container;
	
	//private var highlighter:Canvas;
	private var highlightedObject:Container;
	
	//private var tip:ToolTip;
	private var transformMode:Boolean;
	private var objectUnderMouse:Object;
	
	private var resizeBegin:Boolean;
	
	private var markerSelected:Boolean
	
	public function WorkArea() {
		
		super();
		
		dataManager = DataManager.getInstance();
		//fileManager = FileManager.getInstance();
		renderManager = RenderManager.getInstance();
		resizeManager = ResizeManager.getInstance();
		
		//highlighter = new Canvas();
		
		selectedIndex = -1;
		itemStack = [];
		//transformMode = false;
		resizeBegin = false;
		
		
		//addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		//addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		//addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		//addEventListener(MouseEvent.ROLL_OUT, mouseRollOutHandler);
		//addEventListener(MouseEvent.CLICK, mouseClickHandler);
		
		resizeManager.addEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
		//resizeManager.addEventListener(ResizeManagerEvent.RESIZE_BEGIN, resizeBeginHandler);
		resizeManager.addEventListener(ResizeManagerEvent.ITEM_SELECTED, itemSelectedHandler);
		
		/* resizeManager.addEventListener('markerSelected', markerSelectedHandler);
		resizeManager.addEventListener('markerUnSelected', markerUnSelectedHandler); */
		
		//renderManager.addEventListener(RenderManagerEvent.RENDER_COMPLETE, renderCompleteHandler);
		
		//addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		
		addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, true);
		
		addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
		addEventListener(DragEvent.DRAG_OVER, dragOverHandler);
		addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
		addEventListener(DragEvent.DRAG_EXIT, dragExitHandler);
		
		
	}
	
	/* public function get selectedObjectId():String {
		
		var returnValue:String;
		
		if(selectedObject)
			returnValue = selectedObject.objectID;
		
		return returnValue;
	} */
	
	/**
	 * Удаление всех объектов из рабочей области.
	 * 
	 */
	
	public function deleteObjects():void {
		
		resizeManager.selectItem(null);
		removeAllChildren();
	}
	
	/**
	 * Удаление объекта по его идентификатору
	 * @param objectId идентификатор объекта
	 * 
	 */	
	public function deleteObject(objectId:String):void {
		
		//selectedObject = null;
		renderManager.deleteItem(objectId);
		resizeManager.selectItem(null);
	}
	
	public function updateObject(result:XML):void {
		
		//if(result.Object.@ID == topLevelObjectId)
			//showTopLevelContainer(applicationId, topLevelObjectId)
		//else
			renderManager.lockItem(result.Object.@ID);
			renderManager.updateItem(result.Object.@ID, result.Parent);
	}
	
	public function set pageId(page:String):void {
		
		//removeAllChildren();
		
		if(page) {
			
			if(page != _pageId) {
			
				_pageId = page;
				renderManager.init(this);
				renderManager.addEventListener(RenderManagerEvent.RENDER_COMPLETE, renderCompleteHandler);
				renderManager.createItem(_pageId);
			}
			
		} else {
				
			var warning:Label = new Label()
			warning.text = 'no page selected';
			addChild(warning);
		}
	}
	
	
	
	/* public function set dataProvider(attributes:XML):void {
		
		if(attributes)
        	collection = attributes.Attributes[0];
	} */
	
	/* public function get dataProvider():XML {
		
		return XML(collection);
	} */
	
	/* private function showTopLevelContainer(pageId:String):void {
		
		//this.applicationId = applicationId;
		
	} */
	
	public function createObject(result:XML):void {

		renderManager.createItem(result.Object.@ID, result.Object.Parent);
	}
	
	/* private function selectObject():String {
		
		if(resetItemStack || itemStack.length == 0) {
			
			resetItemStack = false;
			
			itemStack = DisplayUtil.getObjectsUnderMouse(this, 'vdom.components.editor.containers.workAreaClasses::Item');
			selectedIndex = -1;
		}
		
		var itemStackLength:uint = itemStack.length;
		
		if(itemStackLength == 0) 
			return null;
		
		if(selectedIndex >= itemStackLength - 1 || selectedIndex == -1)
			selectedIndex = 0;
		else
			selectedIndex = selectedIndex + 1;
		
		return Item(itemStack[selectedIndex]).objectID;
	} */
	
	/* private function bringOnTop(object:DisplayObject):void {
		
		var currIndex:int = getChildIndex(object);
		var topIndex:int = numChildren - 1;
		
		if(currIndex != topIndex)
			setChildIndex(object, topIndex);
	} */
	
	private function applyChanges(objectId:String, attributes:Object):void {
		
		var newAttributes:XML = <Attributes />
		
		for (var attributeName:String in attributes) {
			
			newAttributes.appendChild(<Attribute Name = {attributeName}>{attributes[attributeName]}</Attribute>);
		}
		
		//trace('WorkAreaEvent.PROPS_CHANGED');
		var ee:EditEvent = new EditEvent(EditEvent.PROPS_CHANGED);
		ee.objectId = objectId;
		ee.props = newAttributes;
		dispatchEvent(ee);
	}
	
	/* private function resizeBeginHandler(event:ResizeManagerEvent):void {
		
		resizeBegin = true;
	} */
	
	/**
     *  @private
     */
	private function resizeCompleteHandler(event:ResizeManagerEvent):void {
		
		//trace('applyChanges');
		
		//resizeBegin = false;
		
		
		var selectedObject:Container = event.item;
		//selectedObject = event.item;
		
		selectedObject.x = event.properties.left;
		selectedObject.y = event.properties.top;
		selectedObject.width = event.properties.width;
		selectedObject.height = event.properties.height;
		//selectedObject.removeAllChildren();
		//selectedObject.waitMode = true;
		//renderManager.lockItem();
		applyChanges(IItem(selectedObject).objectId, event.properties);
		
	}
	
	private function itemSelectedHandler(event:ResizeManagerEvent):void {
		
		if(_selectedObject && IItem(_selectedObject).editableAttributes.length > 0) {
			
			var editableAttributes:Array = IItem(_selectedObject).editableAttributes;
			
			var attributes:Object = {}
			
			for each(var attribute:Object in editableAttributes) {
				
				if(attribute.sourceObject is HTML) {
					attributes[attribute.destName] = 
						HTML(attribute.sourceObject).domWindow.document.getElementsByTagName('body')[0].innerHTML
						
				} else { 
					attributes[attribute.destName] = attribute.sourceObject[attribute.sourceName];
				}
			}
			
			applyChanges(IItem(_selectedObject).objectId, attributes);
		}

		_selectedObject = event.item;
		
		var ee:EditEvent = new EditEvent(EditEvent.OBJECT_CHANGE);
		ee.objectId = IItem(_selectedObject).objectId;
		dispatchEvent(ee);
	}
	
	
	private function renderCompleteHandler(event:RenderManagerEvent):void {
		
		renderManager.removeEventListener(RenderManagerEvent.RENDER_COMPLETE, renderCompleteHandler);
		resizeManager.init(this);
	}
	
/* 	private function markerSelectedHandler(event:ResizeManagerEvent):void {
		trace('markerSelectedHandler');
		markerSelected = true;
	}
	private function markerUnSelectedHandler(event:ResizeManagerEvent):void {
		trace('markerUnSelectedHandler');
		markerSelected = false;
	} */
	/**
     *  @private
     */
	/* override protected function keyDownHandler(event:KeyboardEvent):void {
		
		if(!selectedObjectId) return;
		
		switch (event.keyCode) {
			
			case Keyboard.DELETE:
				var we:EditEvent = new EditEvent(EditEvent.DELETE_OBJECT);
				we.objectID = selectedObjectId;
				
				dispatchEvent(we);
				event.stopPropagation();
			break;
		}
	} */
	
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
	
	
	
	
	private function dragEnterHandler(event:DragEvent):void {
		
		VdomDragManager.acceptDragDrop(UIComponent(event.currentTarget));
		focusedItem = null
	}
	
	private function dragOverHandler(event:DragEvent):void {
		
		var filterFunction:Function = function(item:IItem):Boolean {
			
			return !item.isStatic;
		}
		
		var stack:Array = 
			DisplayUtil.getObjectsUnderMouse(this, 'vdom.containers::IItem', filterFunction);
		
		if(stack.length == 0)
			return;
			
		var currentItem:Container = stack[0];
		
		if(focusedItem == currentItem)
			return;
		
		focusedItem = currentItem;
		
		var typeDescription:Object = event.dragSource.dataForFormat('typeDescription');
		
		var currentItemName:String = 
			dataManager.getTypeByObjectId(IItem(currentItem).objectId).Information.Name;
		
		var containersRE:RegExp = /(\w+)/g;
		
		var aviableContainers:Array = typeDescription.aviableContainers.match(containersRE);
		
		
		
		if(aviableContainers.indexOf(currentItemName) != -1) {
			
			currentItem.setStyle('themeColor', '#00ff00');
		} else {
			
			currentItem.setStyle('themeColor', '#ff0000');
		}
		
		//if(currentItem)
		//trace('focus');
		currentItem.drawFocus(true);
		
		
	}
	
	private function dragDropHandler(event:DragEvent):void {
		
		var typeDescription:Object = event.dragSource.dataForFormat('typeDescription');
		
		var currentContainer:Container = focusedItem;
		
		if(currentContainer)
			currentContainer.drawFocus(false);
		else
			return;
		
		var currentItemName:String = 
			dataManager.getTypeByObjectId(IItem(currentContainer).objectId).Information.Name;
		
		var re:RegExp = /\s+/g;
		
		var aviableContainers:Array = typeDescription.aviableContainers.replace(re, '').split(',');
		
		var bool:Number = aviableContainers.indexOf(currentItemName);
		if(bool != -1) {
			
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
				IItem(currentContainer).objectId,
				'',
				attributes);
				
			focusedItem = null;
		}
		
	}
	
	private function dragExitHandler(event:DragEvent):void {
		
		//var currentContainer:Object = event.currentTarget;
		if(focusedItem is IItem) {
			focusedItem.setStyle('themeColor', '#009dff');
			focusedItem.drawFocus(false);
			focusedItem = null;
		}
	}
	
	private function mouseWheelHandler(event:MouseEvent):void {
		
		event.stopPropagation();
	}
	
	/* private function mouseClickHandler(event:MouseEvent):void {
		
		
		
		
	} */
	
	
	
	/* private function mouseMoveHandler(event:Event):void {
		//trace('mouseMoveHandler');
		//if(objectUnderMouse == event.target)
			//return;
		
		//objectUnderMouse = event.target;
		if(resizeBegin)
			return;
		
		//trace('resizeBegin');
		
		var targetList:Array =
			DisplayUtil.getObjectsUnderMouse(this, 'vdom.components.editor.containers.workAreaClasses::Item');
			
		if(targetList.length == 0)
			return
			
		if(highlightedObject == targetList[0])
			return
		
		highlightedObject = targetList[0];
		
		if(
			topLevelItem != targetList[0] &&
			selectedObject != targetList[0]
		  ) {
				
			var objectName:String = dataManager.getObject(highlightedObject.objectID).@Name;
			
			var tipText:String = "Name:" + objectName;
			//resizeManager.highlightItem(highlightedObject, true, tipText);
			
		} else {
			
			//resizeManager.highlightItem(null);	
		}
	} */
	
	//private function mouseDownHandler(event:MouseEvent):void {
		
		//if(!highlightedObject || markerSelected)
			//return;
		
		//selectedObject = highlightedObject;
		//trace(selectedObject.name);
		//dispatchEvent(new WorkAreaEvent(WorkAreaEvent.OBJECT_CHANGE));
		
		//var selectionResult:Item;
		
		//itemStack =	DisplayUtil.getObjectsUnderMouse(this, 'vdom.components.editor.containers.workAreaClasses::Item');
		
		//selectionResult = Item(itemStack[0]);
		
		//if(!selectionResult) return;
		
		
		//selectedObjectId = highlightedObject.objectID;
		
		//selectionResult.setFocus();
		
		//if(topLevelObjectId != highlightedObject.objectID) {
			
			//var objectType:XML = dataManager.getTypeByObjectId(highlightedObject.objectID);
			
			/* resizeManager.selectItem(
					selectedObject, 
					objectType.Information.Moveable,
					objectType.Information.Resizable) */
		//} else
			//resizeManager.selectItem(null);
		
		//trace('WorkAreaEvent.OBJECT_CHANGE');
				
	//}
	
	/* private function mouseUpHandler(event:MouseEvent):void {
		
		if(highlightedObject != topLevelItem) {
		
		highlightedObject = null
		//resizeManager.highlightItem(null);
		
		var objectType:XML = dataManager.getTypeByObjectId(selectedObject.objectID);
		//trace('SELECT ITEM');
		resizeManager.selectItem(
					selectedObject, 
					objectType.Information.Moveable,
					objectType.Information.Resizable)
					
		} else {
			
			resizeManager.selectItem(null);
		}
	} */
	
	//private function mouseRollOutHandler(event:Event):void {
		
		//highlightedObject = null;
		//resizeManager.highlightItem(null);
	//}
	
	/* private function renderCompleteHandler(event:RenderManagerEvent):void {
		
		resizeManager.selectItem(selectedObject);
	} */
}
}