package vdom.managers {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.net.URLLoader;
import flash.net.URLRequest;

import mx.core.Application;

import vdom.components.editor.Editor;
import vdom.connection.Proxy;
import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.events.DataManagerEvent;
import vdom.events.ProxyEvent;

public class DataManager implements IEventDispatcher {
	
	private static var instance:DataManager;
	
	[Bindable]
	public var topLevelObjects:XML;
	
	private var dispatcher:EventDispatcher;
	private var soap:Soap;
	private var publicData:Object;
	private var _objects:XML;
	private var _types:XML;
	private var _appId:String;
	private var _pageId:String;
	private var proxy:Proxy;
	private var _objectDescription:XML;
	
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
		topLevelObjects = null;
	}
	
	public function init(appId:String, pageId:String):void {
		
		_appId = appId;
		_pageId = pageId;
		_types = publicData['types'];
		objectDescription = null;
		
				
		soap.addEventListener(SoapEvent.GET_TOP_OBJECTS_OK, getTopObjectsHandler);
		soap.getTopObjects(_appId);
	}
	
	public function get types():XML {
		
		return _types;
	}
	
	[Bindable (event="objectDescriptionChanged")]
	public function get objectDescription():XML {
		
		return _objectDescription;
	}
	
	public function set objectDescription(object:XML):void {
		
		_objectDescription = object;
		dispatchEvent(new Event('objectDescriptionChanged'));
	}
	
	/**
	 * 
	 * @param objectId идентификатор объекта
	 * @return все данные об объекте, в т.ч. описание его типа.
	 * 
	 */	
	public function setActiveObject(objectId:String):void {
		
		_objectDescription = new XML(getObject(objectId));
		dispatchEvent(new Event('objectDescriptionChanged'));
	}
	
	public function getAttributes(objectId:String):XML {
		
		return new XML(getObject(objectId));
	}
	
	/**
	 * 
	 * @param selectedObjects описание типа объекта, которое надо сохранить, для последующей отправки на сервер.
	 * 
	 */	
	public function updateAttributes(obdjectDescription:XML):void {
		
		var objectId:String = _objectDescription.@ID;
		
		var oldListAttributes:XMLList = _objects.Object.(@ID == objectId).Attributes.Attribute
		var newListAttributes:XMLList = _objectDescription.Attributes.Attribute;
		
		var newOnlyAttributes:XML = <Attributes />;
		
		for each(var attr:XML in newListAttributes) {
			
			if(oldListAttributes.(@Name == attr.@Name) != attr) {	
				newOnlyAttributes.item += attr;
			} 
		}
		
		_objects.Object.(@ID == objectId).Attributes = _objectDescription.Attributes;
		
		proxy.addEventListener(ProxyEvent.PROXY_COMPLETE, sendAttributeComplete);
		proxy.setAttributes(_appId, _objectDescription.@ID, newOnlyAttributes);
		
		
	}
	
	private function sendAttributeComplete(event:ProxyEvent):void {
		
		proxy.removeEventListener(ProxyEvent.PROXY_COMPLETE, sendAttributeComplete);
		
		var dmEvent:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
		dmEvent.objectId = event.xml.@ID;
		dispatchEvent(new Event('objectDescriptionChanged'));
		dispatchEvent(dmEvent);
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
	
	public function deleteObject(objectId:String):void {
		
		
		soap.addEventListener(SoapEvent.DELETE_OBJECT_OK, objectDeletedHandler);
		soap.deleteObject(_appId, objectId);
		
	}
	
	
	public function objectDeletedHandler (event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.DELETE_OBJECT_OK, objectDeletedHandler);
		delete _objects.Object.(@ID == event.result)[0];
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.OBJECT_DELETED);
		dme.objectId = event.result;
		dispatchEvent(dme);
	}
	/**
	 * 
	 * @param objectId идентификатор объекта
	 * @return XML описание объекта.
	 * 
	 */	
	public function getObject(objectId:String):XML {
		
		return _objects.Object.(@ID == objectId)[0];
	}
	
	/**
	 * Создание нового объекта.
	 * @param initProp Начальные свойства объекта (идентификатор типа, координаты).
	 * @return идентификатор объекта
	 * 
	 */	
	public function createObject(initProp:Object):void {
		
		//var objectType:XML = _types.Type.Information.(ID == initProp.typeId).parent();
		
		//var objectId:String = Math.round(Math.random()*1000).toString();
		//while (_objects.Object.(@ID == objectId).toString()) {
			//objectId = Math.round(Math.random()*1000).toString();
		//}
		
		//var newObject:XML = <Object Name={objectType.Information.DisplayName+objectId} ID={objectId} Type={objectType.Information.ID} />;
		
		var attributes:XML = <Attributes />
		
		//for (var prop:String in initProp) {
		attributes.appendChild(<Attribute Name="left">{initProp.left}</Attribute>);
		attributes.appendChild(<Attribute Name="top">{initProp.top}</Attribute>);
		//}
		
		//attributes.Attribute.(@Name == 'left')[0] = initProp.left;
		//attributes.Attribute.(@Name == 'top')[0] = initProp.top;
		
		//newObject.appendChild(attributes);
		//newObject.appendChild(objectType);
		
		//_objects.appendChild(newObject);
		
		soap.addEventListener(SoapEvent.CREATE_OBJECT_OK, createObjectCompleteHandler);
		soap.createObject(_appId, initProp.parentId, initProp.typeId, attributes);
		
		//return objectId;
	}
	
	private function createObjectCompleteHandler(event:SoapEvent):void {
		
		var result:XML = event.result;
		var objectId:String = result.@ID;
		var objectTypeId:String = result.@Type;
		var objectType:XML = _types.Type.Information.(ID == objectTypeId).parent();
		
		
		var newObject:XML = <Object Name={result.@Name} ID={objectId} Type={objectType.Information.ID} />;

		var attributes:XML = <Attributes />;
		
		for each(var prop:XML in objectType.Attributes.Attribute) {
			
			attributes.appendChild(<Attribute Name={prop.Name.toString()}>{prop.DefaultValue.toString()}</Attribute>);
		}
		
		newObject.appendChild(attributes);
		newObject.appendChild(objectType);
		
		_objects.appendChild(newObject);
		
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
		dme.objectId = '';
		dispatchEvent(dme);

	}
	
	/**
	 * Получение результатов запроса всех объектов верхнего уровня. 
	 * Попытка загрузить всех потомков объекта верхнего уровня
	 * @param event
	 * 
	 */	
	private function getTopObjectsHandler(event:SoapEvent):void {
		
		topLevelObjects = event.result;
		if(!_pageId) {
			_pageId = event.result.Object[0].@ID;
			publicData['topLevelObjectId'] = _pageId;
		}
		
		soap.removeEventListener(SoapEvent.GET_TOP_OBJECTS_OK, getTopObjectsHandler);
		
		soap.addEventListener(SoapEvent.GET_CHILD_OBJECTS_TREE_OK, loadedObjectsHandler);
		soap.getChildObjectsTree(_appId, _pageId);
	}
	
 	private function loadedObjectsHandler(event:SoapEvent):void {
		
		_objects = event.result;
		
		for each (var object:XML in _objects.Object) {
			object.appendChild(_types.Type.Information.(ID == object.@Type).parent());
		}
		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.INIT_COMPLETE));
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