package vdom.components.edit.containers {
	
import flash.display.DisplayObject;
import flash.events.MouseEvent;

import mx.containers.Canvas;
import mx.containers.VBox;
import mx.controls.Label;
import mx.core.Container;
import mx.core.UIComponent;
import mx.events.DragEvent;

import vdom.containers.IItem;
import vdom.controls.IToolBar;
import vdom.controls.ImageToolBar;
import vdom.controls.RichTextToolBar;
import vdom.events.RenderManagerEvent;
import vdom.events.ResizeManagerEvent;
import vdom.events.WorkAreaEvent;
import vdom.managers.DataManager;
import vdom.managers.FileManager;
import vdom.managers.RenderManager;
import vdom.managers.ResizeManager;
import vdom.managers.VdomDragManager;
import vdom.utils.DisplayUtil;

public class WorkArea extends VBox {
	
	private var resizeManager:ResizeManager = ResizeManager.getInstance();;
	private var fileManager:FileManager;
	private var renderManager:RenderManager = RenderManager.getInstance();;
	private var dataManager:DataManager = DataManager.getInstance();;
	
	private var _pageId:String;
	private var _objectId:String;
	
	private var _selectedObject:Container;
	private var focusedObject:Container;
	private var _contentHolder:Canvas;
	
	private var _contentToolbar:IToolBar;
	
	public function WorkArea() {
		
		super();
		registerEvent(true);
	}
	
	public function set pageId(value:String):void {
	
		if(value) {
			
			if(value != _pageId) {
			
				_pageId = value;
				renderManager.init(_contentHolder);
				renderManager.createItem(_pageId);
				resizeManager.selectItem(null);
			}
			
		} else {
				
			var warning:Label = new Label()
			warning.text = 'no page selected';
			_contentHolder.addChild(warning);
		}
	}
	
	public function set objectId(value:String):void {
		
		if(!value)
			return;
		
		_objectId = value;
		
		var item:IItem = renderManager.getItemById(value);
		
		if(item)
			resizeManager.selectItem(item);
	}
	
	private function registerEvent(flag:Boolean):void
	{	
		if(flag) {
			
			resizeManager.addEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
			renderManager.addEventListener(RenderManagerEvent.RENDER_COMPLETE, renderCompleteHandler);
			resizeManager.addEventListener(ResizeManagerEvent.OBJECT_SELECT, objectSelectHandler);
			
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, true);
			addEventListener(MouseEvent.ROLL_OUT, mouseRollOutHandler);
			
			addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
			addEventListener(DragEvent.DRAG_OVER, dragOverHandler);
			addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
			addEventListener(DragEvent.DRAG_EXIT, dragExitHandler);
		} else {
			
			resizeManager.removeEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
			renderManager.removeEventListener(RenderManagerEvent.RENDER_COMPLETE, renderCompleteHandler);
			resizeManager.removeEventListener(ResizeManagerEvent.OBJECT_SELECT, objectSelectHandler);
			
			removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, true);
			removeEventListener(MouseEvent.ROLL_OUT, mouseRollOutHandler);
			
			removeEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
			removeEventListener(DragEvent.DRAG_OVER, dragOverHandler);
			removeEventListener(DragEvent.DRAG_DROP, dragDropHandler);
			removeEventListener(DragEvent.DRAG_EXIT, dragExitHandler);		
		}
	}
	
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
		
		renderManager.deleteItem(objectId);
	}
	
	public function lockItem(objectId:String):void {
		
		renderManager.lockItem(objectId);
	}
	
	public function updateObject(result:XML):void {
		
		var objectId:String = result.Object.@ID;
		
		if(_selectedObject && objectId == IItem(_selectedObject).objectId && resizeManager.itemTransform)
			return;
		
		var item:IItem = renderManager.getItemById(objectId);
		
		if(_contentToolbar)
			_contentToolbar.close();
		
		if(item && item.waitMode)
			renderManager.updateItem(result.Object.@ID, result.Parent);
	}
	
	public function createObject(result:XML):void {

		renderManager.createItem(result.Object.@ID, result.Object.Parent);
	}
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		if(!_contentHolder) {
			
			_contentHolder = new Canvas();
		}
		
		_contentHolder.clipContent = true;
		_contentHolder.horizontalScrollPolicy = "off"; 
		_contentHolder.verticalScrollPolicy = "off";
		_contentHolder.percentWidth = 100;
		_contentHolder.percentHeight = 100;
		
		addChild(_contentHolder);
	}
	
	private function applyChanges(objectId:String, attributes:Object):void {
		
		var newAttributes:XML = <Attributes />
		
		for (var attributeName:String in attributes) {
			
			newAttributes.appendChild(<Attribute Name = {attributeName}>{attributes[attributeName]}</Attribute>);
		}
		
		var wae:WorkAreaEvent = new WorkAreaEvent(WorkAreaEvent.PROPS_CHANGED);
		wae.objectId = objectId;
		wae.props = newAttributes;
		dispatchEvent(wae);
	}
	
	private function initToolbar(item:IItem):void
	{	
		var interfaceType:uint;
		
		if(item && item.editableAttributes.length && item.objectId) {
			
			var type:XML = dataManager.getTypeByObjectId(IItem(_selectedObject).objectId);
			interfaceType = type.Information.InterfaceType;
		}
		else {
			
			interfaceType = 0;
		}
		
		var flag:Boolean = false;
		var newContentToolBar:IToolBar;
		var object:*;
		
		switch(interfaceType)
		{
		case 2:
		{
			if(!(_contentToolbar is RichTextToolBar))
				newContentToolBar = new RichTextToolBar();
			else
				newContentToolBar = _contentToolbar;
			
			object = item.editableAttributes[0].sourceObject;
			flag = true;
			
			break
		}
		case 3:
		{
			break
		}
		case 4:
		{
			if(!(_contentToolbar is ImageToolBar))
				newContentToolBar = new ImageToolBar();
			else
				newContentToolBar = _contentToolbar;
			
			object = item.editableAttributes[0].sourceObject
			
			flag = true;
		break;
		}
		}
		
		if(!flag && _contentToolbar && DisplayObject(_contentToolbar).parent) {
			
			removeChild(DisplayObject(_contentToolbar));
			_contentToolbar = null;
			return;
		}
		
		if(flag)
		{
			if(!DisplayObject(newContentToolBar).parent && _contentToolbar && DisplayObject(_contentToolbar).parent)
				removeChild(DisplayObject(_contentToolbar));
			
			_contentToolbar = newContentToolBar;
			
			if(_contentToolbar && !DisplayObject(_contentToolbar).parent)
				addChild(DisplayObject(_contentToolbar));
			
			_contentToolbar.init(IItem(_selectedObject), object);
		}
	}
	
	/**
     *  @private
     */
	private function resizeCompleteHandler(event:ResizeManagerEvent):void {
		
		var currentObject:Container = event.item;
		var changeFlag:Boolean = false;
		
		if (currentObject.x != event.properties.left) 
			currentObject.x = event.properties.left;
			
		if (currentObject.y != event.properties.top)
			currentObject.y = event.properties.top;
		
		if (currentObject.width != event.properties.width) {
			
			currentObject.width = event.properties.width;
			changeFlag = true;
		}
			
		if (currentObject.height != event.properties.height) {
			
			currentObject.height = event.properties.height;
			changeFlag = true;
		}
		
		if (changeFlag)
			lockItem(IItem(currentObject).objectId);
		
		applyChanges(IItem(currentObject).objectId, event.properties);
	}
	
	private function objectSelectHandler(event:ResizeManagerEvent):void {
		
		var currentToolBar:IToolBar;
		
		if(_contentToolbar && DisplayObject(_contentToolbar).parent)
			currentToolBar = _contentToolbar;
		
		if(currentToolBar)
			currentToolBar.close();
		
		if(_selectedObject && IItem(_selectedObject).editableAttributes[0] &&
			currentToolBar && !currentToolBar.selfChanged
		) {
			
			var attribute:Object = IItem(_selectedObject).editableAttributes[0];
			var attributeValue:String = attribute.sourceObject[attribute.sourceName];
			
			var newAttribute:Object = {};
			
			var xmlCharRegExp:RegExp = /[<>&"]+/;
			
			if(attributeValue.search(xmlCharRegExp) != -1)
				newAttribute[attribute.destName] = XML('<![CDATA['+attributeValue+']'+']>');
				
			else
				newAttribute[attribute.destName] = attributeValue;
			
			applyChanges(IItem(_selectedObject).objectId, newAttribute);
		}
		
		_selectedObject = event.item;
		
		initToolbar(IItem(_selectedObject));
		
		if(!_selectedObject)
			return;
		
		var wae:WorkAreaEvent = new WorkAreaEvent(WorkAreaEvent.CHANGE_OBJECT);
		wae.objectId = IItem(_selectedObject).objectId;
		dispatchEvent(wae);
	}
	
	private function renderCompleteHandler(event:RenderManagerEvent):void {
		
		if(!event.result)
			return;
		
		if(IItem(event.result).objectId == _pageId) {
			
			resizeManager.init(_contentHolder);
		}
		
		var currentObjectId:String;
		
		if(_selectedObject)
			currentObjectId = IItem(_selectedObject).objectId;
		
		var item:IItem;
		if(_objectId && _objectId != currentObjectId)
			item = renderManager.getItemById(_objectId);
			
		var flag:Boolean = true;
		if(_objectId == _pageId)
			flag = false;
		
		if(item)
			resizeManager.selectItem(item, flag);
		
		if(
			event.result == _selectedObject && 
			_contentToolbar
		) {
			
			initToolbar(IItem(event.result));
//			var obj:* = IItem(event.result).editableAttributes[0].sourceObject;
//			_contentToolbar.init(IItem(event.result), obj);
		}
	}

	private function dragEnterHandler(event:DragEvent):void {
		
		resizeManager.itemDrag = true;
		VdomDragManager.acceptDragDrop(UIComponent(event.currentTarget));
		focusedObject = null
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
		
		//trace('WorkArea - dragOverHandler ' + stack.length)
		
		if(focusedObject == currentItem || IItem(currentItem).waitMode)
			return;
		
		if(focusedObject)
			IItem(focusedObject).drawHighlight('none');
		
		var typeDescription:Object = event.dragSource.dataForFormat('typeDescription');
		var containersRE:RegExp = /(\w+)/g;
		var aviableContainers:Array = typeDescription.aviableContainers.match(containersRE);
		
		var currentItemDescription:XML = 
					dataManager.getTypeByObjectId(IItem(currentItem).objectId);
		
		var currentItemName:String = currentItemDescription.Information.Name;
		
		
		if(aviableContainers.indexOf(currentItemName) != -1) {
			
			IItem(currentItem).drawHighlight('0x00FF00');
			
		} else if(currentItemDescription.Information.Container != 1) {
			
			IItem(currentItem).drawHighlight('0xFF0000');
			
		} else if(currentItem.parent is IItem) {
				
				currentItem = Container(currentItem.parent);
				
				currentItemDescription = 
					dataManager.getTypeByObjectId(IItem(currentItem).objectId);
					
				currentItemName = currentItemDescription.Information.Name;
					
				if(aviableContainers.indexOf(currentItemName) != -1)
					
					IItem(currentItem).drawHighlight('0x00FF00');
				else	
					IItem(currentItem).drawHighlight('0xFF0000');
		}
		
		focusedObject = currentItem;
	}
	
	private function dragDropHandler(event:DragEvent):void {
		
		resizeManager.itemDrag = false;
		
		var typeDescription:Object = event.dragSource.dataForFormat('typeDescription');
		
		var currentContainer:Container = focusedObject;
		
		if(focusedObject is IItem)
			IItem(focusedObject).drawHighlight('none');
		
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
			
			var objectLeft:Number = currentContainer.mouseX - 25;
			var objectTop:Number = currentContainer.mouseY - 25;
		
			objectLeft = (objectLeft < 0) ? 0 : objectLeft;
			objectTop = (objectTop < 0) ? 0 : objectTop;
			
			var attributes:XML = 
				<Attributes>
        			<Attribute Name="top">{objectTop}</Attribute>
        			<Attribute Name="left">{objectLeft}</Attribute>
    			</Attributes>
			
			var wae:WorkAreaEvent = new WorkAreaEvent(WorkAreaEvent.CREATE_OBJECT)
			wae.typeId = typeDescription.typeId;
			wae.objectId = IItem(currentContainer).objectId;
			wae.props = attributes;
			
			dispatchEvent(wae);
				
			focusedObject = null;
		}
	}
	
	private function dragExitHandler(event:DragEvent):void {
		
		resizeManager.itemDrag = false;
		
		if(focusedObject is IItem)
			IItem(focusedObject).drawHighlight('none');
	}
	
	private function mouseWheelHandler(event:MouseEvent):void {
		
		event.stopPropagation();
	}
	
	private function mouseRollOutHandler(event:MouseEvent):void {
		
		cursorManager.removeAllCursors();
	}
}
}