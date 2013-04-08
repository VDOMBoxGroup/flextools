package proxy
{
	import connection.SOAP;
	import connection.SOAPEvent;
	
	import events.ContactsProxyEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import model.ContactVO;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	[Event(name="complete", type="flash.events.Event")]
	
	[Event(name="information", type="events.ContactsProxyEvent")]
	
	[Event(name="fault", type="events.ContactsProxyEvent")]
	
	
	public class ContactsProxy extends EventDispatcher
	{
		private static var instance : ContactsProxy;
		
		private var soap : SOAP = SOAP.getInstance();
		
		private var server : String; 
		private var login : String;  
		private var loginPassword : String; 
		private var user : String;
		private var userPassword : String;
		
		private var xml_param : String	= "<Arguments><CallType>server_action</CallType></Arguments>";
		private var appID : String = "526ae088-8004-469c-9d8e-cea715f8f63b";
		private var pageID : String = "79e13aa6-4498-4b1c-be99-47373df2cae2";
		
		
		private var _contacts : ArrayList;
		
		public function ContactsProxy(target:IEventDispatcher=null)
		{
			super(target);
		
			if ( instance )
				throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
			
			addEventListener(Event.COMPLETE, completeHandler);
		}
		
		
		public static function getInstance() : ContactsProxy
		{
			if ( !instance )
				instance = new ContactsProxy();
			
			return instance;
		}
		
		public  function get  contacts() : ArrayList
		{
			return _contacts;	
		}
		
		/**
		 * 
		 * Function for update contact list by loading them from server. Old data will be lost.
		 * 
		 * 
		 **/ 
		public function updateContacts( server: String, login : String, loginPassword : String, user : String, userPassword : String ):void
		{
			
			this.server = server;
			this.login = login;
			this.loginPassword = loginPassword;
			this.user = user;
			this.userPassword = userPassword;
			
			connectToServer();
		}
		
		
		private function connectToServer():void
		{
			dispatchInformation("Connecting...");
			
			var wsdl : String = "http://" + server + "/vdom.wsdl";
			
			soap.addEventListener( "loadWsdlComplete", soap_initCompleteHandler, false, 0, true );
			soap.addEventListener( FaultEvent.FAULT, soapError );
			soap.init( wsdl );
			
			function soap_initCompleteHandler( event : Event ) : void
			{
				soap.removeEventListener( "loadWsdlComplete", soap_initCompleteHandler );
				
				loginToServer();
			}
		}
		
		private function loginToServer( ) : void
		{
			dispatchInformation("Logining to server...");
			
			soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler, false, 0, true );
			soap.login( login, loginPassword );
			
			function soap_loginOKHandler( event : SOAPEvent ) : void
			{
				soap.removeEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );
				
				loginToProConatctApplication();
			}
		}
		
		
		
		
		public function soapError( event : FaultEvent ) : void
		{
			soap.removeEventListener( FaultEvent.FAULT, soapError );
			
			var message : String ;
			if ( "faultstring" in event.fault )
				message =  event.fault["faultstring"] ;
			else
				message =  event.fault.faultString ;
			
			dispatchEvent( new ContactsProxyEvent ( ContactsProxyEvent.FAULT, message ) );
		}
		
		private function loginToProConatctApplication(  ) : void
		{
			dispatchInformation("Logining to ProContact...");
			
			soap.remote_call.addEventListener( ResultEvent.RESULT, loginToAppResultHandler, false, 0, true );
			soap.remote_call.addEventListener( FaultEvent.FAULT, soapError );
			
			var actionName : String = "login";
			var data : String = '{"login" : "'+user+'", "password" : "'+ userPassword+'"}';
			
			
			soap.remote_call( appID, pageID,  "login", xml_param, data );
			
			function loginToAppResultHandler( event : ResultEvent ) : void
			{
				soap.remote_call.removeEventListener( ResultEvent.RESULT, loginToAppResultHandler );
				
				
				var result : Object =  getProContactAppResult( event.result as String );
				
				if ( result )
					loadContact();
			}
		}
		
		private function loadContact():void
		{
			dispatchInformation("Loading contacts...");
			
			soap.remote_call.addEventListener( ResultEvent.RESULT, retriveContactsResultHandler, false, 0, true );
			
			soap.remote_call( appID, pageID,  "retrieve_contacts", xml_param, '' );
			
			function retriveContactsResultHandler( event : ResultEvent ) : void
			{
				soap.remote_call.removeEventListener( ResultEvent.RESULT, retriveContactsResultHandler );
				soap.remote_call.removeEventListener( FaultEvent.FAULT, soapError );
				
				var result : Object =  getProContactAppResult(event.result as String);
				
				if ( result )
				{
					// careate contactVO
					crateContacts( result[1] as Array );
					
					dispatchEvent( new Event( Event.COMPLETE ) );
				}
			}
		}
		
		
		protected function crateContacts( contactsFromApp : Array ):void
		{
			var contactVO : ContactVO;
			var contactsVO : Array = [];

			var len : int = contactsFromApp.length;
			for ( var i:int = 0; i < len; i++ ) 
			{
				contactVO = new ContactVO( contactsFromApp[ i ] );
				contactsVO.push( contactVO ) 
				
			}
			
			contactsVO.sortOn(["label"]);
			
			_contacts = new ArrayList( contactsVO ); 
		}
		
		
		private function getProContactAppResult( result : String ) : Object
		{
			result = result.replace(/<Key>[0-9]+_[0-9]<\/Key>/, ""); 
			var resultObject : Object;
			try
			{
				if ( result != "" )
					resultObject = JSON.parse(result);
				
			} 
			catch ( error : Error )
			{
				var xml : XML = XML(result);
				
				dispatchEvent( new ContactsProxyEvent( ContactsProxyEvent.FAULT, xml ) );
			}
			
			if ( resultObject && resultObject[0] == 'error' )
			{
				dispatchEvent( new ContactsProxyEvent( ContactsProxyEvent.FAULT, resultObject[2] ) );
				return null;
			}
			
			return resultObject;
		}
		
		
		private function completeHandler( event : Event ):void
		{
			// TODO: save data to local storage
			
		}
		
		protected function dispatchInformation( message : String ):void
		{
			dispatchEvent( new ContactsProxyEvent( ContactsProxyEvent.INFORMATION, message ) );
		}
		
		public function quickSearch( request : String ) : ArrayList
		{
			var contacts : Array =  _contacts.source;
			
			if (request.length == 0 )
			{
				return  _contacts;
			}
			else 
			{
				var searchResult : ArrayList = new ArrayList();
				var full_name : String;
				var found : Boolean;
				var contact : Object;
				
				request  = request.toLowerCase();

				var usersCount : int =  contacts.length;
				for ( var i:int = 0; i < usersCount; i++ ) 
				{
					contact = contacts[i]
						
					full_name =  contact['label'];
					full_name = full_name.toLowerCase();
					
					found = full_name.search( request ) != -1
					if ( found  )
						searchResult.addItem(  contact );
				}
				
				return searchResult;
			}
		}
		
	}
}