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
		
	public class Soap 
	{
		
		private static 	var ws			:WebService	= new WebService;
		private static 	var instance	:Soap;
		
		private 		var ed			:EventDispatcher = new EventDispatcher;
		
		
		/**
		 *	  initialisation
		 */
		
		public function Soap() {
            if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
        } 		
		 
		 // initialization		
		 public static function getInstance(wsdl:String = 'http://192.168.0.23:82/vdom.wsdl'):Soap {
             
             if(!instance){
             	
				instance = new Soap();
			//	trace('WSDL')
             }
             return instance ;
        }		
		
		public function init(wsdl:String= 'http://192.168.0.23:82/vdom.wsdl'):void{
			
             	ws.wsdl = wsdl;
				ws.useProxy = false;
				ws.loadWSDL();
				ws.addEventListener(FaultEvent.FAULT,  errorListener  );
			
		}
		/////////////////!!!
		/////////////
/*		public class Command extends SoapEvent 
		{
			private var ws			:WebService;
		   public var ID
			public function Command(ws:WebService):void{
				this.ws = ws;
				this.ID = newguid()
			}
			
			public function execute():void{
			}
			public function addevents(method:Function):void{
			}
		}
		
		public class SLogin extends Command 
		{
			public login
			public function getresult(){
			if OK
				return true
				
			}
			public override function addevents(method:Function):void{
				this.addEventListener(SoapEvent.LOGIN_OK, dispatchEvent);
				this.addEventListener(SoapEvent.LOGIN_ERROR, dispatchEvent);
			}
			public function execute():void{
				ws.
			}
			public function dispatchEvent():void{
				if.....
			}
		}
		a="sdfsdf"
		b=a
		del(b)
		private var sLogin:SLogin = new SLogin(ws);
		sLogin.login = "abc"
		sLogin.password = "abc"
		Soap.execute(sLogin)
		sLogin.addEventListener(Event.ACTIVATE,mycom);*/
		////////////
		public   function execute(cmd:Command):void {
//			Soap.addEventListener(cmd.event,cmd.dispatch);
			hash[cmd.ID] = cmd
			cmd.addevents(Soap.addEventListener)
			cmd.execute()
		}
		/////////////////!!!
		/**
		 *  1 - open session open_session
		 */
		private var sLogin:SLogin = new SLogin(ws); 
		public   function login(login:String='', password:String=''):void {
			sLogin.execute(login,password);
			sLogin.addEventListener(SoapEvent.LOGIN_OK, dispatchEvent);
			sLogin.addEventListener(SoapEvent.LOGIN_ERROR, dispatchEvent);
		}
	
		public   function loginResult():XML {
			return sLogin.getResult();
		}
		
		/**
		 * 2 - close_session  
		 */
		private var sCloseSession:SCloseSession = new SCloseSession(ws); 
		public  function closeSession():void {
			sCloseSession.execute();
			sCloseSession.addEventListener(SoapEvent.CLOSE_SESSION_OK, dispatchEvent);
			sCloseSession.addEventListener(SoapEvent.CLOSE_SESSION_ERROR, dispatchEvent);
		}
		
		public   function Result():XML {
			return sCloseSession.getResult();
		}
		
		/**
		 * 3 - create application 
		 */ 
		private var sCreateApplication:SCreateApplication = new SCreateApplication(ws);  
		public  function createApplication():void {
			sCreateApplication.execute();
			sCreateApplication.addEventListener(SoapEvent.CREATE_APPLICATION_OK, dispatchEvent);
			sCreateApplication.addEventListener(SoapEvent.CREATE_APPLICATION_ERROR, dispatchEvent);
		}
		
		public   function Result():XML {
			return .getResult();
		}
		
		/**
		 *  4 - set application general information
		 */
		private var  sSetApplicationInfo:SSetApplicationInfo = new SSetApplicationInfo(ws);
		
		public  function setApplicationInfo(appid:String='',attrname:String='',attrvalue:String=''):void {
			sSetApplicationInfo.execute(appid, attrname, attrvalue);
			sSetApplicationInfo.addEventListener(SoapEvent.SET_APLICATION_OK, dispatchEvent);
			sSetApplicationInfo.addEventListener(SoapEvent.SET_APLICATION_ERROR, dispatchEvent);
		}
		
		public   function Result():XML {
			return .getResult();
		}
		
		/**
		 *  5 - get the list of all applications  'list_applications'
		 */
		private var istApplications:SListApplications = new SListApplications(ws);
		public  function listApplications():void {
			istApplications.execute();
			istApplications.addEventListener(SoapEvent.LIST_APLICATION_OK, dispatchEvent);
			istApplications.addEventListener(SoapEvent.LIST_APLICATION_ERROR, dispatchEvent);
		}
		
		/**
		 *  6 - get the list of all types 'list_types'
		 */
		private var sListTipes:SListTypes = new SListTypes(ws)
		public  function listTypes():void {
			sListTipes.execute();
			sListTipes.addEventListener(SoapEvent.LIST_TYPES_OK, dispatchEvent);
			sListTipes.addEventListener(SoapEvent.LIST_TYPES_ERROR, dispatchEvent);
		}
		
		/**
		 *  7 - get type description get_type
		 */
		private var sGetType:SGetType = new SGetType(ws);
		public  function getType(typeid:String=''):void {
			sGetType.execute(typeid);
			sGetType.addEventListener(SoapEvent.GET_TYPE_OK, dispatchEvent);
			sGetType.addEventListener(SoapEvent.GET_TYPE_ERROR, dispatchEvent);
		}
		
		/**
		 *  8 - get type resource get_type_resource
		 */
		private var sGetTypeResource:SGetTypeResource = new SGetTypeResource(ws);
		public  function getTypeResource(typeid:String='',resid:String=''):void {
			sGetTypeResource.execute(typeid, resid);
			sGetTypeResource.addEventListener(SoapEvent.GET_TYPE_RESOURCE_OK, dispatchEvent);
			sGetTypeResource.addEventListener(SoapEvent.GET_TYPE_RESOURCE_ERROR, dispatchEvent);
		}
		
		/**
		 *  9 -  get application resource  'get_application_resource'
		 */
		private var sGetApplicationResource:SGetApplicationResource = new SGetApplicationResource(ws);
		public  function getApplicationResource(appid:String='',resid:String=''):void {
			sGetApplicationResource.execute(appid, resid);
			sGetApplicationResource.addEventListener(SoapEvent.GET_APPLICATION_RESOURCE_OK, dispatchEvent);
			sGetApplicationResource.addEventListener(SoapEvent.GET_APPLICATION_RESOURCE_ERROR, dispatchEvent);
		}
		
		/**
		 * 10. render object to xml presentation  - render_wysiwyg
		 */
		private var sRenderWysiwig:SRenderWysiwyg = new SRenderWysiwyg(ws);
		public  function renderWysiwyg(appid:String='',objid:String='',dynamic:String = ''):void {
			sRenderWysiwig.execute(appid, objid, dynamic);
			sRenderWysiwig.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, dispatchEvent);
			sRenderWysiwig.addEventListener(SoapEvent.RENDER_WYSIWYG_ERROR, dispatchEvent);
		}
		
		/**
		 * 11. create object - create_object
		 */
		private var sco: SCreateObject =new SCreateObject(ws);
		public function createObject(appid:String='',parentid:String='',typeid:String = ''):void{
			sco.execute(appid,parentid,typeid);
			sco.addEventListener(SoapEvent.CREATE_OBJECT_OK, dispatchEvent);
			sco.addEventListener(SoapEvent.CREATE_OBJECT_ERROR, dispatchEvent);
		}
		/**
		 * 12. get application top-level objects  - get_top_objects
		 */
		private var sGetTopObjects:SGetTopObjects = new SGetTopObjects(ws);
		public  function getTopObjects(appid:String=''):void {
			sGetTopObjects.execute(appid);
			sGetTopObjects.addEventListener(SoapEvent.GET_TOP_OBJECTS_OK, dispatchEvent);
			sGetTopObjects.addEventListener(SoapEvent.GET_TOP_OBJECTS_ERROR, dispatchEvent);
		}
		
		/**
		 * 13. get object's child objects'  - get_child_objects
		 */
		private var sGetChildObjects:SGetChildObjects = new SGetChildObjects(ws);
		public  function getChildObjects(appid:String='',objid:String=''):void {
			sGetChildObjects.execute(appid, objid );
			sGetChildObjects.addEventListener(SoapEvent.GET_CHILD_OBJECTS_OK, dispatchEvent);
			sGetChildObjects.addEventListener(SoapEvent.GET_CHILD_OBJECTS_ERROR, dispatchEvent);
		}
		
		/**
		 * 14. get application language data - get_application_language_data
		 */
		private var sGetApplicationLanguageData:SGetApplicationLanguageData = new SGetApplicationLanguageData(ws);
		public  function getApplicationLanguageData(appid:String=''):void {
			sGetApplicationLanguageData.execute(appid);
			sGetApplicationLanguageData.addEventListener(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_OK, dispatchEvent);
			sGetApplicationLanguageData.addEventListener(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_ERROR, dispatchEvent);
		}
		/**
		 * 15. set object attribute value - set_attribute
		 */
		private var sSetAttribute:SSetAttribute = new SSetAttribute(ws);
		public  function setAttribute(appid:String='',objid:String='', attr:String='',value:String='' ):void {
			sSetAttribute.execute(appid, objid,attr, value);
			sSetAttribute.addEventListener(SoapEvent.SET_APLICATION_OK, dispatchEvent);
			sSetAttribute.addEventListener(SoapEvent.SET_APLICATION_ERROR, dispatchEvent);
		}
		
		/**
		 * 16. set object value set_value
		 */
		private var sSetValue:SSetValue = new SSetValue(ws);
		public  function setValue(appid:String='',objid:String='', value:String='' ):void {
			sSetValue.execute(appid, objid, value);
			sSetValue.addEventListener(SoapEvent.SET_VALUE_OK, dispatchEvent);
			sSetValue.addEventListener(SoapEvent.SET_VALUE_ERROR, dispatchEvent);
		}
		
		/**
		 * 17. set object script set_script
		 */
		private var sSetScript:SSetScript=  new SSetScript(ws);
		public  function setScript(appid:String='',objid:String='', script:String='' ):void {
			sSetScript.execute(appid, objid, script);
			sSetScript.addEventListener(SoapEvent.SET_SCRIPT_OK, dispatchEvent);
			sSetScript.addEventListener(SoapEvent.SET_SCRIPT_ERROR, dispatchEvent);
		}
		/**
		 * 18. set application resource set_resource
		 */
		private var sSetResource:SSetResource = new SSetResource(ws);
		public  function setResource(appid:String='',resid:String='', resdata:String='' ):void {
			sSetResource.execute(appid, resid,resdata);
			sSetResource.addEventListener(SoapEvent.SET_RESOURCE_OK, dispatchEvent);
			sSetResource.addEventListener(SoapEvent.SET_RESOURCE_ERROR, dispatchEvent);
		}
			
		/**
		 * 19. delete object delete_object
		 */
		private var sDeleteObject:SDeleteObject = new SDeleteObject(ws);
		public  function deleteObject(appid:String='',objid:String='' ):void {
			sDeleteObject.execute();
			sDeleteObject.addEventListener(SoapEvent.DELETE_OBJECT_OK, dispatchEvent);
			sDeleteObject.addEventListener(SoapEvent.DELETE_OBJECT_ERROR, dispatchEvent);
		}

		/**
		 *  20
		 */ 
		private var masEcho:Array = new Array();
		private var masListenet:Array = new Array();
		private var btn:Button;
		public function sendEcho(identificator:String, btn:Button,	 listenerOk:Function, istenerError:Function):void{
			this.btn = btn;
			masEcho[identificator] = new FileUpload();
			masListenet[identificator] =  new Function();
			masEcho[identificator].startUpload(ws, this.btn)
			masEcho[identificator].addEventListener(SoapEvent.GET_ECHO_OK, listenerOk);
			masEcho[identificator].addEventListener(SoapEvent.GET_ECHO_ERROR, istenerError);
		}
		
		public function getEchoResult(identificator:String):Image{
			return masEcho[identificator].getResul();
		}
		
		
		//Error
		private  function errorListener(event:ResultEvent):void{
			dispatchEvent(event);
		}

		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			  ed.addEventListener(type, listener, useCapture, priority);
    	}
           
    	public function dispatchEvent(evt:Event):Boolean{
      		return	 ed.dispatchEvent(evt);
    	}		
	}
}

