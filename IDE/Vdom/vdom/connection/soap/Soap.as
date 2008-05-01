package vdom.connection.soap
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.LoadEvent;
	import mx.rpc.soap.WebService;
	
		
	public class Soap  extends EventDispatcher
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
		 public static function getInstance():Soap 
		 {
             return instance||new Soap() ;
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
		}		
		
		private function loadCompleteListener(event:LoadEvent):void {
			
			dispatchEvent(new Event('loadWsdlComplete'));
		}
		/**
		 *  1 - open session open_session
		 */
		
		public   function login( login:String='', password:String='' ):void 
		{	
			var sLogin:SLogin = SLogin.getInstance(); 
			
			sLogin.addEventListener(SoapEvent.LOGIN_OK,    ldispatchEvent  );
			sLogin.addEventListener(SoapEvent.LOGIN_ERROR, ldispatchEvent);
			
			sLogin.execute(login,password);
		}

		/**
		 *  2 - close_session  
		 */
		
		public  function closeSession():void 
		{
			var sCloseSession:SCloseSession = SCloseSession.getInstance(); 
			
			sCloseSession.addEventListener(SoapEvent.CLOSE_SESSION_OK, ldispatchEvent);
			sCloseSession.addEventListener(SoapEvent.CLOSE_SESSION_ERROR, ldispatchEvent);
			
			sCloseSession.execute();
		}

		/**
		 * 3 - create application  'create_application'
		 */ 
		
		public  function createApplication(attr:XML):void 
		{
			var sCreateApplication:SCreateApplication = SCreateApplication.getInstance(); 
			
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
		
		public  function setApplicationInfo(appid:String='',attrname:String='',attrvalue:String=''):void 
		{
			var  sSetApplicationInfo:SSetApplicationInfo = SSetApplicationInfo.getInstance();
			
			sSetApplicationInfo.addEventListener(SoapEvent.SET_APLICATION_OK, ldispatchEvent);
			sSetApplicationInfo.addEventListener(SoapEvent.SET_APLICATION_ERROR, ldispatchEvent);
			
			sSetApplicationInfo.execute(appid, attrname, attrvalue);
		}

		/**
		 *  5 - get the list of all applications  'list_applications'
		 */
		public  function listApplications():void 
		{
			var istApplications:SListApplications = SListApplications.getInstance();
		
			istApplications.addEventListener(SoapEvent.LIST_APLICATION_OK, ldispatchEvent);
			istApplications.addEventListener(SoapEvent.LIST_APLICATION_ERROR, ldispatchEvent);
			
			istApplications.execute();
		}

		/**
		 *  6 - get the list of all types 'list_types'
		 */
		
		public  function listTypes():void 
		{
			var sListTipes:SListTypes = SListTypes.getInstance();
			
			sListTipes.addEventListener(SoapEvent.LIST_TYPES_OK, ldispatchEvent);
			sListTipes.addEventListener(SoapEvent.LIST_TYPES_ERROR, ldispatchEvent);
			
			sListTipes.execute();
		}
		
		/**
		 *  7 - get type description get_type
		 */
		
		public  function getType(typeid:String=''):void 
		{
			var sGetType:SGetType = SGetType.getInstance();
			
			sGetType.addEventListener(SoapEvent.GET_TYPE_OK, ldispatchEvent);
			sGetType.addEventListener(SoapEvent.GET_TYPE_ERROR, ldispatchEvent);
			
			sGetType.execute(typeid);
		}
		
		/** 
		 *  8 - get type resource get_resource
		 */
		
		public  function getResource(ownerid:String='',resid:String=''):void 
		{
			var sGetTypeResource:SGetResource = SGetResource.getInstance();
			
			sGetTypeResource.addEventListener(SoapEvent.GET_RESOURCE_OK, ldispatchEvent);
			sGetTypeResource.addEventListener(SoapEvent.GET_RESOURCE_ERROR, ldispatchEvent);
			
			sGetTypeResource.execute(ownerid, resid);
		}
		
		
		/**
		 * 9. render object to xml presentation  - render_wysiwyg
		 */
		
		public  function renderWysiwyg(appid:String='',objid:String='', parentid:String='' ,sdynamic:String  = '0'):String 
		{	
			var sRenderWysiwig:SRenderWysiwyg = SRenderWysiwyg.getInstance();
			
			sRenderWysiwig.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, ldispatchEvent);
			sRenderWysiwig.addEventListener(SoapEvent.RENDER_WYSIWYG_ERROR, ldispatchEvent);
			
			var key:String = sRenderWysiwig.execute(appid, objid, parentid, sdynamic);
			
			return key;
		}
		
		
		/**
		 * 10. create object - create_object
		 */
		//private 
		public function createObject(appid:String='',parentid:String='',typeid:String = '', attrs:String = '', name:String =''):void
		{
			var sco: SCreateObject = SCreateObject.getInstance();
			
			sco.addEventListener(SoapEvent.CREATE_OBJECT_OK, ldispatchEvent);
			sco.addEventListener(SoapEvent.CREATE_OBJECT_ERROR, ldispatchEvent);
			
			sco.execute(appid,parentid,typeid, attrs, name);
		}
		
		
		/**
		 * 11. get application top-level objects  - get_top_objects
		 */
		 
		
		public  function getTopObjects(appid:String=''):void 
		{
			var sGetTopObjects:SGetTopObjects = SGetTopObjects.getInstance();
			
			sGetTopObjects.addEventListener(SoapEvent.GET_TOP_OBJECTS_OK, ldispatchEvent);
			sGetTopObjects.addEventListener(SoapEvent.GET_TOP_OBJECTS_ERROR, ldispatchEvent);
			
			sGetTopObjects.execute(appid);
		}
		
		
		/**
		 * 12. get object's child objects'  - get_child_objects
		 */
		
		
		public  function getChildObjects(appid:String='',objid:String=''):void 
		{
			var sGetChildObjects:SGetChildObjects = SGetChildObjects.getInstance();
			
			sGetChildObjects.addEventListener(SoapEvent.GET_CHILD_OBJECTS_OK, ldispatchEvent);
			sGetChildObjects.addEventListener(SoapEvent.GET_CHILD_OBJECTS_ERROR, ldispatchEvent);
			
			sGetChildObjects.execute(appid, objid );
		}
		
		/**
		 * 13. get application language data - get_application_language_data
		 */
		
		public  function getApplicationLanguageData(appid:String=''):void 
		{
			var sGetApplicationLanguageData:SGetApplicationLanguageData = SGetApplicationLanguageData.getInstance();
			
			sGetApplicationLanguageData.addEventListener(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_OK, ldispatchEvent);
			sGetApplicationLanguageData.addEventListener(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_ERROR, ldispatchEvent);
			
			sGetApplicationLanguageData.execute(appid);
		}
		
		
		/**
		 * 14. set object attribute value - set_attribute
		 */
		
		public  function setAttribute(appid:String='',objid:String='', attr:String='',value:String='' ):void 
		{
			var sSetAttribute:SSetAttribute = SSetAttribute.getInstance();
			
			sSetAttribute.addEventListener(SoapEvent.SET_ATTRIBUTE_OK, ldispatchEvent);
			sSetAttribute.addEventListener(SoapEvent.SET_ATTRIBUTE_ERROR, ldispatchEvent);
			
			sSetAttribute.execute(appid, objid, attr, value);
		}
		
		/**
		 * 15. set object value set_value
		 */
		
		
		public  function setValue(appid:String='',objid:String='', value:String='' ):void 
		{
			var sSetValue:SSetValue = SSetValue.getInstance();
			
			sSetValue.addEventListener(SoapEvent.SET_VALUE_OK, ldispatchEvent);
			sSetValue.addEventListener(SoapEvent.SET_VALUE_ERROR, ldispatchEvent);
			
			sSetValue.execute(appid, objid, value);
		}
		
		/**
		 * 16. set object script set_script
		 */
		
		public  function setScript(appid:String='',objid:String='', script:String='' ):void 
		{
			var sSetScript:SSetScript = SSetScript.getInstance();
			
			sSetScript.addEventListener(SoapEvent.SET_SCRIPT_OK, ldispatchEvent);
			sSetScript.addEventListener(SoapEvent.SET_SCRIPT_ERROR, ldispatchEvent);
			
			sSetScript.execute(appid, objid, script);
		}
		
		
		/**
		 * 17. set application resource set_resource
		 */
		
		public  function setResource(appid:String='', restype:String='', resname:String='', resdata:String='' ):void 
		{
			var sSetResource:SSetResource = SSetResource.getInstance();
			
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
		//private 
		public function setAttributes(appid:String = '', objid:String = '', attr:String = ''):String
		{
			var sSetAttributes:SSetAttributes = SSetAttributes.getInstance();
			
			sSetAttributes.addEventListener(SoapEvent.SET_ATTRIBUTE_S_OK, ldispatchEvent);
			sSetAttributes.addEventListener(SoapEvent.SET_ATTRIBUTE_S_ERROR, ldispatchEvent);
			
			var key:String = sSetAttributes.execute(appid, objid, attr);
			return key;
		}
		
		/**
		 * 		22. set object name  'set_name' 
		 */
		public function setName(appid:String = '', objid:String = '', name:String = ''):void
		{
			var sSetName:SSetName = SSetName.getInstance();
			
			sSetName.addEventListener(SoapEvent.SET_NAME_OK, ldispatchEvent);
			sSetName.addEventListener(SoapEvent.SET_NAME_ERROR, ldispatchEvent);
			
			sSetName.execute(appid, objid, name);
		}
		
		/**
		 * 		23. Create WHOLE object - 'whole_create'
		 */
		public function wholeCreate(appid:String = '', parentid:String = '', name:String = '', data:String = ''):void
		{
			var sWholeCreate:SWholeCreate = SWholeCreate.getInstance();
			
			sWholeCreate.addEventListener(SoapEvent.WHOLE_CREATE_OK, ldispatchEvent);
			sWholeCreate.addEventListener(SoapEvent.WHOLE_CREATE_ERROR, ldispatchEvent);
			
			sWholeCreate.execute(appid, parentid, name, data);
		}

		/**
		 * 		24. Delete WHOLE object - 'whole_delete'
		 */
		public function wholeDelete(appid:String = '', objid:String = ''):void
		{
			var sWholeDelete:SWholeDelete = SWholeDelete.getInstance();
			
			sWholeDelete.addEventListener(SoapEvent.WHOLE_DELETE_OK, ldispatchEvent);
			sWholeDelete.addEventListener(SoapEvent.WHOLE_DELETE_ERROR, ldispatchEvent);
			
			sWholeDelete.execute(appid, objid);
		}

		/**
		 * 		25.  Update WHOLE object - 'whole_update'
		 */
		public function wholeUpdate(appid:String = '', objid:String = '', data:String = ''):void
		{
			var sWholeUpdate:SWholeUpdate = SWholeUpdate.getInstance();
			
			sWholeUpdate.addEventListener(SoapEvent.WHOLE_UPDATE_OK, ldispatchEvent);
			sWholeUpdate.addEventListener(SoapEvent.WHOLE_UPDATE_ERROR, ldispatchEvent);
			
			sWholeUpdate.execute(appid, objid, data);
		}

		/**
		 * 		26. Create new page for placing WHOLE objects - 'whole_create_page'
		 */
		public function wholeCreatePage(appid:String = '', sourceid:String = ''):void
		{
			var sWholeCreatePage:SWholeCreatePage = SWholeCreatePage.getInstance();
			
			sWholeCreatePage.addEventListener(SoapEvent.WHOLE_UPDATE_OK, ldispatchEvent);
			sWholeCreatePage.addEventListener(SoapEvent.WHOLE_UPDATE_ERROR, ldispatchEvent);
			
			sWholeCreatePage.execute(appid, sourceid);
		}
		
		
		public  function getChildObjectsTree(appid:String='',objid:String=''):void 
		{	
			var sGetChildObjectsTree:SGetChildObjectsTree = SGetChildObjectsTree.getInstance();
			
			sGetChildObjectsTree.addEventListener(SoapEvent.GET_CHILD_OBJECTS_TREE_OK, ldispatchEvent);
			sGetChildObjectsTree.addEventListener(SoapEvent.GET_CHILD_OBJECTS_TREE_ERROR, ldispatchEvent);
			
			sGetChildObjectsTree.execute(appid, objid);
		}
		
		
		//private 
		public  function getApplicationStructure(appid:String=''):void 
		{	
			var sGetApplicationStructure:SGetApplicationStructure = SGetApplicationStructure.getInstance();
			
			sGetApplicationStructure.addEventListener(SoapEvent.GET_APPLICATION_STRUCTURE_OK, ldispatchEvent);
			sGetApplicationStructure.addEventListener(SoapEvent.GET_APPLICATION_STRUCTURE_ERROR, ldispatchEvent);
			
			sGetApplicationStructure.execute(appid);
		}
		
		
	//	private
		public  function setApplicationStructure(appid:String='', struct:String = ''):void 
		{	
			 var sSetApplicationStructure:SSetApplicationStructure = SSetApplicationStructure.getInstance();
			
			sSetApplicationStructure.addEventListener(SoapEvent.SET_APPLICATION_STRUCTURE_OK, ldispatchEvent);
			sSetApplicationStructure.addEventListener(SoapEvent.SET_APPLICATION_STRUCTURE_ERROR, ldispatchEvent);
			
			sSetApplicationStructure.execute(appid, struct);
		}
		
		
	
		public  function submitObjectScriptPresentation(appid:String='', objid:String = '', pres:String = ''):void 
		{	
			var sSubmitObjectScriptPresentation:SSubmitObjectScriptPresentation = SSubmitObjectScriptPresentation.getInstance();
			
			sSubmitObjectScriptPresentation.addEventListener(SoapEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_OK, ldispatchEvent);
			sSubmitObjectScriptPresentation.addEventListener(SoapEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_ERROR, ldispatchEvent);
			
			sSubmitObjectScriptPresentation.execute(appid, objid, pres);
		}
		
	
		
		
		public  function getOneObject(appid:String='', struct:String = ''):void 
		{	
			var sGetOneObject:SGetOneObject = SGetOneObject.getInstance();
			
			sGetOneObject.addEventListener(SoapEvent.GET_ONE_OBJECT_OK, ldispatchEvent);
			sGetOneObject.addEventListener(SoapEvent.GET_ONE_OBJECT_ERROR, ldispatchEvent);
			
			sGetOneObject.execute(appid, struct);
		}
		
		public  function getObjectScriptPresentation(appid:String='', struct:String = ''):void 
		{	
			var sGetObjectScriptPresentation:SGetObjectScriptPresentation = SGetObjectScriptPresentation.getInstance();
			
			sGetObjectScriptPresentation.addEventListener(SoapEvent.GET_OBJECT_SCRIPT_PRESENTATION_OK, 		ldispatchEvent);
			sGetObjectScriptPresentation.addEventListener(SoapEvent.GET_OBJECT_SCRIPT_PRESENTATION_ERROR, 	ldispatchEvent);
			
			sGetObjectScriptPresentation.execute(appid, struct);
		}
		
		public function listResources(ownerid:String = ''):void
		{
			var sListResources:SListResources = SListResources.getInstance();
			
			sListResources.addEventListener(SoapEvent.LIST_RESOURSES_OK, ldispatchEvent);
			sListResources.addEventListener(SoapEvent.LIST_RESOURSES_ERROR, ldispatchEvent);
			
			sListResources.execute(ownerid);
		}
		
		/**
		 *  --------  Event Dispatcher -------------
		 */
		 
		
		
		//Error
		private  function errorListener(event:FaultEvent):void{
			//ed.dispatchEvent(event);
			trace('Блина, SOAP GLOBaL ERROR: \n' + event);
		}
    	public function ldispatchEvent(evt:SoapEvent):void{
      		//trace(evt.result);
			var soapEvent:SoapEvent = new SoapEvent(evt.type);
			soapEvent.result = evt.result;
			dispatchEvent(soapEvent);
			//trace(evt.type)
    	}	
	}
}

