package com.vdom.connect
{
	import mx.core.Singleton;	
	import mx.rpc.soap.WebService;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.AbstractEvent;
	import com.gsolo.encryption.MD5;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import mx.controls.Alert;
	import com.gsolo.encryption.Code;
	
	public class Soap //extends EventDispatcher
	{
		private static var code:Code;
		private var dispatcher:EventDispatcher;
		private static var ws:WebService = new WebService;
		private static var sid:String; //sission Identifier
		
		public static function getSid():String{
			return sid;
		}
	//	public static var dispatchEvent;
		
		// initialization
		public static function init():void {
			ws.wsdl = 'http://192.168.0.23:82/vdom.wsdl';
			ws.useProxy = false;
			ws.loadWSDL();		
			ws.addEventListener(FaultEvent.FAULT, errorListener);
		}
		
		// 1 - open_session
		public  static function login(login:String, password:String):void {
			ws.open_session.arguments.name = login;
			ws.open_session.arguments.pwd_md5 = MD5.encrypt(password);
			ws.open_session();
			ws.open_session.addEventListener(ResultEvent.RESULT,loginCompleteListener);
		}

		private static function loginCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.open_session.lastResult.Result);
			// run session protector
			code = new Code(myXML.HashString);
			code.inputSKey(myXML.SessionKey);
			
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{  
				sid = myXML.SessionId;
				
				Alert.show("Password and User correct" );
				ws.open_session.removeEventListener(ResultEvent.RESULT,loginCompleteListener);
	//			this.dispatchEvent(new Event('loginLoadComplete'));
				
			}
		}	
		
		// 2 - close_session
		public static function closeSession():void {
			ws.close_session.arguments.sid = sid;
			ws.close_session();
			ws.close_session.addEventListener(ResultEvent.RESULT,closeSessionCompleteListener);	
		}

		private static function closeSessionCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.close_session.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("Сессия закрыта: " + myXML);
				ws.close_session.removeEventListener(ResultEvent.RESULT,closeSessionCompleteListener);
			}
		}
		
		
		// 3 - create application
		public static function createApplication():void {
			ws.create_application.arguments.sid = sid;
			ws.create_application.arguments.skey = code.skey();			
			ws.create_application();
			ws.create_application.addEventListener(ResultEvent.RESULT,createApplicationCompleteListener);	
		}

		private static function createApplicationCompleteListener(event:ResultEvent):void{
			var myXML:XMLList = XMLList(ws.create_application.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("createApplication: " + myXML);
				// myXML - идентификатор нового приложения
				ws.create_application.removeEventListener(ResultEvent.RESULT,createApplicationCompleteListener);
			}
		}
		
		// 4 - set application general information
		public static function setApplicationInfo():void {
			
			ws.set_application_info.arguments.sid = sid;
			ws.set_application_info.arguments.skey = code.skey();
			ws.set_application_info.arguments.appid  = 'any';//- идентификатор приложения;
			ws.set_application_info.arguments.attrname = 'any';//- имя атрибута приложения из раздела information
			ws.set_application_info.arguments.attrvalue = 'any';//- значение атрибута
						
			ws.set_application_info();
			ws.set_application_info.addEventListener(ResultEvent.RESULT,setApplicationInfoCompleteListener);	
		}

		private static function setApplicationInfoCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.set_application_info.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("setIpplicationInfo: " + myXML);
				// 'OK'
				ws.set_application_info.removeEventListener(ResultEvent.RESULT,setApplicationInfoCompleteListener);
			}
		}
		
		// 5 - get the list of all applications  'list_applications'
		public static function listApplications():void {
			
			ws.list_applications.arguments.sid = sid;
			ws.list_applications.arguments.skey = code.skey();
						
			ws.list_applications();
			ws.list_applications.addEventListener(ResultEvent.RESULT,listApplicationsCompleteListener);	
		}

		private static function listApplicationsCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.list_applications.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("setIpplicationInfo: " + myXML);
				// <Applications>
			    //     <Application id="id приложения" name="имя приложения"/>
        		// 	...
				// </Applications>*/
				ws.list_applications.removeEventListener(ResultEvent.RESULT,listApplicationsCompleteListener);
			}
		}
		 
		// 6 - get the list of all types 'list_types'
		public static function listTypes():void {
			
			ws.list_types.arguments.sid = sid;
			ws.list_types.arguments.skey = code.skey();
						
			ws.list_types();
			ws.list_types.addEventListener(ResultEvent.RESULT,listTypesCompleteListener);	
		}

		private static function listTypesCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.list_types.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("setIpplicationInfo: " + myXML);
				// <Types>
			    //     <Type id="id типа" name="имя типа"/>
        		// 	...
				// </Types>
				ws.list_applications.removeEventListener(ResultEvent.RESULT,listApplicationsCompleteListener);
			}
		}
				
		
		// 7 - get type description get_type
		public static function getType():void {
			
			ws.get_type.arguments.sid = sid;
			ws.get_type.arguments.skey = code.skey();
			ws.get_type.arguments.typeid  = 'any';//- идентификатор типа
						
			ws.get_type();
			ws.get_type.addEventListener(ResultEvent.RESULT,getTypeCompleteListener);	
		}

		private static function getTypeCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.get_type.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getType: \n" + myXML);
				// xml вида описание типа без ветки <Resources>
				ws.list_applications.removeEventListener(ResultEvent.RESULT,getTypeCompleteListener);
			}
		}
		
		// 8 - get type resource get_type_resource
		public static function getTypeResource():void {
			
			ws.get_type_resource.arguments.sid = sid;
			ws.get_type_resource.arguments.skey = code.skey();
			ws.get_type_resource.arguments.typeid  = 'any';//- идентификатор типа
			ws.get_type_resource.arguments.resid  = 'any';//- идентификатор ресурса
						
			ws.get_type_resource();
			ws.get_type_resource.addEventListener(ResultEvent.RESULT,getTypeResourceCompleteListener);	
		}

		private static function getTypeResourceCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.get_type_resource.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getType: \n" + myXML);
				// <Resource><![CDATA[resource data]]></Resource>
				ws.list_applications.removeEventListener(ResultEvent.RESULT,getTypeResourceCompleteListener);
			}
		}
		
		// 9 -  get application resource  'get_application_resource'
		public static function getApplicationResource():void {
			
			ws.get_application_resource.arguments.sid = sid;
			ws.get_application_resource.arguments.skey = code.skey();
			ws.get_application_resource.arguments.appid = 'any';//- идентификатор приложения
			ws.get_application_resource.arguments.resid  = 'any';//- идентификатор ресурса
						
			ws.get_application_resource();
			ws.get_application_resource.addEventListener(ResultEvent.RESULT,getApplicationResourceCompleteListener);	
		}

		private static function getApplicationResourceCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.get_application_resource.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getApplicationResource: \n" + myXML);
				// <Resource><![CDATA[resource data]]></Resource>
				ws.list_applications.removeEventListener(ResultEvent.RESULT,getApplicationResourceCompleteListener);
			}
		}
		
		//10. render object to xml presentation  - render_wysiwyg
		
		//11. create object - create_object
		
		//12. get application top-level objects  - get_top_objects
		
		//13. get object's child objects'  - get_child_objects
		
		//14. get application language data - get_application_language_data
		
		//15. set object attribute value - set_attribute
		
		//16. set object value
		//17. set object script
		//18. set application resource
		//19. delete object
		
		//20. get_echo
		public static function getEcho():void {
			
			ws.get_echo.arguments.sid = sid;
											
			ws.get_echo();
			ws.get_echo.addEventListener(ResultEvent.RESULT,getEchoCompleteListener);	
		}

		private static function getEchoCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.get_echo.lastResult.Result);
			if(myXML.Error.toString() == 'Error'){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getApplicationResource: \n" + ws.get_echo.lastResult.Result);
				//trace("getEcho:_" + myXML.Error.toString()+'!')
				// <Resource><![CDATA[resource data]]></Resource>
				ws.list_applications.removeEventListener(ResultEvent.RESULT,getEchoCompleteListener);
			}
		}
		
		//Error
		private static function errorListener(event:FaultEvent):void{
			Alert.show("Error:\n"+ event);
		}		
	}
}