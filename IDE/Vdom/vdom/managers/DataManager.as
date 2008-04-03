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
	private var _currentobjectId:String;

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
		_currentApplicationId = null;
		_currentPageId = null;
		_currentObject = null;
		
		_typeLoaded = false;
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
		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.INIT_COMPLETE));
	}	
	
// ----------------------- end init action -----------------------

	/* public function _init(appId:String, pageId:String):void {
		
		//_appId = appId;
		_pageId = pageId;
		//_listTypes = publicData['types'];
		objectDescription = null;
		
		soap.addEventListener(SoapEvent.GET_TOP_OBJECTS_OK, getTopObjectsHandler);
		soap.getTopObjects(_appId);
	} */
	
	public function loadApplicationData():void {
		
		soap.addEventListener(SoapEvent.GET_TOP_OBJECTS_OK, getTopObjectsHandler);
		soap.getTopObjects(_currentApplicationId);
	}
	
	public function loadTypes():void {
		
		soap.addEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
		soap.getAllTypes();
	}
	
	public function loadPageData():void {
		
		soap.addEventListener(SoapEvent.GET_CHILD_OBJECTS_TREE_OK, loadPageDataHandler);
		soap.getChildObjectsTree(_currentApplicationId, _currentPageId);
	}
	
	private function getTopObjectsHandler(event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.GET_TOP_OBJECTS_OK, getTopObjectsHandler);
		
		var pages:XMLList = event.result.Objects.Object;
		
		_currentApplication.appendChild(<Objects />);
		
		delete pages.Parent;
		
		if(pages.length() > 0) {
		
			_currentApplication.Objects[0].appendChild = pages;
			changeCurrentPage(pages[0].@ID);
		} else {
			
			changeCurrentPage(null);
			
		}
		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.APPLICATION_DATA_LOADED));
	}
	
	private function getAllTypesHandler(event:SoapEvent):void {
	
		trace('getAllTypesHandler');
		_listTypes = event.result.*;
		_typeLoaded = true;
		soap.removeEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
		languageManager.parseLanguageData(_listTypes);
		dispatchEvent(new DataManagerEvent(DataManagerEvent.TYPES_LOADED));
	}
	
	[Bindable (event='listApplicationChanged')]
	public function get listApplication():XMLList {
		
		return _listApplication;
	}
	
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
	
	[Bindable (event='currentPageChanged')]
	public function get currentPage():XML {
		
		return _currentPage
	}
	
	[Bindable (event='currentObjectChanged')]
	public function get currentObject():XML {
		
		return _currentObject;
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
			
			var newPage:XML = _getPage(pageId);
		
			if(newPage) {
				
				_currentPageId = newPage.@ID;
				_currentPage = newPage;
				
			}
		}
		
		changeCurrentObject(_currentPageId);
			
		dispatchEvent(new DataManagerEvent(DataManagerEvent.CURRENT_PAGE_CHANGED));
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
			
			var newObject:XML = new XML(_getObject(objectId));
			var type:XML = getTypeByObjectId(objectId);
			newObject.appendChild(type);
			
			_currentObject = newObject;
			_currentobjectId = newObject.@ID;
		} 
			
		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.CURRENT_OBJECT_CHANGED));
		//dispatchEvent(new Event('objectDescriptionChanged'));
	}
	
	private function _getPage(pageId:String):XML {
		
		var newPage:XML = _currentApplication.Objects.Object.(@ID == pageId)[0];
		
		if(newPage.length())
			return newPage;
		else
			return null;
	}
	
	private function _getObject(objectId:String):XML {
		
		var object:XMLList = _currentApplication..Objects.Object.(@ID == objectId);
		return object[0];
	}
	
	public function getObject(objectId:String):XML {
		
		return _getObject(objectId);
	}
	
	/* public function getAttributes(objectId:String):XML {
		
		return new XML(_getObject(objectId));
	} */
	
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
			
			proxy.addEventListener(ProxyEvent.PROXY_COMPLETE, setAttributeCompleteHandler);
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
		
		var result:XML = _getObject(objectId);
		
		var dmEvent:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
		
		
		dmEvent.objectId = objectId
		dmEvent.result = <Result> {result} </Result>;
		//dispatchEvent(new Event('objectDescriptionChanged'));
		dispatchEvent(dmEvent);
	}
	
	private function setAttributeCompleteHandler(event:ProxyEvent):void {
		
		proxy.removeEventListener(ProxyEvent.PROXY_COMPLETE, setAttributeCompleteHandler);
		
		var dmEvent:DataManagerEvent = new DataManagerEvent(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE);
		dmEvent.objectId = event.xml.Object.@ID;
		dmEvent.result = event.xml;
		//dispatchEvent(new Event('objectDescriptionChanged'));
		dispatchEvent(dmEvent);
	}
	
	/**
	 * 
	 * @param typeId идетнтификатор типа.
	 * @return xml-описание типа.
	 * 
	 */	
	public function getTypeByTypeId(typeId:String):XML {
		
		return _listTypes.Information.(ID == typeId)[0].parent();
	}
	
	public function getTypeByObjectId(objectId:String):XML {
		
		var typeId:String = _getObject(objectId).@Type;
		return getTypeByTypeId(typeId)[0];
	}
	
	public function getTopLevelTypes():XMLList {
		
		var listTopLeveltTypes:XMLList = new XMLList();
		
		for each (var element:XML in _listTypes.Information.(Container == 3))
			listTopLeveltTypes += element.parent();
		
		return listTopLeveltTypes;
	}
	
	/**
	 * 
	 * @return xml-описание всех объектов вместе с типами.
	 * 
	 */	
	/* public function get objects():XMLList {
		
		return _objects;
	} */
	
	public function deleteObject(objectId:String):void {
		
		
		soap.addEventListener(SoapEvent.DELETE_OBJECT_OK, objectDeletedHandler);
		soap.deleteObject(_currentApplicationId, objectId);
		
	}
	
	
	public function objectDeletedHandler (event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.DELETE_OBJECT_OK, objectDeletedHandler);
		
		var objectID:String = event.result;
		
		delete _getObject(objectID);
		
		if(objectID == _currentPageId)
			changeCurrentPage(null);
		
		if(objectID == _currentobjectId)
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
		
		//var objectType:XML = _listTypes.Type.Information.(ID == initProp.typeId).parent();
		
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
		soap.createObject(_currentApplicationId, parentId, typeId, attributes, objectName);
		
		//return objectId;
	}
	
	private function createObjectCompleteHandler(event:SoapEvent):void {
		
		var result:XML = event.result;
		//var objectId:String = result.Object.@ID;
		//var objectName:String = result.Object.@Name;
		var parentId:String = result.Object.Parent;
		
		if(!parentId)
			_currentApplication.Objects.appendChild(result.Object[0]);
			
		else {
			
			var parentObject:XML = getObject(parentId);
		
			var newObject:XML = new XML(result.Object);
			delete newObject.Parent
			
			parentObject.Objects.appendChild(newObject);
		}
		//var objectTypeId:String = result.Object.@Type;
		//var objectType:XML = getTypeByObjectId(obj
		
		
		
		
		/* var newObject:XML = <Object Name={objectName} ID={objectId} Type={objectType.Information.ID} />;

		//var attributes:XML = <Attributes />;
		var attributes:XML = result.Object.Attributes[0];
		
		var objects:XML = <Objects />
		/* for each(var prop:XML in objectType.Attributes.Attribute) {
			
			attributes.appendChild(<Attribute Name={prop.Name.toString()}>{prop.DefaultValue.toString()}</Attribute>);
		} */
		
		/* newObject.appendChild(attributes);
		newObject.appendChild(objectType);
		newObject.appendChild(objects);
		
		if(result.Parent.toString() != '') {
			
			var parentObject:XML = _getObject(parentId);
			parentObject.Objects.appendChild(newObject);
			
		}
		else */
			//_objects.Objects.appendChild(newObject); */
		
		
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
	
	
 	private function loadPageDataHandler(event:SoapEvent):void {
		
		var pageData:XML = event.result;
		var pageId:String = pageData.@ID;
		
		delete _currentApplication.Objects.Object.(@ID == pageId)[0];
		
		_currentApplication.Objects[0].appendChild(pageData);
		
		
		
		changeCurrentObject(pageId);
		
		dispatchEvent(new DataManagerEvent(DataManagerEvent.PAGE_DATA_LOADED));
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