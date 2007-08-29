package com.connection.soap
{
	import mx.rpc.soap.WebService;
	import com.connection.protect.MD5;
	import com.connection.soap.*;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.rpc.soap.LoadEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.connection.soap.SoapEvent;
	import com.connection.utils.FileUpload;
	import mx.controls.Image;
	import mx.charts.AreaChart;
	import mx.controls.Button;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.display.DisplayObject;
		
	public class Soap  extends EventDispatcher
	{
		private static 	var ws			:WebService	= new WebService;
		private static 	var instance	:Soap;

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
             	ws.wsdl = wsdl;
				ws.useProxy = false;
				ws.loadWSDL();
				ws.addEventListener(FaultEvent.FAULT, errorListener  );
		}
	
		/**
		 *  1 - open session open_session
		 */
		private var sLogin:SLogin = new SLogin(ws); 

		public   function login( login:String='', password:String='' ):void 
		{	
			//var fun:Function;
			
			sLogin.execute(login,password);
			sLogin.addEventListener(SoapEvent.LOGIN_OK,    ldispatchEvent  );
			sLogin.addEventListener(SoapEvent.LOGIN_ERROR, ldispatchEvent);
		}
	/*
		public   function loginResult():XML 
		{
			return sLogin.getResult();
		}
	*/
		/**
		 *  2 - close_session  
		 */
		private var sCloseSession:SCloseSession = new SCloseSession(ws); 
		
		public  function closeSession():void 
		{
			sCloseSession.execute();
			sCloseSession.addEventListener(SoapEvent.CLOSE_SESSION_OK, ldispatchEvent);
			sCloseSession.addEventListener(SoapEvent.CLOSE_SESSION_ERROR, ldispatchEvent);
		}
		/*
		public   function closeSessionResult():XML 
		{
			return sCloseSession.getResult();
		}
		*/
		/**
		 * 3 - create application 
		 */ 
		private var sCreateApplication:SCreateApplication = new SCreateApplication(ws);  
		
		public  function createApplication():void 
		{
			sCreateApplication.execute();
			sCreateApplication.addEventListener(SoapEvent.CREATE_APPLICATION_OK, ldispatchEvent);
			sCreateApplication.addEventListener(SoapEvent.CREATE_APPLICATION_ERROR, ldispatchEvent);
		}
		
		public   function createApplicationResult():XML 
		{
			return sCreateApplication.getResult();
		}
		
		/**
		 *  4 - set application general information
		 */
		private var  sSetApplicationInfo:SSetApplicationInfo = new SSetApplicationInfo(ws);
		
		public  function setApplicationInfo(appid:String='',attrname:String='',attrvalue:String=''):void 
		{
			sSetApplicationInfo.execute(appid, attrname, attrvalue);
			sSetApplicationInfo.addEventListener(SoapEvent.SET_APLICATION_OK, ldispatchEvent);
			sSetApplicationInfo.addEventListener(SoapEvent.SET_APLICATION_ERROR, ldispatchEvent);
		}
		/*
		public   function setApplicationInfoResult():XML 
		{
			return sSetApplicationInfo.getResult();
		}
		*/
		/**
		 *  5 - get the list of all applications  'list_applications'
		 */
		private var istApplications:SListApplications = new SListApplications(ws);
		
		public  function listApplications():void 
		{
			istApplications.execute();
			istApplications.addEventListener(SoapEvent.LIST_APLICATION_OK, ldispatchEvent);
			istApplications.addEventListener(SoapEvent.LIST_APLICATION_ERROR, ldispatchEvent);
		}
		
		/* public   function listApplicationsResult():XML 
		{
			return istApplications.getResult();
		} */
		
		/**
		 *  6 - get the list of all types 'list_types'
		 */
		private var sListTipes:SListTypes = new SListTypes(ws);
		
		public  function listTypes():void 
		{
			sListTipes.execute();
			sListTipes.addEventListener(SoapEvent.LIST_TYPES_OK, ldispatchEvent);
			sListTipes.addEventListener(SoapEvent.LIST_TYPES_ERROR, ldispatchEvent);
		}
		
		/* public   function listTypesResult():XML {
			return sListTipes.getResult();
		} */
		
		/**
		 *  7 - get type description get_type
		 */
		private var sGetType:SGetType = new SGetType(ws);
		
		public  function getType(typeid:String=''):void 
		{
			sGetType.execute(typeid);
			sGetType.addEventListener(SoapEvent.GET_TYPE_OK, ldispatchEvent);
			sGetType.addEventListener(SoapEvent.GET_TYPE_ERROR, ldispatchEvent);
		}
		
		/* public   function sGetTypeResult():XML 
		{
			return sGetType.getResult();
		} */
		
		/**
		 *  8 - get type resource get_type_resource
		 */
		private var sGetTypeResource:SGetTypeResource = new SGetTypeResource(ws);
		
		public  function getTypeResource(typeid:String='',resid:String=''):void 
		{
			sGetTypeResource.execute(typeid, resid);
			sGetTypeResource.addEventListener(SoapEvent.GET_TYPE_RESOURCE_OK, ldispatchEvent);
			sGetTypeResource.addEventListener(SoapEvent.GET_TYPE_RESOURCE_ERROR, ldispatchEvent);
		}
		
		/* public   function getTypeResourceResult():XML 
		{
			return sGetTypeResource.getResult();
		} */
		
		/**
		 *  9 -  get application resource  'get_application_resource'
		 */
		private var sGetApplicationResource:SGetApplicationResource = new SGetApplicationResource(ws);
		
		public  function getApplicationResource(appid:String='',resid:String=''):void 
		{
			sGetApplicationResource.execute(appid, resid);
			sGetApplicationResource.addEventListener(SoapEvent.GET_APPLICATION_RESOURCE_OK, ldispatchEvent);
			sGetApplicationResource.addEventListener(SoapEvent.GET_APPLICATION_RESOURCE_ERROR, ldispatchEvent);
		}
		
		/* public   function getApplicationResourceResult():XML 
		{
			return sGetApplicationResource.getResult();
		} */
		
		/**
		 * 10. render object to xml presentation  - render_wysiwyg
		 */
		private var sRenderWysiwig:SRenderWysiwyg = new SRenderWysiwyg(ws);
		
		public  function renderWysiwyg(appid:String='',objid:String='',dynamik:String  = '0'):void 
		{
			sRenderWysiwig.execute(appid, objid, dynamik);
			sRenderWysiwig.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, ldispatchEvent);
			sRenderWysiwig.addEventListener(SoapEvent.RENDER_WYSIWYG_ERROR, ldispatchEvent);
		}
		
		/* public   function renderWysiwygResult():XML 
		{
			return sRenderWysiwig.getResult();
		} */
		
		/**
		 * 11. create object - create_object
		 */
		private var sco: SCreateObject =new SCreateObject(ws);
		
		public function createObject(appid:String='',parentid:String='',typeid:String = ''):void
		{
			sco.execute(appid,parentid,typeid);
			sco.addEventListener(SoapEvent.CREATE_OBJECT_OK, ldispatchEvent);
			sco.addEventListener(SoapEvent.CREATE_OBJECT_ERROR, ldispatchEvent);
		}
		
		/* public   function createObjectResult():XML 
		{
			return sco.getResult();
		} */
		
		/**
		 * 12. get application top-level objects  - get_top_objects
		 */
		private var sGetTopObjects:SGetTopObjects = new SGetTopObjects(ws);
		
		public  function getTopObjects(appid:String=''):void 
		{
			sGetTopObjects.execute(appid);
			sGetTopObjects.addEventListener(SoapEvent.GET_TOP_OBJECTS_OK, ldispatchEvent);
			sGetTopObjects.addEventListener(SoapEvent.GET_TOP_OBJECTS_ERROR, ldispatchEvent);
		}
		
		/* public   function getTopObjectsResult():XML 
		{
			return sGetTopObjects.getResult();
		} */
		
		/**
		 * 13. get object's child objects'  - get_child_objects
		 */
		private var sGetChildObjects:SGetChildObjects = new SGetChildObjects(ws);
		
		public  function getChildObjects(appid:String='',objid:String=''):void 
		{
			sGetChildObjects.execute(appid, objid );
			sGetChildObjects.addEventListener(SoapEvent.GET_CHILD_OBJECTS_OK, ldispatchEvent);
			sGetChildObjects.addEventListener(SoapEvent.GET_CHILD_OBJECTS_ERROR, ldispatchEvent);
		}
		
		/* public   function getChildObjectsResult():XML 
		{
			return sGetChildObjects.getResult();
		}
		 */
		/**
		 * 14. get application language data - get_application_language_data
		 */
		private var sGetApplicationLanguageData:SGetApplicationLanguageData = new SGetApplicationLanguageData(ws);
		
		public  function getApplicationLanguageData(appid:String=''):void 
		{
			sGetApplicationLanguageData.execute(appid);
			sGetApplicationLanguageData.addEventListener(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_OK, ldispatchEvent);
			sGetApplicationLanguageData.addEventListener(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_ERROR, ldispatchEvent);
		}
		
		/* public   function getApplicationLanguageDataResult():XML 
		{
			return sGetApplicationLanguageData.getResult();
		} */
		
		/**
		 * 15. set object attribute value - set_attribute
		 */
		private var sSetAttribute:SSetAttribute = new SSetAttribute(ws);
		
		public  function setAttribute(appid:String='',objid:String='', attr:String='',value:String='' ):void 
		{
			sSetAttribute.execute(appid, objid,attr, value);
			sSetAttribute.addEventListener(SoapEvent.SET_ATTRIBUTE_OK, ldispatchEvent);
			sSetAttribute.addEventListener(SoapEvent.SET_ATTRIBUTE_ERROR, ldispatchEvent);
		}
		
		/* public   function setAttributeResult():XML 
		{
			return sSetAttribute.getResult();
		} */
		/**
		 * 16. set object value set_value
		 */
		private var sSetValue:SSetValue = new SSetValue(ws);
		
		public  function setValue(appid:String='',objid:String='', value:String='' ):void 
		{
			sSetValue.execute(appid, objid, value);
			sSetValue.addEventListener(SoapEvent.SET_VALUE_OK, ldispatchEvent);
			sSetValue.addEventListener(SoapEvent.SET_VALUE_ERROR, ldispatchEvent);
		}
		
		/* public   function setValueResult():XML 
		{
			return sSetValue.getResult();
		} */
		/**
		 * 17. set object script set_script
		 */
		private var sSetScript:SSetScript=  new SSetScript(ws);
		
		public  function setScript(appid:String='',objid:String='', script:String='' ):void 
		{
			sSetScript.execute(appid, objid, script);
			sSetScript.addEventListener(SoapEvent.SET_SCRIPT_OK, ldispatchEvent);
			sSetScript.addEventListener(SoapEvent.SET_SCRIPT_ERROR, ldispatchEvent);
		}
		
		/* public   function setScriptResult():XML 
		{
			return sSetScript.getResult();
		} */
		
		/**
		 * 18. set application resource set_resource
		 */
		private var sSetResource:SSetResource = new SSetResource(ws);
		
		public  function setResource(appid:String='',resid:String='', restype:String='', resname:String='', resdata:String='' ):void 
		{
			sSetResource.execute(appid, resid, restype, resname, resdata);
			sSetResource.addEventListener(SoapEvent.SET_RESOURCE_OK, ldispatchEvent);
			sSetResource.addEventListener(SoapEvent.SET_RESOURCE_ERROR, ldispatchEvent);
		}
		
		/* public   function setResourceResult():XML 
		{
			return sSetResource.getResult();
		}	 */
		
		/**
		 * 19. delete object delete_object
		 */
		private var sDeleteObject:SDeleteObject = new SDeleteObject(ws);
		
		public  function deleteObject(appid:String='',objid:String='' ):void 
		{
			sDeleteObject.execute();
			sDeleteObject.addEventListener(SoapEvent.DELETE_OBJECT_OK, ldispatchEvent);
			sDeleteObject.addEventListener(SoapEvent.DELETE_OBJECT_ERROR, ldispatchEvent);
		}
		
		/* public   function deleteObjectResult():XML 
		{
			return sDeleteObject.getResult();
		} */

		/**
		 *  20 get Echo 
		 */ 
		private var sGetEcho:SGetEcho = new SGetEcho(ws);
		public function getEcho():void{
			sGetEcho.execute();
			sGetEcho.addEventListener(SoapEvent.GET_ECHO_OK, ldispatchEvent);
			sGetEcho.addEventListener(SoapEvent.GET_ECHO_ERROR, ldispatchEvent);
	//		this.btn = btn;
	//		masEcho[identificator] = new FileUpload();
	//		masListenet[identificator] =  new Function();
	//		masEcho[identificator].startUpload(ws, this.btn)
	//		masEcho[identificator].addEventListener(SoapEvent.GET_ECHO_OK, listenerOk);
	//		masEcho[identificator].addEventListener(SoapEvent.GET_ECHO_ERROR, istenerError);
		}
		
		/**
		 *  21 Get All Types 
		 */ 
		private var sGetAllTypes:SGetAllTypes = new SGetAllTypes(ws);
		public function getAllTypes():void{
			sGetAllTypes.execute();
			sGetAllTypes.addEventListener(SoapEvent.GET_ALL_TYPES_OK, ldispatchEvent);
			sGetAllTypes.addEventListener(SoapEvent.GET_ALL_TYPES_ERROR, ldispatchEvent);
		}
		/**
		 *  Event Dispatcher
		 */
	//	 private var ed:EventDispatcher = new EventDispatcher;
		 
		
		
		//Error
		private  function errorListener(event:FaultEvent):void{
			//ed.dispatchEvent(event);
			trace('Блина, SOAP GLOBSL ERROR: \n' + event);
		}

	/*	public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			  ed.addEventListener(type, listener, useCapture, priority);
    	}
           */
    	public function ldispatchEvent(evt:SoapEvent):void{
      		//trace(evt.result);
			var soapEvent:SoapEvent = new SoapEvent(evt.type);
			soapEvent.result = evt.result;
			dispatchEvent(soapEvent);
    	}	
	}
}

