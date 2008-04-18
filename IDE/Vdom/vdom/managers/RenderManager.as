package vdom.managers {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.collections.ArrayCollection;
import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.containers.Canvas;
import mx.controls.Image;
import mx.core.Container;
import mx.utils.UIDUtil;

import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.containers.IItem;
import vdom.containers.Item;
import vdom.events.RenderManagerEvent;
import vdom.managers.renderClasses.ItemDescription;
import vdom.managers.renderClasses.WysiwygTableClasses.Table;
import vdom.managers.renderClasses.WysiwygTableClasses.TableCell;
import vdom.managers.renderClasses.WysiwygTableClasses.TableRow;
import vdom.managers.renderClasses.WysiwygText;

public class RenderManager implements IEventDispatcher {
	
	private static var instance:RenderManager;
	
	private var soap:Soap;
	private var dataManager:DataManager;
	private var dispatcher:EventDispatcher;
	private var fileManager:FileManager;
		
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
		fileManager = FileManager.getInstance();
		dataManager = DataManager.getInstance();
		
		//publicData = mx.core.Application.application.publicData;
		
		_items = new ArrayCollection();
		_cursor = _items.createCursor();
		
		var sort:Sort = new Sort();
		
		_items.sort = sort;
		_items.sort.fields = [new SortField('itemId')];
		
		_items.refresh();
		
		soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, renderWysiwygOkHandler);
	}
	
	public function init(destContainer:Container, applicationId:String = null):void {
		
		_container = destContainer;
		
		if(!applicationId)
			this.applicationId = dataManager.currentApplicationId;
			
	}
	
	/* private function addItem(item:Container, itemId:String, parentId:String = ''):Container {
		
		var fullPath:String = '';
		
		if(parentId == '') {
			
			_items.removeAll();
						
			fullPath = itemId;
			
			item.visible = false;
			
			item.percentWidth = 100;
			item.percentHeight = 100;
			
		} else {
			
			_cursor.findFirst({itemId:parentId});
			fullPath = _cursor.current.fullPath + '.' + itemId;
		}
		
		item.setStyle('backgroundColor', '#ffffff');
		item.setStyle('backgroundAlpha', .0);
		
		
		var itemDescription:ItemDescription = new ItemDescription();
		
			itemDescription.itemId = itemId;
			itemDescription.parentId = parentId;
			itemDescription.fullPath = fullPath;
			itemDescription.zindex = 0;
			itemDescription.hierarchy = 0;
			itemDescription.order = 0;
			itemDescription.item = item;
		
		_items.addItem(itemDescription);
		
		return item;
	} */
	
	
	
	public function createItem(itemId:String, parentId:String = ''):void {
		
		if(!parentId) {
			
			_container.removeAllChildren();
			_items.removeAll();
		}
		
		createItemDescription(itemId, parentId);
	
		soap.renderWysiwyg(applicationId, itemId, parentId);
	}
	
	public function updateItem(itemId:String, parentId:String):void {
		
		soap.renderWysiwyg(applicationId, itemId, parentId);
	}
	
	public function deleteItem(itemId:String):void {
		
		_items.filterFunction = 
			function (item:Object):Boolean {
				return (item.fullPath.indexOf(itemId) != -1);
		}
		
		_items.refresh();
		
		_cursor.findAny({itemId:itemId});
		
		var currentItem:Container = ItemDescription(_cursor.current).item;
		
		currentItem.parent.removeChild(currentItem);
		
		_items.removeAll();
		
		_items.filterFunction = null;
		_items.refresh();
	}
	
	private function renderWysiwygOkHandler(event:SoapEvent):void {
		
		var itemXMLDescription:XML = event.result.Result.*[0];
		
		if(itemXMLDescription.@id.length() == 0) 
			return;
		
		var key:String = event.result.Key[0];
		
		var itemId:String = itemXMLDescription.@id;
		var itemName:String = itemXMLDescription.name().localName;
		
		deleteItemChildren(itemId);
		
		var item:Container = insertItem(itemName, itemId);
		
		if(!item)
			return;
		
		var itemDescription:ItemDescription = updateItemDescription(itemId, itemXMLDescription);
		
		render(itemId, itemXMLDescription);
		
		var arrayOfItems:Array = sortItems(itemId);
		var count:uint = 0;
		
		for each (var collectionItem:Container in arrayOfItems) {
			
			if(collectionItem.parent) {
				
				collectionItem.parent.setChildIndex(collectionItem, count);
				count++;
			}
		}
		
		if(itemDescription.parentId) {
			
			if(itemDescription.item && !itemDescription.item.parent) {
			
				var parentDescription:ItemDescription = getItemDescriptionById(itemDescription.parentId);
				parentDescription.item.addChild(item);
			}
		} else {
			
			item.percentWidth = 100;
			item.percentHeight = 100;
			
			_container.addChild(item);
		}
			
		item.visible = true;
		var rme:RenderManagerEvent = new RenderManagerEvent(RenderManagerEvent.RENDER_COMPLETE);
		rme.result = item;
		
		dispatchEvent(rme);
	}
	
	private function render(itemId:String, itemXMLDescription:XML):void {
		
		var itemDescription:ItemDescription = getItemDescriptionById(itemId);
		
		var item:Container = itemDescription.item;
		var itemStaticFlag:String = itemDescription.staticFlag;
		
		item.removeAllChildren();
		item.graphics.clear();
		
		item.x = Number(itemXMLDescription.@left);
		item.y = Number(itemXMLDescription.@top);
		
		if(itemXMLDescription.@width.length())
			item.width =  Number(itemXMLDescription.@width);
			
		if(itemXMLDescription.@height.length())
			item.height =  Number(itemXMLDescription.@height);
		
		if(itemDescription.staticFlag =='self' || itemDescription.staticFlag =='all')
			IItem(item).isStatic = true;
		
		item.setStyle('backgroundColor', '#ffffff');
		item.setStyle('backgroundAlpha', .0);
		
		for each(var childXMLDescription:XML in itemXMLDescription.*) {
			
			var childName:String = childXMLDescription.name().localName;
			var childId:String = '';
			
			if(childXMLDescription.@id.length != 0 && itemStaticFlag != 'children' && itemStaticFlag != 'all')
				childId = childXMLDescription.@id; 
			
			switch(childName) {
				
			// Containers --------------------------------------
			
			case 'container':
			
			case 'table':
			
			case 'row':
			
			case 'cell':
				
				var childDescription:ItemDescription = createItemDescription(childId, itemId);
				
				childId = childDescription.itemId;
				
				var childItem:Container = insertItem(childName, childId);
				item.addChild(childItem);
				
				updateItemDescription(childId, childXMLDescription);
				
				render(childId, childXMLDescription);
			break;
			
			// --------------------------------------
			
			case 'text':
				
				var viewText:WysiwygText = new WysiwygText()
				
				viewText.x = childXMLDescription.@left;
				viewText.y = childXMLDescription.@top;
				viewText.width = childXMLDescription.@width;
				
				viewText.condenseWhite = true;
				viewText.height = childXMLDescription.@height;
				viewText.text = childXMLDescription;
				
				viewText.selectable = false;
				
				viewText.setStyle('fontStyle', childXMLDescription.@font);
				viewText.setStyle('color', childXMLDescription.@color);
				
				viewText.setStyle('borderStyle', 'solid');
				viewText.setStyle('borderColor', '#cccccc');
				viewText.setStyle('borderAlpha', .3);
				viewText.setStyle('backgroundAlpha', 0);
				
				if(childXMLDescription.@editable.length() && IItem(item).isStatic == false) {
					
					viewText.selectable = true;
					viewText.editable = true;
									
					IItem(item).editableAttributes.push(
						{destName:String(childXMLDescription.@editable),
						sourceObject:viewText,
						sourceName:'text'}
					);
				}
				
				item.addChild(viewText);
			break;
			
			case 'graphics':
				
				renderGraphics(item, childXMLDescription);
			break
			}
		}
		
		if(!(item is IItem))
			return
		
		var arrayOfItems:Array = sortItems(itemId);
		var count:uint = 0;
		
		for each (var collectionItem:Container in arrayOfItems) {
			
			if(collectionItem.parent) {
				
				collectionItem.parent.setChildIndex(collectionItem, count);
				count++;
			}
		}
	}
	
	private function renderGraphics(item:Container, graphicsXMLDescription:XML):void {
		
		var itemId:String = IItem(item).objectId;
		var graphicsLayer:Canvas = IItem(item).graphicsLayer;
		
		var currentSprite:Sprite = new Sprite();
		
		for each(var childXMLDescription:XML in graphicsXMLDescription.*) {
		
		var childName:String = childXMLDescription.name().localName;
		
			switch(childName) {
			
			case 'rectangle':
				
				var alpha:Number = 1;
				
				if(childXMLDescription.@alpha.length())
					alpha = Number(childXMLDescription.@alpha)/100
				
				if(childXMLDescription.@size > 0) {
					
					var borderThickness:uint = childXMLDescription.@size;
					var borderColor:uint = Number('0x' + childXMLDescription.@stroke);
					
					currentSprite.graphics.lineStyle(borderThickness, borderColor, alpha);
				}
				
				var fillColor:Number = 0xFFFFFF;
				
				if(childXMLDescription.@color.length())
					fillColor = Number('0x' + childXMLDescription.@color.toString().substring(1))
				else
					alpha = .0;	
				
				
				currentSprite.graphics.beginFill(fillColor, alpha);
									
				currentSprite.graphics.drawRect(
					childXMLDescription.@left,
					childXMLDescription.@top,
					childXMLDescription.@width,
					childXMLDescription.@height
				);
				currentSprite.graphics.endFill();
				
				graphicsLayer.rawChildren.addChild(currentSprite);
						
				break;
				
				case 'picture':
					
					var resourceId:String = childXMLDescription.@resource;
					var img:Image = new Image();
					
					img.x = childXMLDescription.@left;
					img.y = childXMLDescription.@top;
					 
					if(childXMLDescription.@width.length())
						img.width = childXMLDescription.@width;
						
					if(childXMLDescription.@height.length())
						img.height = childXMLDescription.@height;
					
					img.maintainAspectRatio = false;
					graphicsLayer.rawChildren.addChild(img);
					
					fileManager.loadResource(itemId, resourceId, img, 'source', true);
				break;
			}
		}
	}
	
	private function createItemDescription(itemId:String = '', parentId:String = ''):ItemDescription {
		
		var fullPath:String = '';
		var staticFlag:String = 'none';
		
		if(itemId == '') {
			itemId = UIDUtil.createUID();
			staticFlag = 'self';
		}
		
		if(parentId == '') {
			
			fullPath = itemId;
		} else {
			
			fullPath = getItemDescriptionById(parentId).fullPath;
			fullPath = fullPath + '.' + itemId;
		}
		
		var itemDescription:ItemDescription = new ItemDescription();
		
			itemDescription.itemId = itemId;
			itemDescription.staticFlag = staticFlag;
			itemDescription.parentId = parentId;
			itemDescription.fullPath = fullPath;
			itemDescription.zindex = 0;
			itemDescription.hierarchy = 0;
			itemDescription.order = 0;
			itemDescription.item = null;
		
		_items.addItem(itemDescription);
		
		return itemDescription;
	}
	
	private function insertItem(itemName:String, itemId:String):Container {
		
		var itemDescription:ItemDescription;
		var isStatic:Boolean = false;
		
		itemDescription = getItemDescriptionById(itemId);
		
		if(!itemDescription)
			return null
		
		if(itemDescription.item && itemDescription.item.parent)
			return itemDescription.item;
		
		var container:Container;
		
		switch (itemName) {
			
		case 'container':
		 
			container = new Item(itemId);
		break;
		
		case 'table':
		 
			container = new Table(itemId);
		break;
		
		case 'row':
		 
			container = new TableRow(itemId);
		break;
		
		case 'cell':
		 
			container = new TableCell(itemId);
		break;
		
		default:
			var kosyak:* = '';
		break
		}
		
		itemDescription.item = container;
		
		return container;
	}
	
	private function deleteItemChildren(itemId:String):void {
		
		var result:Container = getItemDescriptionById(itemId).item;
		
		if(!result)
			return
		
		_items.filterFunction = 
			function (item:Object):Boolean {
				return (item.fullPath.indexOf(itemId+'.') != -1);
		}
	
		_items.refresh();
	 
		result.removeAllChildren();
		_items.removeAll();
		
		_items.filterFunction = null;
		_items.refresh();
	}
	
	private function updateItemDescription(itemId:String, itemXMLDescription:XML):ItemDescription {
		
		var itemDescription:ItemDescription = getItemDescriptionById(itemId);
		var parentDescription:ItemDescription;
		var newStaticFlag:String = itemDescription.staticFlag;
		
		if(itemDescription.parentId) {
			
			parentDescription = getItemDescriptionById(itemDescription.parentId);
		
		
			if(parentDescription.staticFlag == 'children' || parentDescription.staticFlag == 'all')
				newStaticFlag = 'all';
				
			else if(itemXMLDescription.@contents == 'static')
				newStaticFlag = 'children';
			
		} else 
			if(itemXMLDescription.@contents == 'static')
				newStaticFlag = 'children';
		
		itemDescription.zindex = uint(itemXMLDescription.@zindex);
		itemDescription.hierarchy = uint(itemXMLDescription.@hierarchy);
		itemDescription.order = uint(itemXMLDescription.@order);
		itemDescription.staticFlag = newStaticFlag; 
		
		return itemDescription;
	}
	
	private function sortItems(parentId:String):Array {
		
		_items.filterFunction = 
			function (item:Object):Boolean {
				return item.parentId == parentId;
		}
		
		_items.sort.fields = [new SortField('zindex'), new SortField('hierarchy'), new SortField('order')];
		
		_items.refresh();
		
		var arrayOfSortedItems:Array = [];
		
		for each (var collectionItem:Object in _items) {
			
			arrayOfSortedItems.push(collectionItem.item);
		}
		
		_items.filterFunction = null;
		_items.sort.fields = [new SortField('itemId')];
			
		_items.refresh();
		
		if(arrayOfSortedItems.length > 0)
			return arrayOfSortedItems
		else
			return null
		
	}
	
	private function getItemDescriptionById(itemId:String):ItemDescription {
		
	
		var searchObject:Object = {itemId:itemId};
		
		var isResult:Boolean = _cursor.findAny(searchObject);
		var result:ItemDescription;
		
		if(isResult)
			result = ItemDescription(_cursor.current);
		
		return result;
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