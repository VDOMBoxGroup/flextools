package vdom.managers {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.controls.Alert;
import mx.rpc.events.FaultEvent;

import vdom.connection.Proxy;
import vdom.connection.SOAP;
import vdom.events.DataManagerEvent;
import vdom.events.ProxyEvent;
import vdom.events.SOAPEvent;

public class DataManager implements IEventDispatcher {
	
	private static var instance:DataManager;
	
	private var soap:SOAP = SOAP.getInstance();
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
	public static function getInstance():DataManager
	{
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
			
		soap.get_application_info.addEventListener(
			SOAPEvent.RESULT,
			soap_getApplicationInfoHandler
		);
		
		soap.get_application_info.addEventListener(
			FaultEvent.FAULT,
			soap_getApplicationInfoHandler
		);
		
		soap.get_application_info(applicationId);
	}
	
	private function soap_getApplicationInfoHandler(event:SOAPEvent):void
	{
		soap.get_application_info.removeEventListener(
			SOAPEvent.RESULT,
			soap_getApplicationInfoHandler
		);
		
		soap.get_application_info.removeEventListener(
			FaultEvent.FAULT, 
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
		
		soap.list_applications.addEventListener(SOAPEvent.RESULT, listApplicationHandler);
		soap.list_applications();
	}
	
	private function listApplicationHandler(event:SOAPEvent):void
	{
		soap.list_applications.removeEventListener(SOAPEvent.RESULT, listApplicationHandler);
		
		var tempApplicationList:XMLList = event.result.Applications.*;
		
		for each(var applicationNode:XML in tempApplicationList)
		{
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
		soap.get_all_types.addEventListener(SOAPEvent.RESULT, getAllTypesHandler);
		soap.get_all_types();
	}
	
	private function getAllTypesHandler(event:SOAPEvent):void
	{
		soap.get_all_types.removeEventListener(SOAPEvent.RESULT, getAllTypesHandler);
		
		_listTypes = event.result.Types.*;
		_typeLoaded = true;
		
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
		
		soap.get_top_objects.addEventListener(SOAPEvent.RESULT, loadApplicationHandler);
		soap.get_top_objects(applicationId);
	}
	
	private function loadApplicationHandler(event:SOAPEvent):void
	{
		soap.get_top_objects.removeEventListener(SOAPEvent.RESULT, loadApplicationHandler);
		
		var pages:XMLList = event.result.Objects.Object;
		
		if(_currentApplication.Objects.length() > 0)
			delete _currentApplication.Objects;
			
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
			soap.get_child_objects_tree(_currentApplicationId, pageId);
		}
	}
	
	/**
	 * Получение результатов запроса всех объектов верхнего уровня. 
	 * Попытка загрузить всех потомков объекта верхнего уровня
	 * @param event
	 * 
	 */	
	
 	private function getChildObjectsTreeHandler(event:SOAPEvent):void
 	{
		var objectData:XML = event.result.Object[0];
		var objectId:String = objectData.@ID;
		
		var currObj:XML = _currentApplication..Objects.Object.(@ID == objectId)[0];
		
		_currentApplication..Objects.Object.(@ID == objectId)[0] = new XML(objectData);
		
		var isPage:Boolean = false;
		
		if(listPages && listPages.(@ID == objectId)[0])
			isPage = true;
		
		if(currObj) {
		
			if(isPage)
			{
				_currentPageId = objectId;
				_currentObject = null;
				dispatchEvent(new DataManagerEvent("currentPageChanged"));
				dispatchEvent(new DataManagerEvent(DataManagerEvent.PAGE_DATA_LOADED));
			}
			
			
			if(objectData && objectData.Type.length() == 0)
			{
				var type:XML = getTypeByObjectId(objectId);
				objectData.appendChild(type);
			}
			
			_currentObject = objectData;
			
			dispatchEvent(new Event("listPagesChanged"));
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
			
			if(newObject && newObject.Type.length() == 0)
			{
				var type:XML = getTypeByObjectId(objectId);
				newObject.appendChild(type);
			}
			
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
			
			soap.set_name.addEventListener(SOAPEvent.RESULT, setNameCompleteHandler);
			soap.set_name.addEventListener(FaultEvent.FAULT, setNameFaultHandler);
			soap.set_name(_currentApplicationId, oldXMLDescription.@ID, oldXMLDescription.@Name);
		}
	}
	
	private function setNameCompleteHandler(event:SOAPEvent):void
	{
		soap.set_name.removeEventListener(SOAPEvent.RESULT, setNameCompleteHandler);
		soap.set_name.removeEventListener(FaultEvent.FAULT, setNameCompleteHandler);
		
		if(event.result.Error[0])
			Alert.show(event.result.Error[0], "Alert");
		
		var objectId:String = event.result.Object.@ID;
		
		var result:XML = getObject(objectId);
		
		if(result)
			result.@Name = event.result.Object.@Name;
		
		if(_currentObject && _currentObject.@ID == objectId)
			_currentObject.@Name = event.result.Object.@Name;
		
		dispatchEvent(new Event("currentObjectRefreshed"));
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
		
		dme.objectId = objectId
		dme.result = <Result>{result}</Result>;
		dispatchEvent(dme);
		
		dme = new DataManagerEvent(DataManagerEvent.LIST_PAGES_CHANGED);
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	private function setNameFaultHandler(event:FaultEvent):void
	{
		Alert.show(event.fault.faultString, "Alert");
		
		var description:XML = XML(event.fault.faultDetail);
		
		var objectId:String = description.@ID;
		
		var result:XML = getObject(objectId);
		
		if(result)
			result.@Name = description.@Name;
		
		if(_currentObject && _currentObject.@ID == objectId)
			_currentObject.@Name = description.@Name;
		
		dispatchEvent(new Event("currentObjectRefreshed"));
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
		
		dme.objectId = objectId;
		dme.result = <Result>{description}</Result>;
		dispatchEvent(dme);
		
		dme = new DataManagerEvent(DataManagerEvent.LIST_PAGES_CHANGED);
		dme.result = <Result>description</Result>;
		dispatchEvent(dme);
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
			
			if(newObject && newObject.Type.length() == 0)
			{
				var type:XML = getTypeByObjectId(objectId);
				newObject.appendChild(type);
			}
			
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
		soap.search.addEventListener(SOAPEvent.RESULT, searchHandler);
		soap.search(applicationId, searchString);
	}
	
	private function searchHandler(event:SOAPEvent):void
	{
		soap.search.removeEventListener(SOAPEvent.RESULT, searchHandler);
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.SEARCH_COMPLETE);
		dme.result = event.result.SearchResult[0];
		dispatchEvent(dme);
	}
	
	public function modifyResource(resourceId:String, operation:String, attributeName:String, attributes:XML):void
	{
		soap.modify_resource.addEventListener(SOAPEvent.RESULT, modifyResourceHandler);
		soap.modify_resource(_currentApplicationId, currentObjectId, resourceId, attributeName, operation, attributes);
	}
	
	private function modifyResourceHandler(event:SOAPEvent):void
	{
		soap.modify_resource.removeEventListener(SOAPEvent.RESULT, modifyResourceHandler);
		
		var objectId:String = event.result.Object[0].@ID;
		var attributes:XML = event.result.Object.Attributes[0];
		
		var object:XML = getObject(objectId);
		object.Attributes[0] = new XML(attributes);
		
		if(_currentObject && _currentObject.@ID == objectId) {
			
			var newObject:XML = new XML(object);
			
			if(newObject && newObject.Type.length() == 0)
			{
				var type:XML = getTypeByObjectId(objectId);
				newObject.appendChild(type);
			}
			
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
			
		soap.get_application_structure.addEventListener(SOAPEvent.RESULT, getApplicationStructureHandler);
		soap.get_application_structure(applicationId);
	}
	
	private function getApplicationStructureHandler(event:SOAPEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.STRUCTURE_LOADED);
		dme.result = event.result.Structure[0];
		dispatchEvent(dme);
	}
	
	public function setApplactionStructure(struct:XML):void
	{
		soap.set_application_structure.addEventListener(SOAPEvent.RESULT, setApplicationStructureHandler);
		soap.set_application_structure(_currentApplicationId, struct.toXMLString());
	}
	
	private function setApplicationStructureHandler(event:SOAPEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.STRUCTURE_SAVED);
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	public function getObjectXMLScript():void
	{
		soap.get_object_script_presentation.addEventListener(
			SOAPEvent.RESULT,
			getObjectXMLScriptHandler
		);
		
		soap.get_object_script_presentation(currentApplicationId, currentObjectId)
	}
	
	private function getObjectXMLScriptHandler(event:SOAPEvent):void
	{
		soap.get_object_script_presentation.removeEventListener(
			SOAPEvent.RESULT,
			getObjectXMLScriptHandler
		);
		
		var result:XML = event.result.Result.*[0];
		dispatchEvent(new DataManagerEvent(DataManagerEvent.OBJECT_XML_SCRIPT_LOADED, result));
	}
	
	public function setObjectXMLScript(objectXMLScript:String):void
	{
		soap.submit_object_script_presentation.addEventListener(
			SOAPEvent.RESULT,
			setObjectXMLScriptHandler
		);
		
		soap.submit_object_script_presentation(currentApplicationId, currentObjectId, objectXMLScript);
	}
	
	private function setObjectXMLScriptHandler(event:SOAPEvent):void
	{
		soap.submit_object_script_presentation.removeEventListener(
			SOAPEvent.RESULT, 
			setObjectXMLScriptHandler
		);
		
		var result:XML = event.result;
		
		var oldObjectId:String = result.IDOld;
		var newObjectId:String = result.IDNew;
		
		_currentApplication..Objects.Object.(@ID == oldObjectId)[0] = <Object ID={newObjectId} />;
		
		soap.get_child_objects_tree(currentApplicationId, newObjectId); //<----
		dispatchEvent(new DataManagerEvent(DataManagerEvent.OBJECT_XML_SCRIPT_SAVED, result));
		
//		var dmEvent:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
//		dmEvent.objectId = newObjectId;
//		dmEvent.result = event.xml;
//		dispatchEvent(dmEvent);
	}
	
	/**
	 * 
	 * @param objectId идентификатор объекта
	 * @return XML описание объекта.
	 * 
	 */	
	
	public function createApplication():void
	{
		soap.create_application.addEventListener(
			SOAPEvent.RESULT,
			createApplicationHandler
		);
		
		soap.create_application(
			<Information>
				<Active>1</Active>
			</Information>
		);
	}
	
	private function createApplicationHandler(event:SOAPEvent):void
	{
		soap.create_application.removeEventListener(
			SOAPEvent.RESULT,
			createApplicationHandler
		);
		
		_listApplication += event.result.Application[0];
		
		dispatchEvent(new DataManagerEvent("listApplicationChanged"));
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.APPLICATION_CREATED);
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	public function setApplicationInformation(applicationId:String, attributes:XML):void
	{
		soap.set_application_info.addEventListener(
			SOAPEvent.RESULT,
			setApplicationInfoHandler
		);
		
		soap.set_application_info(applicationId, attributes);
	}
	
	private function setApplicationInfoHandler(event:SOAPEvent):void
	{
		soap.set_application_info.removeEventListener(
			SOAPEvent.RESULT,
			setApplicationInfoHandler
		);
		
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
		
		soap.create_object.addEventListener(
			SOAPEvent.RESULT,
			createObjectCompleteHandler
		);
		
		if(applicationId)
			soap.create_object(applicationId, parentId, typeId, objectName, attributes);
		else if (_currentApplicationId)
			soap.create_object(_currentApplicationId, parentId, typeId, objectName, attributes);
	}
	
	private function createObjectCompleteHandler(event:SOAPEvent):void
	{
		soap.create_object.removeEventListener(
			SOAPEvent.RESULT,
			createObjectCompleteHandler
		);
		
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
		
		dme = new DataManagerEvent(DataManagerEvent.LIST_PAGES_CHANGED);
		dme.result = event.result;
		dispatchEvent(dme);
		
	}
	
	public function deleteObject(objectId:String):void
	{
		soap.delete_object.addEventListener(
			SOAPEvent.RESULT,
			objectDeletedHandler
		);
		
		soap.delete_object(_currentApplicationId, objectId);
	}
	
	private function objectDeletedHandler (event:SOAPEvent):void
	{
		soap.delete_object.removeEventListener(
			SOAPEvent.RESULT,
			objectDeletedHandler
		);
		
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
		
		soap.get_script.addEventListener(
			SOAPEvent.RESULT,
			soap_getScriptHandler
		);
		
		soap.get_script(applicationId, objectId, language);
	}
	
	private function soap_getScriptHandler(event:SOAPEvent):void
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
		
		soap.set_script.addEventListener(
			SOAPEvent.RESULT,
			soap_setScriptHandler
		);
		
		soap.set_script(applicationId, objectId, script, language);
	}
	
	private function soap_setScriptHandler(event:SOAPEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.OBJECT_SCRIPT_SAVED);
		dme.result = event.result.Result[0];
		
		dispatchEvent(dme);
	}
	
	public function getApplicationEvents(objectId:String):void
	{
		if(!objectId)
			return;
		
		soap.get_application_events.addEventListener(
			SOAPEvent.RESULT,
			soap_getApplicationEventsHandler
		);
		
		soap.get_application_events(_currentApplicationId, objectId); 
	}
	
	private function soap_getApplicationEventsHandler(event:SOAPEvent):void
	{
		soap.get_application_events.removeEventListener(
			SOAPEvent.RESULT,
			soap_getApplicationEventsHandler
		);
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.APPLICATION_EVENT_LOADED)
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	public function setApplicationEvents(objectId:String, eventsValue:String):void
	{
		if(!objectId)
			return;
		
		soap.set_application_events.addEventListener(
			SOAPEvent.RESULT,
			soap_setApplicationEventsHandler
		);
		
		soap.set_application_events(_currentApplicationId, objectId, eventsValue); 
	}
	
	private function soap_setApplicationEventsHandler(event:SOAPEvent):void
	{
		soap.set_application_events.removeEventListener(
			SOAPEvent.RESULT,
			soap_getApplicationEventsHandler
		);
		
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
			soap.get_child_objects_tree.addEventListener(
				SOAPEvent.RESULT,
				getChildObjectsTreeHandler
			);
			
			proxy.addEventListener(ProxyEvent.PROXY_SEND, proxySendedHandler);
			proxy.addEventListener(ProxyEvent.PROXY_COMPLETE, setAttributesCompleteHandler);
			
		}
		else
		{
			soap.get_child_objects_tree.removeEventListener(
				SOAPEvent.RESULT,
				getChildObjectsTreeHandler
			);
			
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