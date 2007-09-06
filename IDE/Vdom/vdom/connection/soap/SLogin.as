package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	import vdom.connection.protect.MD5;
	
	
	public class SLogin extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SLogin(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute( login:String, password:String):void
		{
			// data
			ws.open_session.arguments.name 		= login; 				 //- имя пользователя, строка
			ws.open_session.arguments.pwd_md5 	= MD5.encrypt(password); //- md5-хэш пароля, строка
			
			//send data & set listener 
			ws.open_session();
			ws.open_session.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.open_session.lastResult.Result);
			var evt:SoapEvent;
			
			
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