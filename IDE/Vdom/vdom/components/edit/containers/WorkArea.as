package vdom.components.edit.containers {
	
import flash.events.MouseEvent;

import mx.containers.Canvas;
import mx.containers.VBox;
import mx.controls.HTML;
import mx.controls.Label;
import mx.core.Container;
import mx.core.UIComponent;
import mx.events.DragEvent;

import vdom.components.edit.containers.toolbarClasses.ImageTools;
import vdom.components.edit.containers.toolbarClasses.RichTextTools;
import vdom.containers.IItem;
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
	
	private var resizeManager:ResizeManager;
	private var fileManager:FileManager;
	private var renderManager:RenderManager;
	private var dataManager:DataManager;
	
	private var _pageId:String;
	private var _selectedObject:Container;
	private var focusedObject:Container;
	private var _contentHolder:Canvas;
	private var _contentToolbar:Canvas;
	
	public function WorkArea() {
		
		super();
		
		dataManager = DataManager.getInstance();
		renderManager = RenderManager.getInstance();
		resizeManager = ResizeManager.getInstance();
		
		resizeManager.addEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
		resizeManager.addEventListener(ResizeManagerEvent.OBJECT_SELECT, objectSelectHandler);
		
		addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, true);
		addEventListener(MouseEvent.ROLL_OUT, mouseRollOutHandler);
		
		addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
		addEventListener(DragEvent.DRAG_OVER, dragOverHandler);
		addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
		addEventListener(DragEvent.DRAG_EXIT, dragExitHandler);
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
		
		//selectedObject = null;
		renderManager.deleteItem(objectId);
		//resizeManager.selectItem(null);
	}
	
	public function updateObject(result:XML):void {
		
		var objectId:String = result.Object.@ID;
		
		if(_selectedObject && objectId == IItem(_selectedObject).objectId && resizeManager.itemTransform)
			return;
			
		renderManager.updateItem(result.Object.@ID, result.Parent);
	}
	
	public function set pageId(page:String):void {
	
		if(page) {
			
			if(page != _pageId) {
			
				_pageId = page;
				renderManager.init(_contentHolder);
				renderManager.addEventListener(RenderManagerEvent.RENDER_COMPLETE, renderCompleteHandler);
				renderManager.createItem(_pageId);
			}
			
		} else {
				
			var warning:Label = new Label()
			warning.text = 'no page selected';
			_contentHolder.addChild(warning);
		}
	}
	
	public function set objectId(value:String):void {
		
		if(!value /* || _selectedObject && IItem(_selectedObject).objectId == value */)
			return;
	
		var item:IItem = renderManager.getItemById(value);
		
		if(item)	
			resizeManager.selectItem(item)
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
	
	/**
     *  @private
     */
	private function resizeCompleteHandler(event:ResizeManagerEvent):void {
		
		var currentObject:Container = event.item;
		
		currentObject.x = event.properties.left;
		currentObject.y = event.properties.top;
		currentObject.width = event.properties.width;
		currentObject.height = event.properties.height;
		
		renderManager.lockItem(IItem(currentObject).objectId);
		
		applyChanges(IItem(currentObject).objectId, event.properties);
		
	}
	
	private function objectSelectHandler(event:ResizeManagerEvent):void {
		
		if(_selectedObject && IItem(_selectedObject).editableAttributes.length > 0) {
			
			var editableAttributes:Array = IItem(_selectedObject).editableAttributes;
			
			var attributes:Object = {}
			
			for each(var attribute:Object in editableAttributes) {
				
				if(attribute.sourceObject is HTML) {
					attributes[attribute.destName] = 
						HTML(attribute.sourceObject).domWindow.document.getElementsByTagName('body')[0].innerHTML
						
				} else
					attributes[attribute.destName] = attribute.sourceObject[attribute.sourceName];
			}
			
			applyChanges(IItem(_selectedObject).objectId, attributes);
		}
		
		var selectedObjectId:String = IItem(event.item).objectId;
		
		var type:XML = dataManager.getTypeByObjectId(selectedObjectId);
		var interfaceType:uint = type.Information.InterfaceType;
		
		if(_contentToolbar && _contentToolbar.parent) {
			
			removeChild(_contentToolbar);
			_contentToolbar = null;
		}
		
		
		switch(interfaceType) {
		
		case 2:
			
			
		break
		
		case 3:
			_contentToolbar = new RichTextTools();
			var obj:HTML = HTML(IItem(event.item).editableAttributes[0].sourceObject);
			RichTextTools(_contentToolbar).init(obj);
		break
		
		case 4:
			
			_contentToolbar = new ImageTools();
		break
		}
		
		if(_contentToolbar)
			addChild(_contentToolbar);
		
		_selectedObject = event.item;
		
		var wae:WorkAreaEvent = new WorkAreaEvent(WorkAreaEvent.CHANGE_OBJECT);
		wae.objectId = IItem(_selectedObject).objectId;
		dispatchEvent(wae);
	}
	
	private function renderCompleteHandler(event:RenderManagerEvent):void {
		
		renderManager.removeEventListener(RenderManagerEvent.RENDER_COMPLETE, renderCompleteHandler);
		resizeManager.init(_contentHolder);
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