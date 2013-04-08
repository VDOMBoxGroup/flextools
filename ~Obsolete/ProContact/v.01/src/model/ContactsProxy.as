//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package model
{
	import connection.SOAP;
	import connection.SOAPEvent;
	
	import events.ContactsProxyEvent;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	[Event( name = "complete", type = "flash.events.Event" )]
	[Event( name = "information", type = "events.ContactsProxyEvent" )]
	[Event( name = "fault", type = "events.ContactsProxyEvent" )]
	
	/**
	 * 
	 * @author andreev ap
	 */
	public class ContactsProxy extends EventDispatcher
	{
		private static var instance : ContactsProxy;

		public static function getInstance() : ContactsProxy
		{
			if ( !instance )
				instance = new ContactsProxy();

			return instance;
		}

		public function ContactsProxy( target : IEventDispatcher = null )
		{
			super( target );

			if ( instance )
				throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );

			addEventListener( Event.COMPLETE, completeHandler );

			loadCachedContacts();

			resourcesProxy = ResourcesProxy.getInstance();

		}

		private var _contacts : ArrayList;

		private var appID : String = "526ae088-8004-469c-9d8e-cea715f8f63b";

		private var login : String;

		private var loginPassword : String;

		private var pageID : String = "79e13aa6-4498-4b1c-be99-47373df2cae2";

		private var resourcesProxy : ResourcesProxy;

		private var server : String;

		private var soap : SOAP = SOAP.getInstance();

		private var user : String;

		private var userPassword : String;

		private var xml_param : String = "<Arguments><CallType>server_action</CallType></Arguments>";

		public function get contacts() : ArrayList
		{
			return _contacts;
		}

		
		
		/**
		 * Function return found conatactsVO if request is not empty;
		 * @param request
		 * @return 
		 */
		public function quickSearch( request : String ) : ArrayList
		{

			if ( request.length != 0 )
				return searchIncontactsVO( request );
			else
				return _contacts;
		}
		
		/**
		 * Function return found conatactsVO.
		 * @param value
		 * @return 
		 */
		private function searchIncontactsVO( value : String ):ArrayList
		{
			var contacts : Array = _contacts.source;
			
			var searchResult : ArrayList = new ArrayList();
			var full_name : String;
			var found : Boolean;
			var contact : Object;
			
			value = value.toLowerCase();
			
			var usersCount : int = contacts.length;
			
			for ( var i : int = 0; i < usersCount; i++ )
			{
				contact = contacts[ i ];
				
				full_name = contact[ 'label' ];
				full_name = full_name.toLowerCase();
				
				found = full_name.search( value ) != -1;
				
				if ( found )
					searchResult.addItem( contact );
			}
			
			return searchResult;
		}




		public function soapError( event : FaultEvent ) : void
		{
			soap.removeEventListener( FaultEvent.FAULT, soapError );

			var message : String;
			var detail : String;
			var fault : Fault = event.fault;

			message =  "faultstring" in fault ? fault[ "faultstring" ] : fault.faultString;
			detail  = fault[ "detail" ] ? fault[ "detail" ] : "";

			message += " ("+detail+")";

			dispatchEvent( new ContactsProxyEvent( ContactsProxyEvent.FAULT, message ) );
		}

		/**
		 *
		 * Function for update contact list by loading them from server. Old data will be lost.
		 *
		 *
		 **/
		public function updateContacts( server : String, login : String, loginPassword : String, user : String, userPassword : String ) : void
		{

			this.server = server;
			this.login = login;
			this.loginPassword = loginPassword;
			this.user = user;
			this.userPassword = userPassword;

			connectToServer();
		}

		/**
		 * Function for create ContactsVO and start loading and cache contacts images.
		 *
		 **/
		protected function crateContacts( contactsFromApp : Array ) : void
		{
			var contactVO : ContactVO;
			var contactsVO : Array = [];

			var len : int = contactsFromApp.length;

			for ( var i : int = 0; i < len; i++ )
			{
				contactVO = new ContactVO( contactsFromApp[ i ] );
				contactsVO.push( contactVO )
			}

			contactsVO.sortOn( [ "label" ] );

			_contacts = new ArrayList( contactsVO );

			resourcesProxy.loadImages( contactsVO );
		}

		protected function dispatchInformation( message : String ) : void
		{
			dispatchEvent( new ContactsProxyEvent( ContactsProxyEvent.INFORMATION, message ) );
		}


		private function completeHandler( event : Event ) : void
		{
			// TODO: save data to local storage
			var contactsJSON : String = JSON.stringify( _contacts );
			var fileStream : FileStream = new FileStream();

			try
			{
				fileStream.open( contactsFile, FileMode.WRITE );
				fileStream.writeUTF( contactsJSON );
			}
			catch ( error : IOError )
			{

			}

			fileStream.close();
		}

		/**
		 * It is 1-st function to update contact list, 
		 * КОТОРОЙ initialisate connection to server contents ProContact application.
		 */
		private function connectToServer() : void
		{
			dispatchInformation( "Connecting..." );

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

		
		private function get contactsFile() : File
		{
			return File.applicationStorageDirectory.resolvePath( "contacts.json" );
		}


		private function getProContactAppResult( result : String ) : Object
		{
			result = result.replace( /<Key>[0-9]+_[0-9]<\/Key>/, "" );
			var resultObject : Object;

			try
			{
				if ( result != "" )
					resultObject = JSON.parse( result );
			}
			catch ( error : Error )
			{
				var xml : XML = XML( result );

				dispatchEvent( new ContactsProxyEvent( ContactsProxyEvent.FAULT, xml ) );
			}

			if ( resultObject && resultObject[ 0 ] == 'error' )
			{
				dispatchEvent( new ContactsProxyEvent( ContactsProxyEvent.FAULT, resultObject[ 2 ] ) );
				return null;
			}

			return resultObject;
		}

		/**
		 * It is 4-d and final function  to update contact list, 
		 * КОТОРОЙ loading  contact list from ProContact application.
		 */
		private function loadContact() : void
		{
			dispatchInformation( "Loading contacts..." );

			soap.remote_call.addEventListener( ResultEvent.RESULT, retriveContactsResultHandler, false, 0, true );

			soap.remote_call( appID, pageID, "retrieve_contacts", xml_param, '' );

			function retriveContactsResultHandler( event : ResultEvent ) : void
			{
				soap.remote_call.removeEventListener( ResultEvent.RESULT, retriveContactsResultHandler );
				soap.remote_call.removeEventListener( FaultEvent.FAULT, soapError );

				var result : Object = getProContactAppResult( event.result as String );

				if ( result )
				{
					// careate contactVO
					crateContacts( result[ 1 ] as Array );

					dispatchEvent( new Event( Event.COMPLETE ) );
				}
			}
		}

		/**
		 * Function for loading cached contact list. Run on init this class.
		 */
		private function loadCachedContacts() : void
		{
			var fileStream : FileStream = new FileStream();
			var contactsJSON : String = "[]";
			var contactsVO : Object;

			try
			{
				fileStream.open( contactsFile, FileMode.READ );
				contactsJSON = fileStream.readUTF();
			}
			catch ( error : IOError )
			{
			}

			fileStream.close();

			contactsVO = JSON.parse( contactsJSON );
			_contacts = new ArrayList( contactsVO[ 'source' ] );
		}

		/**
		 * It is 3-d function to update contact list, 
		 * КОТОРОЙ login to  ProContact application.
		 */
		private function loginToProConatctApplication() : void
		{
			dispatchInformation( "Logining to ProContact..." );

			soap.remote_call.addEventListener( ResultEvent.RESULT, loginToAppResultHandler, false, 0, true );
			soap.remote_call.addEventListener( FaultEvent.FAULT, soapError );

			var actionName : String = "login";
			var data : String = '{"login" : "' + user + '", "password" : "' + userPassword + '"}';

			soap.remote_call( appID, pageID, "login", xml_param, data );

			function loginToAppResultHandler( event : ResultEvent ) : void
			{
				soap.remote_call.removeEventListener( ResultEvent.RESULT, loginToAppResultHandler );

				var result : Object = getProContactAppResult( event.result as String );

				if ( result )
					loadContact();
			}
		}

		/**
		 * It is 2-nd function to update contact list, 
		 * КОТОРОЙ login to server contents ProContact application.
		 */
		private function loginToServer() : void
		{
			dispatchInformation( "Logining to server..." );

			soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler, false, 0, true );
			soap.login( login, loginPassword );

			function soap_loginOKHandler( event : SOAPEvent ) : void
			{
				soap.removeEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );

				loginToProConatctApplication();
			}
		}
	}
}
