package vdom.managers {

import flash.events.IEventDispatcher;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.URLLoader;
import flash.net.URLRequest;
import mx.core.Application;

import vdom.components.editor.events.DataManagerEvent;
import vdom.connection.soap.SoapEvent;
import vdom.connection.soap.Soap;
import mx.messaging.Producer;
import vdom.connection.Proxy;

public class DataManager implements IEventDispatcher {
	
	private static var instance:DataManager;
	
	[Bindable]
	public var pages:XML;
	
	private var dispatcher:EventDispatcher;
	private var soap:Soap;
	private var publicData:Object;
	private var _objects:XML;
	private var _types:XML;
	private var _appId:String;
	private var _pageId:String;
	private var proxy:Proxy;
	
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
	
	/**
	 * 
	 * Constructor
	 * 
	 */	
	public function DataManager() {
		
		if (instance)
			throw new Error("Instance already exists.");
		
		dispatcher = new EventDispatcher();
		soap = Soap.getInstance();
		proxy = Proxy.getInstance();
		publicData = mx.core.Application.application.publicData;
		
		_objects = null;
	}
	
	public function init(appId:String, pageId:String):void {
		
		_appId = appId;
		_pageId = pageId;
		_types = publicData['types'];
				
		soap.addEventListener(SoapEvent.GET_TOP_OBJECTS_OK, getTopObjectsHandler);
		soap.getTopObjects(_appId);
	}
	
	public function get types():XML {
		
		return _types;
	}
	
	public function get objectsXML():XML {
		
		return _objects;
	}
	
	/**
	 * 
	 * @param objectId идентификатор объекта
	 * @return все данные об объекте, в т.ч. описание его типа.
	 * 
	 */	
	public function getFullAttributes(objectId:String):XML {
		
		
		var object:Object = getAttributes(objectId);
		
		var type:XML = new XML(getType(object.@Type));
		
		var element:XML = <Element ID={objectId} />;
		
		element.appendChild(type);
		
		var attributes:XML = <Attributes />;
		
		for each(var attr:XML in type.Attributes.Attribute){
			
			attr.appendChild(<Value>{object.Attributes.Attribute.(@Name == attr.Name).toString()}</Value>);
			attributes.appendChild(attr);
		}
		
		element.appendChild(attributes);
		
		proxy.setAttributes(_appId, objectId, attributes);
		
		return element;
	}
	
	/**
	 * 
	 * @param selectedObjects описание типа объекта, которое надо сохранить, для последующей отправки на сервер.
	 * 
	 */	
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
	
	public function getAttributes(objectId:String):XML {
		return _objects.Object.(@ID == objectId)[0];
	}
	
	/**
	 * 
	 * @param typeId идетнтификатор типа.
	 * @return xml-описание типа.
	 * 
	 */	
	public function getType(typeId:String):XML {
		
		return _types.Type.Information.(ID == typeId).parent();
	}
	
	/**
	 * 
	 * @return xml-описание всех объектов вместе с типами.
	 * 
	 */	
	public function getObjects():XML {
		
		return _objects;
	}
	
	/**
	 * Создание нового объекта.
	 * @param initProp Начальные свойства объекта (идентификатор типа, координаты).
	 * @return идентификатор объекта
	 * 
	 */	
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
		
		newObject.appendChild(attributes);
		
		_objects.appendChild(newObject);		

		return objectId;
	}
	
	/**
	 * Получение результатов запроса всех объектов верхнего уровня. 
	 * Попытка загрузить всех потомков объекта верхнего уровня
	 * @param event
	 * 
	 */	
	private function getTopObjectsHandler(event:SoapEvent):void {
		
		pages = event.result;
		if(!_pageId) {
			_pageId = event.result.Object[0].@ID;
		}
		
		soap.removeEventListener(SoapEvent.GET_TOP_OBJECTS_OK, getTopObjectsHandler);
		
		soap.addEventListener(SoapEvent.GET_CHILD_OBJECTS_OK, loadedObjectsHandler);
		soap.getChildObjects(_appId, _pageId);
	}
	
 	private function loadedObjectsHandler(event:SoapEvent):void {
		
		_objects = event.result;
		
		for each (var object:XML in _objects.Object) {
			object.appendChild(_types.Type.Information.(ID == object.@Type).parent());
		}
		dispatchEvent(new Event('initComplete'));
	}
	
	// Реализация диспатчера
	
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