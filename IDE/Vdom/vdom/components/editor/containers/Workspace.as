package vdom.components.editor.containers
{
import mx.containers.Canvas;
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import vdom.components.editor.managers.ResizeManager;
import vdom.components.editor.events.ResizeManagerEvent;
import flash.events.Event;
import vdom.components.editor.containers.WorkspaceClasses.Item;
import mx.collections.XMLListCollection;
	
public class Workspace extends Canvas
{
	
	public var selectedElement:String;
	
	private var resizer:ResizeManager;
	
	private var _elements:Object;
	private var collection:XML;
	
	public function Workspace()
	{
		super();
		
		_elements = [];
		resizer = new ResizeManager();
		resizer.addEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
		addEventListener(MouseEvent.CLICK, mainClickHandler, false);
	}
	
	public function updateObject(objectAttributes:XML):void {
		
		var objectId:String = objectAttributes.@ID;
		
		var object:Item = _elements[objectId];
		
		var objWidth:int = objectAttributes.Attributes.Attribute.(@Name == 'width')[0];
		var objHeight:int = objectAttributes.Attributes.Attribute.(@Name == 'height')[0];
		
		object.width = (objWidth == 0) ? 50 : objWidth;
		object.height = (objHeight == 0) ? 50 : objHeight;
		
		object.x = objectAttributes.Attributes.Attribute.(@Name == 'left')[0];
		object.y = objectAttributes.Attributes.Attribute.(@Name == 'top')[0];
		
		resizer.item = object;
		
	}
	
	public function destroyElements():void {
		selectedElement = null;
		removeAllChildren();
	}
	
	public function set dataProvider(attributes:XML):void {
		
		//var xl:XMLList = new XMLList();
       //xl += attributes.Attributes.Attribute;
        //collection = new XMLListCollection(xl);
        collection = attributes.Attributes[0];
	}
	
	public function get dataProvider():XML {
		
		return XML(collection);
	}
	
	
	
	public function addObject(objectAttributes:XML):void {
		
		var objectId:String = objectAttributes.@ID;
		
		var element:Item = new Item(objectId);
		
		var objWidth:int = objectAttributes.Attributes.Attribute.(@Name == 'width')[0];
		var objHeight:int = objectAttributes.Attributes.Attribute.(@Name == 'height')[0];
		
		element.width = (objWidth == 0) ? 50 : objWidth;
		element.height = (objHeight == 0) ? 50 : objHeight;
		
		element.x = objectAttributes.Attributes.Attribute.(@Name == 'left')[0];
		element.y = objectAttributes.Attributes.Attribute.(@Name == 'top')[0];
		
		/* for each(var attr:XML in objectAttributes.Attributes.Attribute) {
			element[attr.@Name] = attr;
		} */
		
		element.addEventListener(MouseEvent.CLICK, elementClickHandler);
		_elements[objectAttributes.@ID] = element
		addChild(element);
	}
	
	private function resizeCompleteHandler(event:ResizeManagerEvent):void {
		collection.Attribute.(Name == 'top').Value = event.properties['top'];
		collection.Attribute.(Name == 'left').Value = event.properties['left'];
		collection.Attribute.(Name == 'width').Value = event.properties['width'];
		collection.Attribute.(Name == 'height').Value = event.properties['height'];
		//var zzz:Object = collection.(Name == 'top'); //= event.properties['top'];
		//collection.Attributes.Attribute.(Name == 'left') = event.properties['left'];
		//collection.Attributes.Attribute.(Name == 'width') = event.properties['width'];
		//collection.Attributes.Attribute.(Name == 'height') = event.properties['height'];
		
		dispatchEvent(new Event('propsChanged'));
	}
	
	private function elementClickHandler(event:MouseEvent):void {
	
		if(selectedElement) {
			removeEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
			selectedElement = null;
			removeChild(resizer);
		}
		
		selectedElement = Item(event.currentTarget).objectId;
		_elements[selectedElement].content.setFocus();
		
		addEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
		resizer.item = _elements[selectedElement];
		addChild(resizer);
		event.stopPropagation();
		dispatchEvent(new Event('objectChange'));
	}
	
	
	
	private function mainClickHandler(event:MouseEvent):void {
		if(event.target == event.currentTarget && selectedElement) {
			setFocus();
			selectedElement = null;
			removeChild(resizer);
			dispatchEvent(new Event('objectChange'));
		}
	}
}
}