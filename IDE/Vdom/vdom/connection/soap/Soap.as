package vdom.connection.soap
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.LoadEvent;
	import mx.rpc.soap.WebService;
	
		
	public class Soap extends EventDispatcher
	{
		public static var ws			:WebService;
		private static 	var instance	:Soap;
//FileUpload
		/**
		 *	  initialisation
		 */
		
		public function Soap() 
		{
            if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
        } 		
		 
		 // initialization		
		public static function getInstance():Soap {
			
			if (!instance)
				instance = new Soap();
	
			return instance;
		}	
		//app_text
		public function init(wsdl:String= 'http://192.168.0.23:82/vdom.wsdl'):void
		{
             //	var loader :Loader = new Loader;
             	ws = new WebService();	
             	ws.wsdl =wsdl;
				ws.useProxy = false;
				ws.addEventListener(LoadEvent.LOAD, loadCompleteListener);
				ws.addEventListener(FaultEvent.FAULT, errorListener);
				ws.loadWSDL();
				
				sLogin = SLogin.getInstance(); 
				sSetAttributes = SSetAttributes.getInstance();
				sCloseSession = SCloseSession.getInstance(); 
				sCreateApplication = SCreateApplication.getInstance(); 
				sSetApplicationInfo = SSetApplicationInfo.getInstance();
				sGetApplicationInfo = SGetApplicationInfo.getInstance();
				istApplications = SListApplications.getInstance();
				sListTipes = SListTypes.getInstance();
				sGetType = SGetType.getInstance();
				sGetTypeResource = SGetResource.getInstance();
				sRenderWysiwig = SRenderWysiwyg.getInstance();
				sco = SCreateObject.getInstance();
				sGetTopObjects = SGetTopObjects.getInstance();
				sGetChildObjects = SGetChildObjects.getInstance();
				sGetApplicationLanguageData= SGetApplicationLanguageData.getInstance();
				 sSetAttribute= SSetAttribute.getInstance();
				 sSetValue = SSetValue.getInstance();
				 sSetScript = SSetScript.getInstance();
				 sGetScript = SGetScript.getInstance();
				sSetName = SSetName.getInstance();
				sSetResource = SSetResource.getInstance();
				sWholeCreate = SWholeCreate.getInstance();
				sWholeDelete = SWholeDelete.getInstance();
				sWholeUpdate = SWholeUpdate.getInstance();
				sWholeCreatePage = SWholeCreatePage.getInstance();
				sGetChildObjectsTree = SGetChildObjectsTree.getInstance();
				sGetApplicationStructure = SGetApplicationStructure.getInstance();
				sSetApplicationStructure  = SSetApplicationStructure.getInstance();
				sSubmitObjectScriptPresentation = SSubmitObjectScriptPresentation.getInstance();
				sGetOneObject = SGetOneObject.getInstance();
				sGetObjectScriptPresentation = SGetObjectScriptPresentation.getInstance();
				sListResources = SListResources.getInstance();
				sModifyResource	= SModifyResource.getInstance();
				sSetApplicationEvents = SSetApplicationEvents.getInstance();
				sGetApplicationEvents = SGetApplicationEvents.getInstance();
				sGetThumbnail = SGetThumbnail.getInstance();
				sRemoteMethodCall = SRemoteMethodCall.getInstance();
			
		}		
		
		private function loadCompleteListener(event:LoadEvent):void {
			
			dispatchEvent(new Event('loadWsdlComplete'));
		}
		/**
		 *  1 - open session open_session
		 */
		private var sLogin:SLogin;
		public   function login( login:String='', password:String='' ):void 
		{	
			
			
			sLogin.addEventListener(SoapEvent.LOGIN_OK,    ldispatchEvent);
			sLogin.addEventListener(SoapEvent.LOGIN_ERROR, ldispatchEvent);
			
			sLogin.execute(login,password);
		}

		/**
		 *  2 - close_session  
		 */
		private var sCloseSession:SCloseSession;
		public  function closeSession():void 
		{
			
			
			sCloseSession.addEventListener(SoapEvent.CLOSE_SESSION_OK, ldispatchEvent);
			sCloseSession.addEventListener(SoapEvent.CLOSE_SESSION_ERROR, ldispatchEvent);
			
			sCloseSession.execute();
		}

		/**
		 * 3 - create application  'create_application'
		 */ 
		private var sCreateApplication:SCreateApplication;
		public  function createApplication(attr:XML = null):void 
		{
			
			
			sCreateApplication.addEventListener(SoapEvent.CREATE_APPLICATION_OK, ldispatchEvent);
			sCreateApplication.addEventListener(SoapEvent.CREATE_APPLICATION_ERROR, ldispatchEvent);
			
			sCreateApplication.execute(attr);
		}
	/*	
		public   function createApplicationResult():XML 
		{
			return sCreateApplication.getResult();
		}
		*/
		/**
		 *  4 - set application general information 'set_application_info'
		 */
		private var  sSetApplicationInfo:SSetApplicationInfo;
		public  function setApplicationInfo(appid:String='',attr:String=''):void 
		{
			
			
			sSetApplicationInfo.addEventListener(SoapEvent.SET_APLICATION_INFO_OK, ldispatchEvent);
			sSetApplicationInfo.addEventListener(SoapEvent.SET_APLICATION_INFO_ERROR, ldispatchEvent);
			
			sSetApplicationInfo.execute(appid, attr);
		}
		
		private var  sGetApplicationInfo:SGetApplicationInfo;
		public  function getApplicationInfo(appid:String='',attr:String=''):void 
		{
			sGetApplicationInfo.addEventListener(SoapEvent.GET_APLICATION_INFO_OK, ldispatchEvent);
			sGetApplicationInfo.addEventListener(SoapEvent.GET_APLICATION_INFO_ERROR, ldispatchEvent);
			
			sGetApplicationInfo.execute(appid, attr);
		}


		/**
		 *  5 - get the list of all applications  'list_applications'
		 */
		 private var istApplications:SListApplications;
		public  function listApplications():void 
		{
			
		
			istApplications.addEventListener(SoapEvent.LIST_APLICATION_OK, ldispatchEvent);
			istApplications.addEventListener(SoapEvent.LIST_APLICATION_ERROR, ldispatchEvent);
			
			istApplications.execute();
		}

		/**
		 *  6 - get the list of all types 'list_types'
		 */
		private var sListTipes:SListTypes;
		public  function listTypes():void 
		{
			
			
			sListTipes.addEventListener(SoapEvent.LIST_TYPES_OK, ldispatchEvent);
			sListTipes.addEventListener(SoapEvent.LIST_TYPES_ERROR, ldispatchEvent);
			
			sListTipes.execute();
		}
		
		/**
		 *  7 - get type description get_type
		 */
		private var sGetType:SGetType;
		public  function getType(typeid:String=''):void 
		{
			
			
			sGetType.addEventListener(SoapEvent.GET_TYPE_OK, ldispatchEvent);
			sGetType.addEventListener(SoapEvent.GET_TYPE_ERROR, ldispatchEvent);
			
			sGetType.execute(typeid);
		}
		
		/** 
		 *  8 - get type resource get_resource
		 */
		private var sGetTypeResource:SGetResource;
		public  function getResource(ownerid:String='',resid:String=''):void 
		{
			
			
			sGetTypeResource.addEventListener(SoapEvent.GET_RESOURCE_OK, ldispatchEvent);
			sGetTypeResource.addEventListener(SoapEvent.GET_RESOURCE_ERROR, ldispatchEvent);
			
			sGetTypeResource.execute(ownerid, resid);
		}
		
		
		/**
		 * 9. render object to xml presentation  - render_wysiwyg
		 */
		private var sRenderWysiwig:SRenderWysiwyg;
		public  function renderWysiwyg(appid:String='',objid:String='', parentid:String='' ,sdynamic:String  = '0'):String 
		{	
			
			
			sRenderWysiwig.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, ldispatchEvent);
			sRenderWysiwig.addEventListener(SoapEvent.RENDER_WYSIWYG_ERROR, ldispatchEvent);
			
			var key:String = sRenderWysiwig.execute(appid, objid, parentid, sdynamic);
			
			return key;
		}
		
		
		/**
		 * 10. create object - create_object
		 */
		private var sco: SCreateObject
		public function createObject(appid:String='',parentid:String='',typeid:String = '', attrs:String = '', name:String =''):void
		{
			
			
			sco.addEventListener(SoapEvent.CREATE_OBJECT_OK, ldispatchEvent);
			sco.addEventListener(SoapEvent.CREATE_OBJECT_ERROR, ldispatchEvent);
			
			sco.execute(appid,parentid,typeid, attrs, name);
		}
		
		
		/**
		 * 11. get application top-level objects  - get_top_objects
		 */
		 
		private var sGetTopObjects:SGetTopObjects ;
		public  function getTopObjects(appid:String=''):void 
		{
			
			
			sGetTopObjects.addEventListener(SoapEvent.GET_TOP_OBJECTS_OK, ldispatchEvent);
			sGetTopObjects.addEventListener(SoapEvent.GET_TOP_OBJECTS_ERROR, ldispatchEvent);
			
			sGetTopObjects.execute(appid);
		}
		
		
		/**
		 * 12. get object's child objects'  - get_child_objects
		 */
		
		private var sGetChildObjects:SGetChildObjects ;
		public  function getChildObjects(appid:String='',objid:String=''):void 
		{
			
			
			sGetChildObjects.addEventListener(SoapEvent.GET_CHILD_OBJECTS_OK, ldispatchEvent);
			sGetChildObjects.addEventListener(SoapEvent.GET_CHILD_OBJECTS_ERROR, ldispatchEvent);
			
			sGetChildObjects.execute(appid, objid );
		}
		
		/**
		 * 13. get application language data - get_application_language_data
		 */
		private var sGetApplicationLanguageData:SGetApplicationLanguageData;
		public  function getApplicationLanguageData(appid:String=''):void 
		{
			
			
			sGetApplicationLanguageData.addEventListener(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_OK, ldispatchEvent);
			sGetApplicationLanguageData.addEventListener(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_ERROR, ldispatchEvent);
			
			sGetApplicationLanguageData.execute(appid);
		}
		
		
		/**
		 * 14. set object attribute value - set_attribute
		 */
		private var sSetAttribute:SSetAttribute;
		public  function setAttribute(appid:String='',objid:String='', attr:String='',value:String='' ):void 
		{
			
			
			sSetAttribute.addEventListener(SoapEvent.SET_ATTRIBUTE_OK, ldispatchEvent);
			sSetAttribute.addEventListener(SoapEvent.SET_ATTRIBUTE_ERROR, ldispatchEvent);
			
			sSetAttribute.execute(appid, objid, attr, value);
		}
		
		/**
		 * 15. set object value set_value
		 */
		
		private var sSetValue:SSetValue;
		public  function setValue(appid:String='',objid:String='', value:String='' ):void 
		{
			
			
			sSetValue.addEventListener(SoapEvent.SET_VALUE_OK, ldispatchEvent);
			sSetValue.addEventListener(SoapEvent.SET_VALUE_ERROR, ldispatchEvent);
			
			sSetValue.execute(appid, objid, value);
		}
		
		/**
		 * 16. set object script set_script
		 */
		private var sSetScript:SSetScript;
		public  function setScript(appid:String='',objid:String='', script:String='', lang:String=''):void 
		{
			
			
			sSetScript.addEventListener(SoapEvent.SET_SCRIPT_OK, ldispatchEvent);
			sSetScript.addEventListener(SoapEvent.SET_SCRIPT_ERROR, ldispatchEvent);
			
			sSetScript.execute(appid, objid, script, lang);
		}
		
		private var sGetScript:SGetScript;
		public  function getScript(appid:String='',objid:String='', lang:String='' ):void 
		{
			
			
			sGetScript.addEventListener(SoapEvent.GET_SCRIPT_OK, ldispatchEvent);
			sGetScript.addEventListener(SoapEvent.GET_SCRIPT_ERROR, ldispatchEvent);
			
			sGetScript.execute(appid, objid, lang);
		}
		
		/**
		 * 17. set application resource set_resource
		 */
		private var sSetResource:SSetResource;
		public  function setResource(appid:String='', restype:String='', resname:String='', resdata:String='' ):void 
		{
			
			
			sSetResource.addEventListener(SoapEvent.SET_RESOURCE_OK, ldispatchEvent);
			sSetResource.addEventListener(SoapEvent.SET_RESOURCE_ERROR, ldispatchEvent);
			
			sSetResource.execute(appid,  restype, resname, resdata);
		}
		
		
		/**
		 * 18. delete object delete_object
		 */
		
		public  function deleteObject(appid:String='',objid:String='' ):void 
		{
			var sDeleteObject:SDeleteObject = SDeleteObject.getInstance();
			
			sDeleteObject.addEventListener(SoapEvent.DELETE_OBJECT_OK, ldispatchEvent);
			sDeleteObject.addEventListener(SoapEvent.DELETE_OBJECT_ERROR, ldispatchEvent);
			
			sDeleteObject.execute(appid, objid);

		}
		
		
		/**
		 * ------------- 19 get Echo -------- didn't used
		 */ 
		public function getEcho():void
		{
			var sGetEcho:SGetEcho = SGetEcho.getInstance();
			
			sGetEcho.addEventListener(SoapEvent.GET_ECHO_OK, ldispatchEvent);
			sGetEcho.addEventListener(SoapEvent.GET_ECHO_ERROR, ldispatchEvent);
			
			sGetEcho.execute();
		}
		
		/**
		 *  --------- 20 Get All Types -----
		 */ 
		public function getAllTypes():void
		{	
			var sGetAllTypes:SGetAllTypes = SGetAllTypes.getInstance();
			
			sGetAllTypes.addEventListener(SoapEvent.GET_ALL_TYPES_OK, ldispatchEvent);
			sGetAllTypes.addEventListener(SoapEvent.GET_ALL_TYPES_ERROR, ldispatchEvent);
			
			sGetAllTypes.execute();
		}
		
		/**
		 *  --------- 21  Set value of several object's attributes -----
		 * 						--setAttributes --
		 */ 
		private var sSetAttributes:SSetAttributes; 
		public function setAttributes(appid:String = '', objid:String = '', attr:String = ''):String
		{
				
				sSetAttributes.addEventListener(SoapEvent.SET_ATTRIBUTE_S_OK, ldispatchEvent);
				sSetAttributes.addEventListener(SoapEvent.SET_ATTRIBUTE_S_ERROR, ldispatchEvent);
				
			var key:String = sSetAttributes.execute(appid, objid, attr);
			return key;
		}
		
		/**
		 * 		22. set object name  'set_name' 
		 */
		 private var sSetName:SSetName;
		public function setName(appid:String = '', objid:String = '', name:String = ''):void
		{
			
			
			sSetName.addEventListener(SoapEvent.SET_NAME_OK, ldispatchEvent);
			sSetName.addEventListener(SoapEvent.SET_NAME_ERROR, ldispatchEvent);
			
			sSetName.execute(appid, objid, name);
		}
		
		/**
		 * 		23. Create WHOLE object - 'whole_create'
		 */
		 private var sWholeCreate:SWholeCreate;
		public function wholeCreate(appid:String = '', parentid:String = '', name:String = '', data:String = ''):void
		{
			
			
			sWholeCreate.addEventListener(SoapEvent.WHOLE_CREATE_OK, ldispatchEvent);
			sWholeCreate.addEventListener(SoapEvent.WHOLE_CREATE_ERROR, ldispatchEvent);
			
			sWholeCreate.execute(appid, parentid, name, data);
		}

		/**
		 * 		24. Delete WHOLE object - 'whole_delete'
		 */
		 private var sWholeDelete:SWholeDelete
		public function wholeDelete(appid:String = '', objid:String = ''):void
		{
			
			
			sWholeDelete.addEventListener(SoapEvent.WHOLE_DELETE_OK, ldispatchEvent);
			sWholeDelete.addEventListener(SoapEvent.WHOLE_DELETE_ERROR, ldispatchEvent);
			
			sWholeDelete.execute(appid, objid);
		}

		/**
		 * 		25.  Update WHOLE object - 'whole_update'
		 */
		 private var sWholeUpdate:SWholeUpdate;
		public function wholeUpdate(appid:String = '', objid:String = '', data:String = ''):void
		{
			
			
			sWholeUpdate.addEventListener(SoapEvent.WHOLE_UPDATE_OK, ldispatchEvent);
			sWholeUpdate.addEventListener(SoapEvent.WHOLE_UPDATE_ERROR, ldispatchEvent);
			
			sWholeUpdate.execute(appid, objid, data);
		}

		/**
		 * 		26. Create new page for placing WHOLE objects - 'whole_create_page'
		 */
		 private var sWholeCreatePage:SWholeCreatePage ;
		public function wholeCreatePage(appid:String = '', sourceid:String = ''):void
		{
			
			
			sWholeCreatePage.addEventListener(SoapEvent.WHOLE_UPDATE_OK, ldispatchEvent);
			sWholeCreatePage.addEventListener(SoapEvent.WHOLE_UPDATE_ERROR, ldispatchEvent);
			
			sWholeCreatePage.execute(appid, sourceid);
		}
		
		private var sGetChildObjectsTree:SGetChildObjectsTree;
		public  function getChildObjectsTree(appid:String='',objid:String=''):void 
		{	
			
			
			sGetChildObjectsTree.addEventListener(SoapEvent.GET_CHILD_OBJECTS_TREE_OK, ldispatchEvent);
			sGetChildObjectsTree.addEventListener(SoapEvent.GET_CHILD_OBJECTS_TREE_ERROR, ldispatchEvent);
			
			sGetChildObjectsTree.execute(appid, objid);
		}
		
		
		private var sGetApplicationStructure:SGetApplicationStructure
		public  function getApplicationStructure(appid:String=''):void 
		{	
			
			sGetApplicationStructure.addEventListener(SoapEvent.GET_APPLICATION_STRUCTURE_OK, ldispatchEvent);
			sGetApplicationStructure.addEventListener(SoapEvent.GET_APPLICATION_STRUCTURE_ERROR, ldispatchEvent);
			
			sGetApplicationStructure.execute(appid);
		}
		
		
		private var sSetApplicationStructure:SSetApplicationStructure;
		public  function setApplicationStructure(appid:String='', struct:String = ''):void 
		{	
			
			
			sSetApplicationStructure.addEventListener(SoapEvent.SET_APPLICATION_STRUCTURE_OK, ldispatchEvent);
			sSetApplicationStructure.addEventListener(SoapEvent.SET_APPLICATION_STRUCTURE_ERROR, ldispatchEvent);
			
			sSetApplicationStructure.execute(appid, struct);
		}
		
		
		private var sSubmitObjectScriptPresentation:SSubmitObjectScriptPresentation ;
		public  function submitObjectScriptPresentation(appid:String='', objid:String = '', pres:String = ''):void 
		{	
			
			
			sSubmitObjectScriptPresentation.addEventListener(SoapEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_OK, ldispatchEvent);
			sSubmitObjectScriptPresentation.addEventListener(SoapEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_ERROR, ldispatchEvent);
			
			sSubmitObjectScriptPresentation.execute(appid, objid, pres);
		}
		
	
		
		private var sGetOneObject:SGetOneObject;
		public  function getOneObject(appid:String='', struct:String = ''):void 
		{	
			
			
			sGetOneObject.addEventListener(SoapEvent.GET_ONE_OBJECT_OK, ldispatchEvent);
			sGetOneObject.addEventListener(SoapEvent.GET_ONE_OBJECT_ERROR, ldispatchEvent);
			
			sGetOneObject.execute(appid, struct);
		}
		
		private var sGetObjectScriptPresentation:SGetObjectScriptPresentation;
		public  function getObjectScriptPresentation(appid:String='', struct:String = ''):void 
		{	
			
			
			sGetObjectScriptPresentation.addEventListener(SoapEvent.GET_OBJECT_SCRIPT_PRESENTATION_OK, 		ldispatchEvent);
			sGetObjectScriptPresentation.addEventListener(SoapEvent.GET_OBJECT_SCRIPT_PRESENTATION_ERROR, 	ldispatchEvent);
			
			sGetObjectScriptPresentation.execute(appid, struct);
		}
		
		private var sListResources:SListResources ;
		public function listResources(ownerid:String = ''):void
		{
			
			
			sListResources.addEventListener(SoapEvent.LIST_RESOURSES_OK, ldispatchEvent);
			sListResources.addEventListener(SoapEvent.LIST_RESOURSES_ERROR, ldispatchEvent);
			
			sListResources.execute(ownerid);
		}
		
		private var sModifyResource:SModifyResource;
		public  function modifyResource(appid:String = '', objid:String = '', 
														resid:String = '', 
														attrname:String = '', 
														operation:String = '',
														attr:String = ''):void 
		{	
			
			
			
			sModifyResource.addEventListener(SoapEvent.MODIFY_RESOURSE_OK, 		ldispatchEvent);
			sModifyResource.addEventListener(SoapEvent.MODIFY_RESOURSE_ERROR, 	ldispatchEvent);
			
			sModifyResource.execute(appid, objid, resid, attrname,operation, attr);
		}
		
		private var sSetApplicationEvents:SSetApplicationEvents;
		public  function setApplicationEvents(appid:String='', objid:String = '', events:String=''):void 
		{	
			
			
			sSetApplicationEvents.addEventListener(SoapEvent.SET_APPLICATION_EVENTS_OK, ldispatchEvent);
			sSetApplicationEvents.addEventListener(SoapEvent.SET_APPLICATION_EVENTS_ERROR, ldispatchEvent);
			
			sSetApplicationEvents.execute(appid, objid, events);
		}
		
		private var sGetApplicationEvents:SGetApplicationEvents;
		public  function getApplicationEvents(appid:String='', objid:String = ''):void 
		{	
			
			
			sGetApplicationEvents.addEventListener(SoapEvent.GET_APPLICATION_EVENTS_OK, ldispatchEvent);
			sGetApplicationEvents.addEventListener(SoapEvent.GET_APPLICATION_EVENTS_ERROR, ldispatchEvent);
			
			sGetApplicationEvents.execute(appid, objid);
		}
		
		private var sGetThumbnail:SGetThumbnail;
		public  function getThumbnail( appid:String = '', 	resid:String = '', 
															width:String = '', 
															height:String = ''):void 
		{	
			var sGetThumbnail:SGetThumbnail = SGetThumbnail.getInstance();
			
			sGetThumbnail.addEventListener(SoapEvent.GET_THUMBNAIL_OK, ldispatchEvent);
			sGetThumbnail.addEventListener(SoapEvent.GET_THUMBNAIL_ERROR, ldispatchEvent);
			
			sGetThumbnail.execute(appid, resid, width, height);
		}
		
		private var sRemoteMethodCall:SRemoteMethodCall;
		public  function remoteMethodCall(appid:String='', objid:String = '', funcName:String = '', xmlParam:String = ''):String 
		{	
			
			
			sRemoteMethodCall.addEventListener(SoapEvent.REMOTE_METHOD_CALL_OK, ldispatchEvent);
			sRemoteMethodCall.addEventListener(SoapEvent.REMOTE_METHOD_CALL_ERROR, ldispatchEvent);
			
			var key:String = sRemoteMethodCall.execute(appid, objid, funcName, xmlParam);
			
			return key;
		}
		
		private var sSearch:SSearch;
		public  function search(appid:String='', pattern:String = ''):void 
		{	
			sSearch = SSearch.getInstance();
			
			sSearch.addEventListener(SoapEvent.SEARCH_OK, ldispatchEvent);
			sSearch.addEventListener(SoapEvent.SEARCH_ERROR, ldispatchEvent);
			
			sSearch.execute(appid, pattern);
		}
		
		
		/**
		 *  --------  Event Dispatcher -------------
		 */
		 
		
		
		//Error
		private  function errorListener(event:FaultEvent):void{
			
			var fe:FaultEvent = FaultEvent.createEvent(event.fault, null, event.message);
			dispatchEvent(fe);
		}
		
    	public function ldispatchEvent(evt:SoapEvent):void{
      		//trace(evt.result);
			var soapEvent:SoapEvent = new SoapEvent(evt.type);
			soapEvent.result = evt.result;
			dispatchEvent(soapEvent);
		//	trace(evt.type)
    	}	
	}
}

