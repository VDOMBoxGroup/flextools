package vdom.components.editor.containers {

import flash.display.Loader;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.containers.Canvas;
import mx.controls.Button;
import mx.controls.Image;
import mx.controls.Text;
import mx.events.DragEvent;

import vdom.components.editor.containers.workAreaClasses.Item;
import vdom.components.editor.containers.workAreaClasses.WysiwygCheckBox;
import vdom.components.editor.containers.workAreaClasses.WysiwygRadioButton;
import vdom.components.editor.events.ResizeManagerEvent;
import vdom.components.editor.events.WorkAreaEvent;
import vdom.components.editor.managers.ResizeManager;
import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.managers.DataManager;
import vdom.managers.ResourceManager;
import vdom.managers.VdomDragManager;

public class WorkArea extends Canvas {
	
	public var selectedObjectId:String;
	
	private var resizeManager:ResizeManager;
	private var resourceManager:ResourceManager;
	
	private var dataManager:DataManager;
	private var _elements:Object;
	private var collection:XML;
	private var soap:Soap;
	private var container:Item;
	
	private var applicationId:String;
	private var topLevelObjectId:String;
	
	private var _images:Object;
	private var loader:Loader;

	
	public function WorkArea() {
		
		super();
		dataManager = DataManager.getInstance();
		resourceManager = ResourceManager.getInstance();
		soap = Soap.getInstance();
		_images = {};
		_elements = [];
		
		
		
		addEventListener(MouseEvent.CLICK, mainClickHandler, false);
		
	}
	
	/**
	 * Обновление отображения объекта.
	 * @param objectAttributes аттрибуты объекта.
	 * 
	 */	
	/* public function updateObject(objectAttributes:XML):void {
		
		var objectId:String = objectAttributes.@ID;
		
		var object:Item = _elements[objectId];
		
		var objWidth:int = objectAttributes.Attributes.Attribute.(@Name == 'width')[0];
		var objHeight:int = objectAttributes.Attributes.Attribute.(@Name == 'height')[0];
		
		object.width = (objWidth == 0) ? 50 : objWidth;
		object.height = (objHeight == 0) ? 50 : objHeight;
		
		object.x = objectAttributes.Attributes.Attribute.(@Name == 'left')[0];
		object.y = objectAttributes.Attributes.Attribute.(@Name == 'top')[0];
		
		resizeManager.item = resizeManager.item;
	} */
	
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
		
		resizeManager.visible = false;
		selectedObjectId = null;
		createObjects(applicationId, topLevelObjectId, '');
		//removeChild(_elements[objectId]);
		//setFocus();
		
		//removeChild(resizeManager);
		dispatchEvent(new WorkAreaEvent(WorkAreaEvent.OBJECT_CHANGE));
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
			
			container = new Item(null)
			
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
		
		this.applicationId = applicationId;
		this.topLevelObjectId = topLevelObjectId;
		
		var parentId:String = '';
		if(objectId == '') objectId = topLevelObjectId;
		if(_elements[objectId]) {
			
			parentId = _elements[objectId].parentId;
			if(objectId == topLevelObjectId && parentId == topLevelObjectId) parentId = '';
		}
			
		var dyn:String = '1';
		//parentId = '';
		trace('------------------------');
		trace('topLevelObjectId: ' + topLevelObjectId);
		trace('objectId: ' + objectId);
		trace('parentId: ' + parentId);
		trace('------------------------');
		
		if(parentId == '')
			soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, updatePageHandler);
		else
			soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, updateItemHandler);
		soap.renderWysiwyg(applicationId, objectId, parentId, dyn);
	}
	
	private function updatePageHandler(event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.RENDER_WYSIWYG_OK, updatePageHandler);
		_elements = {};
		container.removeAllChildren();
		container.guid = topLevelObjectId;

		renderWysiwyg(event.result, container)
	}
	
	private function updateItemHandler(event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.RENDER_WYSIWYG_OK, updateItemHandler);
		var guid:String = event.result.object.@guid;
		var item:Item = _elements[guid];
		item.removeAllChildren();
		renderWysiwyg(event.result, Item(item.parent));
		resizeManager.item = _elements[selectedObjectId];
	}
	
	private function renderWysiwyg(source:XML, parent:Item = null):void {
		
		for each(var item:XML in source.*) {
			
			var name:String = item.name().localName;
			var guid:String = item.@guid.toString();
			var parentGuid:String = parent.guid;
			
			switch(name) {
				
				case 'object':
					var obj:Item = new Item(item.@guid);
					var objectAttributes:XML = dataManager.getObject(item.@guid);
					obj.horizontalScrollPolicy = 'off';
					obj.verticalScrollPolicy = 'off';
					parent.addChild(obj);
					obj.x = item.@left;
					obj.y = item.@top;
					if(int(item.@width) != 0)
						obj.width = item.@width;
					if(int(item.@height) != 0)
						obj.height = item.@height;
						
					var moveable:int = objectAttributes.Type.Information.Moveable;
					var resizable:int = objectAttributes.Type.Information.Resizable;		
					obj.name = 	objectAttributes.Type.Information.Name
					obj.parentId = parent.guid;
					
					switch (resizable) {
						case 0:
							obj.resizeMode = ResizeManager.RESIZE_NONE;
						break;
						case 1:
							obj.resizeMode = ResizeManager.RESIZE_WIDTH;
						break;
						case 2:
							obj.resizeMode = ResizeManager.RESIZE_HEIGHT;
						break;
						case 3:
							obj.resizeMode = ResizeManager.RESIZE_ALL;
						break;
					}
					switch (moveable) {
						case 0:
							obj.moveMode = false;
						break;
						case 1:
							obj.moveMode = true
						break;
					}
					
					obj.containers = objectAttributes.Type.Information.Containers;
					
					//trace('\n ---element---\nresizeMode: '+obj.resizeMode+'\nmoveMode: '+obj.moveMode);
					obj.addEventListener(MouseEvent.CLICK, objectClickHandler);
					obj.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
					
					obj.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler, true);
					obj.addEventListener(DragEvent.DRAG_DROP, dropHandler);
					
					_elements[objectAttributes.@ID] = obj;
					this.renderWysiwyg(item, obj);
				break;
				
				case 'rectangle':
					var rectangle:Canvas = new Canvas()
					parent.addChild(rectangle);
					//properties
					rectangle.x = item.@left;
					rectangle.y = item.@top;
					rectangle.width = item.@width;
					rectangle.height = item.@height;
					rectangle.setStyle('borderStyle', 'solid');
					rectangle.setStyle('borderThickness', item.@border);
					rectangle.setStyle('borderColor', item.@color);
					rectangle.setStyle('backgroundColor', '#'+item.@fill);
				break;
				
				case 'radiobutton':
					var radiobutton:WysiwygRadioButton = new WysiwygRadioButton()
					parent.addChild(radiobutton);
					
					radiobutton.x = item.@left;
					radiobutton.y = item.@top;
					radiobutton.width = item.@width;
					radiobutton.height = item.@height;
					radiobutton.value = item.@value;
					radiobutton.label = item.@label;
					if(item.@state == 'checked')
						radiobutton.selected = true;
					
					
					radiobutton.setStyle('fontStyle ', item.@font);
					radiobutton.setStyle('color ', item.@color);
				break;
				
				case 'checkbox':
					var checkbox:WysiwygCheckBox = new WysiwygCheckBox()
					parent.addChild(checkbox);
					
					checkbox.x = item.@left;
					checkbox.y = item.@top;
					checkbox.width = item.@width;
					checkbox.height = item.@height;
					checkbox.label = item.@label;
					if(item.@state == 'checked')
						checkbox.selected = true;
					
					checkbox.setStyle('fontStyle ', item.@font);
					checkbox.setStyle('color ', item.@color);
				break;
				
				case 'button':
					var button:Button = new Button()
					parent.addChild(button);
							
					button.x = item.@left;
					button.y = item.@top;
					button.width = item.@width;
					button.height = item.@height;
					button.label = item.@label;
					
					button.setStyle('fontStyle ', item.@font);
					button.setStyle('color ', item.@color);
				break;
				
				case 'text':
					var text:Text = new Text()
					parent.addChild(text);
					text.x = item.@left;
					text.y = item.@top;
					text.width = item.@width;
					text.height = item.@height;
					text.htmlText = item;
					text.selectable = false;
					text.setStyle('fontStyle ', item.@font);
					text.setStyle('color ', item.@color);
				break;
				
				case 'image':
					var image:Image = new Image()
					parent.addChild(image);
					image.x = item.@left;
					image.y = item.@top;
					image.width = item.@width;
					image.height = item.@height;
					image.maintainAspectRatio = false;
					_images[guid] = image;
					resourceManager.loadResource(parentGuid, guid, this);
				break;
			}
		}
	}
	
	public function set resource(imageResource:Object):void {
		
		_images[imageResource.guid].source = imageResource.data;
	}
	
	/**
	 * Добавление нового объекта в рабочую область
	 * @param objectAttributes аттрибуты объекта.
	 * 
	 */	
	/* public function addObject(objectAttributes:XML):void {
		
		var objectId:String = objectAttributes.@ID;
		var element:Item = new Item(objectId);
		var objWidth:int = objectAttributes.Attributes.Attribute.(@Name == 'width')[0];
		var objHeight:int = objectAttributes.Attributes.Attribute.(@Name == 'height')[0];
		
		element.width = (objWidth == 0) ? 50 : objWidth;
		element.height = (objHeight == 0) ? 50 : objHeight;
		
		element.x = objectAttributes.Attributes.Attribute.(@Name == 'left')[0];
		element.y = objectAttributes.Attributes.Attribute.(@Name == 'top')[0];
		
		var resizable:int = objectAttributes.Type.Information.Resizable;
		var moveable:int = objectAttributes.Type.Information.Moveable;
		
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
		switch (moveable) {
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
	} */
	
	/* public function addNewObject(objectAttributes:XML):void {
		
		var objectId:String = objectAttributes.@ID;
		var element:Item = new Item(objectId);
		var objWidth:int = objectAttributes.Attributes.Attribute.(@Name == 'width');
		var objHeight:int = objectAttributes.Attributes.Attribute.(@Name == 'height');
		
		element.width = (objWidth == 0) ? 50 : objWidth;
		element.height = (objHeight == 0) ? 50 : objHeight;
		
		element.x = objectAttributes.Attributes.Attribute.(@Name == 'left');
		element.y = objectAttributes.Attributes.Attribute.(@Name == 'top');
		
		var resizable:int = objectAttributes.Type.Information.Resizable;
		var moveable:int = objectAttributes.Type.Information.Moveable;
		
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
		switch (moveable) {
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
	} */
	
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
		
		var item:Item = Item(event.currentTarget);
		if(item.guid == selectedObjectId) return;
		
		if(selectedObjectId) {
			
			removeEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
			selectedObjectId = null;
			
		}
		
		selectedObjectId = item.guid;
		//_elements[selectedObjectId].content.setFocus();
		
		addEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
		resizeManager.resizeMode = _elements[selectedObjectId].resizeMode;
		resizeManager.moveMode = _elements[selectedObjectId].moveMode;
		resizeManager.item = _elements[selectedObjectId];
		resizeManager.visible = true;
		item.setFocus();
		//addChild(resizeManager);
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
			//removeChild(resizeManager);
			resizeManager.visible = false;
			dispatchEvent(new WorkAreaEvent(WorkAreaEvent.OBJECT_CHANGE));
		}
	}
	
	private function dragEnterHandler(event:DragEvent):void {
		
		var typeDescription:Object = event.dragSource.dataForFormat('typeDescription');
		var currentContainer:Item = Item(event.currentTarget);
		
		//var currentItemName:String = 'HTML'
		var currentItemName:String = currentContainer.name;
		var aviableContainers:Array = typeDescription.aviableContainers.split(',');
		//trace('acceptDragDrop '+ currentItemName);
		VdomDragManager.acceptDragDrop(currentContainer);
		if(aviableContainers.indexOf(currentItemName) != -1) {
			
			//VdomDragManager.acceptDragDrop(currentContainer);
			
		}
		
		//event.stopPropagation();
	}
	
	private function dropHandler(event:DragEvent):void {
		
		trace(event.currentTarget.name);
		
		var typeDescription:Object = event.dragSource.dataForFormat('typeDescription');
		var currentContainer:Item = Item(event.currentTarget);
		
		//var currentItemName:String = 'HTML'
		var currentItemName:String = currentContainer.name;
		var aviableContainers:Array = typeDescription.aviableContainers.split(',');
		//trace('acceptDragDrop '+ currentItemName);
		//VdomDragManager.acceptDragDrop(currentContainer);
		if(aviableContainers.indexOf(currentItemName) != -1) {
			
			var objectLeft:Number = currentContainer.mouseX - 25;// - bm.left;
			var objectTop:Number = currentContainer.mouseY - 25;// - bm.top;
		
			objectLeft = (objectLeft < 0) ? 0 : objectLeft;
			objectTop = (objectTop < 0) ? 0 : objectTop;
			
			var initProp:Object = {};
			
			initProp.typeId = typeDescription.typeId
			initProp.parentId = currentContainer.guid;
			initProp.left = objectLeft;
			initProp.top = objectTop;
			
			dataManager.createObject(initProp);
			
			trace('done!')
		}
		//var workArea:WorkArea = WorkArea(event.currentTarget);
		
		//var bm:EdgeMetrics = workArea.borderMetrics;
		
		//var typeId:String = event.dragSource.dataForFormat('Object').typeId;
		//var type:Object = editorDataManager.getType(typeId);
		
		/* Patch: проверка типа родителя */
		/* if(type.Information.Containers != 'HTML') {
			Alert.show('Not aviable');
			return;
		} */
		
		//var objectLeft:Number = workArea.mouseX - 25 - bm.left;
		//var objectTop:Number = workArea.mouseY - 25 - bm.top;
		
		//objectLeft = (objectLeft < 0) ? 0 : objectLeft;
		//objectTop = (objectTop < 0) ? 0 : objectTop;
		
		//var initProp:Object = {};
		
		//initProp.typeId = typeId;
		//initProp.left = objectLeft;
		//initProp.top = objectTop;
		
		//var id:String = editorDataManager.createObject(initProp);
		
		//var newItemAtrs:XML = editorDataManager.getAttributes(id);
		
		//workArea.addObject(newItemAtrs);
	}
}
}