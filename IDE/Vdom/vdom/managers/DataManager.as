package vdom.managers {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import vdom.connection.Proxy;
import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.events.DataManagerEvent;
import vdom.events.ProxyEvent;

public class DataManager implements IEventDispatcher {
	
	private static var instance:DataManager;
	
	private var languageManager:LanguageManager;
	
	//[Bindable]
	//public var topLevelObjects:XML;
	
	private var dispatcher:EventDispatcher;
	
	private var soap:Soap;
	private var proxy:Proxy;
	
	private var _listApplication:XMLList;
	private var _listPages:XMLList;
	
	private var _types:XML;
	private var _objects:XML;
	
	private var _currentApplication:String;
	private var _currentPage:String;
	private var _currentObject:XML;

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
		
		languageManager = LanguageManager.getInstance();
		
		_currentApplication = null;
		_currentPage = null;
		_currentObject = null;
		
		_objects = null;
		
		//topLevelObjects = null;
	}

// ----------------------- start init action -----------------------

	public function new_init():void {
		
		soap.addEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
		soap.listApplications();
	}
	
	private function listApplicationHandler(event:SoapEvent):void {
	
		trace('listApplicationHandler');
		_listApplication = event.result.*;
		//publicData['applicationId'] = listApplication.Application[0].@id.toString();
		
		soap.removeEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
		
		dispatchEvent(new Event('listApplicationChanged'));
		
		soap.addEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
		soap.getAllTypes();
	}
	
	private function getAllTypesHandler(event:SoapEvent):void {
	
		trace('getAllTypesHandler');
		_types = event.result;
		soap.removeEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
		languageManager.parseLanguageData(_types);
		dispatchEvent(new DataManagerEvent(DataManagerEvent.INIT_COMPLETE));
		
	}

// ----------------------- end init action -----------------------



	/* public function _init(appId:String, pageId:String):void {
		
		//_appId = appId;
		_pageId = pageId;
		//_types = publicData['types'];
		objectDescription = null;
		
		soap.addEventListener(SoapEvent.GET_TOP_OBJECTS_OK, getTopObjectsHandler);
		soap.getTopObjects(_appId);
	} */
	
	public function get types():XML {
		
		return _types;
	}
	
	
	
	[Bindable (event="listApplicationChanged")]
	public function get listApplication():XMLList {
		
		return _listApplication;
	}
	
	public function get currentApplication():String {
		
		return _currentApplication;
	}
	
	public function get listPages():XMLList {
		
		return _listPages;
	}
	
	public function get currentPage():String {
		
		return _currentPage;
	}
	
	[Bindable (event="objectDescriptionChanged")]
	public function get objectDescription():XML {
		
		return _currentObject;
	}
	
	public function set objectDescription(object:XML):void {
		
		_currentObject = object;
		dispatchEvent(new Event('objectDescriptionChanged'));
	}
	
	/**
	 * 
	 * @param objectId идентификатор объекта
	 * @return все данные об объекте, в т.ч. описание его типа.
	 * 
	 */	
	public function setActiveObject(objectId:String):void {
		
		if(objectId) {
			
			_currentObject = new XML(_getObject(objectId));
			//publicData.selectedObject = objectId;
		} else {
			
			_currentObject = null;
			//publicData.selectedObject = null;
		}
		
		dispatchEvent(new Event('objectDescriptionChanged'));
	}
	
	public function getAttributes(objectId:String):XML {
		
		return new XML(_getObject(objectId));
	}
	
	/**
	 * 
	 * @param selectedObjects описание типа объекта, которое надо сохранить, для последующей отправки на сервер.
	 * 
	 */	
	public function updateAttributes():void {
		
		var objectId:String = _currentObject.@ID;
		
		var oldXMLDescription:XML = _getObject(objectId);
		var newXMLDescription:XML = _currentObject;
		
		var oldListAttributes:XMLList = oldXMLDescription.Attributes.Attribute
		var newListAttributes:XMLList = newXMLDescription.Attributes.Attribute;
		
		var newOnlyAttributes:XML = <Attributes />;
		
		var nameChanged:Boolean = false;
		var attrChanged:Boolean = false;
		
		if(oldXMLDescription.@Name != newXMLDescription.@Name)
			nameChanged = true;
		
		for each(var attr:XML in newListAttributes) {
			
			if(oldListAttributes.(@Name == attr.@Name) != attr) {	
				newOnlyAttributes.item += attr;
			} 
		}
		
		if(newOnlyAttributes.*.length() > 0)
			attrChanged = true;
		
		
		if(attrChanged) {
			
			oldXMLDescription.Attributes[0] = new XML(newXMLDescription.Attributes[0]);
			
			proxy.addEventListener(ProxyEvent.PROXY_COMPLETE, sendAttributeCompleteHandler);
			proxy.setAttributes(_currentApplication, oldXMLDescription.@ID, newOnlyAttributes);
		}
		
		if(nameChanged) {
			
			oldXMLDescription.@Name = newXMLDescription.@Name;
			
			soap.addEventListener(SoapEvent.SET_NAME_OK, setNameCompleteHandler);
			soap.setName(_currentApplication, oldXMLDescription.@ID, oldXMLDescription.@Name);
		}
		
	}
	
	private function setNameCompleteHandler(event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.SET_NAME_OK, setNameCompleteHandler);
		
		var objectId:String = event.result.@ID;
		
		var result:XML = _getObject(objectId);
		
		var dmEvent:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
		
		
		dmEvent.objectId = objectId
		dmEvent.result = <Result> {result} </Result>;
		//dispatchEvent(new Event('objectDescriptionChanged'));
		dispatchEvent(dmEvent);
	}
	
	private function sendAttributeCompleteHandler(event:ProxyEvent):void {
		
		proxy.removeEventListener(ProxyEvent.PROXY_COMPLETE, sendAttributeCompleteHandler);
		
		var dmEvent:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
		dmEvent.objectId = event.xml.Object.@ID;
		dmEvent.result = event.xml;
		//dispatchEvent(new Event('objectDescriptionChanged'));
		dispatchEvent(dmEvent);
	}
	
	public function changeApplication(applicationId:String):void {
		
		_currentApplication = applicationId;
	}
	
	/**
	 * 
	 * @param typeId идетнтификатор типа.
	 * @return xml-описание типа.
	 * 
	 */	
	public function getTypeByTypeId(typeId:String):XML {
		
		return _types.Type.Information.(ID == typeId)[0].parent();
	}
	
	public function getTypeByObjectId(objectId:String):XML {
		
		return _getObject(objectId).Type[0];
	}
	
	public function getTopLevelTypes():XML {
		
		var topLevelTypes:XML = <Types />;
		
		for each (var element:XML in _types.Type.Information.(Container == 3)) {
		
			topLevelTypes.appendChild(element.parent());
		}
		
		return topLevelTypes;
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
		soap.deleteObject(_currentApplication, objectId);
		
	}
	
	
	public function objectDeletedHandler (event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.DELETE_OBJECT_OK, objectDeletedHandler);
		
		var objectID:String = event.result;
		
		delete _getObject(objectID);
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.OBJECT_DELETED);
		dme.objectId = event.result;
		dispatchEvent(dme);
	}
	
	public function getApplicationStructure():void {
		
		soap.addEventListener(SoapEvent.GET_APPLICATION_STRUCTURE_OK, getApplicationStructureHandler);
		soap.getApplicationStructure(_currentApplication);
	}
	
	private function getApplicationStructureHandler(event:SoapEvent):void {
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.STRUCTURE_LOADED);
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	public function setApplactionStructure(struct:XML):void {
		
		soap.addEventListener(SoapEvent.SET_APPLICATION_STRUCTURE_OK, setApplicationStructureHandler);
		soap.setApplicationStructure(_currentApplication, struct);
	}
	
	private function setApplicationStructureHandler(event:SoapEvent):void {
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.STRUCTURE_SAVED);
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	/**
	 * 
	 * @param objectId идентификатор объекта
	 * @return XML описание объекта.
	 * 
	 */	
	private function _getObject(objectId:String):XML {
		
		var object:XMLList = _objects..Objects.Object.(@ID == objectId);
		return object[0];
	}
	
	public function getObject(objectId:String):XML {
		
		return _getObject(objectId);
	}
	
	/**
	 * Создание нового объекта.
	 * @param initProp Начальные свойства объекта (идентификатор типа, координаты).
	 * @return идентификатор объекта
	 * 
	 */	
	public function createObject(typeId:String, parentId:String = '', objectName:String = '', attributes:String = ''):void {
		
		//var objectType:XML = _types.Type.Information.(ID == initProp.typeId).parent();
		
		//var objectId:String = Math.round(Math.random()*1000).toString();
		//while (_objects.Object.(@ID == objectId).toString()) {
			//objectId = Math.round(Math.random()*1000).toString();
		//}
		
		//var newObject:XML = <Object Name={objectType.Information.DisplayName+objectId} ID={objectId} Type={objectType.Information.ID} />;
		
		//var attributes:XML = <Attributes />
		
		//for (var prop:String in initProp) {
		//attributes.appendChild(<Attribute Name="left">{initProp.left}</Attribute>);
		//attributes.appendChild(<Attribute Name="top">{initProp.top}</Attribute>);
		//}
		
		//attributes.Attribute.(@Name == 'left')[0] = initProp.left;
		//attributes.Attribute.(@Name == 'top')[0] = initProp.top;
		
		//newObject.appendChild(attributes);
		//newObject.appendChild(objectType);
		
		//_objects.appendChild(newObject);
		
		soap.addEventListener(SoapEvent.CREATE_OBJECT_OK, createObjectCompleteHandler);
		soap.createObject(_currentApplication, parentId, typeId, attributes, objectName);
		
		//return objectId;
	}
	
	private function createObjectCompleteHandler(event:SoapEvent):void {
		
		var result:XML = event.result;
		var objectId:String = result.Object.@ID;
		var objectName:String = result.Object.@Name;
		var parentId:String = result.Parent;
		var objectTypeId:String = result.Object.@Type;
		var objectType:XML = _types.Type.Information.(ID == objectTypeId).parent();
		
		
		var newObject:XML = <Object Name={objectName} ID={objectId} Type={objectType.Information.ID} />;

		//var attributes:XML = <Attributes />;
		var attributes:XML = result.Object.Attributes[0];
		
		var objects:XML = <Objects />
		/* for each(var prop:XML in objectType.Attributes.Attribute) {
			
			attributes.appendChild(<Attribute Name={prop.Name.toString()}>{prop.DefaultValue.toString()}</Attribute>);
		} */
		
		newObject.appendChild(attributes);
		newObject.appendChild(objectType);
		newObject.appendChild(objects);
		
		if(result.Parent.toString() != '') {
			
			var parentObject:XML = _getObject(parentId);
			parentObject.Objects.appendChild(newObject);
			
		}
		else
			_objects.Objects.appendChild(newObject);
		
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.OBJECTS_CREATED);
		dme.result = event.result;
		dispatchEvent(dme);

	}
	
	/**
	 * Получение результатов запроса всех объектов верхнего уровня. 
	 * Попытка загрузить всех потомков объекта верхнего уровня
	 * @param event
	 * 
	 */	
	private function getTopObjectsHandler(event:SoapEvent):void {
		
		_listPages = event.result.*;
		if(!_currentPage) {
			_currentPage = event.result.Object[0].@ID;
			//publicData['topLevelObjectId'] = _pageId;
		}
		
		soap.removeEventListener(SoapEvent.GET_TOP_OBJECTS_OK, getTopObjectsHandler);
		
		soap.addEventListener(SoapEvent.GET_CHILD_OBJECTS_TREE_OK, loadedObjectsHandler);
		soap.getChildObjectsTree(_currentApplication, _currentPage);
	}
	
 	private function loadedObjectsHandler(event:SoapEvent):void {
		
		_objects = <page>{event.result}</page>;
		
		for each (var object:XML in _objects..Objects.Object) {
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
    public function dispatchEvent(event:Event):Boolean{
        return dispatcher.dispatchEvent(event);
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