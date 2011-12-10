package connection
{

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.soap.LoadEvent;
import mx.rpc.soap.Operation;
import mx.rpc.soap.WebService;

import vdom.connection.protect.Code;

public dynamic class SOAP extends Proxy implements IEventDispatcher
{
	private static var instance : SOAP;

	private var ws : WebService;
	private var dispatcher : EventDispatcher = new EventDispatcher();

	private var code : Code = Code.getInstance();

	private var resourceManager : IResourceManager = ResourceManager.getInstance();

	public function SOAP()
	{
		if ( instance )
			throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	}

	public static function getInstance() : SOAP
	{
		if ( !instance )
			instance = new SOAP();

		return instance;
	}

	public function init( wsdl : String ) : void
	{
		ws = new WebService();
		ws.wsdl = wsdl;
		ws.useProxy = false;
		ws.addEventListener( LoadEvent.LOAD, loadHandler );
		ws.addEventListener( FaultEvent.FAULT, faultHandler );
		ws.loadWSDL();
	}

	public function login( login : String, password : String ) : *
	{
		var password : String = MD5Utils.encrypt( password );

		ws.open_session.addEventListener( ResultEvent.RESULT, loginCompleteHandler );
		ws.open_session.addEventListener( FaultEvent.FAULT, loginErrorHandler );

		ws.open_session( login, password );
	}

	override flash_proxy function getProperty( name : * ) : *
	{
		var functionName : String = getLocalName( name );
		var operation : * = ws[ functionName ];

		if ( functionName && operation )
			return operation;
		else
			return null;
	}

	override flash_proxy function setProperty( name : *, value : * ) : void
	{
		var message : String = resourceManager.getString( "rpc", "operationsNotAllowedInService",
				[ getLocalName( name ) ] );
		throw new Error( message );
	}

	override flash_proxy function callProperty( name : *, ...args : Array ) : *
	{
		var functionName : String = getLocalName( name );
		var operation : Operation = ws[ functionName ];
		var key : String = code.skey();

		args.unshift( code.sessionId, key );
		operation.addEventListener( ResultEvent.RESULT, operationResultHandler );
		operation.xmlSpecialCharsFilter = escapeXML;
		operation.send.apply( null, args );
		return key;
	}

	private function escapeXML( value : Object ) : String
	{
		var str : String = value.toString();
		//str = str.replace(/&/g, "&amp;").replace(/</g, "&lt;"); // TODO very dirty hack. wrong escaping special xml symbols
		return str;
	}

	private function getLocalName( name : Object ) : String
	{
		if ( name is QName )
		{
			return QName( name ).localName;
		}
		else
		{
			return String( name );
		}
	}

	private function loadHandler( event : LoadEvent ) : void
	{
		dispatchEvent( new Event( 'loadWsdlComplete' ) );
	}

	private function faultHandler( event : FaultEvent ) : void
	{
		var fe : FaultEvent = FaultEvent.createEvent( event.fault, null, event.message );
		dispatchEvent( fe );
	}

	private function loginCompleteHandler( event : ResultEvent ) : void
	{
		var resultXML : XML = new XML(
				<Result/>
		);
		resultXML.appendChild( XMLList( event.result ) );

		code.init( resultXML.Session.HashString );
		code.inputSKey( resultXML.Session.SessionKey );
		code.sessionId = resultXML.Session.SessionId;

		var se : SOAPEvent = new SOAPEvent( SOAPEvent.LOGIN_OK );
		se.result = resultXML;
		dispatchEvent( se );
	}

	private function loginErrorHandler( event : FaultEvent ) : void
	{
		if ( event.fault is Fault )
		{
			ws.dispatchEvent( FaultEvent.createEvent( event.fault, event.token,
					event.message ) );
			return;
		}

		var se : SOAPEvent = new SOAPEvent( SOAPEvent.LOGIN_ERROR );
		se.result = new XML( event.fault.faultDetail )
		dispatchEvent( se );
	}

	private function operationResultHandler( event : ResultEvent ) : void
	{
		var resultXML : XML = new XML(
				<Result/>
		);

		try
		{
			resultXML.appendChild( XMLList( event.result ) );
		}
		catch ( error : Error )
		{
			var faultEvent : FaultEvent = FaultEvent.createEvent( new Fault( "i101",
					"Parse data error" ) );
			faultHandler( faultEvent );
			return;
		}

		var se : SOAPEvent = new SOAPEvent( SOAPEvent.RESULT );
		se.result = resultXML;

		event.target.dispatchEvent( se );
	}

	// Реализация диспатчера

	/**
	 *  @private
	 */
	public function addEventListener( type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false ) : void
	{
		dispatcher.addEventListener( type, listener, useCapture, priority );
	}

	/**
	 *  @private
	 */
	public function dispatchEvent( event : Event ) : Boolean
	{
		return dispatcher.dispatchEvent( event );
	}

	/**
	 *  @private
	 */
	public function hasEventListener( type : String ) : Boolean
	{
		return dispatcher.hasEventListener( type );
	}

	/**
	 *  @private
	 */
	public function removeEventListener( type : String, listener : Function, useCapture : Boolean = false ) : void
	{
		dispatcher.removeEventListener( type, listener, useCapture );
	}

	/**
	 *  @private
	 */
	public function willTrigger( type : String ) : Boolean
	{
		return dispatcher.willTrigger( type );
	}
}
}