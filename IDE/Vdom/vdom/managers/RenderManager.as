package vdom.managers {

import flash.display.Graphics;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.collections.ArrayCollection;
import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.containers.Grid;
import mx.containers.GridItem;
import mx.containers.GridRow;
import mx.core.Container;

import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.containers.IItem;
import vdom.containers.Item;
import vdom.events.RenderManagerEvent;
import vdom.managers.renderClasses.ItemDescription;
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
		_items.sort.fields = [new SortField('objectId')];
		
		_items.refresh();
		
		soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, renderWysiwygOkHandler);
	}
	
	public function init(destContainer:Container, applicationId:String = null):void {
		
		_container = destContainer;
		
		if(!applicationId)
			this.applicationId = dataManager.currentApplicationId;
			
	}
	
	private function addItem(objectId:String, parentId:String = ''):Container {
		
		var item:Item = new Item(objectId);
		
		var fullPath:String = '';
		
		if(parentId == '') {
			
			_items.removeAll();
						
			fullPath = objectId;
			
			item.visible = false;
			
			item.percentWidth = 100;
			item.percentHeight = 100;
			
		} else {
			
			_cursor.findFirst({objectId:parentId});
			fullPath = _cursor.current.fullPath + '.' + objectId;
		}
		
		item.setStyle('backgroundColor', '#ffffff');
		item.setStyle('backgroundAlpha', .0);
		
		
		var itemDescription:ItemDescription = new ItemDescription();
		
			itemDescription.objectId = objectId;
			itemDescription.parentId = parentId;
			itemDescription.fullPath = fullPath;
			itemDescription.zindex = 0;
			itemDescription.hierarchy = 0;
			itemDescription.order = 0;
			itemDescription.item = item;
		
		_items.addItem(itemDescription);
		
		return item;
	}
	
	public function createItem(objectId:String, parentId:String = ''):Container {
		
		var item:Container = addItem(objectId, parentId);
		
		if(parentId) {
			
			_cursor.findFirst({objectId:parentId});
			_cursor.current.item.addChild(item)
			
		} else {
			
			_container.removeAllChildren();
			_container.addChild(item);
		}
		
		soap.renderWysiwyg(applicationId, objectId, parentId);
		
		return item;
	}
	
	public function deleteItem(objectId:String):void {
		
		_items.filterFunction = 
			function (item:Object):Boolean {
				return (item.fullPath.indexOf(objectId) != -1);
		}
		
		_items.refresh();
		
		_cursor.findAny({objectId:objectId});
		
		var currentItem:Container = ItemDescription(_cursor.current).item;
		
		currentItem.parent.removeChild(currentItem);
		
		_items.removeAll();
		
		_items.filterFunction = null;
		_items.refresh();
	}
	
	public function updateItem(objectId:String, parentId:String):void {
		
		/* _items.filterFunction = null;
		_items.sort = new Sort();
		_items.sort.fields = [new SortField('objectId')];
		_items.refresh(); */
		
		//_cursor.findAny({objectId:objectId});
		
		//var currentItem:Item = Item(_cursor.current.item);
		//currentItem.graphics.clear();
		//currentItem.removeAllChildren();
		//currentItem.waitMode = true;
		//parentId = _cursor.current.parentId
		
		
		//_cursor.current = null;
		_cursor.findAny({objectId:objectId});
		if(_cursor.current)
			IItem(_cursor.current.item).waitMode = true;
		 
		
		var key:String = soap.renderWysiwyg(applicationId, objectId, parentId);
		//waitArray[key] = _cursor.current.item;
	}
	
	private function updateItemDescription(objectId:String, itemXMLDescription:XML):ItemDescription {
		
		_cursor.findFirst({objectId:objectId});
		
		var itemDescription:ItemDescription = ItemDescription(_cursor.current);
		
		itemDescription.zindex = uint(itemXMLDescription.@zindex);
		itemDescription.hierarchy = uint(itemXMLDescription.@hierarchy);
		itemDescription.order = uint(itemXMLDescription.@order);
		
		return itemDescription;
	}
	
	public function lockItem(objectId:String):void {
		
		
	}
	
	private function renderWysiwygOkHandler(event:SoapEvent):void {
		
		var itemXMLDescription:XML = event.result.Result.object[0];
		var key:String = event.result.Key[0];
				
		var itemId:String = itemXMLDescription.@guid;
		
		var itemDescription:ItemDescription = updateItemDescription(itemId, itemXMLDescription);
		
		if(!itemDescription) {
			
			trace('Alert Render Manager - cant find item description');
			return	
		}
		
		var item:Container = itemDescription.item;
		
		var isStatic:Boolean = false;
		
		if(itemXMLDescription.@contents == 'static')
			isStatic = true;
		
		render(item, itemXMLDescription, isStatic);
		
		var arrayOfItems:Array = sortItems(itemId);
		var count:uint = 0;
		
		for each (var collectionItem:Container in arrayOfItems) {
			
			if(collectionItem.parent) {
				
				collectionItem.parent.setChildIndex(collectionItem, count);
				count++;
			}
		}
		
		item.visible = true;
		var rme:RenderManagerEvent = new RenderManagerEvent(RenderManagerEvent.RENDER_COMPLETE);
		rme.result = item;
		
		dispatchEvent(rme);
	}
	
	private function render(item:Container, itemXMLDescription:XML, isStatic:Boolean):void {
		
		item.removeAllChildren();
		item.graphics.clear();
		
		item.x = Number(itemXMLDescription.@left);
		item.y = Number(itemXMLDescription.@top);
		
		if(itemXMLDescription.@width.length())
			item.width = itemXMLDescription.@width;
			
		if(itemXMLDescription.@height.length())
			item.height = itemXMLDescription.@height;
		
		var itemId:String = itemXMLDescription.@guid;
		
		if(itemXMLDescription.@contents == 'static')
			isStatic = true;
		
		for each(var childXMLDescription:XML in itemXMLDescription.*) {
			
			var childName:String = childXMLDescription.name().localName;
			var childId:String = childXMLDescription.@guid.toString(); 
			
			switch(childName) {
				
			case 'object':
				
				var newItem:Container = addItem(childId, itemId)
				updateItemDescription(childId, childXMLDescription);
				
				if(isStatic)
					IItem(newItem).isStatic = true;
				
				newItem.clipContent = true;
				
				render(newItem, childXMLDescription, isStatic);
			break;
			
			case 'text':
				
				var viewText:WysiwygText = new WysiwygText()
				
				viewText.x = childXMLDescription.@left;
				viewText.y = childXMLDescription.@top;
				viewText.width = childXMLDescription.@width;
				
				viewText.condenseWhite = true;	
				viewText.height = childXMLDescription.@height;
				viewText.htmlText = childXMLDescription;
				
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
						sourceName:'htmlText'}
					);
				}
				
				item.addChild(viewText);
			break;
			
			case 'graphics':
				
				renderGraphics(item.graphics, childXMLDescription);
			break
			
			case 'table':
				
				renderTable(item, childXMLDescription, isStatic);
			break;
			}
		}
		
		if(!(item is IItem))
			return
		
		var arrayOfItems:Array = sortItems(itemId);
		
		for each (var collectionItem:Container in arrayOfItems) {
			item.addChild(collectionItem);
		}
	}
	
	private function renderGraphics(graphics:Graphics, graphicsXMLDescription:XML):void {
		
		for each(var childXMLDescription:XML in graphicsXMLDescription.*) {
			
		var childName:String = childXMLDescription.name().localName;
		var childId:String = childXMLDescription.@guid.toString();
		
			switch(childName) {
			
			case 'rectangle':
				
				if(childXMLDescription.@border > 0) {
					
					var border:uint = childXMLDescription.@border;
					var color:uint = Number('0x' + childXMLDescription.@color);
					
					graphics.lineStyle(border, color);
				}
				
				var fillColor:Number = 0x000000;
				var alpha:Number = 1;
				 
				if(childXMLDescription.@fill.length())
					fillColor = Number('0x' + childXMLDescription.@fill.toString().substring(1))
					
				if(childXMLDescription.@alpha.length())
					alpha = Number(childXMLDescription.@alpha)/100
				
				graphics.beginFill(fillColor, alpha);
									
				graphics.drawRect(
					childXMLDescription.@left,
					childXMLDescription.@top,
					childXMLDescription.@width,
					childXMLDescription.@height
				);
				graphics.endFill();
				//var viewRectangle:Canvas = new Canvas()
				
				//properties
				// viewRectangle.x = itemDescription.@left;
				//viewRectangle.y = itemDescription.@top;
				//viewRectangle.width = itemDescription.@width;
				//viewRectangle.height = itemDescription.@height;
				//viewRectangle.setStyle('borderStyle', 'solid');
				//viewRectangle.setStyle('borderThickness', itemDescription.@border);
				//viewRectangle.setStyle('borderColor', itemDescription.@color);
				//viewRectangle.setStyle('backgroundColor', '#'+itemDescription.@fill);
				
				//parentContainer.addChild(viewRectangle);
				
				// if(parentContainer is Item)					
					//Item(parentContainer).addViewChild(viewRectangle);
					
				//else
					//item.rawChildren.addChild(viewRectangle);
						
				break;
				
				/* case 'image':
					
					var viewImage:Image = new WysiwygImage()
					
					viewImage.x = childXMLDescription.@left;
					viewImage.y = childXMLDescription.@top;
					
					if(childXMLDescription.@width.length())
						viewImage.width = childXMLDescription.@width;
					if(childXMLDescription.@height.length()) {
						//trace('image set height!: '+itemDescription.@height)
						viewImage.height = childXMLDescription.@height;
					}
						
					//tempArray.push(viewImage);
					viewImage.maintainAspectRatio = false;
					//trace('LoadImage: ' + objectId);
					fileManager.loadResource(parentId, objectId, viewImage, 'source', true);
					
					parentItem.addChild(viewImage);
					
				break; */
			}
		}
	}
	
	private function renderTable(item:Container, tableXMLDescription:XML, isStatic:Boolean):void {
		
		var viewGrid:Grid = new Grid()
		
		viewGrid.setStyle('horizontalGap', 0);
		viewGrid.setStyle('verticalGap', 0);
		
		viewGrid.x = tableXMLDescription.@left;
		viewGrid.y = tableXMLDescription.@top;
					
		for each(var rowXMLDescription:XML in tableXMLDescription.*) {
			
			var rowChildName:String = rowXMLDescription.name().localName;
			
			switch(rowChildName) {
				
			case 'object':
				
				var rowId:String = rowXMLDescription.@guid.toString();
				rowXMLDescription = rowXMLDescription.*[0];
			
			case 'row':
				
				var viewGridRow:GridRow = new GridRow()
			break;
			}
				
			for each(var cellXMLDescription:XML in rowXMLDescription.*) {
				
				var cellChildName:String = cellXMLDescription.name().localName;
	
				switch(cellChildName) {
				
				case 'object':
					
					var cellId:String = cellXMLDescription.@guid.toString();
					cellXMLDescription = cellXMLDescription.*[0];
									
				case 'cell':
					
					var viewGridItem:GridItem = new GridItem()
				break;
				}
				
				render(viewGridItem, cellXMLDescription, isStatic);
			}
		}
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
		_items.sort.fields = [new SortField('objectId')]
			
		_items.refresh();
		
		if(arrayOfSortedItems.length > 0)
			return arrayOfSortedItems
		else
			return null
		
	}
	
	private function getItemDescriptionById(itemId:String):ItemDescription {
		
		var findItemResult:Boolean = _cursor.findAny({objectId:itemId});
		
		if(findItemResult)
			return ItemDescription(_cursor.current);
		else 
			return null;
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