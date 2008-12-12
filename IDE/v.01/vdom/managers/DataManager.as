package vdom.managers {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.rpc.events.FaultEvent;

import vdom.connection.Proxy;
import vdom.connection.SOAP;
import vdom.events.DataManagerErrorEvent;
import vdom.events.DataManagerEvent;
import vdom.events.ProxyEvent;
import vdom.events.SOAPEvent;
import vdom.utils.StringUtil;

public class DataManager implements IEventDispatcher {
	
	include "includes/dataManager.as";
	
	private static var instance:DataManager;
	
	private var soap:SOAP = SOAP.getInstance();
	private var proxy:Proxy = Proxy.getInstance();
	private var languageManager:LanguageManager = LanguageManager.getInstance();
	
	private var dispatcher:EventDispatcher = new EventDispatcher();
	
	private var _listApplication:XMLList;
	private var _listTypes:XMLList;
		
	private var _currentApplication:XML;
	private var _currentPageId:String;
	
	private var _currentObject:XML;
	
	private var requestQue:Object = {};
	
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
	
	[Bindable (event="currentApplicationIdChanged")]
	public function get currentApplicationId():String
	{
		if(_currentApplication)
			return _currentApplication.@ID;
		else
			return null;	
	}
	
	[Bindable (event="currentApplicationInformationChanged")]
	public function get currentApplicationInformation():XML
	{
		if(currentApplicationId)
			return _listApplication.(@ID == currentApplicationId).Information[0];
		else
			return null;
	}
	
	[Bindable (event="currentPageIdChanged")]
	public function get currentPageId():String
	{
		return _currentPageId;
	}
	
	[Bindable (event="currentObjectIdChanged")]
	public function get currentObjectId():String
	{
		if(_currentObject)
			return _currentObject.@ID;
		else
			return null;
	}
	
	[Bindable (event="currentObjectChanged")]
	public function get currentObject():XML
	{
		return _currentObject;
	}
// ----------------------- start init action -----------------------

	public function init():void
	{	
		registerEvent(true);
		
		requestQue = {};
		
		_currentApplication = null;
		_currentPageId = null;
		_currentObject = null;

		soap.list_applications();
	}
	
// ----------------------- end init action -----------------------
	
// ----------------------- start close action -----------------------

	public function close():void
	{
		registerEvent(false);
		
		requestQue = {};
		
		_currentApplication = null;
		_currentPageId = null;
		_currentObject = null;
		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.CLOSE));
	}

// ----------------------- end close action -----------------------
	
	public function createApplication():void
	{
		soap.create_application(
			<Information>
				<Active>1</Active>
			</Information>
		);
	}
	
	public function loadApplication(applicationId:String):void
	{
		if(!applicationId)
			return;
		
		soap.get_top_objects(applicationId);
	} 
	
	public function changeCurrentApplication(applicationId:String):void
	{
		if(currentApplicationId == applicationId)
			return;
		
		_currentApplication = null;
		_currentPageId = null;
		_currentObject = null;
		
		if(!applicationId)
			return;
		
		_currentApplication = _listApplication.(@ID == applicationId)[0]
		
		dispatchEvent(new Event("currentApplicationIdChanged"));
		dispatchEvent(new Event("currentApplicationInformationChanged"));
	}
	
	public function applicationStatus(applicationId:String):Boolean
	{
		if(!applicationId && currentApplicationId)
			applicationId = currentApplicationId;
		
		var application:XML = _listApplication.(@ID == applicationId)[0];
		
		if(application && application.@Status == "loaded")
			return true;
		else
			return false;
	}
	
	public function getApplicationInformation(applicationId:String = ""):void
	{
		if(applicationId == "")
			applicationId = currentApplicationId;
		
		soap.get_application_info(applicationId);
	}
	
	public function setApplicationInformation(applicationId:String, attributes:XML):void
	{
		soap.set_application_info(applicationId, attributes);
	}
	
	public function getApplicationStructure(applicationId:String = ""):void
	{
		if(applicationId == "")
			applicationId = currentApplicationId;
		
		soap.get_application_structure(applicationId);
	}
	
	public function setApplicationStructure(struct:XML):void
	{
		soap.set_application_structure(currentApplicationId, struct.toXMLString());
	}
	
	public function getApplicationEvents(objectId:String):void
	{
		if(!objectId)
			return;
		soap.get_application_events(currentApplicationId, objectId); 
	}
	
	public function setApplicationEvents(objectId:String, eventsValue:String):void
	{
		if(!objectId)
			return;
		
		soap.set_application_events(currentApplicationId, objectId, eventsValue); 
	}

	public function loadTypes():void
	{
		soap.get_all_types();
	}
	
	public function getTypeByTypeId(typeId:String):XML 
	{
		if(typeId)
			return _listTypes.Information.(ID == typeId)[0].parent(); //FIXME !!!!! исправить добавить проверку!!!
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
	
	public function changeCurrentPage(pageId:String):void
	{
		if(!pageId)
		{	
			_currentPageId = null;
			_currentObject = null;
			
		}
		else
		{
			soap.get_child_objects_tree(currentApplicationId, pageId);
		}
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
	
	public function createObject(typeId:String, parentId:String = "", 
								objectName:String = "", attributes:String = "", 
								applicationId:String = ""):void
	{
		proxy.flush();
		
		if(applicationId)
			soap.create_object(applicationId, parentId, typeId, objectName, attributes);
		else if (currentApplicationId)
			soap.create_object(currentApplicationId, parentId, typeId, objectName, attributes);
	}
	
	public function deleteObject(objectId:String):void
	{
		soap.delete_object(currentApplicationId, objectId);
	}
	
	public function changeCurrentObject(objectId:String):XML
	{
		if(objectId == currentObjectId)
			return currentObject;
		
		if(!objectId)
		{
			_currentObject = null;
		}	
		else
		{
			_currentObject = createNewCurrentObject(objectId);
		} 
		
		dispatchEvent(new Event("currentObjectIdChanged"));
		dispatchEvent(new Event("currentObjectChanged"));
		dispatchEvent(new DataManagerEvent(DataManagerEvent.OBJECT_CHANGED));
		return currentObject;
	}
	
	
	public function getObject(objectId:String):XML
	{
		var object:XMLList = _currentApplication..Objects.Object.(@ID == objectId);
		return object[0];
	}
	
	public function getObjectXMLScript():void
	{	
		soap.get_object_script_presentation(currentApplicationId, currentObjectId)
	}
	
	public function setObjectXMLScript(objectXMLScript:String):void
	{
		soap.submit_object_script_presentation(currentApplicationId, currentObjectId, objectXMLScript);
	}
	
	public function getScript(objectId:String = ""):void
	{
		if(objectId == "")
			objectId = currentObjectId;
		
		var applicationId:String = currentApplicationId;
		var language:String = "vbscript";
		
		soap.get_script(applicationId, objectId, language);
	}
	
	public function setScript(script:String, objectId:String = ""):void
	{
		if(objectId == "")
			objectId = currentObjectId;
		
		var applicationId:String = currentApplicationId;
		var language:String = "vbscript";
		
		soap.set_script(applicationId, objectId, script, language);
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
		
		var dme:DataManagerEvent;
		
		if(newOnlyAttributes || nameChanged)
		{
			dme = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_BEGIN);
			dme.result = newOnlyAttributes;
			dispatchEvent(dme);
		}
		else
		{
			dme = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_BEGIN);
			dispatchEvent(dme);
			
			var dmEvent:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
			dmEvent.objectId = objectId;
			dispatchEvent( dmEvent );
		}
		
		if(newOnlyAttributes)
		{
			requestQue[objectId] = "empty key";	
			proxy.setAttributes(currentApplicationId, objectId, newOnlyAttributes);
		}
		
		if(nameChanged)
			soap.set_name(currentApplicationId, oldXMLDescription.@ID, newXMLDescription.@Name);
	}
	
	public function search(applicationId:String, searchString:String):void
	{
		soap.search(applicationId, searchString);
	}
	
	public function modifyResource(resourceId:String, operation:String, attributeName:String, attributes:XML):void
	{
		soap.modify_resource(currentApplicationId, currentObjectId, 
										resourceId, attributeName, 
										operation, attributes);
	}
	
	private function createNewCurrentObject(objectId:String):XML
	{
		var newCurrentObject:XML = new XML(getObject(objectId));
			
		if(newCurrentObject && newCurrentObject.Type.length() == 0)
		{
			var type:XML = getTypeByObjectId(objectId);
			newCurrentObject.appendChild(type);
		}
		
		return newCurrentObject;
	}
	
	private function deleteXMLNodes(objectId:String):void
	{
		if(!objectId)
			return;
		
		var deleteNodes:XMLList = _currentApplication..Objects.Object.(@ID == objectId)
		
		for (var i:int = deleteNodes.length() - 1; i >= 0; i--)
			delete deleteNodes[i];
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
	
	private function soap_createApplicationHandler(event:SOAPEvent):void
	{
		_listApplication += event.result.Application[0];
		
		dispatchEvent(new DataManagerEvent("listApplicationChanged"));
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.CREATE_APPLICATION_COMPLETE);
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	private function soap_listApplicationsHandler(event:SOAPEvent):void
	{		
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
	
	private function soap_getApplicationInfoHandler(event:SOAPEvent):void
	{
		var result:XML = event.result.Information[0];
		
		if(!result)
			return;
		
		var applicationId:String = result.Id;
		
		var application:XML = _listApplication.(@ID == applicationId)[0]
		if(application)
			application.Information[0] = result;
		
		dispatchEvent(new Event("currentApplicationInformationChanged"));
	}
	
	private function soap_setApplicationInfoHandler(event:SOAPEvent):void
	{
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
		
		var dme1:DataManagerEvent = new DataManagerEvent(DataManagerEvent.SET_APPLICATION_INFO_COMPLETE);
		dispatchEvent(dme1);
		
		dispatchEvent(new Event("currentApplicationInformationChanged"));
	}
	
	private function soap_getApplicationStructureHandler(event:SOAPEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.GET_APPLICATION_STRUCTURE_COMPLETE);
		dme.result = event.result.Structure[0];
		dispatchEvent(dme);
	}
	
	private function soap_setApplicationStructureHandler(event:SOAPEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.SET_APPLICATION_STRUCTURE_COMPLETE);
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	private function soap_getApplicationEventsHandler(event:SOAPEvent):void
	{	
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.GET_APPLICATION_EVENTS_COMPLETE)
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	private function soap_setApplicationEventsHandler(event:SOAPEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.SET_APPLICATION_EVENTS_COMPLETE)
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	private function soap_getAllTypesHandler(event:SOAPEvent):void
	{
		_listTypes = event.result.Types.*;
		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_TYPES_COMPLETE));
	}
	
	private function soap_createObjectHandler(event:SOAPEvent):void
	{
		var result:XML = event.result;
		var parentId:String = result.ParentId;
		
		if(parentId)
		{
			var parentObject:XML = getObject(parentId);
		
			var newObject:XML = new XML(result.Object);
			delete newObject.Parent
			
			parentObject.Objects.appendChild(newObject);	
		}
		else
		{
			var applicationId:String = event.result.ApplicationID;
			var application:XML = _listApplication.(@ID == applicationId)[0]
			
			if(application && application.Objects[0]) ///<---- Fix for first page creation in Appl. Managment 
				application.Objects.appendChild(result.Object[0]);
			
			getApplicationInformation(applicationId);
		}
		
		dispatchEvent(new Event("listPagesChanged"));
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.CREATE_OBJECT_COMPLETE);
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	private function soap_deleteObjectHandler (event:SOAPEvent):void
	{
		var objectId:String = event.result.Result;
		
		deleteXMLNodes(objectId);
		
		if(objectId == currentPageId)
			changeCurrentPage(null);
		
		if(objectId == currentObjectId)
			changeCurrentObject(currentPageId);
		
		dispatchEvent(new Event("listPagesChanged"));
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.DELETE_OBJECT_COMPLETE);
		dme.objectId = objectId;
		dispatchEvent(dme);
		
		getApplicationInformation();
	}
	
	private function soap_getTopObjectsHandler(event:SOAPEvent):void
	{
		var pages:XMLList = event.result.Objects.Object;
		
		if(_currentApplication.Objects.length() > 0)
			delete _currentApplication.Objects;
			
		_currentApplication.appendChild(<Objects />);
		
		delete pages.Parent;
		
		if(pages.length() > 0)		
			_currentApplication.Objects[0].appendChild(pages);
		
		_currentApplication.@Status = "loaded";
		
		dispatchEvent(
			new DataManagerEvent(DataManagerEvent.LOAD_APPLICATION_COMPLETE)
		);
	}
	
	private function soap_getChildObjectsTreeHandler(event:SOAPEvent):void
 	{
		var objectData:XML = event.result.Object[0];
		var objectId:String = objectData.@ID;
		
		var currObj:XMLList = _currentApplication..Objects.Object.(@ID == objectId);

		if(currObj.length() == 0)
			return;
		
		currObj[0] = new XML(objectData);
		
		var isPage:Boolean = false;
		
		if(listPages && listPages.(@ID == objectId)[0])
			isPage = true;
		
		if(isPage)
		{
			_currentPageId = objectId;
			_currentObject = null;
			dispatchEvent(new Event("currentPageIdChanged"));
			dispatchEvent(new DataManagerEvent(DataManagerEvent.PAGE_CHANGED));
		}
		
		_currentObject = createNewCurrentObject(objectId);
		
		dispatchEvent(new Event("listPagesChanged"));
		dispatchEvent(new Event("currentObjectIdChanged"));
		dispatchEvent(new Event("currentObjectChanged"));
		
	}
	
	private function soap_setNameHandler(event:SOAPEvent):void
	{
		var objectId:String = event.result.Object.@ID;
		
		var result:XML = getObject(objectId);
		
		if(result)
			result.@Name = event.result.Object.@Name;
		
		if(_currentObject && _currentObject.@ID == objectId)
			_currentObject.@Name = event.result.Object.@Name;
		
		dispatchEvent(new Event("currentObjectChanged"));
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
		
		dme.objectId = objectId
		dme.result = <Result>{result}</Result>;
		dispatchEvent(dme);
		
		dispatchEvent(new Event("listPagesChanged"));
	}
	
	private function soap_getObjectScriptPresentationHandler(event:SOAPEvent):void
	{	
		var result:XML = event.result.Result.*[0];
		dispatchEvent(new DataManagerEvent(DataManagerEvent.GET_OBJECT_XML_SCRIPT_COMPLETE, result));
	}
	
	private function soap_setObjectScriptPresentationHandler(event:SOAPEvent):void
	{
		var result:XML = event.result;
		
		var oldObjectId:String = result.IDOld;
		var newObjectId:String = result.IDNew;
		
		_currentApplication..Objects.Object.(@ID == oldObjectId)[0] = <Object ID={newObjectId} />;
		
		soap.get_child_objects_tree(currentApplicationId, newObjectId); //<------
		dispatchEvent(new DataManagerEvent(DataManagerEvent.SET_OBJECT_XML_SCRIPT_COMPLETE, result));
	}
	
	private function soap_getScriptHandler(event:SOAPEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.GET_SCRIPT_COMPLETE);
		dme.result = event.result.Result[0];
		
		dispatchEvent(dme);
	}
	
	private function soap_setScriptHandler(event:SOAPEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.SET_SCRIPT_COMPLETE);
		dme.result = event.result.Result[0];
		
		dispatchEvent(dme);
	}
	
	private function soap_searchHandler(event:SOAPEvent):void
	{
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.SEARCH_COMPLETE);
		dme.result = event.result.SearchResult[0];
		dispatchEvent(dme);
	}
	
	private function soap_modifyResourceHandler(event:SOAPEvent):void
	{
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
				
			dispatchEvent(new Event("currentObjectChanged"));
		}
		
		var dme:DataManagerEvent = new DataManagerEvent(DataManagerEvent.MODIFY_RESOURCE_COMPLETE);
		dme.objectId = objectId;
		dme.result = event.result;
		dispatchEvent(dme);
	}
	
	private function proxy_sendHandler(event:ProxyEvent):void
	{
		var objectId:String = event.objectId;
		var key:String = event.key;
		
		if(requestQue[objectId] !== null) {
			requestQue[objectId] = key;
		}
	}
	
	private function proxy_setAttributesHandler(event:ProxyEvent):void
	{
		var key:String = event.xml.Key[0];
		
		if( !key )
			return;
		
		var objectId:String = event.xml.Object[0].@ID;
		var attributes:XML = event.xml.Object.Attributes[0];
		
		var object:XML = getObject(objectId);
		object.Attributes[0] = new XML(attributes);
		
		if(_currentObject && _currentObject.@ID == objectId)
		{
			_currentObject = createNewCurrentObject(objectId);
			dispatchEvent(new Event("currentObjectChanged"));		
		}
		
		if(requestQue[objectId] !== null && requestQue[objectId] == key)
		{
			delete requestQue[objectId];
			var dmEvent:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
			dmEvent.objectId = event.xml.Object.@ID;
			dmEvent.result = event.xml;
			dispatchEvent(dmEvent);
		}
	}
	
	private function faultHandler(event:FaultEvent):void
	{
		var errorCode:String = StringUtil.getLocalName(event.fault.faultCode);
		var errorDetails:XML = XML(event.fault.faultDetail);
		var dme:DataManagerErrorEvent;
		
		switch(errorCode)
		{
			case "305":
			{
				dme = new DataManagerErrorEvent(DataManagerErrorEvent.OBJECT_XML_SCRIPT_SAVE_ERROR);
				dispatchEvent(dme);
				break;
			} 
			case "306":
			{
				var objectId:String = errorDetails.ObjectID[0];
				_currentObject = createNewCurrentObject(objectId);
				
				dispatchEvent(new Event("currentObjectChanged"));
				
				dme = new DataManagerErrorEvent(DataManagerErrorEvent.SET_NAME_ERROR);
				dme.fault = event.fault;
				dispatchEvent(dme);
				break;
			}
			default:
				dme = new DataManagerErrorEvent(DataManagerErrorEvent.GLOBAL_ERROR);
				dme.fault = event.fault;
				dispatchEvent(dme);
			break;
		}
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