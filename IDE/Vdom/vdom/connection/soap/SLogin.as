package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	import vdom.connection.protect.MD5;
	
	
	public class SLogin extends EventDispatcher 
	{
		private static 	var instance:SLogin;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SLogin() 
		{	
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.open_session.addEventListener(ResultEvent.RESULT,completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SLogin 
		{
			if (!instance)
				instance = new SLogin();
	
			return instance;
		}
		
		public function execute(login:String, password:String):void
		{
			// data
			var name:String		= login; 				 //- имя пользователя, строка
			var pwd_md5:String 	= MD5.encrypt(password); //- md5-хэш пароля, строка
			
			//send data & set listener 
			//ws.open_session.resultFormat = 'e4x';
			//ws.open_session(login, MD5.encrypt(password));
			ws.open_session(login, pwd_md5);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(event.result);
			
			var evt:SoapEvent;
			/*
			var resultXML:XML = 
			<Result>
				<HashString>{event.result.Session.HashString}</HashString>
				<SessionKey>{event.result.Session.SessionKey}</SessionKey>
				<SessionId>{event.result.Session.SessionId}</SessionId>
			</Result>; */
			
			// check Error
			if(resultXML.name().toString() == 'Error'){
				evt = new SoapEvent(SoapEvent.LOGIN_ERROR);
				evt.result = resultXML;
				dispatchEvent(evt);
				//Alert.show("ERROR!\nFrom: " + this.toString() )
			} else{
				
				// run session protector
				code.init(resultXML.HashString);
				code.inputSKey(resultXML.SessionKey);  
				code.sessionId = resultXML.SessionId;
		
			//	Alert.show("Password and User correct\nsid: "+ code.sessionId );
			//trace("Password and User correct\nsid: "+ code.sessionId);
		//	trace(this.toString() );
				evt = new SoapEvent(SoapEvent.LOGIN_OK);
				evt.result = resultXML;
				dispatchEvent(evt);
			}
		}
		
		public    function getResult():XML{
			return resultXML;
		}
	}
}