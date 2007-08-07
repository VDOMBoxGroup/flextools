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
	
	public class Soap 
	{
		private static var code:Code;
		private var dispatcher:EventDispatcher;
		private static var ws:WebService = new WebService;
		private static var sid:String; //sission Identifier
		
		public static function getSid():String{
			return sid;
		}

		
		// initialization
		public static function init():void {
			ws.wsdl = 'http://192.168.0.23:82/vdom.wsdl';
			ws.useProxy = false;
			ws.loadWSDL();		
			ws.addEventListener(FaultEvent.FAULT, errorListener);
		}
		
		// 1 - open session open_session
		public  static function login(login:String='NaN', password:String='NaN'):void {
			ws.open_session.arguments.name 		= login; 				 //- имя пользователя, строка
			ws.open_session.arguments.pwd_md5 	= MD5.encrypt(password); //- md5-хэш пароля, строка
			
			ws.open_session();
			ws.open_session.addEventListener(ResultEvent.RESULT,loginCompleteListener);
		}

		private static function loginCompleteListener(event:ResultEvent):void{
			
			var myXML:XML = XML(ws.open_session.lastResult.Result);
			
			// run session protector
			code = new Code(myXML.HashString);
			code.inputSKey(myXML.SessionKey);
			
			if(myXML.children().toXMLString() == ''){
				Alert.show("Error from server:\n" + myXML );
			} else{  
				sid = myXML.SessionId;
			
				Alert.show("Password and User correct\nsid: "+ sid  );
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
			if(myXML.children().toXMLString() == ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("Сессия закрыта: " + myXML);
				ws.close_session.removeEventListener(ResultEvent.RESULT,closeSessionCompleteListener);
			}
		}
		
		
		// 3 - create application
		public static function createApplication():void {
			ws.create_application.arguments.sid 		= sid;			// - идентификатор сессии 
			ws.create_application.arguments.skey 		= code.skey();	//- очередной ключ сессии 

			ws.create_application();
			ws.create_application.addEventListener(ResultEvent.RESULT,createApplicationCompleteListener);	
		}

		private static function createApplicationCompleteListener(event:ResultEvent):void{
			var myXML:XMLList = XMLList(ws.create_application.lastResult.Result);
			if(myXML.children().toXMLString() == ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("createApplication: " + myXML);
				// myXML - идентификатор нового приложения
				ws.create_application.removeEventListener(ResultEvent.RESULT,createApplicationCompleteListener);
			}
		}
		
		// 4 - set application general information
		public static function setApplicationInfo(appid:String='NaN',attrname:String='NaN',attrvalue:String='NaN'):void {
			
			ws.set_application_info.arguments.sid 		= sid;			// - идентификатор сессии 
			ws.set_application_info.arguments.skey 		= code.skey();	//- очередной ключ сессии 
			ws.set_application_info.arguments.appid  	= appid;		//- идентификатор приложения;
			ws.set_application_info.arguments.attrname 	= attrname;		//- имя атрибута приложения из раздела information
			ws.set_application_info.arguments.attrvalue = attrvalue;	//- значение атрибута
						
			ws.set_application_info();
			ws.set_application_info.addEventListener(ResultEvent.RESULT,setApplicationInfoCompleteListener);	
		}

		private static function setApplicationInfoCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.set_application_info.lastResult.Result);
			if(myXML.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("setIpplicationInfo: " + myXML);
				// 'OK'
		//		ws.set_application_info.removeEventListener(ResultEvent.RESULT,setApplicationInfoCompleteListener);
			}
		}
		
		// 5 - get the list of all applications  'list_applications'
		public static function listApplications():void {
			
			ws.list_applications.arguments.sid 	= sid;			// - идентификатор сессии 
			ws.list_applications.arguments.skey = code.skey();	//- очередной ключ сессии 
						
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
			
			ws.list_types.arguments.sid 		= sid;				// - идентификатор сессии 
			ws.set_attribute.arguments.skey 	= code.skey();		//- очередной ключ сессии 
						
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
		public static function getType(typeid:String='NaN'):void {
			
			ws.get_type.arguments.sid 		= sid;			// - идентификатор сессии 
			ws.get_type.arguments.skey 		= code.skey();	//- очередной ключ сессии 
			ws.get_type.arguments.typeid  	= typeid;		//- идентификатор типа
						
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
		public static function getTypeResource(typeid:String='NaN',resid:String='NaN'):void {
			
			ws.get_type_resource.arguments.sid 		= sid;			// - идентификатор сессии 
			ws.get_type_resource.arguments.skey 	= code.skey();	//- очередной ключ сессии 
			ws.get_type_resource.arguments.typeid  	= typeid;		//- идентификатор типа
			ws.get_type_resource.arguments.resid  	= resid;		//- идентификатор ресурса
						
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
		public static function getApplicationResource(appid:String='NaN',resid:String='NaN'):void {
			
			ws.get_application_resource.arguments.sid 		= sid;			// - идентификатор сессии 
			ws.get_application_resource.arguments.skey 		= code.skey();	//- очередной ключ сессии 
			ws.get_application_resource.arguments.appid 	= appid;		//- идентификатор приложения
			ws.get_application_resource.arguments.resid  	= resid;		//- идентификатор ресурса
						
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

		public static function renderWysiwyg(appid:String='NaN',objid:String='NaN',dynamic:String = 'NaN'):void {
			
			ws.render_wysiwyg.arguments.sid 	= sid; 			// - идентификатор сессии 
			ws.render_wysiwyg.arguments.skey 	= code.skey(); 	//- очередной ключ сессии 
			ws.render_wysiwyg.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.render_wysiwyg.arguments.objid  	= objid;		//- идентификатор объекта 
			ws.render_wysiwyg.arguments.dynamic  = dynamic;		//- способ рендеринга: для только что созданных объектов нужно указывать 0, для всех остальных 1
						
			ws.render_wysiwyg();
			ws.render_wysiwyg.addEventListener(ResultEvent.RESULT,renderWysiwygCompleteListener);	
		}

		private static function renderWysiwygCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.render_wysiwyg.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getType: \n" + myXML);
				// <Resource><![CDATA[resource data]]></Resource>
				ws.render_wysiwyg.removeEventListener(ResultEvent.RESULT,renderWysiwygCompleteListener);
			}
		}

		//11. create object - create_object
/*
 
 */
		public static function createObject(appid:String='NaN',parentid:String='NaN',typeid:String = 'NaN'):void {
			
			ws.create_object.arguments.sid 		= sid; 			// - идентификатор сессии 
			ws.create_object.arguments.skey 	= code.skey(); 	//- очередной ключ сессии 
			ws.create_object.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.create_object.arguments.parentid = parentid;		//- идентификатор объекта 
			ws.create_object.arguments.typeid  	= typeid;		//- идентификатор типа
						
			ws.create_object();
			ws.create_object.addEventListener(ResultEvent.RESULT,createObjectCompleteListener);	
		}

		private static function createObjectCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.create_object.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getType: \n" + myXML);
				// <Resource><![CDATA[resource data]]></Resource>
				ws.render_wysiwyg.removeEventListener(ResultEvent.RESULT,createObjectCompleteListener);
			}
		}
		
		
		//12. get application top-level objects  - get_top_objects
/*
 
 */
		public static function getTopObjects(appid:String='NaN'):void {
			
			ws.get_top_objects.arguments.sid 	= sid; 			// - идентификатор сессии 
			ws.get_top_objects.arguments.skey 	= code.skey(); 	//- очередной ключ сессии 
			ws.get_top_objects.arguments.appid  = appid;		//- идентификатор приложения 
							
			ws.get_top_objects();
			ws.get_top_objects.addEventListener(ResultEvent.RESULT,getTopObjectsCompleteListener);	
		}

		private static function getTopObjectsCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.get_top_objects.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getType: \n" + myXML);
				// <Resource><![CDATA[resource data]]></Resource>
				ws.render_wysiwyg.removeEventListener(ResultEvent.RESULT,getTopObjectsCompleteListener);
			}
		}
		
		
		//13. get object's child objects'  - get_child_objects
/*

 */
		public static function getChildObjects(appid:String='NaN',objid:String='NaN'):void {
			
			ws.get_child_objects.arguments.sid 		= sid; 			// - идентификатор сессии 
			ws.get_child_objects.arguments.skey 	= code.skey(); 	//- очередной ключ сессии 
			ws.get_child_objects.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.get_child_objects.arguments.objid  	= objid;		//- идентификатор объекта 
						
			ws.get_child_objects();
			ws.get_child_objects.addEventListener(ResultEvent.RESULT,getChildObjectsCompleteListener);	
		}

		private static function getChildObjectsCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.get_child_objects.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getType: \n" + myXML);
				// <Resource><![CDATA[resource data]]></Resource>
				ws.render_wysiwyg.removeEventListener(ResultEvent.RESULT,getChildObjectsCompleteListener);
			}
		}
	/*
		//14. get application language data - get_application_language_data
/*

 */
		public static function getApplicationLanguageData(appid:String='NaN'):void {
			
			ws.get_application_language_data.arguments.sid 		= sid; 			// - идентификатор сессии 
			ws.get_application_language_data.arguments.skey 	= code.skey(); 	//- очередной ключ сессии 
			ws.get_application_language_data.arguments.appid  	= appid;		//- идентификатор приложения 
						
			ws.get_application_language_data();
			ws.get_application_language_data.addEventListener(ResultEvent.RESULT,getApplicationLanguageCompleteListener);	
		}

		private static function getApplicationLanguageCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.get_application_language_data.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getType: \n" + myXML);
				// <Resource><![CDATA[resource data]]></Resource>
				ws.render_wysiwyg.removeEventListener(ResultEvent.RESULT,getApplicationLanguageCompleteListener);
			}
		}
	/*
	
		//15. set object attribute value - set_attribute
/*

 */
		public static function setAttribute(appid:String='NaN',objid:String='NaN', attr:String='NaN',value:String='NaN' ):void {
			
			ws.set_attribute.arguments.sid 		= sid; 			// - идентификатор сессии 
			ws.set_attribute.arguments.skey 	= code.skey();	//- очередной ключ сессии 
			ws.set_attribute.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.set_attribute.arguments.objid  	= objid;		//- идентификатор объекта
			ws.set_attribute.arguments.attr  	= attr;			//- имя атрибута  
			ws.set_attribute.arguments.value 	= value;		//- значение атрибута
						
			ws.set_attribute();
			ws.set_attribute.addEventListener(ResultEvent.RESULT,setAttributeCompleteListener);	
		}

		private static function setAttributeCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.set_attribute.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getType: \n" + myXML);
				// <Resource><![CDATA[resource data]]></Resource>
				ws.render_wysiwyg.removeEventListener(ResultEvent.RESULT,setAttributeCompleteListener);
			}
		}
		
		//16. set object value set_value
/*

 */
		public static function setValue(appid:String='NaN',objid:String='NaN', value:String='NaN' ):void {
			
			ws.set_value.arguments.sid 		= sid; 			// - идентификатор сессии 
			ws.set_value.arguments.skey 	= code.skey();	//- очередной ключ сессии 
			ws.set_value.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.set_value.arguments.objid  	= objid;		//- идентификатор объекта
			ws.set_value.arguments.value  	= value;		//- имя атрибута  
						
			ws.set_value();
			ws.set_value.addEventListener(ResultEvent.RESULT,setValueCompleteListener);	
		}

		private static function setValueCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.set_value.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getType: \n" + myXML);
				// <Resource><![CDATA[resource data]]></Resource>
				ws.render_wysiwyg.removeEventListener(ResultEvent.RESULT,setValueCompleteListener);
			}
		}
	
		//17. set object script set_script
/*

 */
		public static function setScript(appid:String='NaN',objid:String='NaN', script:String='NaN' ):void {
			
			ws.set_script.arguments.sid 		= sid; 			// - идентификатор сессии 
			ws.set_script.arguments.skey 		= code.skey();	//- очередной ключ сессии 
			ws.set_script.arguments.appid  		= appid;		//- идентификатор приложения 
			ws.set_script.arguments.objid  		= objid;		//- идентификатор объекта
			ws.set_script.arguments.script  	= script;		//- текст скрипта 
						
			ws.set_script();
			ws.set_script.addEventListener(ResultEvent.RESULT,setScriptCompleteListener);	
		}

		private static function setScriptCompleteListener(event:ResultEvent):void{
			
			var myXML:XML = XML(ws.set_script.lastResult.Result);
			
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getType: \n" + myXML);
				// <Resource><![CDATA[resource data]]></Resource>
				ws.render_wysiwyg.removeEventListener(ResultEvent.RESULT,setScriptCompleteListener);
			}
		}
	
		//18. set application resource set_resource
/*

 */
		public static function setResource(appid:String='NaN',resid:String='NaN', resdata:String='NaN' ):void {
			
			ws.set_resource.arguments.sid 		= sid; 			// - идентификатор сессии 
			ws.set_resource.arguments.skey 		= code.skey();	//- очередной ключ сессии 
			ws.set_resource.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.set_resource.arguments.resid  	= resid;		//- идентификатор ресурса: необходимо указывать для изменения существующего ресурса; 
																	// для добавления нового - пустая строка
			ws.set_resource.arguments.resdata  	= resdata;		//- текст скрипта 
						
			ws.set_resource();
			ws.set_resource.addEventListener(ResultEvent.RESULT,setResourceCompleteListener);	
		}

		private static function setResourceCompleteListener(event:ResultEvent):void{
			
			var myXML:XML = XML(ws.set_resource.lastResult.Result);
			
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getType: \n" + myXML);
				// <Resource><![CDATA[resource data]]></Resource>
				ws.render_wysiwyg.removeEventListener(ResultEvent.RESULT,setResourceCompleteListener);
			}
		}
	
			
		//19. delete object delete_object
/*

 */
		public static function deleteObject(appid:String='NaN',objid:String='NaN' ):void {
			
			ws.set_resource.arguments.sid 			= sid; 			// - идентификатор сессии 
			ws.set_resource.arguments.skey 			= code.skey();	//- очередной ключ сессии 
			ws.set_resource.arguments.appid  		= appid;		//- идентификатор приложения 
			ws.set_resource.arguments.objid  		= objid;		//- идентификатор объекта
			
						
			ws.set_resource();
			ws.set_resource.addEventListener(ResultEvent.RESULT,deleteObjecCompleteListener);	
		}

		private static function deleteObjecCompleteListener(event:ResultEvent):void{
			
			var myXML:XML = XML(ws.set_resource.lastResult.Result);
			
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("getType: \n" + myXML);
				// <Resource><![CDATA[resource data]]></Resource>
				ws.render_wysiwyg.removeEventListener(ResultEvent.RESULT,deleteObjecCompleteListener);
			}
		}
	/*
		*/
		//20. get temporarily stored session data  get_echo
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