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
import vdom.controls.EditableHTML;
import vdom.events.DataManagerEvent;
import vdom.events.RenderManagerEvent;
import vdom.managers.renderClasses.ItemDescription;
import vdom.managers.renderClasses.WysiwygTableClasses.Table;
import vdom.managers.renderClasses.WysiwygTableClasses.TableCell;
import vdom.managers.renderClasses.WysiwygTableClasses.TableRow;

public class RenderManager implements IEventDispatcher {
	
	private static var instance:RenderManager;
	
	private var soap:Soap;
	private var dataManager:DataManager;
	private var dispatcher:EventDispatcher;
	private var fileManager:FileManager;
	private var cacheManager:CacheManager;
	
	private var applicationId:String;
	private var rootContainer:Container;
	private var items:ArrayCollection;
	private var cursor:IViewCursor;
	private var lockedItems:Object;
	private var lastKey:String;
	
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
		
		items = new ArrayCollection();
		dispatcher = new EventDispatcher();
		
		soap = Soap.getInstance();
		fileManager = FileManager.getInstance();
		dataManager = DataManager.getInstance();
		
		soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, renderWysiwygOkHandler);
		dataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_BEGIN, updateAttributesBeginHandler);
		
		
		cursor = items.createCursor();
		
		items.sort = new Sort();
		items.sort.fields = [new SortField('itemId')];
		items.refresh();
		
		lockedItems = {};
	}
	
	public function init(destContainer:Container, applicationId:String = null):void {
		
		rootContainer = destContainer;
		
		if(!applicationId)
			this.applicationId = dataManager.currentApplicationId;
			
	}
	
	public function createItem(itemId:String, parentId:String = ''):void {
		
		if(!parentId) {
			
			rootContainer.removeAllChildren();
			items.removeAll();
		}
		
		createItemDescription(itemId, parentId);
	
		lastKey = soap.renderWysiwyg(applicationId, itemId, parentId);
	}
	
	public function updateItem(itemId:String, parentId:String):void {
		
		lastKey = soap.renderWysiwyg(applicationId, itemId, parentId);
	}
	
	public function deleteItem(itemId:String):void {
		
		items.filterFunction = 
			function (item:Object):Boolean {
				return (item.fullPath.indexOf(itemId) != -1);
		}
		
		items.refresh();
		
		cursor.findAny({itemId:itemId});
		
		var currentItem:Container = ItemDescription(cursor.current).item as Container;
		
		currentItem.parent.removeChild(currentItem);
		
		items.removeAll();
		
		items.filterFunction = null;
		items.refresh();
	}
	
	public function lockItem(itemId:String):void {
		
		if(!itemId && lockedItems[itemId])
			return;
		
		var itemDescription:ItemDescription= getItemDescriptionById(itemId);
		IItem(itemDescription.item).waitMode = true;
		lockedItems[itemId] = '';
	}
	
	public function getItemById(itemId:String):IItem {
		
		if(itemId) {
			
			var itemDescription:ItemDescription = getItemDescriptionById(itemId);
			
			if(itemDescription)
				return 	itemDescription.item;
		}
		
		return null;
	}
	
	private function insertItem(itemName:String, itemId:String):IItem {
		
		var itemDescription:ItemDescription;
		var isStatic:Boolean = false;
		
		itemDescription = getItemDescriptionById(itemId);
		
		if(!itemDescription)
			return null
		
		if(itemDescription.item && Container(itemDescription.item).parent)
			return itemDescription.item;
		
		var container:IItem;
		
		switch (itemName) {
			
		case 'container':
		 
			container = new Item(itemId);
		break;
		
		case 'table':
		 
			container = new Table(itemId);
		break;
		
		case 'row':
		 
			container = new TableRow(itemId);
			Container(container).percentWidth = 100;
		break;
		
		case 'cell':
		 
			container = new TableCell(itemId);
		break;
		}
		
		itemDescription.item = container;
		
		return container;
	}
	
	private function deleteItemChildren(itemId:String):void {
		
		var itemDescription:ItemDescription = getItemDescriptionById(itemId);
		
		if(!itemDescription)
			return
		var result:Container = itemDescription.item as Container;
		
		if(!result)
			return
		
		items.filterFunction = 
			function (item:Object):Boolean {
				return (item.fullPath.indexOf(itemId+'.') != -1);
			}
	
		items.refresh();
	 
		result.removeAllChildren();
		items.removeAll();
		
		items.filterFunction = null;
		items.refresh();
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
		
		items.addItem(itemDescription);
		
		return itemDescription;
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
	
	private function getItemDescriptionById(itemId:String):ItemDescription {
		
		var searchObject:Object = {itemId:itemId};
		
		var isResult:Boolean = cursor.findAny(searchObject);
		var result:ItemDescription;
		
		if(isResult)
			result = ItemDescription(cursor.current);
		
		return result;
	}
	
	private function sortItems(parentId:String):Array {
		
		items.filterFunction = 
			function (item:Object):Boolean {
				return item.parentId == parentId;
		}
		
		items.sort.fields = [new SortField('zindex'), new SortField('hierarchy'), new SortField('order')];
		
		items.refresh();
		
		var arrayOfSortedItems:Array = [];
		
		for each (var collectionItem:Object in items) {
			
			arrayOfSortedItems.push(collectionItem.item);
		}
		
		items.filterFunction = null;
		items.sort.fields = [new SortField('itemId')];
			
		items.refresh();
		
		if(arrayOfSortedItems.length > 0)
			return arrayOfSortedItems
		else
			return null
		
	}
	
	private function updateAttributesBeginHandler(event:DataManagerEvent):void {
		
		if(lockedItems[event.objectId] !== null)
			lockedItems[event.objectId] = event.key;
	}
	
	private function render(itemId:String, itemXMLDescription:XML):void {
		
		var itemDescription:ItemDescription = getItemDescriptionById(itemId);
		
		var item:Container = itemDescription.item as Container;
		var itemStaticFlag:String = itemDescription.staticFlag;
		
		item.removeAllChildren();
		item.graphics.clear();
		IItem(item).editableAttributes = [];
		
		item.x = Number(itemXMLDescription.@left);
		item.y = Number(itemXMLDescription.@top);
		
		if(itemXMLDescription.@width.length())
			item.width = Number(itemXMLDescription.@width);
			
		if(itemXMLDescription.@height.length())
			item.height = Number(itemXMLDescription.@height);
		
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
			
			case 'container':
			
			case 'table':
			
			case 'row':
			
			case 'cell':
				
				var childDescription:ItemDescription = createItemDescription(childId, itemId);
				
				childId = childDescription.itemId;
				
				var childItem:Container = insertItem(childName, childId) as Container;
				
				item.addChild(childItem);
				
				updateItemDescription(childId, childXMLDescription);
				
				render(childId, childXMLDescription);
			break;
			
			// --------------------------------------
			
			case 'text':
				
				var viewText:EditableHTML = new EditableHTML();
				var isEditable:Boolean = false;
				var fontStyle:String = '12px Tahoma';
				var colorStyle:String = '#000000';
				
				viewText.paintsDefaultBackground = false;
				viewText.x = childXMLDescription.@left;
				viewText.y = childXMLDescription.@top;
				
				if(childXMLDescription.@color.length())
					colorStyle = childXMLDescription.@color;
				
				if(childXMLDescription.@font.length())
					fontStyle = childXMLDescription.@font;
				
				if(childXMLDescription.@width.length())
					viewText.width = childXMLDescription.@width;
				
				var HTMLText:String = childXMLDescription;
				
				viewText.setStyle('backgroundAlpha', .0);
				
				if(childXMLDescription.@editable.length() && IItem(item).isStatic == false) {
					
					isEditable = false;
									
					IItem(item).editableAttributes.push(
						{destName:String(childXMLDescription.@editable),
						sourceObject:viewText,
						sourceName:'editabledText'}
					);
				}
				if(HTMLText == '')
					HTMLText = '<div>simple text </div>';
				HTMLText =
						'<html><head>' + 
						'<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' +
						'</head>' +
						'<body style="margin:5px;">' +
						HTMLText +
						'</body></html>';
				
				viewText.htmlText = HTMLText;
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
		
		/* for each (var collectionItem:Container in arrayOfItems) {
			
			if(collectionItem.parent) {
				
				collectionItem.parent.setChildIndex(collectionItem, count);
				count++;
			}
		} */
	}
	
	private function renderGraphics(item:Container, graphicsXMLDescription:XML):void {
		
		var itemId:String = IItem(item).objectId;
		var graphicsLayer:Canvas = IItem(item).graphicsLayer;

		var currentSprite:Sprite = new Sprite();
		
		for each(var childXMLDescription:XML in graphicsXMLDescription.*) {
		
		var x1:Number = 0, x2:Number = 0;
		var y1:Number = 0, y2:Number = 0;
		
		var alpha:Number = 1;
		var thickness:Number = 1;
		var fillColor:Number = 0xFFFFFF;
		var lineColor:Number = 0xFFFFFF;
		var borderColor:Number = 0x000000;
		var childName:String = childXMLDescription.name().localName;
		
			switch(childName) {
			
			case 'rectangle':
				
				if(childXMLDescription.@alpha.length())
					alpha = Number(childXMLDescription.@alpha)/100
				
				if(childXMLDescription.@size.length())
					thickness = childXMLDescription.@size;
				
				if(childXMLDescription.@stroke.length()) {
					borderColor = Number('0x' + childXMLDescription.@stroke.toString().substring(1));
					currentSprite.graphics.lineStyle(thickness, borderColor, alpha);
				}
				
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
				
			case 'ellipse':
				
				if(childXMLDescription.@alpha.length())
					alpha = Number(childXMLDescription.@alpha)/100
				
				if(childXMLDescription.@size.length())
					thickness = childXMLDescription.@size;
				
				if(childXMLDescription.@stroke.length()) {
					borderColor = Number('0x' + childXMLDescription.@stroke.toString().substring(1));
					currentSprite.graphics.lineStyle(thickness, borderColor, alpha);
				}
				
				if(childXMLDescription.@color.length())
					fillColor = Number('0x' + childXMLDescription.@color.toString().substring(1))
				else
					alpha = .0;	
				
				
				currentSprite.graphics.beginFill(fillColor, alpha);
									
				currentSprite.graphics.drawEllipse(
					childXMLDescription.@left,
					childXMLDescription.@top,
					childXMLDescription.@width,
					childXMLDescription.@height
				);
				currentSprite.graphics.endFill();
				
				graphicsLayer.rawChildren.addChild(currentSprite);
				
			break
				
			case 'picture':
					
					var resourceId:String = childXMLDescription.@resource;
					var img:Image = new Image();
					
					img.x = childXMLDescription.@left;
					img.y = childXMLDescription.@top;
					 
					if(childXMLDescription.@width.length())
						img.width = childXMLDescription.@width;
						
					if(childXMLDescription.@height.length())
						img.height = childXMLDescription.@height;
					
					if(childXMLDescription.@editable.length()) {
						
						var tempObject:Object = {value:'#Res('+resourceId+')'};
						
						IItem(item).editableAttributes.push( 
							{
								destName:String(childXMLDescription.@editable),
								sourceObject:tempObject,
								sourceName:'value'
							}
						)
					}
					
					img.maintainAspectRatio = false;
					graphicsLayer.rawChildren.addChild(img);
					
					fileManager.loadResource(itemId, resourceId, img, 'source', true);
			break;
				
			case 'line':
				
				if(childXMLDescription.@alpha.length())
					alpha = Number(childXMLDescription.@alpha)/100;
				
				if(childXMLDescription.@left.length())
					x1 = x2 = Number(childXMLDescription.@left)
				
				if(childXMLDescription.@top.length())
					y1 = y2 = Number(childXMLDescription.@top);
				
				if(childXMLDescription.@width.length())
					x2 = x1 + Number(childXMLDescription.@width)
				
				if(childXMLDescription.@height.length())
					y2 = y1 + Number(childXMLDescription.@height);
				
				if(childXMLDescription.@size.length())
					thickness = Number(childXMLDescription.@size);
				
				if(childXMLDescription.@color.length())
					lineColor = Number('0x' + childXMLDescription.@color.toString().substring(1))
				else
					alpha = .0;	
				
				currentSprite.graphics.lineStyle(thickness, lineColor, alpha);;
				currentSprite.graphics.moveTo(x1, y1);
				currentSprite.graphics.lineTo(x2, y2);
				currentSprite.graphics.moveTo(0, 0);
				
				graphicsLayer.rawChildren.addChild(currentSprite);
						
			break;
			}
		}
	}
	
	private function renderWysiwygOkHandler(event:SoapEvent):void {
		
		var itemXMLDescription:XML = event.result.Result.*[0];
		
		if(itemXMLDescription.@id.length() == 0) 
			return;
		
		var key:String = event.result.Key[0];
		
		if(key != lastKey)
			return;
		
		var itemId:String = itemXMLDescription.@id;
		var itemName:String = itemXMLDescription.name().localName;
		
		if(lockedItems[itemId] && lockedItems[itemId] != key)
			return;
			
		deleteItemChildren(itemId);
		
		var item:IItem = insertItem(itemName, itemId);
		
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
		
		var itemAsContainer:Container = item as Container;
		
		if(itemDescription.parentId) {
			
			if(!itemAsContainer.parent) {
				
				var parentDescription:ItemDescription = getItemDescriptionById(itemDescription.parentId);
				Container(parentDescription.item).addChild(itemAsContainer);
			}
			
			var p_arrayOfItems:Array = sortItems(itemDescription.parentId);
			var p_count:uint = 0;
			
			for each (var p_collectionItem:Container in p_arrayOfItems) {
				
				if(p_collectionItem.parent) {
					//trace(p_collectionItem.parent.getChildIndex(p_collectionItem))
					p_collectionItem.parent.setChildIndex(p_collectionItem, p_count);
					p_count++;
				}
			}
		} else {
			
			itemAsContainer.percentWidth = 100;
			itemAsContainer.percentHeight = 100;
			
			if(!itemAsContainer.parent)
				rootContainer.addChild(itemAsContainer);
		}
		
		itemAsContainer.dispatchEvent(new Event('refreshComplete'));
		itemAsContainer.visible = true;
		
		item.waitMode = false;
		
		var rme:RenderManagerEvent = new RenderManagerEvent(RenderManagerEvent.RENDER_COMPLETE);
		rme.result = itemAsContainer;
		
		dispatchEvent(rme);
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