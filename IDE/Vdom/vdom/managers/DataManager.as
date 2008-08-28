package vdom.managers {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.controls.Alert;

import vdom.connection.Proxy;
import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.events.DataManagerEvent;
import vdom.events.ProxyEvent;

public class DataManager implements IEventDispatcher {
	
	private static var instance:DataManager;
	
	private var soap:Soap = Soap.getInstance();
	private var proxy:Proxy = Proxy.getInstance();
	private var languageManager:LanguageManager = LanguageManager.getInstance();
	
	private var dispatcher:EventDispatcher = new EventDispatcher();
	
	private var _listApplication:XMLList;
	private var _listTypes:XMLList;
	
	private var _typeLoaded:Boolean = false;
		
	private var _currentApplication:XML;
	private var _currentApplicationId:String;
	
	private var _currentPage:XML;
	private var _currentPageId:String;
	
	private var _currentObject:XML;
	
	private var requestQue:Object = {};

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
	public function DataManager()
	{
		if (instance)
			throw new Error("Instance already exists.");
	}
	
	[Bindable (event="listApplicationChanged")]
	public function get listApplication():XMLList
	{
		return _listApplication;
	}
	
	[Bindable (event="listPagesChanged")]
	public function get listPages():XMLList
	{
		if(!_currentApplication)
			return null;
		
		if(_currentApplication.Objects.Object.length())
			return new XMLList(_currentApplication.Objects.Object);
		else
			return null
	}
	
	public function get listTypes():XMLList
	{
		return _listTypes;
	}
	
	public function get typeLoaded():Boolean
	{
		return _typeLoaded;
	}
	
	[Bindable (event="applicationChanged")]
	public function get currentApplicationId():String
	{
		return _currentApplicationId;	
	}
	
	[Bindable (event="applicationInfoChanged")]
	public function get currentApplicationInformation():XML
	{
		if(_currentApplicationId)
			return _listApplication.(@ID == _currentApplicationId).Information[0];
		else
			return null;
	}
	
	[Bindable (event="currentPageChanged")]
	public function get currentPageId():String
	{
		return _currentPageId;
	}
	
	[Bindable (event="currentObjectRefreshed")]
	public function get currentObject():XML
	{
		return _currentObject;
	}
	
	[Bindable (event="currentObjectChanged")]
	public function get currentObjectId():String
	{
		if(_currentObject)
			return _currentObject.@ID;
		else
			return null;
	}
	
	public function getApplicationInformation(applicationId:String = ""):void
	{
		if(applicationId == "")
			applicationId = _currentApplicationId;
			
		soap.addEventListener(SoapEvent.GET_APLICATION_INFO_OK, soap_getApplicationInfoHandler);
		soap.addEventListener(SoapEvent.GET_APLICATION_INFO_ERROR, soap_getApplicationInfoHandler);
		soap.getApplicationInfo(applicationId);
	}
	
	private function soap_getApplicationInfoHandler(event:SoapEvent):void
	{
		soap.removeEventListener(
			SoapEvent.GET_APLICATION_INFO_OK,
			soap_getApplicationInfoHandler
		);
		
		soap.removeEventListener(
			SoapEvent.GET_APLICATION_INFO_ERROR, 
			soap_getApplicationInfoHandler
		);
		
		var result:XML = event.result.Information[0];
		
		if(!result)
			return;
		
		var applicationId:String = result.Id;
		
		var application:XML = _listApplication.(@ID == applicationId)[0]
		if(application)
			application.Information[0] = result;
		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.APPLICATION_INFO_CHANGED));
	}
	
	public function getTypeByTypeId(typeId:String):XML 
	{
		if(typeId)
			return _listTypes.Information.(ID == typeId)[0].parent();
		else
			return null;
	}
	
	public function getTypeByObjectId(objectId:String):XML
	{
		var object:XML = getObject(objectId);
		
		if(!object)
			return null;
		
		var type:XML = getTypeByTypeId(object.@Type);
		
		if(!type)
			return null
			 
		return type[0];
	}
	
	public function getTopLevelTypes():XMLList
	{
		var listTopLeveltTypes:XMLList = new XMLList();
		
		for each (var element:XML in _listTypes.Information.(Container == 3))
			listTopLeveltTypes += element.parent();
		
		return listTopLeveltTypes;
	}
	
	public function getObject(objectId:String):XML
	{
		var object:XMLList = _currentApplication..Objects.Object.(@ID == objectId);
		return object[0];
	}	
	
// ----------------------- start init action -----------------------

	public function init():void
	{	
		registerEvent(true);
		
		soap.addEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
		soap.listApplications();
	}
	
	private function listApplicationHandler(event:SoapEvent):void
	{
		soap.removeEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
		
		var tempApplicationList:XMLList = event.result.Applications.*;
		
		for each(var applicationNode:XML in tempApplicationList) {
			
			applicationNode.@Name = applicationNode.Information.Name[0];
			applicationNode.@IconID = applicationNode.Information.Icon[0];
			applicationNode.@Status = "";
		}
		_listApplication = tempApplicationList;
		
		dispatchEvent(new Event("listApplicationChanged"));
		dispatchEvent(new DataManagerEvent(DataManagerEvent.INIT_COMPLETE));
	}	
	
// ----------------------- end init action -----------------------
	
// ----------------------- start close action -----------------------

	public function close():void
	{
		registerEvent(false);
		
		requestQue = {};
		
		_currentApplication = null;
		_currentApplicationId = null;
		_currentPageId = null;
		_currentObject = null;
		_typeLoaded = false;
		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.CLOSE));
	}

// ----------------------- end close action -----------------------
	
	public function loadTypes():void
	{
		soap.addEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
		soap.getAllTypes();
	}
	
	private function getAllTypesHandler(event:SoapEvent):void
	{
		_listTypes = event.result.Types.*;
		_typeLoaded = true;
		soap.removeEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
		languageManager.parseLanguageData(_listTypes);
		dispatchEvent(new DataManagerEvent(DataManagerEvent.TYPES_LOADED));
	}
	
	public function applicationStatus(applicationId:String):Boolean
	{
		if(!applicationId && _currentApplicationId)
			applicationId = _currentApplicationId;
		
		var application:XML = _listApplication.(@ID == applicationId)[0];
		
		if(application && application.@Status == "loaded")
			return true;
			
		else
			return false;
	}
	
	public function pageStatus(applicationId:String, pageId:String):Boolean
	{
		
		var application:XML = _listApplication.(@ID == applicationId)[0];
		
		if(!application || !application.@Status == "loaded")
			return false;
			
		var page:XML = application.Objects.Object.(@ID == pageId)[0];
		
		if(page && page.@Status == "loaded")
			return true;
			
		return false; 
	}
	
	public function applicationInformation(applicationId:String = ""):XML
	{
		if(!applicationId)
			return _listApplication.Information.(Id == _currentApplicationId)[0];
		else
			return _listApplication.Information.(Id == applicationId)[0];
	}
	
	public function loadApplication(applicationId:String):void
	{
		if(!applicationId)
			return;
		
		soap.addEventListener(SoapEvent.GET_TOP_OBJECTS_OK, loadApplicationHandler);
		soap.getTopObjects(applicationId);
	}
	
	private function loadApplicationHandler(event:SoapEvent):void
	{
		soap.removeEventListener(SoapEvent.GET_TOP_OBJECTS_OK, loadApplicationHandler);
		
		var pages:XMLList = event.result.Objects.Object;
		
		_currentApplication.appendChild(<Objects />);
		
		delete pages.Parent;
		
		if(pages.length() > 0)		
			_currentApplication.Objects[0].appendChild(pages);
		
		_currentApplication.@Status = "loaded";
		dispatchEvent(new DataManagerEvent(DataManagerEvent.APPLICATION_DATA_LOADED));
	}
	
	public function changeCurrentApplication(applicationId:String):void
	{
		if(_currentApplicationId == applicationId)
			return;
		
		_currentApplicationId = null;
		_currentApplication = null;
		
		_currentPageId = null;
		_currentPage = null;
		
		_currentObject = null;
		
		if(!applicationId)
			return;
		
		_currentApplicationId = _listApplication.(@ID == applicationId).@ID;
		_currentApplication = _listApplication.(@ID == applicationId)[0]
		dispatchEvent(new DataManagerEvent(DataManagerEvent.APPLICATION_CHANGED));
		dispatchEvent(new DataManagerEvent(DataManagerEvent.APPLICATION_INFO_CHANGED));
	}
	
	public function changeCurrentPage(pageId:String):void
	{
		if(!pageId)
		{	
			_currentPageId = null;
			_currentPage = null;
			_currentObject = null;
			
		}
		else
		{
			soap.getChildObjectsTree(_currentApplicationId, pageId);
		}
	}
	
	/**
	 * Получение результатов запроса всех объектов верхнего уровня. 
	 * Попытка загрузить всех потомков объекта верхнего уровня
	 * @param event
	 * 
	 */	
	
 	private function getChildObjectsTreeHandler(event:SoapEvent):void
 	{
		var objectData:XML = event.result.Object[0];
		var objectId:String = objectData.@ID;
		
		var currObj:XML = _currentApplication..Objects.Object.(@ID == objectId)[0];
		
		_currentApplication..Objects.Object.(@ID == objectId)[0] = objectData;
		
		if(_currentApplication.Objects.Object.(@ID == objectId).length() != 0) {
		
			_currentPageId = objectId;
			_currentObject = null;
			
			dispatchEvent(new Event("listPagesChanged"));
			dispatchEvent(new DataManagerEvent("currentPageChanged"));
			dispatchEvent(new DataManagerEvent(DataManagerEvent.PAGE_DATA_LOADED));
			dispatchEvent(new DataManagerEvent(DataManagerEvent.CURRENT_OBJECT_CHANGED));
			dispatchEvent(new DataManagerEvent("currentObjectRefreshed"));
		}
	}
	
	/**
	 * 
	 * @param objectId идентификатор объекта
	 * @return все данные об объекте, в т.ч. описание его типа.
	 * 
	 */	
	public function changeCurrentObject(objectId:String):void
	{
		if(_currentObject && objectId &&_currentObject.@ID[0] == objectId)
			return;
		
		if(!objectId)
			_currentObject = null;
			
		else {
			
			var newObject:XML = new XML(getObject(objectId));
			var type:XML = getTypeByObjectId(objectId);
			newObject.appendChild(type);
			
			_currentObject = newObject;
		} 
		
		dispatchEvent(new DataManagerEvent("currentObjectChanged"));
		dispatchEvent(new DataManagerEvent("currentObjectRefreshed"));
	}
	
	/**
	 * 
	 * @param selectedObjects описание типа объекта, которое надо сохранить, для последующей отправки на сервер.
	 * 
	 */	
	public function updateAttributes(newObjectId:String = "none", attributes:XML = null):void
	{
		var objectId:String;
		var newXMLDescription:XML;
		var newListAttributes:XMLList;
		
		if(newObjectId != "none") {
			
			objectId = newObjectId;
			newXMLDescription = getObject(newObjectId);
			
			if(!newXMLDescription)
				return;
				
			newListAttributes = attributes.Attribute;
			
		} else {
			
			objectId = _currentObject.@ID;
			if(!_currentObject)
				return;
			newXMLDescription = _currentObject;
			newListAttributes = newXMLDescription.Attributes.Attribute;
		}
			
		var oldXMLDescription:XML = getObject(objectId);
		if(!oldXMLDescription)
			return;
		var oldListAttributes:XMLList = oldXMLDescription.Attributes.Attribute
		
		var newOnlyAttributes:XML = extractNewValues(
										oldListAttributes,
										newListAttributes
									);
		
		var nameChanged:Boolean = false;
		var attrChanged:Boolean = false;
		
		if(oldXMLDescription.@Name != newXMLDescription.@Name)
			nameChanged = true;
		
		if(newOnlyAttributes || nameChanged)
		{
			var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_BEGIN)
			dme.result = newOnlyAttributes;
			dispatchEvent(dme);
		}
			
		
		if(newOnlyAttributes)
		{
			requestQue[objectId] = "empty key";	
			proxy.setAttributes(_currentApplicationId, objectId, newOnlyAttributes);
		}
		
		if(nameChanged) {
			
			oldXMLDescription.@Name = newXMLDescription.@Name;
			
			soap.addEventListener(SoapEvent.SET_NAME_OK, setNameCompleteHandler);
			soap.addEventListener(SoapEvent.SET_NAME_ERROR, setNameCompleteHandler);
			soap.setName(_currentApplicationId, oldXMLDescription.@ID, oldXMLDescription.@Name);
		}
	}
	
	private function setNameCompleteHandler(event:SoapEvent):void
	{
		soap.removeEventListener(SoapEvent.SET_NAME_OK, setNameCompleteHandler);
		soap.removeEventListener(SoapEvent.SET_NAME_ERROR, setNameCompleteHandler);
		
		if(event.result.Error[0])
			Alert.show(event.result.Error[0], "Alert");
		
		var objectId:String = event.result.Object.@ID;
		
		var result:XML = getObject(objectId);
		
		if(result)
			result.@Name = event.result.Object.@Name;
		
		if(_currentObject && _currentObject.@ID == objectId)
			_currentObject.@Name = event.result.Object.@Name;
		
		var dmEvent:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
		
		dispatchEvent(new Event("currentObjectRefreshed"));
		
		dmEvent.objectId = objectId
		dmEvent.result = <Result>{result}</Result>;
		dispatchEvent(dmEvent);
	}
	
	private function setAttributesCompleteHandler(event:ProxyEvent):void
	{
		
		
		var key:String = event.xml.Key[0];
		
		var res:String = event.xml.Error;
			// check Error
		if(res != "")
		{
			if(res == "'Application not found'")
				close();
			return;
		}
		
		var objectId:String = event.xml.Object[0].@ID;
		var attributes:XML = event.xml.Object.Attributes[0];
		
		var object:XML = getObject(objectId);
		object.Attributes[0] = new XML(attributes);
		
		if(_currentObject && _currentObject.@ID == objectId) {
		
			var newObject:XML = new XML(object);
			var type:XML = getTypeByObjectId(objectId);
			newObject.appendChild(type);
			
			_currentObject = newObject;
			
			dispatchEvent(new Event("currentObjectRefreshed"));		
		}
		
		if(requestQue[objectId] !== null && requestQue[objectId] == key) {
			
			delete requestQue[objectId];
			var dmEvent:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
			dmEvent.objectId = event.xml.Object.@ID;
			dmEvent.result = event.xml;
			dispatchEvent(dmEvent);
		}
	}
	
	public function search(applicationId:String, searchString:String):void
	{
		soap.addEventListener(SoapEvent.SEARCH_OK, searchHandler);
		soap.search(applicationId, searchString);
	}
	
	private function searchHandler(event:SoapEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.SEARCH_COMPLETE);
		dme.result = event.result.SearchResult[0];
		dispatchEvent(dme);
	}
	
	public function modifyResource(resourceId:String, operation:String, attributeName:String, attributes:XML):void
	{
		soap.addEventListener(SoapEvent.MODIFY_RESOURSE_OK, modifyResourceHandler);
		soap.modifyResource(_currentApplicationId, currentObjectId, resourceId, attributeName, operation, attributes);
	}
	
	private function modifyResourceHandler(event:SoapEvent):void
	{
		soap.removeEventListener(SoapEvent.MODIFY_RESOURSE_OK, modifyResourceHandler);
		
		var objectId:String = event.result.Object[0].@ID;
		var attributes:XML = event.result.Object.Attributes[0];
		
		var object:XML = getObject(objectId);
		object.Attributes[0] = new XML(attributes);
		
		if(_currentObject && _currentObject.@ID == objectId) {
			
			var newObject:XML = new XML(object);
			var type:XML = getTypeByObjectId(objectId);
			newObject.appendChild(type);
			
			_currentObject = newObject;
				
			dispatchEvent(new Event("currentObjectRefreshed"));
		}
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.RESOURCE_MODIFIED);
		dme.result = event.result;
		
		dispatchEvent(dme);
	}
	
	public function getApplicationStructure(applicationId:String = ""):void
	{
		if(applicationId == "")
			applicationId = _currentApplicationId;
			
		soap.addEventListener(SoapEvent.GET_APPLICATION_STRUCTURE_OK, getApplicationStructureHandler);
		soap.getApplicationStructure(applicationId);
	}
	
	private function getApplicationStructureHandler(event:SoapEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.STRUCTURE_LOADED);
		dme.result = event.result.Structure[0];
		dispatchEvent(dme);
	}
	
	public function setApplactionStructure(struct:XML):void
	{
		soap.addEventListener(SoapEvent.SET_APPLICATION_STRUCTURE_OK, setApplicationStructureHandler);
		soap.setApplicationStructure(_currentApplicationId, struct.toXMLString() );
	}
	
	private function setApplicationStructureHandler(event:SoapEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.STRUCTURE_SAVED);
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	public function getObjectXMLScript():void
	{
		soap.addEventListener(SoapEvent.GET_OBJECT_SCRIPT_PRESENTATION_OK, getObjectXMLScriptHandler);
		soap.getObjectScriptPresentation(currentApplicationId, currentObjectId)
	}
	
	private function getObjectXMLScriptHandler(event:SoapEvent):void
	{
		soap.removeEventListener(SoapEvent.GET_OBJECT_SCRIPT_PRESENTATION_OK, getObjectXMLScriptHandler);
		var result:XML = event.result.Result.*[0];
		dispatchEvent(new DataManagerEvent(DataManagerEvent.OBJECT_XML_SCRIPT_LOADED, result));
	}
	
	public function setObjectXMLScript(objectXMLScript:String):void
	{
		soap.addEventListener(SoapEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_OK, setObjectXMLScriptHandler);
		soap.submitObjectScriptPresentation(currentApplicationId, currentObjectId, objectXMLScript);
	}
	
	private function setObjectXMLScriptHandler(event:SoapEvent):void
	{
		soap.removeEventListener(SoapEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_OK, setObjectXMLScriptHandler);
		var result:XML = event.result;
		
		var oldObjectId:String = result.IDOld;
		var newObjectId:String = result.IDNew;
		
		_currentApplication..Objects.Object.(@ID == oldObjectId)[0] = <Object ID={newObjectId} />;
		soap.getChildObjectsTree(currentApplicationId, newObjectId);
//		node[0] = <Object ID={newObjectId} />;
//		deleteXMLNodes()
		dispatchEvent(new DataManagerEvent(DataManagerEvent.OBJECT_XML_SCRIPT_SAVED, result));
//		dispatchEvent(new Event("currentObjectChanged"));
	}
	
	/**
	 * 
	 * @param objectId идентификатор объекта
	 * @return XML описание объекта.
	 * 
	 */	
	
	public function createApplication():void
	{
		soap.addEventListener(SoapEvent.CREATE_APPLICATION_OK, createApplicationHandler);
		soap.createApplication(
			<Information>
				<Active>1</Active>
			</Information>
		);
	}
	
	private function createApplicationHandler(event:SoapEvent):void
	{
		soap.removeEventListener(SoapEvent.CREATE_APPLICATION_OK, createApplicationHandler);
		
		_listApplication += event.result.Application[0];
		
		dispatchEvent(new DataManagerEvent("listApplicationChanged"));
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.APPLICATION_CREATED);
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	public function setApplicationInformation(applicationId:String, attributes:XML):void
	{
		soap.addEventListener(SoapEvent.SET_APLICATION_INFO_OK, setApplicationInfoHandler);
		soap.setApplicationInfo(applicationId, attributes);
	}
	
	private function setApplicationInfoHandler(event:SoapEvent):void
	{
		soap.removeEventListener(SoapEvent.SET_APLICATION_INFO_OK, setApplicationInfoHandler);
		
		var information:XML = event.result.Information[0];
		var applicationId:String = information.Id;
		var application:XML;
		
		if(applicationId)
			application = listApplication.(@ID == applicationId)[0];
			
		if(application)
			application.Information[0] = information;
		
		if(information.Name[0] && application.@Name[0] != information.Name[0])
			application.@Name = information.Name[0];
			
		if(information.Icon[0] && application.@IconID[0] != information.Icon[0])
			application.@IconID = information.Icon[0];
		
		var dme1:DataManagerEvent = new DataManagerEvent(DataManagerEvent.APPLICATION_INFO_SET_COMPLETE);
		dispatchEvent(dme1);
		var dme2:DataManagerEvent = new DataManagerEvent(DataManagerEvent.APPLICATION_INFO_CHANGED);
		dispatchEvent(dme2);
	}
	
	/**
	 * Создание нового объекта.
	 * @param initProp Начальные свойства объекта (идентификатор типа, координаты).
	 * @return идентификатор объекта
	 * 
	 */	
	public function createObject(typeId:String, parentId:String = "", 
								objectName:String = "", attributes:String = "", 
								applicationId:String = ""):void
	{
		proxy.flush();
		soap.addEventListener(SoapEvent.CREATE_OBJECT_OK, createObjectCompleteHandler);
		if(applicationId)
			soap.createObject(applicationId, parentId, typeId, attributes, objectName);
		else if (_currentApplicationId)
			soap.createObject(_currentApplicationId, parentId, typeId, attributes, objectName);
	}
	
	private function createObjectCompleteHandler(event:SoapEvent):void
	{
		soap.removeEventListener(SoapEvent.CREATE_OBJECT_OK, createObjectCompleteHandler);
		
		var result:XML = event.result;
		var parentId:String = result.ParentId;
		
		if(!parentId) {
			
			var applicationId:String = event.result.ApplicationID;
			var application:XML = _listApplication.(@ID == applicationId)[0]
			
			if(application && application.Objects[0]) ///<---- Fix for first page creation in Application Managment !!! 
				application.Objects.appendChild(result.Object[0]);
			
			getApplicationInformation(applicationId);
		}
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
	
	public function deleteObject(objectId:String):void
	{
		soap.addEventListener(SoapEvent.DELETE_OBJECT_OK, objectDeletedHandler);
		soap.deleteObject(_currentApplicationId, objectId);
	}
	
	private function objectDeletedHandler (event:SoapEvent):void
	{
		soap.removeEventListener(SoapEvent.DELETE_OBJECT_OK, objectDeletedHandler);
		
		var objectId:String = event.result.Result;
		
		deleteXMLNodes(objectId);
		
		if(objectId == _currentPageId)
			changeCurrentPage(null);
		
		if(objectId == currentObjectId)
			changeCurrentObject(_currentPageId);
		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.LIST_PAGES_CHANGED));
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.OBJECT_DELETED);
		dme.objectId = objectId;
		dispatchEvent(dme);
		
		getApplicationInformation();
	}
	
	private function deleteXMLNodes(objectId:String):void
	{
		if(!objectId)
			return;
		
		var deleteNodes:XMLList = _currentApplication..Objects.Object.(@ID == objectId)
		
		for (var i:int = deleteNodes.length() - 1; i >= 0; i--)
			delete deleteNodes[i];
	}
	
	public function getObjectScript(objectId:String = ""):void
	{
		if(objectId == "")
			objectId = currentObjectId;
		
		var applicationId:String = _currentApplicationId;
		var language:String = "vbscript";
		
		soap.addEventListener(SoapEvent.GET_SCRIPT_OK, soap_getScriptHandler)
		soap.getScript(applicationId, objectId, language);
	}
	
	private function soap_getScriptHandler(event:SoapEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.OBJECT_SCRIPT_LOADED);
		dme.result = event.result.Result[0];
		
		dispatchEvent(dme);
	}
	
	public function setObjectScript(script:String, objectId:String = ""):void
	{
		if(objectId == "")
			objectId = currentObjectId;
		
		var applicationId:String = _currentApplicationId;
		var language:String = "vbscript";
		
		
		soap.addEventListener(SoapEvent.SET_SCRIPT_OK, soap_setScriptHandler)
		soap.setScript(applicationId, objectId, script, language);
	}
	
	private function soap_setScriptHandler(event:SoapEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.OBJECT_SCRIPT_SAVED);
		dme.result = event.result.Result[0];
		
		dispatchEvent(dme);
	}
	
	public function getApplicationEvents(objectId:String):void
	{
		if(!objectId)
			return;
		
		soap.addEventListener(SoapEvent.GET_APPLICATION_EVENTS_OK, soap_getApplicationEventsHandler);
		soap.getApplicationEvents(_currentApplicationId, objectId); 
	}
	
	private function soap_getApplicationEventsHandler(event:SoapEvent):void
	{
		soap.removeEventListener(SoapEvent.GET_APPLICATION_EVENTS_OK, soap_getApplicationEventsHandler);
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.APPLICATION_EVENT_LOADED)
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	public function setApplicationEvents(objectId:String, eventsValue:String):void
	{
		if(!objectId)
			return;
		
		soap.addEventListener(SoapEvent.SET_APPLICATION_EVENTS_OK, soap_setApplicationEventsHandler);
		soap.setApplicationEvents(_currentApplicationId, objectId, eventsValue); 
	}
	
	private function soap_setApplicationEventsHandler(event:SoapEvent):void
	{
		soap.removeEventListener(SoapEvent.SET_APPLICATION_EVENTS_OK, soap_getApplicationEventsHandler);
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.APPLICATION_EVENT_SAVED)
		dme.result = event.result;
		
		dispatchEvent(dme);
	}
	
	private function proxySendedHandler(event:ProxyEvent):void
	{
		var objectId:String = event.objectId;
		var key:String = event.key;
		
		if(requestQue[objectId] !== null) {
			requestQue[objectId] = key;
		}
	}
	
	private function registerEvent(flag:Boolean):void
	{
		if(flag)
		{
			soap.addEventListener(SoapEvent.GET_CHILD_OBJECTS_TREE_OK, getChildObjectsTreeHandler);
			
			proxy.addEventListener(ProxyEvent.PROXY_SEND, proxySendedHandler);
			proxy.addEventListener(ProxyEvent.PROXY_COMPLETE, setAttributesCompleteHandler);
			
		}
		else
		{
			soap.removeEventListener(SoapEvent.GET_CHILD_OBJECTS_TREE_OK, getChildObjectsTreeHandler);
			
			proxy.removeEventListener(ProxyEvent.PROXY_SEND, proxySendedHandler);
			proxy.removeEventListener(ProxyEvent.PROXY_COMPLETE, setAttributesCompleteHandler);
		}
	}
	
	private function extractNewValues(oldAttributes:XMLList, newAttributes:XMLList):XML
	{
		var newOnlyAttributes:XML = <Attributes />
		var oldAttribute:XML;
		for each(var attr:XML in newAttributes)
		{
			oldAttribute = oldAttributes.(@Name == attr.@Name)[0];
			if(!oldAttribute)
				continue;
			
			if(oldAttribute != attr)
			{	
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
	public function addEventListener(type:String, listener:Function, 
		useCapture:Boolean = false, priority:int = 0, 
		useWeakReference:Boolean = false):void 
	{
			dispatcher.addEventListener(type, listener, useCapture, priority);
    }
    
    /**
     *  @private
     */
    public function dispatchEvent(event:Event):Boolean
    {
        return dispatcher.dispatchEvent(event);
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
    public function removeEventListener(type:String, listener:Function, 
    	useCapture:Boolean = false):void
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