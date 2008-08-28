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
//	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		trace('login: '+ws.open_session.willTrigger(ResultEvent.RESULT))
	 		ws.open_session.addEventListener(ResultEvent.RESULT,completeListener);
	 		trace('login: '+ws.open_session.willTrigger(ResultEvent.RESULT))
 
		} 		
		 
		 // initialization		
		public static function getInstance():SLogin 
		{
//			if (!instance)
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
			trace('login: '+ws.open_session.willTrigger(ResultEvent.RESULT))
			resultXML = new XML(<Result />);
			resultXML.appendChild(XMLList(event.result));
			
			var se:SoapEvent;
			var errorResult:String = resultXML.Error;
			
			// check Error
			if(errorResult != "")
			{
				se = new SoapEvent(SoapEvent.LOGIN_ERROR);
				se.result = resultXML;
				dispatchEvent(se);
			}
			else
			{
				code.init(resultXML.Session.HashString);
				code.inputSKey(resultXML.Session.SessionKey);  
				code.sessionId = resultXML.Session.SessionId;
				
				se = new SoapEvent(SoapEvent.LOGIN_OK);
				se.result = resultXML;
				dispatchEvent(se);
				trace('Logined');
			}
		}
		
		public    function getResult():XML{
			return resultXML;
		}
	}
}