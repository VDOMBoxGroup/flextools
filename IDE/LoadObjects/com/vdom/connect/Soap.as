package com.vdom.connect
{

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
	
	public class Soap 
	{
		private var code:Code;
		private var dispatcher:EventDispatcher;
		private var ws:WebService = new WebService;
		private var sid:String; //sission Identifier
		
		// initialization
		public function Soap():void {
			ws.wsdl = 'http://192.168.0.23:82/vdom.wsdl';
			ws.useProxy = false;
			ws.loadWSDL();		
			ws.addEventListener(FaultEvent.FAULT, errorListener);
		}
		
		// 1 - open_session
		public function login(login:String, password:String):void {
			ws.open_session.arguments.name = login;
			ws.open_session.arguments.pwd_md5 = MD5.encrypt(password);
			ws.open_session();
			ws.open_session.addEventListener(ResultEvent.RESULT,loginCompleteListener);
		}

		private function loginCompleteListener(event:ResultEvent):void{
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
			}
		}	
		
		// 2 - close_session
		public function closeSession():void {
			ws.close_session.arguments.sid = sid;
			ws.close_session();
			ws.close_session.addEventListener(ResultEvent.RESULT,closeSessionCompleteListener);	
		}

		private function closeSessionCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.close_session.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("Сессия закрыта: " + myXML);
				ws.close_session.removeEventListener(ResultEvent.RESULT,closeSessionCompleteListener);
			}
		}
		
		
		// 3 - create application
		public function createApplication():void {
			ws.create_application.arguments.sid = sid;
			ws.create_application.arguments.skey = code.skey();			
			ws.create_application();
			ws.create_application.addEventListener(ResultEvent.RESULT,createApplicationCompleteListener);	
		}

		private function createApplicationCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.create_application.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("createApplication: " + myXML);
				// myXML - идентификатор нового приложения
				ws.create_application.removeEventListener(ResultEvent.RESULT,createApplicationCompleteListener);
			}
		}
		
		// 4 - set application general information
		public function setApplicationInfo():void {
			
			ws.set_application_info.arguments.sid = sid;
			ws.set_application_info.arguments.skey = code.skey();
			ws.set_application_info.arguments.appid  = 'any';//- идентификатор приложения;
			ws.set_application_info.arguments.attrname = 'any';//- имя атрибута приложения из раздела information
			ws.set_application_info.arguments.attrvalue = 'any';//- значение атрибута
						
			ws.set_application_info();
			ws.set_application_info.addEventListener(ResultEvent.RESULT,setApplicationInfoCompleteListener);	
		}

		private function setApplicationInfoCompleteListener(event:ResultEvent):void{
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
		public function listApplications():void {
			
			ws.list_applications.arguments.sid = sid;
			ws.list_applications.arguments.skey = code.skey();
						
			ws.list_applications();
			ws.list_applications.addEventListener(ResultEvent.RESULT,listApplicationsCompleteListener);	
		}

		private function listApplicationsCompleteListener(event:ResultEvent):void{
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
		public function listTypes():void {
			
			ws.list_types.arguments.sid = sid;
			ws.list_types.arguments.skey = code.skey();
						
			ws.list_types();
			ws.list_types.addEventListener(ResultEvent.RESULT,listTypesCompleteListener);	
		}

		private function listTypesCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.list_types.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("setIpplicationInfo: " + myXML);
				// <Types>
			    //     <Application id="id приложения" name="имя приложения"/>
        		// 	...
				// </Types>
				ws.list_applications.removeEventListener(ResultEvent.RESULT,listApplicationsCompleteListener);
			}
		}
				
		
		// 7 - get type description get_type
		public function getType():void {
			
			ws.get_type.arguments.sid = sid;
			ws.get_type.arguments.skey = code.skey();
			ws.get_type.arguments.type_id  = 'any';//- идентификатор типа
						
			ws.get_type();
			ws.get_type.addEventListener(ResultEvent.RESULT,getTypeCompleteListener);	
		}

		private function getTypeCompleteListener(event:ResultEvent):void{
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
		public function getTypeResource():void {
			
			ws.get_type_resource.arguments.sid = sid;
			ws.get_type_resource.arguments.skey = code.skey();
			ws.get_type_resource.arguments.type_id  = 'any';//- идентификатор типа
			ws.get_type_resource.arguments.res_id  = 'any';//- идентификатор ресурса
						
			ws.get_type_resource();
			ws.get_type_resource.addEventListener(ResultEvent.RESULT,getTypeResourceCompleteListener);	
		}

		private function getTypeResourceCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.get_type_resource.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getType: \n" + myXML);
				// <Resource><![CDATA[resource data]]></Resource>
				ws.list_applications.removeEventListener(ResultEvent.RESULT,getTypeResourceCompleteListener);
			}
		}
		//Error
		private function errorListener(event:FaultEvent):void{
			Alert.show("Error:\n"+ event);
		}		
	}
}