package vdom.connection.soap
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.LoadEvent;
	import mx.rpc.soap.WebService;
	
		
	public class Soap  extends EventDispatcher
	{
		private static var ws			:WebService = new WebService();
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
			
			var sLogin:SLogin = new SLogin(ws); 
			sLogin.execute(login,password);
			sLogin.addEventListener(SoapEvent.LOGIN_OK,    ldispatchEvent  );
			sLogin.addEventListener(SoapEvent.LOGIN_ERROR, ldispatchEvent);
		}

		/**
		 *  2 - close_session  
		 */
		
		public  function closeSession():void 
		{
			var sCloseSession:SCloseSession = new SCloseSession(ws); 
			
			sCloseSession.execute();
			sCloseSession.addEventListener(SoapEvent.CLOSE_SESSION_OK, ldispatchEvent);
			sCloseSession.addEventListener(SoapEvent.CLOSE_SESSION_ERROR, ldispatchEvent);
		}

		/**
		 * 3 - create application  'create_application'
		 */ 
		
		public  function createApplication():void 
		{
			var sCreateApplication:SCreateApplication = new SCreateApplication(ws); 
			
			sCreateApplication.execute();
			sCreateApplication.addEventListener(SoapEvent.CREATE_APPLICATION_OK, ldispatchEvent);
			sCreateApplication.addEventListener(SoapEvent.CREATE_APPLICATION_ERROR, ldispatchEvent);
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
			var  sSetApplicationInfo:SSetApplicationInfo = new SSetApplicationInfo(ws);
			
			sSetApplicationInfo.execute(appid, attrname, attrvalue);
			sSetApplicationInfo.addEventListener(SoapEvent.SET_APLICATION_OK, ldispatchEvent);
			sSetApplicationInfo.addEventListener(SoapEvent.SET_APLICATION_ERROR, ldispatchEvent);
		}

		/**
		 *  5 - get the list of all applications  'list_applications'
		 */
		public  function listApplications():void 
		{
			var istApplications:SListApplications = new SListApplications(ws);
			istApplications.execute();
			istApplications.addEventListener(SoapEvent.LIST_APLICATION_OK, ldispatchEvent);
			istApplications.addEventListener(SoapEvent.LIST_APLICATION_ERROR, ldispatchEvent);
		}

		/**
		 *  6 - get the list of all types 'list_types'
		 */
		
		public  function listTypes():void 
		{
			var sListTipes:SListTypes = new SListTypes(ws);
			
			sListTipes.execute();
			sListTipes.addEventListener(SoapEvent.LIST_TYPES_OK, ldispatchEvent);
			sListTipes.addEventListener(SoapEvent.LIST_TYPES_ERROR, ldispatchEvent);
		}
		
		/**
		 *  7 - get type description get_type
		 */
		
		public  function getType(typeid:String=''):void 
		{
			var sGetType:SGetType = new SGetType(ws);
			
			sGetType.execute(typeid);
			sGetType.addEventListener(SoapEvent.GET_TYPE_OK, ldispatchEvent);
			sGetType.addEventListener(SoapEvent.GET_TYPE_ERROR, ldispatchEvent);
		}
		
		/** 
		 *  8 - get type resource get_resource
		 */
		private var sGetTypeResource:SGetResource = new SGetResource(ws);
		public  function getResource(ownerid:String='',resid:String=''):void 
		{
			
			
			sGetTypeResource.execute(ownerid, resid);
			sGetTypeResource.addEventListener(SoapEvent.GET_RESOURCE_OK, ldispatchEvent);
			sGetTypeResource.addEventListener(SoapEvent.GET_RESOURCE_ERROR, ldispatchEvent);
		}
		
		
		/**
		 * 9. render object to xml presentation  - render_wysiwyg
		 */
		private var sRenderWysiwig:SRenderWysiwyg = new SRenderWysiwyg(ws);
		public  function renderWysiwyg(appid:String='',objid:String='', parentid:String='' ,sdynamic:String  = '0'):void 
		{	
			sRenderWysiwig.execute(appid, objid, parentid, sdynamic);
			sRenderWysiwig.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, ldispatchEvent);
			sRenderWysiwig.addEventListener(SoapEvent.RENDER_WYSIWYG_ERROR, ldispatchEvent);
		}
		
		
		/**
		 * 10. create object - create_object
		 */
		private var sco: SCreateObject =new SCreateObject(ws);
		public function createObject(appid:String='',parentid:String='',typeid:String = '', attrs:String = '', name:String =''):void
		{
			
			sco.execute(appid,parentid,typeid, attrs, name);
			sco.addEventListener(SoapEvent.CREATE_OBJECT_OK, ldispatchEvent);
			sco.addEventListener(SoapEvent.CREATE_OBJECT_ERROR, ldispatchEvent);
		}
		
		
		/**
		 * 11. get application top-level objects  - get_top_objects
		 */
		 
		
		public  function getTopObjects(appid:String=''):void 
		{
			var sGetTopObjects:SGetTopObjects = new SGetTopObjects(ws);
			sGetTopObjects.execute(appid);
			sGetTopObjects.addEventListener(SoapEvent.GET_TOP_OBJECTS_OK, ldispatchEvent);
			sGetTopObjects.addEventListener(SoapEvent.GET_TOP_OBJECTS_ERROR, ldispatchEvent);
		}
		
		
		/**
		 * 12. get object's child objects'  - get_child_objects
		 */
		private var sGetChildObjects:SGetChildObjects = new SGetChildObjects(ws);
		
		public  function getChildObjects(appid:String='',objid:String=''):void 
		{
			
			sGetChildObjects.execute(appid, objid );
			sGetChildObjects.addEventListener(SoapEvent.GET_CHILD_OBJECTS_OK, ldispatchEvent);
			sGetChildObjects.addEventListener(SoapEvent.GET_CHILD_OBJECTS_ERROR, ldispatchEvent);
		}
		
		/**
		 * 13. get application language data - get_application_language_data
		 */
		
		public  function getApplicationLanguageData(appid:String=''):void 
		{
			var sGetApplicationLanguageData:SGetApplicationLanguageData = new SGetApplicationLanguageData(ws);
			
			sGetApplicationLanguageData.execute(appid);
			sGetApplicationLanguageData.addEventListener(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_OK, ldispatchEvent);
			sGetApplicationLanguageData.addEventListener(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_ERROR, ldispatchEvent);
		}
		
		
		/**
		 * 14. set object attribute value - set_attribute
		 */
		
		public  function setAttribute(appid:String='',objid:String='', attr:String='',value:String='' ):void 
		{
			var sSetAttribute:SSetAttribute = new SSetAttribute(ws);

			sSetAttribute.execute(appid, objid,attr, value);
			sSetAttribute.addEventListener(SoapEvent.SET_ATTRIBUTE_OK, ldispatchEvent);
			sSetAttribute.addEventListener(SoapEvent.SET_ATTRIBUTE_ERROR, ldispatchEvent);
		}
		
		/**
		 * 15. set object value set_value
		 */
		
		
		public  function setValue(appid:String='',objid:String='', value:String='' ):void 
		{
			var sSetValue:SSetValue = new SSetValue(ws);
			
			sSetValue.execute(appid, objid, value);
			sSetValue.addEventListener(SoapEvent.SET_VALUE_OK, ldispatchEvent);
			sSetValue.addEventListener(SoapEvent.SET_VALUE_ERROR, ldispatchEvent);
		}
		
		/**
		 * 16. set object script set_script
		 */
		
		public  function setScript(appid:String='',objid:String='', script:String='' ):void 
		{
			var sSetScript:SSetScript=  new SSetScript(ws);
			
			sSetScript.execute(appid, objid, script);
			sSetScript.addEventListener(SoapEvent.SET_SCRIPT_OK, ldispatchEvent);
			sSetScript.addEventListener(SoapEvent.SET_SCRIPT_ERROR, ldispatchEvent);
		}
		
		
		/**
		 * 17. set application resource set_resource
		 */
		
		public  function setResource(appid:String='',resid:String='', restype:String='', resname:String='', resdata:String='' ):void 
		{
			var sSetResource:SSetResource = new SSetResource(ws);
			
			sSetResource.execute(appid, resid, restype, resname, resdata);
			sSetResource.addEventListener(SoapEvent.SET_RESOURCE_OK, ldispatchEvent);
			sSetResource.addEventListener(SoapEvent.SET_RESOURCE_ERROR, ldispatchEvent);
		}
		
		
		/**
		 * 18. delete object delete_object
		 */
		
		public  function deleteObject(appid:String='',objid:String='' ):void 
		{
			var sDeleteObject:SDeleteObject = new SDeleteObject(ws);
			
			sDeleteObject.execute(appid, objid);
			sDeleteObject.addEventListener(SoapEvent.DELETE_OBJECT_OK, ldispatchEvent);
			sDeleteObject.addEventListener(SoapEvent.DELETE_OBJECT_ERROR, ldispatchEvent);
		}
		
		
		/**
		 * ------------- 19 get Echo --------
		 */ 
		public function getEcho():void
		{
			var sGetEcho:SGetEcho = new SGetEcho(ws);
			
			sGetEcho.execute();
			sGetEcho.addEventListener(SoapEvent.GET_ECHO_OK, ldispatchEvent);
			sGetEcho.addEventListener(SoapEvent.GET_ECHO_ERROR, ldispatchEvent);
		}
		
		/**
		 *  --------- 20 Get All Types -----
		 */ 
		public function getAllTypes():void
		{	
			var sGetAllTypes:SGetAllTypes = new SGetAllTypes(ws);
			
			sGetAllTypes.execute();
			sGetAllTypes.addEventListener(SoapEvent.GET_ALL_TYPES_OK, ldispatchEvent);
			sGetAllTypes.addEventListener(SoapEvent.GET_ALL_TYPES_ERROR, ldispatchEvent);
		}
		
		/**
		 *  --------- 21  Set value of several object's attributes -----
		 * 						--setAttributes --
		 */ 
		//private 
		public function setAttributes(appid:String = '', objid:String = '', attr:String = ''):void
		{
			var sSetAttributes:SSetAttributes = new SSetAttributes(ws);
			sSetAttributes.execute(appid, objid, attr);
			sSetAttributes.addEventListener(SoapEvent.SET_ATTRIBUTE_S_OK, ldispatchEvent);
			sSetAttributes.addEventListener(SoapEvent.SET_ATTRIBUTE_S_ERROR, ldispatchEvent);
		}
		
		/**
		 * 		22. set object name  'set_name' 
		 */
		public function setName(appid:String = '', objid:String = '', name:String = ''):void
		{
			var sSetName:SSetName = new SSetName(ws);
			sSetName.execute(appid, objid, name);
			sSetName.addEventListener(SoapEvent.SET_NAME_OK, ldispatchEvent);
			sSetName.addEventListener(SoapEvent.SET_NAME_ERROR, ldispatchEvent);
		}
		
		/**
		 * 		23. Create WHOLE object - 'whole_create'
		 */
		public function wholeCreate(appid:String = '', parentid:String = '', name:String = '', data:String = ''):void
		{
			var sWholeCreate:SWholeCreate = new SWholeCreate(ws);
			sWholeCreate.execute(appid, parentid, name, data);
			sWholeCreate.addEventListener(SoapEvent.WHOLE_CREATE_OK, ldispatchEvent);
			sWholeCreate.addEventListener(SoapEvent.WHOLE_CREATE_ERROR, ldispatchEvent);
		}

		/**
		 * 		24. Delete WHOLE object - 'whole_delete'
		 */
		public function wholeDelete(appid:String = '', objid:String = ''):void
		{
			var sWholeDelete:SWholeDelete = new SWholeDelete(ws);
			sWholeDelete.execute(appid, objid);
			sWholeDelete.addEventListener(SoapEvent.WHOLE_DELETE_OK, ldispatchEvent);
			sWholeDelete.addEventListener(SoapEvent.WHOLE_DELETE_ERROR, ldispatchEvent);
		}

		/**
		 * 		25.  Update WHOLE object - 'whole_update'
		 */
		public function wholeUpdate(appid:String = '', objid:String = '', data:String = ''):void
		{
			var sWholeUpdate:SWholeUpdate = new SWholeUpdate(ws);
			
			sWholeUpdate.execute(appid, objid, data);
			sWholeUpdate.addEventListener(SoapEvent.WHOLE_UPDATE_OK, ldispatchEvent);
			sWholeUpdate.addEventListener(SoapEvent.WHOLE_UPDATE_ERROR, ldispatchEvent);
		}

		/**
		 * 		26. Create new page for placing WHOLE objects - 'whole_create_page'
		 */
		public function wholeCreatePage(appid:String = '', sourceid:String = ''):void
		{
			var sWholeCreatePage:SWholeCreatePage = new SWholeCreatePage(ws);
			sWholeCreatePage.execute(appid, sourceid);
			sWholeCreatePage.addEventListener(SoapEvent.WHOLE_UPDATE_OK, ldispatchEvent);
			sWholeCreatePage.addEventListener(SoapEvent.WHOLE_UPDATE_ERROR, ldispatchEvent);
		}
		
		
		public  function getChildObjectsTree(appid:String='',objid:String=''):void 
		{	
			var sGetChildObjectsTree:SGetChildObjectsTree = new SGetChildObjectsTree(ws);
			sGetChildObjectsTree.execute(appid, objid);
			sGetChildObjectsTree.addEventListener(SoapEvent.GET_CHILD_OBJECTS_TREE_OK, ldispatchEvent);
			sGetChildObjectsTree.addEventListener(SoapEvent.GET_CHILD_OBJECTS_TREE_ERROR, ldispatchEvent);
		}
		
		
		//private 
		public  function getApplicationStructure(appid:String=''):void 
		{	
			var sGetApplicationStructure:SGetApplicationStructure = new SGetApplicationStructure(ws);
			sGetApplicationStructure.execute(appid);
			sGetApplicationStructure.addEventListener(SoapEvent.GET_APPLICATION_STRUCTURE_OK, ldispatchEvent);
			sGetApplicationStructure.addEventListener(SoapEvent.GET_APPLICATION_STRUCTURE_ERROR, ldispatchEvent);
		}
		
		
		private var sSetApplicationStructure:SSetApplicationStructure = new SSetApplicationStructure(ws);
		public  function setApplicationStructure(appid:String='', struct:String = ''):void 
		{	
			sSetApplicationStructure.execute(appid, struct);
			sSetApplicationStructure.addEventListener(SoapEvent.SET_APPLICATION_STRUCTURE_OK, ldispatchEvent);
			sSetApplicationStructure.addEventListener(SoapEvent.SET_APPLICATION_STRUCTURE_ERROR, ldispatchEvent);
		}
		
		
		private var sSubmitObjectScriptPresentation:SSubmitObjectScriptPresentation = new SSubmitObjectScriptPresentation(ws);
		public  function submitObjectScriptPresentation(appid:String='', struct:String = '', pres:String = ''):void 
		{	
			sSubmitObjectScriptPresentation.execute(appid, struct, pres);
			sSubmitObjectScriptPresentation.addEventListener(SoapEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_OK, ldispatchEvent);
			sSubmitObjectScriptPresentation.addEventListener(SoapEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_ERROR, ldispatchEvent);
		}
		
	
		
		private var sGetOneObject:SGetOneObject = new SGetOneObject(ws);
		public  function getOneObject(appid:String='', struct:String = ''):void 
		{	
			sGetOneObject.execute(appid, struct);
			sGetOneObject.addEventListener(SoapEvent.GET_ONE_OBJECT_OK, ldispatchEvent);
			sGetOneObject.addEventListener(SoapEvent.GET_ONE_OBJECT_ERROR, ldispatchEvent);
		}
		
		
		private var sGetObjectScriptPresentation:SGetObjectScriptPresentation = new SGetObjectScriptPresentation(ws);
		public  function getObjectScriptPresentation(appid:String='', struct:String = ''):void 
		{	
			sGetObjectScriptPresentation.execute(appid, struct);
			sGetObjectScriptPresentation.addEventListener(SoapEvent.GET_OBJECT_SCRIPT_PRESENTATION_OK, 		ldispatchEvent);
			sGetObjectScriptPresentation.addEventListener(SoapEvent.GET_OBJECT_SCRIPT_PRESENTATION_ERROR, 	ldispatchEvent);
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
    	}	
	}
}

