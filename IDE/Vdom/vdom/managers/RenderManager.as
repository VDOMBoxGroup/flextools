package vdom.managers {

import com.zavoo.svg.SVGViewer;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.collections.ArrayCollection;
import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.core.Container;
import mx.core.UIComponent;
import mx.utils.StringUtil;
import mx.utils.UIDUtil;

import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.containers.IItem;
import vdom.containers.Item;
import vdom.controls.wysiwyg.EditableHTML;
import vdom.controls.wysiwyg.EditableText;
import vdom.controls.wysiwyg.SimpleText;
import vdom.controls.wysiwyg.table.Table;
import vdom.controls.wysiwyg.table.TableCell;
import vdom.controls.wysiwyg.table.TableRow;
import vdom.events.DataManagerEvent;
import vdom.events.RenderManagerEvent;
import vdom.managers.renderClasses.ItemDescription;

public class RenderManager implements IEventDispatcher {
	
	private static var instance:RenderManager;
	
	public static const styleList:Array = 
	[
		["opacity", "backgroundAlpha"], 
		["backgroundcolor", "backgroundColor"], 
		["borderwidth", "borderThickness"], 
		["bordercolor", "borderColor"],
		["color", "color"],
		["fontfamily", "fontFamily"],
		["fontsize", "fontSize"],
		["fontweight", "fontWeight"],
		["fontstyle", "fontStyle"],
		["textdecoration", "textDecoration"],
		["textalign", "textAlign"]
	];
	
	public static const propertyList:Array = 
	[
		["left", "x"], 
		["top", "y"], 
		["width", "width"], 
		["height", "height"]
	];
	
	private var soap:Soap = Soap.getInstance();
	private var dataManager:DataManager = DataManager.getInstance();
	private var dispatcher:EventDispatcher = new EventDispatcher();
	private var fileManager:FileManager = FileManager.getInstance();
	private var cacheManager:CacheManager = CacheManager.getInstance();
	
	private var applicationId:String;
	private var rootContainer:Container;
	private var items:ArrayCollection = new ArrayCollection();;
	private var cursor:IViewCursor;
	private var lockedItems:Object = {};
	private var lastKey:String;
	
	/**
	 * 
	 * @return instance of RenderManager class (Singleton)
	 * 
	 */
	public static function getInstance():RenderManager
	{
		if (!instance)
			instance = new RenderManager();
		
		return instance;
	}
	
	public function RenderManager()
	{
		if (instance)
			throw new Error("Instance already exists.");
		
		soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, renderWysiwygOkHandler);
		dataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_BEGIN, updateAttributesBeginHandler);
		
		cursor = items.createCursor();
		
		items.sort = new Sort();
		items.sort.fields = [new SortField("itemId")];
		items.refresh();
	}
	
	public function init(destContainer:Container, applicationId:String = null):void
	{
		rootContainer = destContainer;
		
		if(!applicationId)
			this.applicationId = dataManager.currentApplicationId;
			
	}
	
	public function createItem(itemId:String, parentId:String = ""):void
	{
		if(!parentId) {
			
			rootContainer.removeAllChildren();
			items.removeAll();
		}
		
//		createItemDescription(itemId, parentId);
	
		lastKey = soap.renderWysiwyg(applicationId, itemId, parentId);
	}
	
	public function updateItem(itemId:String, parentId:String):void
	{
		lastKey = soap.renderWysiwyg(applicationId, itemId, parentId);
	}
	
	public function deleteItem(itemId:String):void
	{
		items.filterFunction = 
			function (item:Object):Boolean {
				return (item.fullPath.indexOf(itemId) != -1);
		}
		
		items.refresh();
		
		cursor.findAny({itemId:itemId});
		
		var currentItem:Container = ItemDescription(cursor.current).item as Container;
		
		if(currentItem && currentItem.parent)
			currentItem.parent.removeChild(currentItem);
		
		items.removeAll();
		
		items.filterFunction = null;
		items.refresh();
	}
	
	public function lockItem(itemId:String):void
	{
		if(!itemId && lockedItems[itemId])
			return;
		
		var itemDescription:ItemDescription= getItemDescriptionById(itemId);
		if(itemDescription && itemDescription.item)
		{
			IItem(itemDescription.item).waitMode = true;
			lockedItems[itemId] = "";
		}
	}
	
	public function getItemById(itemId:String):IItem
	{	
		if(itemId) {
			
			var itemDescription:ItemDescription = getItemDescriptionById(itemId);
			
			if(itemDescription)
				return 	itemDescription.item;
		}
		
		return null;
	}
	
	private function insertItem(itemName:String, itemId:String):IItem
	{	
		var itemDescription:ItemDescription;
		var isStatic:Boolean = false;
		
		itemDescription = getItemDescriptionById(itemId);
		
//		if(!itemDescription)
//			return null
		
		if(itemDescription && itemDescription.item && Container(itemDescription.item).parent)
			return itemDescription.item;
		
		var container:IItem;
		
		switch (itemName) {
			
		case "container":
		 
			container = new Item(itemId);
		break;
		
		case "table":
		 
			container = new Table(itemId);
			Table(container).setStyle("horizontalGap", 0);
			Table(container).setStyle("verticalGap", 0);
		break;
		
		case "row":
		 
			container = new TableRow(itemId);
			TableRow(container).percentWidth = 100;
			TableRow(container).minHeight = 10;
		break;
		
		case "cell":
		 
			container = new TableCell(itemId);
			TableCell(container).minWidth = 10;
			TableCell(container).minHeight = 10;
		break;
		}
		container.editableAttributes = [];
		
		if(itemDescription)
			itemDescription.item = container;
		
		return container;
	}
	
	private function deleteItemChildren(itemId:String):void
	{
		var itemDescription:ItemDescription = getItemDescriptionById(itemId);
		
		if(!itemDescription)
			return
		var result:Container = itemDescription.item as Container;
		
		if(!result)
			return
		
		items.filterFunction = 
			function (item:Object):Boolean {
				return (item.fullPath.indexOf(itemId+".") != -1);
			}
	
		items.refresh();
	 
		result.removeAllChildren();
		items.removeAll();
		
		items.filterFunction = null;
		items.refresh();
	}
	
	private function createItemDescription(itemId:String = "", parentId:String = ""):ItemDescription
	{
		var fullPath:String = "";
		var staticFlag:String = "none";
		
		if(!itemId || itemId == "") {
			itemId = UIDUtil.createUID();
			staticFlag = "self";
		}
		
		if(!parentId || parentId == "") {
			
			fullPath = itemId;
		} else {
			
			fullPath = getItemDescriptionById(parentId).fullPath;
			fullPath = fullPath + "." + itemId;
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
	
	private function updateItemDescription(itemId:String, itemXMLDescription:XML):ItemDescription
	{
		if(!itemId)
			return null;
		
		var itemDescription:ItemDescription = getItemDescriptionById(itemId);
		var parentDescription:ItemDescription;
		var newStaticFlag:String = itemDescription.staticFlag;
		
		if(itemDescription.parentId) {
			
			parentDescription = getItemDescriptionById(itemDescription.parentId);
		
		
			if(parentDescription.staticFlag == "children" || parentDescription.staticFlag == "all")
				newStaticFlag = "all";
				
			else if(itemXMLDescription.@contents == "static")
				newStaticFlag = "children";
			
		} else 
			if(itemXMLDescription.@contents == "static")
				newStaticFlag = "children";
		
		itemDescription.zindex = uint(itemXMLDescription.@zindex);
		itemDescription.hierarchy = uint(itemXMLDescription.@hierarchy);
		itemDescription.order = uint(itemXMLDescription.@order);
		itemDescription.staticFlag = newStaticFlag; 
		
		return itemDescription;
	}
	
	private function getItemDescriptionById(itemId:String):ItemDescription
	{
		if(!itemId)
			return null;
		
		var searchObject:Object = {itemId:itemId};
		
		var isResult:Boolean = cursor.findAny(searchObject);
		var result:ItemDescription;
		
		if(isResult)
			result = ItemDescription(cursor.current);
		
		return result;
	}
	
	private function sortItems(parentId:String):Array
	{
		items.filterFunction = 
			function (item:Object):Boolean {
				return item.parentId == parentId;
		}
		
		items.sort.fields = [new SortField("zindex"), new SortField("hierarchy"), new SortField("order")];
		
		items.refresh();
		
		var arrayOfSortedItems:Array = [];
		
		for each (var collectionItem:Object in items) {
			
			arrayOfSortedItems.push(collectionItem.item);
		}
		
		items.filterFunction = null;
		items.sort.fields = [new SortField("itemId")];
			
		items.refresh();
		
		if(arrayOfSortedItems.length > 0)
			return arrayOfSortedItems
		else
			return []
		
	}
	
	private function updateAttributesBeginHandler(event:DataManagerEvent):void
	{
		if(lockedItems[event.objectId] !== null)
			lockedItems[event.objectId] = event.key;
	}
	
	private function arrangeItem(itemId:String):void
	{
		var arrayOfItems:Array = sortItems(itemId);
		
		if(!arrayOfItems)
			return;
		
		var collectionItem:UIComponent;
		var indexArray:Array = [];
		
		for each(collectionItem in arrayOfItems)
		{
			if(collectionItem.parent)
			{
				indexArray.push(collectionItem.parent.getChildIndex(collectionItem));
			}
		}
		
		indexArray.sort(Array.NUMERIC);
		
		var count:uint = 0;
		for each(collectionItem in arrayOfItems)
		{
			if(collectionItem.parent)
			{
				collectionItem.parent.setChildIndex(collectionItem, indexArray[count]);
				count++;
			}
		}
	}
	
	private function newRender(parentId:String, itemXMLDescription:XML):UIComponent
	{
		var itemName:String = itemXMLDescription.name().localName;
		var item:UIComponent;
		var itemId:String;
		
		var parentItemDescription:ItemDescription;
		var parentItem:IItem;
		
		var isStatic:Boolean = false;
		
		if(parentId == "static")
		{
			isStatic = true;
		}
		else if(parentId)
		{
			parentItemDescription = getItemDescriptionById(parentId);
			parentItem = parentItemDescription.item;
		}
		
		var hasChildren:Boolean = false;
		
		switch(itemName)
			{
				case "container":
				{
					
				}
				
				case "table":
				{
					
				}
				
				case "row":
				{
					
				}
				
				case "cell":
				{
					itemId = isStatic ? null : itemXMLDescription.@id[0];
					
					var itemDescription:ItemDescription = getItemDescriptionById(itemId);
					
					if(itemDescription && itemDescription.item)
					{
						item = Container(itemDescription.item);
						Container(item).removeAllChildren();
						item.graphics.clear();
						itemDescription.item.editableAttributes = [];
					}
					else
					{
						if(itemId)
						{
							itemDescription = createItemDescription(itemId, parentId);
							itemId = itemDescription.itemId;
						}
						
						item = insertItem(itemName, itemId) as UIComponent;
					}
					
					itemDescription = updateItemDescription(itemId, itemXMLDescription);
					
					if(!itemDescription || itemDescription.staticFlag =="self" || itemDescription.staticFlag =="all")
						IItem(item).isStatic = true;
					
					hasChildren = true;
					break;
				}
			
				case "text":
				{
					if(itemXMLDescription.@editable[0] && parentItem && !parentItem.isStatic)
					{
						item = new EditableText();
						insertEditableAttributes(parentItem, item, itemXMLDescription);
					}
					else
					{
						item = new SimpleText();
					}
					
					var text:String = itemXMLDescription.text().toString();
					
					item["text"] = text;
					item["selectable"] = false;
					
					break;
				}
			
				case "htmltext":
				{
					item = new EditableHTML();
					
					if(itemXMLDescription.@editable[0] && !parentItem.isStatic)
					{
						insertEditableAttributes(parentItem, item, itemXMLDescription);
					}
							
					item["paintsDefaultBackground"] = false;
					
					var HTMLText:String =itemXMLDescription.text().toString();
					
					item.setStyle("backgroundAlpha", .0);
					
					if(HTMLText == "")
						HTMLText = "<div>simple text</div>";
					
					HTMLText =
							"<html>" + 
								"<head>" + 
									"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />" +
								"</head>" +
								"<body style=\"margin:0px;\" >" +
									HTMLText +
								"</body>" + 
							"</html>";
							
					item["htmlText"] = HTMLText;
					
					break;
				}
				
				case "svg":
				{
					item = new SVGViewer();
					var d:Array = SVGViewer(item).setXML(itemXMLDescription);
					if(parentItem)
					{
						parentItem.editableAttributes = 
							parentItem.editableAttributes.concat(d);
					}
//					SVGViewer(item).xml = itemXMLDescription;
					
					break
				}
			}
		
		if(!item)
			return null;
		
		applyProperties(item, itemXMLDescription);
		applyStyles(item, itemXMLDescription);
		
		if(!hasChildren)
			return item;
		
		var childList:XMLList = itemXMLDescription.*;
		
		var graphArr:Array = [];
		
		var parId:String = "";
		
		if(itemXMLDescription.@contents == "static")
			parId = "static";
		else if(itemId)
			parId = itemId;
		else
			parId = parentId;
		
		var elm:UIComponent;
		
		for each(var child:XML in childList)
		{
			if(child.nodeKind() == "element")
			{
				elm = newRender(parId, child);
				
				if(!(elm is IItem) || IItem(elm).isStatic)
					graphArr.push(elm);
			}
		}
		
		var length:uint = graphArr.length;
		var i:uint = 0;
		
		for (i ; i < length; i++)
			item.addChild(graphArr[i]);
		
		
		var itemArr:Array = sortItems(itemId);
		length = itemArr.length;
		i = 0;
		
		for (i; i < length; i++)
			item.addChild(itemArr[i]);
		
		return item;
	}
	
	private function insertEditableAttributes(item:IItem, childItem:UIComponent, childXMLDescription:XML):void
	{
		var str:String = StringUtil.trimArrayElements(childXMLDescription.@editable, ",");
		var atrArray:Array = str.split(",");
		
		var attributes:Object = {};
		
		for each(var atrName:String in atrArray)
		{
			attributes[atrName] = "";
		}
		
		if(childXMLDescription.@editable[0] && item.isStatic == false)
		{
			item.editableAttributes.push(
				{
					attributes:attributes,
					sourceObject:childItem
				}
			);
		}
	}
	
	private function applyStyles(item:UIComponent, itemXMLDescription:XML):void
	{
		var _style:Object = {};
		var hasStyle:Boolean = false;
		
		item.styleName = "WYSIWYGItem";
		
		var xmlList:XMLList;
		for each (var attribute:Array in styleList)
		{
			xmlList = itemXMLDescription.attribute(attribute[0]);
			if (xmlList.length() > 0)
			{
				_style[attribute[1]] = xmlList[0].toString();
				hasStyle = true;
			}
		}
		
		if(!hasStyle)
			return;
		
		if(_style.hasOwnProperty("backgroundColor") && !_style.hasOwnProperty("backgroundAlpha"))
			_style["backgroundAlpha"] = 1;
			
		if(_style.hasOwnProperty("borderColor"))
			_style["borderStyle"] = "solid";
		
		for(var atrName:String in _style)
		{
			if(_style[atrName] != "")
				item.setStyle(atrName, _style[atrName])
		}
	}
	
	private function applyProperties(item:UIComponent, itemXMLDescription:XML):void
	{
		var _properties:Object = {};
		var hasProperties:Boolean = false;
		
		var xmlList:XMLList;
		for each (var attribute:Array in propertyList)
		{
			xmlList = itemXMLDescription.attribute(attribute[0]);
			if (xmlList.length() > 0)
			{
				_properties[attribute[1]] = xmlList[0].toString();
				hasProperties = true;
			}
		}
		
		for(var atrName:String in _properties)
		{
			item[atrName] = _properties[atrName];
		}
	}
	
	private function renderWysiwygOkHandler(event:SoapEvent):void
	{
		var itemXMLDescription:XML = event.result.Result.*[0];
		var itemId:String = itemXMLDescription.@id[0];
		var parentId:String = event.result.ParentId[0];
		
		if(!itemId)
			return;
		
		var key:String = event.result.Key[0];
		
		if(key != lastKey)
			return;
		
		if(lockedItems[itemId] && lockedItems[itemId] != key)
			return;
		
		deleteItemChildren(itemId);

		var item:UIComponent = newRender(parentId, itemXMLDescription);
		
		var itemDescription:ItemDescription = getItemDescriptionById(itemId);
		
		if(!item)
			return;
		
		if(itemDescription.parentId) {
			
			if(!item.parent) {
				var parentDescription:ItemDescription = getItemDescriptionById(itemDescription.parentId);
				Container(parentDescription.item).addChild(item);
			}
			arrangeItem(parentId);
		}
		else
		{
			item.percentWidth = 100;
			item.percentHeight = 100;
			
			if(!item.parent)
				rootContainer.addChild(item);
		}
		
		item.dispatchEvent(new Event("refreshComplete"));
		item.visible = true;
		
		IItem(item).waitMode = false;
		
		var rme:RenderManagerEvent = new RenderManagerEvent(RenderManagerEvent.RENDER_COMPLETE);
		rme.result = Container(item);
		
		dispatchEvent(rme);
	}
	
	/**
     *  @private
     */
	public function addEventListener(	type:String, listener:Function, 
										useCapture:Boolean = false, priority:int = 0, 
										useWeakReference:Boolean = false):void
	{
		dispatcher.addEventListener(type, listener, useCapture, priority);
	}
    /**
     *  @private
     */
	public function dispatchEvent(evt:Event):Boolean
	{
		return dispatcher.dispatchEvent(evt);
	}
    
	/**
     *  @private
     */
	public function hasEventListener(type:String):Boolean
	{
		return dispatcher.hasEventListener(type);
	}
    
	/**
     *  @private
     */
	public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
	{
		dispatcher.removeEventListener(type, listener, useCapture);
	}
    
    /**
     *  @private
     */            
	public function willTrigger(type:String):Boolean
	{
		return dispatcher.willTrigger(type);
	}
}
}