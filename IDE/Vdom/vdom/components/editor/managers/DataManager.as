package vdom.components.editor.managers
{
import flash.events.IEventDispatcher;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.URLLoader;
import flash.net.URLRequest;
import vdom.components.editor.events.DataManagerEvent;

import mx.core.Application;
import vdom.connection.soap.SoapEvent;
import vdom.connection.soap.Soap;

public class DataManager implements IEventDispatcher
{
	private var _typesURL:String
	private var _typesXML:XML;	
	private var _objectsURL:String
	private var _objectsXML:XML;
	
	private var _objects:XML;
	private var _types:XML;
	[Bindable]
	public var pages:XML;
	
	private var soap:Soap;
	
	private var _appId:String;
	private var _pageId:String;
	
	private var publicData:Object;
	
	private var dispatcher:EventDispatcher;
	
	private static var instance:DataManager;

	/**
	 * 
	 * @return instance of DataManager class (Singleton)
	 * 
	 */	
	
	public static function getInstance():DataManager
	{
		if (!instance) {
			
			instance = new DataManager();
		}

		return instance;
	}
	
	public function getFullAttributes(objectId:String):XML {
		
		var object:Object = getAttributes(objectId);
		
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
	
	public function updateAttributes(selectedObjects:XML):void {
		var objectId:String = selectedObjects.@ID;
		var attributes:XMLList = selectedObjects.Attributes.Attribute;
		var newAttributes:XML = <Attributes />;
		for each(var attr:XML in attributes) {
			newAttributes.appendChild(<Attribute Name={attr.Name}>{attr.Value.toString()}</Attribute>);
		}
		_objects.Object.(@ID == objectId).Attributes = newAttributes;
		var dmEvent:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
		dmEvent.objectId = objectId;
		dispatchEvent(dmEvent);
		
	}
	
	public function DataManager() {
		
		if (instance)
			throw new Error("Instance already exists.");
		
		dispatcher = new EventDispatcher();
		soap = Soap.getInstance();
		
		publicData = mx.core.Application.application.publicData;
		
		_typesURL = 'remoute/types.xml';
		_typesXML = null;
		_objectsURL = 'remoute/application.xml';
		_objectsXML = null;
		_objects = null;
	}
	
	/**
	 * Инициализация класса, попытка загрузить объекты вехнего уровня.
	 * @param appId идентификатор приложения
	 * 
	 */	
	
	public function init(appId:String, pageId:String):void {
		
		_appId = appId;
		_pageId = pageId;
		_types = publicData['types'];
		//trace('init');
		//trace(appId);
		//_pageId = 'acc9e168-8b68-49e3-a9f7-c355e7b5a016';
				
		soap.addEventListener(SoapEvent.GET_TOP_OBJECTS_OK, getTopObjectsHandler);
		soap.getTopObjects(_appId);
	}
	
	/**
	 * Получение результатов запроса всех объектов верхнего уровня. 
	 * Попытка загрузить всех потомков объекта верхнего уровня
	 * @param event
	 * 
	 */	
	
	private function getTopObjectsHandler(event:SoapEvent):void {
		//trace('getTopObjectsHandler');
		
		pages = event.result;
		if(!_pageId) {
			_pageId = event.result.Object[0].@ID;
		}
		//trace('pageId: '+_pageId);
		
		soap.removeEventListener(SoapEvent.GET_TOP_OBJECTS_OK, getTopObjectsHandler);
		
		soap.addEventListener(SoapEvent.GET_CHILD_OBJECTS_OK, loadedObjectsHandler);
		soap.getChildObjects(_appId, _pageId);
	}
	
	/* private function loadedObjectsHandler(event:SoapEvent):void {
		
		trace('loadedObjectsHandler');
		
		
	} */
	
	/* private function typeLoadedHandler(event:Event):void {
		
		_types = soap.listTypesResult();
		
		soap.addEventListener(SoapEvent.GET_CHILD_OBJECTS_OK, loadedObjectsHandler);
		soap.getChildObjects(_appId, _pageId);
	} */
	
 	private function loadedObjectsHandler(event:SoapEvent):void {
 		
		//soap.addEventListener(SoapEvent.GET_APPLICATION_RESOURCE_OK, zzz);
		//soap.getApplicationResource(_appId, '002');
		
		_objects = event.result;
		dispatchEvent(new Event('initComplete'));
		//trace('initComplete');
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
		
		soap.getChildObjects('26c0dc2d-5edd-44ae-aaa9-195f54c46f74', 'acc9e168-8b68-49e3-a9f7-c355e7b5a016');
	}
	
	public function getAttributes(objectId:String):XML {
		return _objects.Object.(@ID == objectId)[0];
	}
	
	public function getType(typeId:String):XML {
		return _types.Type.Information.(ID == typeId).parent();
	}
	
	public function getTypeById(typeId:int):XML {
		return _types.Type.Information.(ID == typeId).parent();
	}
	
	public function getObjects():XML {
		return _objects;
	}
	
	public function getAttributeHelp(objectId:int, attributeName:String):String {
		var typeId:Number = _objects.Object.(@ID == objectId).@Type;
		var help:String = _types.Type.Information.(ID == typeId).parent().Attributes.Attribute.(Name == attributeName).Help;
		return help;
	}
	
	public function createObject(initProp:Object):String {
		
		var objectType:XML = _types.Type.Information.(ID == initProp.typeId).parent();
		
		var objectId:String = Math.round(Math.random()*1000).toString();
		while (_objects.Object.(@ID == objectId).toString()) {
			objectId = Math.round(Math.random()*1000).toString();
		}
		
		var newObject:XML = <Object Name={objectType.Information.DisplayName+objectId} ID={objectId} Type={objectType.Information.ID} />;

		var attributes:XML = <Attributes />
		
		for each(var prop:XML in objectType.Attributes.Attribute) {
			attributes.appendChild(<Attribute Name={prop.Name.toString()}>{prop.DefaultValue.toString()}</Attribute>);
		}
		attributes.Attribute.(@Name == 'left')[0] = initProp.left;
		attributes.Attribute.(@Name == 'top')[0] = initProp.top;
		//attributes.appendChild(<Attribute Name="left">{initProp.left}</Attribute>);
		//attributes.appendChild(<Attribute Name="top">{initProp.top}</Attribute>);
		
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