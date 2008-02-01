package vdom.managers {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.collections.XMLListCollection;
import mx.containers.Canvas;
import mx.controls.Button;
import mx.controls.Image;
import mx.controls.Text;
import mx.controls.TextArea;
import mx.core.Application;
import mx.core.Container;
import mx.core.UIComponent;
import mx.events.DragEvent;

import vdom.components.editor.containers.workAreaClasses.Item;
import vdom.components.editor.containers.workAreaClasses.WysiwygCheckBox;
import vdom.components.editor.containers.workAreaClasses.WysiwygImage;
import vdom.components.editor.containers.workAreaClasses.WysiwygRadioButton;
import vdom.components.editor.containers.workAreaClasses.WysiwygText;
import vdom.components.editor.containers.workAreaClasses.WysiwygTextInput;
import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.events.RenderManagerEvent;
import flash.display.Graphics;
import vdom.managers.renderClasses.ItemDescription;

public class RenderManager implements IEventDispatcher {
	
	private static var instance:RenderManager;
	
	private var soap:Soap;
	private var dispatcher:EventDispatcher;
	private var publicData:Object;
	private var resourceManager:ResourceManager;
	
	private var _container:Container;
	private var applicationId:String;
	private var _items:ArrayCollection;
	private var _source:XML;
	private var _cursor:IViewCursor;
	
	/**
	 * 
	 * @return instance of RenderManager class (Singleton)
	 * 
	 */
	public static function getInstance():RenderManager {
		
		if (!instance) {
			
			instance = new RenderManager();
		}

		return instance;
	}
	
	public function RenderManager() {
		
		if (instance)
			throw new Error("Instance already exists.");
		
		dispatcher = new EventDispatcher();
		soap = Soap.getInstance();
		resourceManager = ResourceManager.getInstance();
		
		publicData = mx.core.Application.application.publicData;
		
		_items = new ArrayCollection();
		_cursor = _items.createCursor();
		
		var sort:Sort = new Sort();
		
		_items.sort = sort;
		_items.sort.fields = [new SortField('objectID')];
		
		_items.refresh();
		
		soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, renderWysiwygOkHandler);
	}
	
	/* public function renderWYSIWYG(applicationId:String, objectId:String, parentId:String):void {
		
		var dyn:String = '1';
		
		soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, renderWysiwygOkHandler);
		soap.renderWysiwyg(applicationId, objectId, parentId, dyn);
	} */
	
	/* public function removeItem(id:String):void {
		
		
	} */
	
	/* public function refreshItem(objectId:String, parentId:String):void {
		
		
	} */
	
	public function init(destContainer:Container, applicationId:String = null):void {
		//_container.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		_container = destContainer;
		
		//_container.removeAllChildren();
		//_container.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		/* if(_items.length > 0)
			_items.removeAll(); */
			
		if(!applicationId)
			this.applicationId = publicData['applicationId'];
			
	}
	
	public function addItem(objectID:String, parentID:String = ''):Item {
		
		var item:Item = new Item(objectID);
		
		var fullPath:String = '';
		
		var parentObject:Container;
		
		if(parentID == '') {
			
			_items.removeAll();
			
			parentObject = _container;
			parentObject.removeAllChildren();
			
			fullPath = objectID;
			
			item.setStyle('backgroundColor', '#cc0000');
			item.setStyle('backgroundAlpha', .0);
			
			item.visible = false;
			
			item.percentWidth = 100;
			item.percentHeight = 100;
			
		} else {
			
			/* _items.filterFunction = null;
			_items.sort = new Sort();
			_items.sort.fields = [new SortField('objectID')];
			_items.refresh(); */
			
			_cursor.findFirst({objectID:parentID});
			
			fullPath = _cursor.current.fullPath + '.' + objectID;
			
			parentObject = _cursor.current.item;
		}
		
		var itemDescription:ItemDescription = new ItemDescription();
		
			itemDescription.objectID = objectID;
			itemDescription.parentID = parentID;
			itemDescription.fullPath = fullPath;
			itemDescription.zindex = 0;
			itemDescription.hierarchy = 0;
			itemDescription.order = 0;
			itemDescription.item = item;
			itemDescription.properties = {};
		
		_items.addItem(itemDescription);
		
		parentObject.addChild(item);
		
		soap.renderWysiwyg(publicData['applicationId'], objectID, parentID);
		
		return item;
	}
	
	public function deleteItem(objectID:String):void {
		
		_items.filterFunction = 
			function (item:Object):Boolean {
				return (item.fullPath.indexOf(objectID) != -1);
		}
		/* _items.sort = new Sort();
		_items.sort.fields = [new SortField('objectID')]; */
		_items.refresh();
		
		_cursor.findAny({objectID:objectID});
		
		var currentItem:Item = _cursor.current.item;
		
		Container(currentItem.parent).removeChild(currentItem);
		
		_items.removeAll();
		
		_items.filterFunction = null;
		_items.refresh();
	}
	
	public function updateItem(objectID:String, parentID:String):void {
		
		/* _items.filterFunction = null;
		_items.sort = new Sort();
		_items.sort.fields = [new SortField('objectID')];
		_items.refresh(); */
		
		//_cursor.findAny({objectID:objectID});
		
		//var currentItem:Item = Item(_cursor.current.item);
		//currentItem.graphics.clear();
		//currentItem.removeAllChildren();
		//currentItem.waitMode = true;
		//parentID = _cursor.current.parentID
			
		soap.renderWysiwyg(applicationId, objectID, parentID);
			
	}
	
	private function renderWysiwygOkHandler(event:SoapEvent):void {
		
		var itemXMLDescription:XML = /*_source = */event.result.object[0];
		
		var itemID:String = itemXMLDescription.@guid;
		
		var findItemResult:Boolean = _cursor.findAny({objectID:itemID});
		
		if(!findItemResult)
			trace('Error item finding!!!');
		
		var itemDescription:ItemDescription = ItemDescription(_cursor.current);
		
		var item:Item = itemDescription.item;
		
		itemDescription.zindex = uint(itemXMLDescription.@zindex);
		itemDescription.hierarchy = uint(itemXMLDescription.@hierarchy);
		
		var findParentResult:Boolean = 
			_cursor.findAny({objectID:itemDescription.parentID});
		
		var parentContainer:Item = null;
		
		if(findParentResult)
			parentContainer = Item(_cursor.current.item);
		
		item.x = itemXMLDescription.@left;
		item.y = itemXMLDescription.@top;
		
		if(itemXMLDescription.@width.length())
			item.width = itemXMLDescription.@width;
			
		if(itemXMLDescription.@height.length())
			item.height = itemXMLDescription.@height;
		
		var staticContainer:Boolean = false;
		
		if(itemXMLDescription.@contents == 'static')
			staticContainer = true;
		
		item.removeAllChildren();
		
		/* var numChildren:uint = item.numChildren;
		
		for(var i:uint = 0; i < numChildren; i++) {
			
			var child:* = item.getChildAt(i);
			
			if(child is Item)
				item.removeChildAt(i);
		} */ 
		
		//container.removeViewChildren();
			
		_items.filterFunction = 
			function (ido:Object):Boolean {
				return (ido.fullPath.indexOf(itemID+'.') != -1);
		}
		
		_items.refresh();
		_items.removeAll();
		
		_items.filterFunction = null;
		_items.refresh();
		
		render(item, itemXMLDescription, itemDescription.fullPath, staticContainer, item);
		
		if(itemDescription.parentID) {
			
			_items.filterFunction = 
				function (item:Object):Boolean {
					return item.parentID == itemDescription.parentID;
			}
			
			//var sort:Sort = new Sort();
			//sort.fields = 
			_items.sort.fields = [
					new SortField('zindex'), 
					new SortField('hierarchy'), 
					new SortField('order')
			];
			
			_items.refresh();
			
			var count:uint = 0;
			
			for each (var collectionItem:Object in _items) {
				
				parentContainer.setChildIndex(collectionItem.item, count);
				count++;
				//this.render(viewObject, collectionItem, staticContainer);
			}
			
			_items.filterFunction = null;
			_items.sort.fields = [new SortField('objectID')]
			
			_items.refresh();
		}
		
		item.visible = true;
		
		var rme:RenderManagerEvent = new RenderManagerEvent(RenderManagerEvent.RENDER_COMPLETE);
		rme.result = item;
		dispatchEvent(rme); 
	}
	
/* 	private function rollOverHandler(event:MouseEvent):void {
		//trace('RM-mouseOverHandler');
		var rme:RenderManagerEvent = new RenderManagerEvent(
				RenderManagerEvent.RENDER_ROLL_OVER,
				Item(event.currentTarget),
				true);
		dispatchEvent(rme);
	}
	
	private function rollOutHandler(event:MouseEvent):void {
		
		var rme:RenderManagerEvent = new RenderManagerEvent(RenderManagerEvent.RENDER_ROLL_OUT);
		rme.result = Item(event.currentTarget);
		dispatchEvent(rme);
	} */
	
	private function render(
		parentContainer:Container, 
		source:XML, 
		fullPath:String, 
		staticContainer:Boolean,
		parentItem:Item):void {
		
		//var itemList:XMLListCollection = new XMLListCollection();
		//var count:int = 0;
		var parentID:String = source.@guid;
		
		for each(var itemXMLDescription:XML in source.*) {
			
			var objectName:String = itemXMLDescription.name().localName;
			var objectID:String = itemXMLDescription.@guid.toString(); 
			
			switch(objectName) {
				
				case 'object':
				
					var viewObject:Container;
					var item:Item;
			
					if(!staticContainer) {
						
						viewObject = item = new Item(objectID);
						
						//viewObject.addEventListener(MouseEvent.MOUSE_OVER, rollOverHandler, false);
						//viewObject.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
						
					} else {
						
						viewObject = new Canvas();
						item = parentItem;
					}
						
						
					viewObject.setStyle('backgroundColor', '#ffffff');
					viewObject.setStyle('backgroundAlpha', '.0');
					
					viewObject.clipContent = true;
					
					viewObject.x = itemXMLDescription.@left;
					viewObject.y = itemXMLDescription.@top;
					
					//var zzz:* = itemDescription.@width;
					
					if(itemXMLDescription.@width.length())
						viewObject.width = itemXMLDescription.@width;
					
					if(itemXMLDescription.@height.length()) {
						//trace('height set!: '+itemDescription.@height)
						viewObject.height = itemXMLDescription.@height;
					}
						
					
					/* if(parentID && viewObject is Item)	
						Item(viewObject).parentID = parentID; */
					
					//parentContainer.addChild(viewObject);
					
					if(staticContainer || itemXMLDescription.@contents == 'static')
						staticContainer = true;
					
					var newPath:String = fullPath + '.' + objectID
					
					var itemDescription:ItemDescription = new ItemDescription();
					
					itemDescription.objectID = objectID;
					itemDescription.parentID = parentID;
					itemDescription.fullPath = fullPath;
					itemDescription.zindex = 0;
					itemDescription.hierarchy = 0;
					itemDescription.order = 0;
					itemDescription.item = item;
					itemDescription.properties = {};
					
					_items.addItem(itemDescription);
					//trace('objectID: ' + objectID, 'zindex: '+itemDescription.@zindex);
					//count++;
					
					this.render(viewObject, itemXMLDescription, newPath, staticContainer, item);
					
				break;
				
				case 'rectangle':
					
					var graph:Graphics = parentContainer.graphics;
					
					graph.beginFill(Number('0x' + itemXMLDescription.@fill));
					
					if(itemXMLDescription.@border > 0) {
						
						var border:uint = itemXMLDescription.@border;
						var color:uint = Number('0x' + itemXMLDescription.@color);
						
						graph.lineStyle(border, color);
					}
					
					if(itemXMLDescription.@fill.length)
						graph.beginFill(
							Number('0x' + itemXMLDescription.@fill));
						
					graph.drawRect(
						itemXMLDescription.@left,
						itemXMLDescription.@top,
						itemXMLDescription.@width,
						itemXMLDescription.@height
					);
					graph.endFill();
					//var viewRectangle:Canvas = new Canvas()
					
					//properties
					/* viewRectangle.x = itemDescription.@left;
					viewRectangle.y = itemDescription.@top;
					viewRectangle.width = itemDescription.@width;
					viewRectangle.height = itemDescription.@height;
					viewRectangle.setStyle('borderStyle', 'solid');
					viewRectangle.setStyle('borderThickness', itemDescription.@border);
					viewRectangle.setStyle('borderColor', itemDescription.@color);
					viewRectangle.setStyle('backgroundColor', '#'+itemDescription.@fill);
					
					//parentContainer.addChild(viewRectangle);
					
					/* if(parentContainer is Item)					
						Item(parentContainer).addViewChild(viewRectangle);
						
					else
						parentContainer.rawChildren.addChild(viewRectangle);  */
					
				break;
				
				case 'radiobutton':
					
					var viewRadiobutton:WysiwygRadioButton = new WysiwygRadioButton()
					
					viewRadiobutton.x = itemXMLDescription.@left;
					viewRadiobutton.y = itemXMLDescription.@top;
					viewRadiobutton.width = itemXMLDescription.@width;
					viewRadiobutton.height = itemXMLDescription.@height;
					viewRadiobutton.value = itemXMLDescription.@value;
					viewRadiobutton.label = itemXMLDescription.@label;
					
					if(itemXMLDescription.@state == 'checked')
						viewRadiobutton.selected = true;
					
					
					viewRadiobutton.setStyle('fontStyle ', itemXMLDescription.@font);
					viewRadiobutton.setStyle('color ', itemXMLDescription.@color);
					
					parentContainer.addChild(viewRadiobutton);
					
				break;
				
				case 'checkbox':
				
					var viewCheckbox:WysiwygCheckBox = new WysiwygCheckBox()
					
					viewCheckbox.x = itemXMLDescription.@left;
					viewCheckbox.y = itemXMLDescription.@top;
					viewCheckbox.width = itemXMLDescription.@width;
					viewCheckbox.height = itemXMLDescription.@height;
					viewCheckbox.label = itemXMLDescription.@label;
					if(itemXMLDescription.@state == 'checked')
						viewCheckbox.selected = true; 
						
					viewCheckbox.setStyle('fontStyle ', itemXMLDescription.@font);
					viewCheckbox.setStyle('color ', itemXMLDescription.@color);
					parentContainer.removeAllChildren();
					parentContainer.addChild(viewCheckbox);
					
				break;
				
				/* case 'table':
					
					//trace('aaaa');
					
				break */
				
				case 'input':
				
					var viewInput:WysiwygTextInput = new WysiwygTextInput()
					
					viewInput.x = itemXMLDescription.@left;
					viewInput.y = itemXMLDescription.@top;
					viewInput.width = itemXMLDescription.@width;
					if(itemXMLDescription.@height.length())
						viewInput.height = itemXMLDescription.@height;
					viewInput.htmlText = itemXMLDescription;
					viewInput.editable = false;
					viewInput.enabled = false;
					//viewInput.selectable = false;
					viewInput.setStyle('disabledColor', '#000000');
					viewInput.setStyle('fontStyle', itemXMLDescription.@font);
					viewInput.setStyle('color', itemXMLDescription.@color);
					
					//viewInput.setStyle('borderStyle', 'solid');
					//viewInput.setStyle('borderColor', '#cccccc');
					//viewInput.setStyle('borderAlpha', .3);
					//viewInput.setStyle('backgroundAlpha', 0);
					viewInput.focusEnabled = false;
					
					parentContainer.addChild(viewInput);
					
				break;
				
				case 'password':
				
					var viewPassword:WysiwygTextInput = new WysiwygTextInput()
					
					viewPassword.x = itemXMLDescription.@left;
					viewPassword.y = itemXMLDescription.@top;
					viewPassword.width = itemXMLDescription.@width;
					if(itemXMLDescription.@height.length())
						viewPassword.height = itemXMLDescription.@height;
					viewPassword.htmlText = itemXMLDescription;
					viewPassword.editable = false;
					viewPassword.enabled = false;
					viewPassword.displayAsPassword = true;
					//viewInput.selectable = false;
					viewPassword.setStyle('disabledColor', '#000000');
					viewPassword.setStyle('fontStyle', itemXMLDescription.@font);
					viewPassword.setStyle('color', itemXMLDescription.@color);
					
					//viewInput.setStyle('borderStyle', 'solid');
					//viewInput.setStyle('borderColor', '#cccccc');
					//viewInput.setStyle('borderAlpha', .3);
					//viewInput.setStyle('backgroundAlpha', 0);
					viewPassword.focusEnabled = false;
					
					parentContainer.addChild(viewPassword);
					
				break;
				
				case 'button':
				
					var viewButton:Button = new Button()
							
					viewButton.x = itemXMLDescription.@left;
					viewButton.y = itemXMLDescription.@top;
					viewButton.width = itemXMLDescription.@width;
					viewButton.height = itemXMLDescription.@height;
					viewButton.label = itemXMLDescription.@label;
					
					//viewButton.setStyle('fontStyle ', itemDescription.@font);
					//viewButton.setStyle('color ', itemDescription.@color);
					
					parentContainer.addChild(viewButton);
					
				break;
				
				case 'text':
					
					var viewText:WysiwygText = new WysiwygText()
					
					viewText.x = itemXMLDescription.@left;
					viewText.y = itemXMLDescription.@top;
					viewText.width = itemXMLDescription.@width;
					
					viewText.condenseWhite = true;	
					viewText.height = itemXMLDescription.@height;
					viewText.htmlText = itemXMLDescription;
					
					viewText.selectable = false;
					
					viewText.setStyle('fontStyle', itemXMLDescription.@font);
					viewText.setStyle('color', itemXMLDescription.@color);
					
					viewText.setStyle('borderStyle', 'solid');
					viewText.setStyle('borderColor', '#cccccc');
					viewText.setStyle('borderAlpha', .3);
					viewText.setStyle('backgroundAlpha', 0);
					
					if(itemXMLDescription.@editable.length()) {
										
						parentItem.editableAttributes.push(
							{destName:String(itemXMLDescription.@editable),
							sourceObject:viewText,
							sourceName:'htmlText'}
						);
					}
					
					parentContainer.addChild(viewText);
					
				break;
				
				case 'image':
					
					var viewImage:Image = new WysiwygImage()
					
					viewImage.x = itemXMLDescription.@left;
					viewImage.y = itemXMLDescription.@top;
					
					if(itemXMLDescription.@width.length())
						viewImage.width = itemXMLDescription.@width;
					if(itemXMLDescription.@height.length()) {
						//trace('image set height!: '+itemDescription.@height)
						viewImage.height = itemXMLDescription.@height;
					}
						
						
					viewImage.maintainAspectRatio = false;
					
					resourceManager.loadResource(parentID, objectID, viewImage, 'source', true);
					
					parentContainer.addChild(viewImage);
					
				break;
			}
		}
		
		_items.filterFunction = 
			function (item:Object):Boolean {
				return item.parentID == parentID;
		}
		
		_items.sort.fields = [new SortField('zindex'), new SortField('hierarchy'), new SortField('order')];
		//_items.sort = sort;
		
		_items.refresh();
		
		for each (var collectionItem:Object in _items) {
			
			parentContainer.addChild(collectionItem.item);
			//this.render(viewObject, collectionItem, staticContainer);
		}
		
		_items.filterFunction = null;
		_items.sort.fields = [new SortField('objectID')]
			
		_items.refresh();
	}
		
	/**
     *  @private
     */
	public function addEventListener(
		type:String, 
		listener:Function, 
		useCapture:Boolean = false, 
		priority:int = 0, 
		useWeakReference:Boolean = false):void {
			dispatcher.addEventListener(type, listener, useCapture, priority);
	}
    /**
     *  @private
     */
	public function dispatchEvent(evt:Event):Boolean{
		return dispatcher.dispatchEvent(evt);
	}
    
	/**
     *  @private
     */
	public function hasEventListener(type:String):Boolean{
		return dispatcher.hasEventListener(type);
	}
    
	/**
     *  @private
     */
	public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
		dispatcher.removeEventListener(type, listener, useCapture);
	}
    
    /**
     *  @private
     */            
	public function willTrigger(type:String):Boolean {
		return dispatcher.willTrigger(type);
	}
}
}