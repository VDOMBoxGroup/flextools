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
	
	private var _pageId:String;
	private var _selectedObject:Container;
	private var focusedObject:Container;
	
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
		resizeManager.selectItem(null);
	}
	
	public function updateObject(result:XML):void {
		
		var objectId:String = result.Object.@ID;
		
		if(objectId == IItem(_selectedObject).objectId && resizeManager.itemTransform)
			return;
			
		renderManager.updateItem(result.Object.@ID, result.Parent);
	}
	
	public function set pageId(page:String):void {
	
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
	
	public function createObject(result:XML):void {

		renderManager.createItem(result.Object.@ID, result.Object.Parent);
	}
	
	private function applyChanges(objectId:String, attributes:Object):void {
		
		var newAttributes:XML = <Attributes />
		
		for (var attributeName:String in attributes) {
			
			newAttributes.appendChild(<Attribute Name = {attributeName}>{attributes[attributeName]}</Attribute>);
		}
		
		var ee:EditEvent = new EditEvent(EditEvent.PROPS_CHANGED);
		ee.objectId = objectId;
		ee.props = newAttributes;
		dispatchEvent(ee);
	}
	
	/**
     *  @private
     */
	private function resizeCompleteHandler(event:ResizeManagerEvent):void {
		
		var selectedObject:Container = event.item;
		
		selectedObject.x = event.properties.left;
		selectedObject.y = event.properties.top;
		selectedObject.width = event.properties.width;
		selectedObject.height = event.properties.height;
		
		renderManager.lockItem(IItem(selectedObject).objectId);
		
		applyChanges(IItem(selectedObject).objectId, event.properties);
		
	}
	
	private function objectSelectHandler(event:ResizeManagerEvent):void {
		
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
		
		if(focusedObject == currentItem)
			return;
		
		if(focusedObject)
			IItem(focusedObject).drawHighlight('none');
		
		focusedObject = currentItem;
		
		var typeDescription:Object = event.dragSource.dataForFormat('typeDescription');
		
		var currentItemName:String = 
			dataManager.getTypeByObjectId(IItem(currentItem).objectId).Information.Name;
		
		var containersRE:RegExp = /(\w+)/g;
		
		var aviableContainers:Array = typeDescription.aviableContainers.match(containersRE);
		
		if(aviableContainers.indexOf(currentItemName) != -1) {
			
			IItem(currentItem).drawHighlight('0x00FF00');
		} else {
			
			IItem(currentItem).drawHighlight('0xFF0000');
		}
			
		
		//currentItem.drawFocus(true);
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
			
			dataManager.createObject(
				typeDescription.typeId,
				IItem(currentContainer).objectId,
				'',
				attributes);
				
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