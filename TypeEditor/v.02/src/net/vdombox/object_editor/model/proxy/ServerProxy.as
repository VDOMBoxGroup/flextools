package net.vdombox.object_editor.model.proxy
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.Operation;
	
	import net.vdombox.object_editor.event.SOAPErrorEvent;
	import net.vdombox.object_editor.event.SOAPEvent;
	import net.vdombox.object_editor.model.bisiness.SOAP;
	import net.vdombox.object_editor.model.vo.AuthInfoVO;
	import net.vdombox.object_editor.model.vo.ConnectInfoVO;
	import net.vdombox.object_editor.model.vo.ErrorVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class ServerProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ServerProxy";
		
		private static const PING_TIMER : uint = 900000;    
		
		private var soap : SOAP;
		
		private var _pingServerTimer : Timer;
		
		private var _authInfo : AuthInfoVO;
		
		private var _connectInfoVO : ConnectInfoVO;
		
		private var isSOAPConnected : Boolean;
		
		public function ServerProxy()
		{
			super( NAME );
		}
		
		override public function onRegister() : void
		{			
			soap = SOAP.getInstance();
			
			if ( soap.ready )
				soap.disconnect();
			
			addHandlers();
			
			_pingServerTimer = new Timer(PING_TIMER);
		}
		
		public function connect( connectInfoVO : ConnectInfoVO ) : void
		{			
			_authInfo = new AuthInfoVO();
			
			_connectInfoVO = connectInfoVO;
			
			_authInfo.setHostname( connectInfoVO.serverAddress );
			_authInfo.setUsername( connectInfoVO.userName );
			
			soap.connect( _authInfo.WSDLFilePath );				
		}
		
		public function uploadType( objectTypeXML : String ) : AsyncToken
		{		
			var token : AsyncToken;
			token = soap.set_type( objectTypeXML );		
			
			return token;
		}
		
		private function addHandlers() : void
		{
			soap.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			
			soap.addEventListener( SOAPEvent.CONNECTION_OK, soap_connectionOKHandler, false, 0, true );
			soap.addEventListener( SOAPErrorEvent.CONNECTION_ERROR, soap_connectionErrorHandler, false, 0, true );
			
			soap.addEventListener( SOAPEvent.DISCONNECTON_OK, soap_disconnectionOKHandler, false, 0, true );
			
			soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler, false, 0, true );
			soap.addEventListener( SOAPErrorEvent.LOGIN_ERROR, soap_loginErrorHandler, false, 0, true );
			
			soap.set_type.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_type.addEventListener( FaultEvent.FAULT, soap_faultHandler );
		}
		
		private function removeHandlers() : void
		{
			soap.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.removeEventListener( SOAPEvent.CONNECTION_OK, soap_connectionOKHandler );
			soap.removeEventListener( SOAPErrorEvent.CONNECTION_ERROR, soap_connectionErrorHandler );
			
			soap.removeEventListener( SOAPEvent.DISCONNECTON_OK, soap_disconnectionOKHandler );
			
			soap.removeEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );
			soap.removeEventListener( SOAPErrorEvent.LOGIN_ERROR, soap_loginErrorHandler );
			
			soap.set_type.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_type.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
		}
		
		private function soap_connectionOKHandler( event : SOAPEvent ) : void
		{
			isSOAPConnected = true;			
			soap.logon( _connectInfoVO.userName, _connectInfoVO.password );
		}
		
		private function soap_connectionErrorHandler( event : SOAPErrorEvent ) : void
		{
			var error : ErrorVO = new ErrorVO();
			
			error.code = event.faultCode;
			error.string = event.faultString;
			error.detail = event.faultDetail;
			
			sendNotification( ApplicationFacade.SERVER_CONNECTION_ERROR, error );
		}
		
		private function soap_disconnectionOKHandler( event : SOAPEvent ) : void
		{
			isSOAPConnected = false;
		}
		
		private function soap_loginOKHandler( event : SOAPEvent ) : void
		{
			var result : XML = event.result;
			
			_authInfo.serverVersion = result.ServerVersion[0].toString();
			
			startInfiniteSession();
		}
		
		private function startInfiniteSession() : void
		{
			Alert.show("Connect successfull!!!", "Success");
			
			sendNotification( ApplicationFacade.SERVER_LOGIN_OK );
			
			_pingServerTimer.addEventListener(TimerEvent.TIMER, pingOfServer); 
			_pingServerTimer.start();				
		}
		
		public function pingOfServer(event:TimerEvent):void  
		{ 	
			soap.keep_alive();
		} 
		
		
		private function soap_loginErrorHandler( event : SOAPErrorEvent ) : void
		{
			var error : ErrorVO = new ErrorVO();
			
			error.code = event.faultCode;
			error.string = event.faultString;
			error.detail = XML( event.faultDetail ).User[ 0 ];
			
			sendNotification( ApplicationFacade.SERVER_LOGIN_ERROR, error );
		}
		
		private function soap_resultHandler( event : SOAPEvent ) : void
		{
			var token : AsyncToken = event.token;
			var operation : Operation = event.currentTarget as Operation;
			if ( !operation )
				return;
			
			var operationName : String = operation.name;
			
			switch ( operationName )
			{
				case "set_type":
				{
					Alert.show("Set type successfull!!!", "Success");
					
					break;
				}
			}

		}
		
		private function soap_faultHandler( event : FaultEvent ) : void
		{
			var operation : Operation = event.target as Operation;
			
			if ( !operation )
				return;
			
			var operationName : String = operation.name;
			
			switch ( operationName )
			{
				case "set_type":
				{
					Alert.show("Not set type!!!", "Error");
					
					break;
				}
			}
		}
		
		
	}
}