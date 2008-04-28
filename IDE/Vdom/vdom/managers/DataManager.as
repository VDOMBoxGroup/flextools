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
	
	private var dispatcher:EventDispatcher;
	
	private var soap:Soap;
	private var proxy:Proxy;
	
	private var _listApplication:XMLList;
	private var _listTypes:XMLList;
	
	private var _typeLoaded:Boolean;
		
	private var _currentApplication:XML;
	private var _currentApplicationId:String;
	
	private var _currentPage:XML;
	private var _currentPageId:String;
	
	private var _currentObject:XML;
	
	private var requestQue:Object;

	/**
	 * 
	 * @return instance of DataManager class (Singleton)
	 * 
	 */	
	public static function getInstance():DataManager {
		
		if (!instance)
			instance = new DataManager();

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
		
		proxy.addEventListener(ProxyEvent.PROXY_SEND, proxySendedHandler);
		proxy.addEventListener(ProxyEvent.PROXY_COMPLETE, setAttributesCompleteHandler);
		requestQue = {};
		
		_currentApplication = null;
		_currentApplicationId = null;
		_currentPageId = null;
		_currentObject = null;
		
		_typeLoaded = false;
	}
	
	[Bindable (event='listApplicationChanged')]
	public function get listApplication():XMLList {
		
		return _listApplication;
	}
	[Bindable (event='listPagesChanged')]
	public function get listPages():XMLList {
		
		if(_currentApplication.Objects.Object.length())
			return _currentApplication.Objects.Object;
		else
			return null
	}
	[Bindable (event='typesLoaded')]
	public function get listTypes():XMLList {
		
		return _listTypes;
	}
	
	public function get typeLoaded():Boolean {
		
		return _typeLoaded;
	}
	
	public function get currentApplicationId():String {
		
		return _currentApplicationId;
	}
	
	[Bindable (event='currentApplicationChanged')]
	public function get currentApplicationInformation():XML {
		
		return _currentApplication.Information[0];
	}
	
	[Bindable (event='currentPageChanged')]
	public function get currentPageId():String {
		
		return _currentPageId;
	}
	
	[Bindable (event='currentObjectChanged')]
	public function get currentObject():XML {
		
		return _currentObject;
	}
	
	[Bindable (event='currentObjectChanged')]
	public function get currentObjectId():String {
		
		return _currentObject.@ID;
	}
	
	public function getTypeByTypeId(typeId:String):XML {
		
		return _listTypes.Information.(ID == typeId)[0].parent();
	}
	
	public function getTypeByObjectId(objectId:String):XML {
		
		var typeId:String = getObject(objectId).@Type;
		return getTypeByTypeId(typeId)[0];
	}
	
	public function getTopLevelTypes():XMLList {
		
		var listTopLeveltTypes:XMLList = new XMLList();
		
		for each (var element:XML in _listTypes.Information.(Container == 3))
			listTopLeveltTypes += element.parent();
		
		return listTopLeveltTypes;
	}
	
	public function getObject(objectId:String):XML {
		
		var object:XMLList = _currentApplication..Objects.Object.(@ID == objectId);
		return object[0];
	}
	
	
	
// ----------------------- start init action -----------------------

	public function init():void {
		
		soap.addEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
		soap.listApplications();
	}
	
	private function listApplicationHandler(event:SoapEvent):void {

		_listApplication = event.result.*;
		
		soap.removeEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
		
		dispatchEvent(new Event('listApplicationChanged'));
		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.INIT_COMPLETE));
	}	
	
// ----------------------- end init action -----------------------
	
	
	public function loadApplicationData():void {
		
		soap.addEventListener(SoapEvent.GET_TOP_OBJECTS_OK, loadApplicationDataHandler);
		soap.getTopObjects(_currentApplicationId);
	}
	
	private function loadApplicationDataHandler(event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.GET_TOP_OBJECTS_OK, loadApplicationDataHandler);
		
		var pages:XMLList = event.result.Objects.Object;
		
		_currentApplication.appendChild(<Objects />);
		
		delete pages.Parent;
		
		if(pages.length() > 0) {
		
			_currentApplication.Objects[0].appendChild = pages;
			changeCurrentPage(pages[0].@ID);
			
		} else
			changeCurrentPage(null);
		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.APPLICATION_DATA_LOADED));
	}
	
	public function loadTypes():void {
		
		soap.addEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
		soap.getAllTypes();
	}
	
	private function getAllTypesHandler(event:SoapEvent):void {
	
		_listTypes = event.result.*;
		_typeLoaded = true;
		soap.removeEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
		languageManager.parseLanguageData(_listTypes);
		dispatchEvent(new DataManagerEvent(DataManagerEvent.TYPES_LOADED));
	}
	
	public function changeCurrentApplication(applicationId:String):void {
		
		var application:XML = new XML(_listApplication.(@ID == applicationId)[0]);
		
		if(application && application.Information.Name) {
			
			_currentApplicationId = applicationId;
			_currentApplication = application;
			dispatchEvent(new DataManagerEvent('currentApplicationChanged'));
		}
	}
	
	public function changeCurrentPage(pageId:String):void {
		
		if(!pageId) {
			
			_currentPageId = null
			_currentPage = null;
			
		} else {
			
			soap.addEventListener(SoapEvent.GET_CHILD_OBJECTS_TREE_OK, changeCurrentPageHandler);
			soap.getChildObjectsTree(_currentApplicationId, pageId);
		}
	}
	
	/**
	 * Получение результатов запроса всех объектов верхнего уровня. 
	 * Попытка загрузить всех потомков объекта верхнего уровня
	 * @param event
	 * 
	 */	
	
 	private function changeCurrentPageHandler(event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.GET_CHILD_OBJECTS_TREE_OK, changeCurrentPageHandler);
		
		var pageData:XML = event.result;
		var pageId:String = pageData.@ID;
		
		_currentApplication.Objects.Object.(@ID == pageId)[0] = pageData;
		
		_currentPageId = pageId;
		
		changeCurrentObject(pageId);
		
		dispatcher.dispatchEvent(new DataManagerEvent('listPagesChanged'));
		dispatcher.dispatchEvent(new DataManagerEvent('currentPageChanged'));
		dispatchEvent(new DataManagerEvent(DataManagerEvent.PAGE_DATA_LOADED));
	}
	
	/**
	 * 
	 * @param objectId идентификатор объекта
	 * @return все данные об объекте, в т.ч. описание его типа.
	 * 
	 */	
	public function changeCurrentObject(objectId:String):void {
		
		if(!objectId)
			_currentObject = null;
			
		else {
			
			var newObject:XML = new XML(getObject(objectId));
			var type:XML = getTypeByObjectId(objectId);
			newObject.appendChild(type);
			
			_currentObject = newObject;
		} 
			
		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.CURRENT_OBJECT_CHANGED));
	}
	
	
	
	/**
	 * 
	 * @param selectedObjects описание типа объекта, которое надо сохранить, для последующей отправки на сервер.
	 * 
	 */	
	public function updateAttributes(newObjectId:String = 'none', attributes:XML = null):void {
		
		var objectId:String;
		var newXMLDescription:XML;
		var newListAttributes:XMLList;
		
		if(newObjectId != 'none') {
			
			objectId = newObjectId;
			newXMLDescription = getObject(newObjectId);
			newListAttributes = attributes.Attribute;
			
		} else {
			
			objectId = _currentObject.@ID;
			newXMLDescription = _currentObject;
			newListAttributes = newXMLDescription.Attributes.Attribute;
		}
			
		var oldXMLDescription:XML = getObject(objectId);
		var oldListAttributes:XMLList = oldXMLDescription.Attributes.Attribute
		
		var newOnlyAttributes:XML = extractNewValues(
										oldListAttributes,
										newListAttributes
									);
		
		var nameChanged:Boolean = false;
		var attrChanged:Boolean = false;
		
		if(oldXMLDescription.@Name != newXMLDescription.@Name)
			nameChanged = true;
		
		if(newOnlyAttributes) {
			
			requestQue[objectId] = 'empty key';
			
			
			proxy.setAttributes(_currentApplicationId, objectId, newOnlyAttributes);
		}
		
		if(nameChanged) {
			
			oldXMLDescription.@Name = newXMLDescription.@Name;
			
			soap.addEventListener(SoapEvent.SET_NAME_OK, setNameCompleteHandler);
			soap.setName(_currentApplicationId, oldXMLDescription.@ID, oldXMLDescription.@Name);
		}
		
	}
	
	private function setNameCompleteHandler(event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.SET_NAME_OK, setNameCompleteHandler);
		
		var objectId:String = event.result.@ID;
		
		var result:XML = getObject(objectId);
		
		var dmEvent:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
		
		
		dmEvent.objectId = objectId
		dmEvent.result = <Result> {result} </Result>;
		dispatchEvent(dmEvent);
	}
	
	private function setAttributesCompleteHandler(event:ProxyEvent):void {
		
		//proxy.removeEventListener(ProxyEvent.PROXY_COMPLETE, setAttributesCompleteHandler);
		var key:String = event.xml.Key[0];
		var objectId:String = event.xml.Object[0].@ID;
		var attributes:XML = event.xml.Object.Attributes[0];
		
		var object:XML = getObject(objectId);
		object.Attributes[0] = new XML(attributes);
		
		var newObject:XML = new XML(object);
		var type:XML = getTypeByObjectId(objectId);
		newObject.appendChild(type);
		
		_currentObject = newObject;
			
		if(requestQue[objectId] !== null && requestQue[objectId] == key) {
			
			delete requestQue[objectId];
			var dmEvent:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
			dmEvent.objectId = event.xml.Object.@ID;
			dmEvent.result = event.xml;
			dispatchEvent(dmEvent);
		}
		dispatchEvent(new Event('currentObjectChanged'));
		
	}
	
	public function deleteObject(objectId:String):void {
		
		
		soap.addEventListener(SoapEvent.DELETE_OBJECT_OK, objectDeletedHandler);
		soap.deleteObject(_currentApplicationId, objectId);
		
	}
	
	private function objectDeletedHandler (event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.DELETE_OBJECT_OK, objectDeletedHandler);
		
		var objectID:String = event.result;
		
		delete getObject(objectID);
		
		if(objectID == _currentPageId)
			changeCurrentPage(null);
		
		if(objectID == currentObjectId)
			changeCurrentObject(null);
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.OBJECT_DELETED);
		dme.objectId = event.result;
		dispatchEvent(dme);
	}
	
	public function getApplicationStructure():void {
		
		soap.addEventListener(SoapEvent.GET_APPLICATION_STRUCTURE_OK, getApplicationStructureHandler);
		soap.getApplicationStructure(_currentApplicationId);
	}
	
	private function getApplicationStructureHandler(event:SoapEvent):void {
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.STRUCTURE_LOADED);
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	public function setApplactionStructure(struct:XML):void {
		
		soap.addEventListener(SoapEvent.SET_APPLICATION_STRUCTURE_OK, setApplicationStructureHandler);
		soap.setApplicationStructure(_currentApplicationId, struct);
	}
	
	private function setApplicationStructureHandler(event:SoapEvent):void {
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.STRUCTURE_SAVED);
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	public function getObjectXMLScript():void {
		
		soap.addEventListener(SoapEvent.GET_OBJECT_SCRIPT_PRESENTATION_OK, getObjectXMLScriptHandler);
		soap.getObjectScriptPresentation(currentApplicationId, currentObjectId)
		
	}
	
	private function getObjectXMLScriptHandler(event:SoapEvent):void {
		
		var result:XML = event.result.*[0];
		dispatchEvent(new DataManagerEvent(DataManagerEvent.OBJECT_XML_SCRIPT_LOADED, result));
	}
	
	/**
	 * 
	 * @param objectId идентификатор объекта
	 * @return XML описание объекта.
	 * 
	 */	
	
	public function createApplication(name:String, description:String):void {
		
		var applicationAttributes:XML = 
			<Attributes>
				<Name>{name}</Name>
				<Description>{description}</Description>
			</Attributes>
		
		soap.addEventListener(SoapEvent.CREATE_APPLICATION_OK, createApplicationHandler);
		soap.createApplication(applicationAttributes);
	}
	
	private function createApplicationHandler(event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.CREATE_APPLICATION_OK, createApplicationHandler);
		
		_listApplication += event.result.Application[0];
		
		dispatcher.dispatchEvent(new DataManagerEvent('listApplicationChanged'));
		dispatcher.dispatchEvent(new DataManagerEvent(DataManagerEvent.APPLICATION_CREATED));
	}
	
	
	/**
	 * Создание нового объекта.
	 * @param initProp Начальные свойства объекта (идентификатор типа, координаты).
	 * @return идентификатор объекта
	 * 
	 */	
	public function createObject(typeId:String, parentId:String = '', objectName:String = '', attributes:String = ''):void {
		
		soap.addEventListener(SoapEvent.CREATE_OBJECT_OK, createObjectCompleteHandler);
		soap.createObject(_currentApplicationId, parentId, typeId, attributes, objectName);
	}
	
	private function createObjectCompleteHandler(event:SoapEvent):void {
		
		var result:XML = event.result;
		var parentId:String = result.Object.Parent;
		
		if(!parentId)
			_currentApplication.Objects.appendChild(result.Object[0]);
			
		else {
			
			var parentObject:XML = getObject(parentId);
		
			var newObject:XML = new XML(result.Object);
			delete newObject.Parent
			
			parentObject.Objects.appendChild(newObject);
		}

		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.OBJECTS_CREATED);
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	private function proxySendedHandler(event:ProxyEvent):void {
		
		var objectId:String = event.objectId;
		var key:String = event.key;
		
		if(requestQue[objectId] !== null) {
			requestQue[objectId] = key;
		}
	}
	
	private function extractNewValues(oldAttributes:XMLList, newAttributes:XMLList):XML {
		
		var newOnlyAttributes:XML = <Attributes />
		
		for each(var attr:XML in newAttributes) {
			
			if(oldAttributes.(@Name == attr.@Name) != attr) {	
				newOnlyAttributes.item += attr;
			} 
		}
		
		if(newOnlyAttributes.*.length() > 0)
			return newOnlyAttributes;
		else
			return null;
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