package vdom.components.editor.managers
{
import flash.events.IEventDispatcher;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.URLLoader;
import flash.net.URLRequest;
import vdom.components.editor.events.DataManagerEvent;
	
public class DataManager implements IEventDispatcher
{
	private var _typesURL:String
	private var _typesXML:XML;	
	private var _objectsURL:String
	private var _objectsXML:XML;
	
	private var _objects:XML;
	private var _types:XML;
	
	private var dispatcher:EventDispatcher;
	
	private static var instance:DataManager;
	
	public static function getInstance():DataManager
	{
		if (!instance)
		{
			//sm = SystemManagerGlobals.topLevelSystemManagers[0];
			instance = new DataManager();
		}

		return instance;
	}
	
	public function getFullAttributes(objectId:int):XML {
		
		var object:Object = getProperties(objectId);
		
		var type:XML = new XML(getType(object.@Type));
		
		var element:XML = <Element ID={objectId} />;
		
		element.appendChild(type);
		
		var attributes:XML = <Attributes />;
		
		for each(var attr:XML in type.Attributes.Attribute){
			
			//var value:XML
			//if(!attr.Value)	
				attr.appendChild(<Value>{object.Attributes.Attribute.(@Name == attr.Name).toString()}</Value>);
			
			attributes.appendChild(attr);
		}
		
		element.appendChild(attributes);
		
		return element;
	}
	
	public function getTypeId(objectId:int):Number {
		
		return _objects.Object.(@ID == objectId).@Type;
	}
	
	public function DataManager() {
		
		if (instance)
			throw new Error("Instance already exists.");
		
		dispatcher = new EventDispatcher();
		
		_typesURL = 'remoute/types.xml';
		_typesXML = null;
		_objectsURL = 'remoute/application.xml';
		_objectsXML = null;
		_objects = null;
	}
	
	public function get types():XML {
		return _types;
	}
	
	public function get objectsXML():XML {
		return _objects;
	}
	
	public function loadTypes():void {
		
		var typesXML_URLRequest:URLRequest = new URLRequest(_typesURL);
		var typesXML_URLLoader:URLLoader = new URLLoader(typesXML_URLRequest);
	
		typesXML_URLLoader.addEventListener(Event.COMPLETE, typesXMLLoadHandler);
	}
	
	public function loadObjects():void {
		
		var objectsXML_URLRequest:URLRequest = new URLRequest(_objectsURL);
		var objectsXML_URLLoader:URLLoader = new URLLoader(objectsXML_URLRequest);
	
		objectsXML_URLLoader.addEventListener(Event.COMPLETE, objectsXMLLoadHandler);
	}
	
	public function getProperties(itemId:int):XML {
		return _objects.Object.(@ID == itemId)[0];
	}
	
	public function getType(typeId:int):XML {
		return _types.Type.Information.(ID == typeId).parent();
	}
	
	public function getTypeById(typeId:int):XML {
		return _types.Type.Information.(ID == typeId).parent();
	}
	
	public function getObjects():Object {
		return _objects.Object;
	}
	
	public function getAttributeHelp(objectId:int, attributeName:String):String {
		var typeId:Number = _objects.Object.(@ID == objectId).@Type;
		var help:String = _types.Type.Information.(ID == typeId).parent().Attributes.Attribute.(Name == attributeName).Help;
		return help;
	}
	
	public function createObject(initProp:Object):uint {
		
		var objectType:XML = _types.Type.Information.(ID == initProp.typeId).parent();
		
		var objectId:int = Math.round(Math.random()*1000);
		while (_objects.Object.(@ID == objectId).toString()) {
			objectId = Math.round(Math.random()*1000);
		}
		
		var newObject:XML = <Object Name={objectType.Information.DisplayName+objectId} ID={objectId} Type={objectType.Information.ID} />;

		var attributes:XML = <Attributes />
		
		for each(var prop:XML in objectType.Attributes.Attribute) {
			attributes.appendChild(<Attribute Name={prop.Name.toString()}>{prop.DefaultValue.toString()}</Attribute>);
		}
		attributes.appendChild(<Attribute Name="x">{initProp.x}</Attribute>);
		attributes.appendChild(<Attribute Name="y">{initProp.y}</Attribute>);
		
		newObject.appendChild(attributes);
		
		//var information:XML = <information></information>;
		//information.appendChild(<interfacetype>{itemType.Information.InterfaceType.toString()}</interfacetype>);
		//newItem.appendChild(information);
		
		_objects.appendChild(newObject);		

		return objectId;
	}

	private function typesXMLLoadHandler(event:Event):void {
		
		_types = XML(event.currentTarget.data);		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.TYPES_LOADED));
	}
	
	private function objectsXMLLoadHandler(event:Event):void {
		
		_objects = XML(event.currentTarget.data).Objects[0];
		dispatchEvent(new DataManagerEvent(DataManagerEvent.OBJECTS_LOADED));
	}



	public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
		dispatcher.addEventListener(type, listener, useCapture, priority);
    }
           
    public function dispatchEvent(evt:Event):Boolean{
        return dispatcher.dispatchEvent(evt);
    }
    
    public function hasEventListener(type:String):Boolean{
        return dispatcher.hasEventListener(type);
    }
    
    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
        dispatcher.removeEventListener(type, listener, useCapture);
    }
                   
    public function willTrigger(type:String):Boolean {
        return dispatcher.willTrigger(type);
    }
}
}