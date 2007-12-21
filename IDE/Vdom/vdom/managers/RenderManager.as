package vdom.managers {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;

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
import vdom.components.editor.managers.ResizeManager;
import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.events.RenderManagerEvent;
import mx.collections.XMLListCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.collections.ArrayCollection;
import mx.collections.IViewCursor;
import vdom.components.editor.containers.workAreaClasses.WysiwygText;
import vdom.components.editor.containers.workAreaClasses.WysiwygTextInput;

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
		publicData = mx.core.Application.application.publicData;
		resourceManager = ResourceManager.getInstance();
		
		_items = new ArrayCollection();
		_cursor = _items.createCursor();
		var sort:Sort = new Sort();
		_items.sort = sort;
		
		soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, renderWysiwygOkHandler);
	}
	
	/* public function renderWYSIWYG(applicationId:String, objectId:String, parentId:String):void {
		
		var dyn:String = '1';
		
		soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, renderWysiwygOkHandler);
		soap.renderWysiwyg(applicationId, objectId, parentId, dyn);
	} */
	
	public function removeItem(id:String):void {
		
		
	}
	
	public function refreshItem(objectId:String, parentId:String):void {
		
		
	}
	
	public function init(destContainer:Container, applicationId:String = null):void {
		
		_container = destContainer;
		
		if(!applicationId)
			this.applicationId = publicData['applicationId'];
			
	}
	
	public function addItem(objectID:String, parentID:String):void {
		
		var item:Item = new Item(objectID);
		
		_items.filterFunction = null;
		_items.sort = new Sort();
		_items.sort.fields = [new SortField('objectID')];
		_items.refresh();
		
		_cursor.findFirst({objectID:parentID});
		
		_items.addItem({
			objectID:objectID, 
			parentID:parentID,
			fullPath:_cursor.current.fullPath + '.' + objectID,
			zindex:0, 
			hierarchy:0,
			order:0,
			item:item, 
			properties:{}
		});
		
		var parentObject:Item = Item(_cursor.current.item);
		parentObject.addChild(item);
		
		//item.visible = false;
		
		item.setStyle('backgroundColor', '#ffffff');
		item.setStyle('backgroundAlpha', '0');
		
		soap.renderWysiwyg(publicData['applicationId'], objectID, parentID);
	}
	
	public function deleteItem(objectID:String):void {
		
		_items.filterFunction = null;
		_items.sort = new Sort();
		_items.sort.fields = [new SortField('objectID')];
		_items.refresh();
		
		_cursor.findAny({objectID:objectID});
		
		var currentItem:Item = _cursor.current.item;
		
		_cursor.findAny({objectID:_cursor.current.parentID});
		
		Item(_cursor.current.item).removeChild(currentItem);
		
		_items.filterFunction = 
			function (item:Object):Boolean {
				return (item.fullPath.indexOf(objectID) != -1);
		}
		
		_items.sort = new Sort();
		_items.sort.fields = [new SortField('objectID')];
		_items.refresh();
		
		_items.removeAll();
		_items.filterFunction = null;
		_items.refresh();
	}
	
	private function reorderItems():void {
		
		
	}
	
	public function updateItem(objectID:String, parentID:String):void {
		
		if(parentID == '') {
			
			_container.removeAllChildren();
			
			
			_items.filterFunction = null;
			_items.sort = new Sort();
			_items.refresh();
			_items.removeAll();
			var item:Item = new Item(objectID);
		
			_items.addItem({
				objectID:objectID, 
				parentID:parentID,
				fullPath:objectID,
				zindex:0, 
				hierarchy:0,
				order:0,
				item:item, 
				properties:{}
			});
			//_items.sort = new Sort();
			
			//var res:Boolean = _cursor.findFirst({objectID:parentID});
			
			//var parentObject:Item = Item(_cursor.current.item);
			_container.addChild(item);
			
			item.setStyle('backgroundColor', '#ffffff');
			item.setStyle('backgroundAlpha', '0');
			item.visible = false;
			//_items[objectId] = mainItem;
			
		} else {
			_items.filterFunction = null;
			_items.sort = new Sort();
			_items.sort.fields = [new SortField('objectID')];
			_items.refresh();
			
			_cursor.findAny({objectID:objectID});
			
			var currentItem:Item = Item(_cursor.current.item);
			currentItem.removeAllChildren();
			parentID = _cursor.current.parentID
		}
			
		soap.renderWysiwyg(applicationId, objectID, parentID);
			
	}
	
	private function renderWysiwygOkHandler(event:SoapEvent):void {
		
		var result:XML = _source = event.result;
		
		/* if(_source == null)
			_source = result; */
			
		
		
		var objectID:String = result.object.@guid;
		
		_items.filterFunction = null
		_items.sort = new Sort();
		_items.sort.fields = [new SortField('objectID')];
		_items.refresh();
		
		var res:Boolean = _cursor.findAny({objectID:objectID});
		
		var parentID:String = _cursor.current.parentID;
		var fullPath:String = _cursor.current.fullPath;
		
		_cursor.current.zindex = String(event.result.object.@zindex);
		_cursor.current.hierarchy = String(event.result.object.@hierarchy);
		
		var container:Item = Item(_cursor.current.item);
		
		var res1:Boolean = _cursor.findAny({objectID:parentID});
		var parentContainer:Item = Item(_cursor.current.item);
		
		container.x = result.object.@left;
		container.y = result.object.@top;
			
		if(result.object.@width.length())
			container.width = result.object.@width;
			
		if(result.object.@height.length())
			container.height = result.object.@height;
		
		var staticContainer:Boolean = false;
		//trace(_source);
		if(result.object.@contents == 'static')
			staticContainer = true
			
		container.removeAllChildren();
		container.removeViewChildren();
		
		if(parentID) {
			
			_items.filterFunction = 
				function (item:Object):Boolean {
					return (item.fullPath.indexOf(objectID+'.') != -1);
			}
			var sort1:Sort = new Sort();
			sort1.fields = [new SortField('zindex'), new SortField('hierarchy'), new SortField('order')];
			_items.sort = sort1;
			
			_items.refresh();
			
			_items.removeAll();
			
			_items.refresh();
		}
		
		render(container, result.object[0], fullPath, staticContainer);
		//-->z-index refresh;
		_items.filterFunction = null;
		_items.sort = null;
		_items.refresh();
		
		if(parentID) {
			
			_items.filterFunction = 
				function (item:Object):Boolean {
					return item.parentID == parentID;
			}
			var sort:Sort = new Sort();
			sort.fields = [new SortField('zindex'), new SortField('hierarchy'), new SortField('order')];
			_items.sort = sort;
			
			_items.refresh();
			
			var count:uint = 0;
			
			for each (var collectionItem:Object in _items) {
				
				parentContainer.setChildIndex(collectionItem.item, count);
				count++;
				//this.render(viewObject, collectionItem, staticContainer);
			}
		}
		
		container.visible = true;
		//var rme:RenderManagerEvent = new RenderManagerEvent(RenderManagerEvent.RENDER_COMPLETE);
		//rme.result = container;
		//dispatchEvent(rme);
	}
	
	private function render(
		parentContainer:Container, 
		source:XML, 
		fullPath:String, 
		staticContainer:Boolean):void {
		
		//var itemList:XMLListCollection = new XMLListCollection();
		//var count:int = 0;
		var parentID:String = source.@guid;
		
		for each(var itemDescription:XML in source.*) {
			
			var objectName:String = itemDescription.name().localName;
			var objectID:String = itemDescription.@guid.toString(); 
			
			switch(objectName) {
				
				case 'object':
					
					var viewObject:Container;
			
					if(!staticContainer)
						viewObject = new Item(objectID);
						
					else
						viewObject = new Canvas();
						
					viewObject.setStyle('backgroundColor', '#cccccc');
					viewObject.setStyle('backgroundAlpha', '.2');
					
					viewObject.clipContent = true;
					
					viewObject.x = itemDescription.@left;
					viewObject.y = itemDescription.@top;
					
					var zzz:* = itemDescription.@width;
					
					if(itemDescription.@width.length())
						viewObject.width = itemDescription.@width;
					
					if(itemDescription.@height.length())
								viewObject.height = itemDescription.@height;
					
					/* if(parentID && viewObject is Item)	
						Item(viewObject).parentID = parentID; */
					
					//parentContainer.addChild(viewObject);
					
					if(staticContainer || itemDescription.@contents == 'static')
						staticContainer = true;
					
					var newPath:String = fullPath + '.' + objectID
					
					_items.addItem({
						objectID:objectID, 
						parentID:parentID,
						fullPath:newPath ,
						zindex:String(itemDescription.@zindex), 
						hierarchy:String(itemDescription.@hierarchy), 
						order:String(itemDescription.@order),
						item:viewObject, 
						properties:{}
					});
					
					//count++;
					
					this.render(viewObject, itemDescription, newPath, staticContainer);
					
				break;
				
				case 'rectangle':
				
					var viewRectangle:Canvas = new Canvas()
					
					//properties
					viewRectangle.x = itemDescription.@left;
					viewRectangle.y = itemDescription.@top;
					viewRectangle.width = itemDescription.@width;
					viewRectangle.height = itemDescription.@height;
					viewRectangle.setStyle('borderStyle', 'solid');
					viewRectangle.setStyle('borderThickness', itemDescription.@border);
					viewRectangle.setStyle('borderColor', itemDescription.@color);
					viewRectangle.setStyle('backgroundColor', '#'+itemDescription.@fill);
					
					if(parentContainer is Item)					
						Item(parentContainer).addViewChild(viewRectangle);
						
					else
						parentContainer.rawChildren.addChild(viewRectangle);
					
				break;
				
				case 'radiobutton':
					
					var viewRadiobutton:WysiwygRadioButton = new WysiwygRadioButton()
					
					viewRadiobutton.x = itemDescription.@left;
					viewRadiobutton.y = itemDescription.@top;
					viewRadiobutton.width = itemDescription.@width;
					viewRadiobutton.height = itemDescription.@height;
					viewRadiobutton.value = itemDescription.@value;
					viewRadiobutton.label = itemDescription.@label;
					
					if(itemDescription.@state == 'checked')
						viewRadiobutton.selected = true;
					
					
					viewRadiobutton.setStyle('fontStyle ', itemDescription.@font);
					viewRadiobutton.setStyle('color ', itemDescription.@color);
					
					parentContainer.addChild(viewRadiobutton);
					
				break;
				
				case 'checkbox':
				
					var viewCheckbox:WysiwygCheckBox = new WysiwygCheckBox()
					
					viewCheckbox.x = itemDescription.@left;
					viewCheckbox.y = itemDescription.@top;
					viewCheckbox.width = itemDescription.@width;
					viewCheckbox.height = itemDescription.@height;
					viewCheckbox.label = itemDescription.@label;
					if(itemDescription.@state == 'checked')
						viewCheckbox.selected = true; 
						
					viewCheckbox.setStyle('fontStyle ', itemDescription.@font);
					viewCheckbox.setStyle('color ', itemDescription.@color);
					parentContainer.removeAllChildren();
					parentContainer.addChild(viewCheckbox);
					
				break;
				
				case 'input':
				
					var viewInput:WysiwygTextInput = new WysiwygTextInput()
					
					viewInput.x = itemDescription.@left;
					viewInput.y = itemDescription.@top;
					viewInput.width = itemDescription.@width;
					if(itemDescription.@height.length())
						viewInput.height = itemDescription.@height;
					viewInput.htmlText = itemDescription;
					viewInput.editable = false;
					viewInput.enabled = false;
					//viewInput.selectable = false;
					viewInput.setStyle('disabledColor', '#000000');
					viewInput.setStyle('fontStyle', itemDescription.@font);
					viewInput.setStyle('color', itemDescription.@color);
					
					//viewInput.setStyle('borderStyle', 'solid');
					//viewInput.setStyle('borderColor', '#cccccc');
					//viewInput.setStyle('borderAlpha', .3);
					//viewInput.setStyle('backgroundAlpha', 0);
					viewInput.focusEnabled = false;
					
					parentContainer.addChild(viewInput);
					
				break;
				
				case 'password':
				
					var viewPassword:WysiwygTextInput = new WysiwygTextInput()
					
					viewPassword.x = itemDescription.@left;
					viewPassword.y = itemDescription.@top;
					viewPassword.width = itemDescription.@width;
					if(itemDescription.@height.length())
						viewPassword.height = itemDescription.@height;
					viewPassword.htmlText = itemDescription;
					viewPassword.editable = false;
					viewPassword.enabled = false;
					viewPassword.displayAsPassword = true;
					//viewInput.selectable = false;
					viewPassword.setStyle('disabledColor', '#000000');
					viewPassword.setStyle('fontStyle', itemDescription.@font);
					viewPassword.setStyle('color', itemDescription.@color);
					
					//viewInput.setStyle('borderStyle', 'solid');
					//viewInput.setStyle('borderColor', '#cccccc');
					//viewInput.setStyle('borderAlpha', .3);
					//viewInput.setStyle('backgroundAlpha', 0);
					viewPassword.focusEnabled = false;
					
					parentContainer.addChild(viewPassword);
					
				break;
				
				case 'button':
				
					var viewButton:Button = new Button()
							
					viewButton.x = itemDescription.@left;
					viewButton.y = itemDescription.@top;
					viewButton.width = itemDescription.@width;
					viewButton.height = itemDescription.@height;
					viewButton.label = itemDescription.@label;
					
					//viewButton.setStyle('fontStyle ', itemDescription.@font);
					//viewButton.setStyle('color ', itemDescription.@color);
					
					parentContainer.addChild(viewButton);
					
				break;
				
				case 'text':
					
					var viewText:WysiwygText = new WysiwygText()
					
					viewText.x = itemDescription.@left;
					viewText.y = itemDescription.@top;
					viewText.width = itemDescription.@width;
					if(itemDescription.@height.length())
						viewText.height = itemDescription.@height;
					viewText.htmlText = itemDescription;
					viewText.selectable = false;
					viewText.setStyle('fontStyle', itemDescription.@font);
					viewText.setStyle('color', itemDescription.@color);
					
					viewText.setStyle('borderStyle', 'solid');
					viewText.setStyle('borderColor', '#cccccc');
					viewText.setStyle('borderAlpha', .3);
					viewText.setStyle('backgroundAlpha', 0);
					viewText.focusEnabled = false;
					
					parentContainer.addChild(viewText);
					
				break;
				
				case 'image':
					
					var viewImage:Image = new WysiwygImage()
					
					viewImage.x = itemDescription.@left;
					viewImage.y = itemDescription.@top;
					viewImage.width = itemDescription.@width;
					viewImage.height = itemDescription.@height;
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
		
		var sort:Sort = new Sort();
		sort.fields = [new SortField('zindex'), new SortField('hierarchy'), new SortField('order')];
		_items.sort = sort;
		
		_items.refresh();
		
		for each (var collectionItem:Object in _items) {
			
			parentContainer.addChild(collectionItem.item);
			//this.render(viewObject, collectionItem, staticContainer);
		}
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