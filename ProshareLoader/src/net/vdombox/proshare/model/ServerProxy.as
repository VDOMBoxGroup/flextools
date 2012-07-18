/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 13.07.12
 * Time: 12:54
 */
package net.vdombox.proshare.model
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.soap.SOAPFault;

import net.vdombox.proshare.connection.SOAP;
import net.vdombox.proshare.connection.SOAPErrorEvent;
import net.vdombox.proshare.connection.SOAPEvent;
import net.vdombox.proshare.connection.protect.MD5;


public class ServerProxy     extends EventDispatcher
{
	private var soap : SOAP;

	public static var SUCCESS  : String = "Success";

	public static var ERROR  : String = "Error";

	public static var RESULT_RECEIVED  : String = "resultReceived";

	private var _result : Object;

	private var _resultType : String = ERROR;

	private var _state : String= '';

	public static var LOGIN  : String = "login";
	public static var LOAD_SPACES_INFO  : String = "loadSpacesInfo";
	public static var LOAD_FILES_INFO  : String = "loadFilesInfo";


	public function ServerProxy(  target : IEventDispatcher = null )
	{
		super( target );

		soap = SOAP.getInstance();
	}

	public function login( server: String, login : String, password : String  ):void
	{
		_state = LOGIN;

		if ( soap.ready )
			soap.disconnect();


		password = MD5.encrypt( password );

		var wsdl : String = "http://" + server + "/vdom.wsdl";

		soap.addEventListener( SOAPEvent.CONNECTION_OK , soap_initCompleteHandler );
		soap.addEventListener( FaultEvent.FAULT, soapError );

		soap.connect( wsdl );

		function soap_initCompleteHandler( event : Event ) : void
		{
			soap.removeEventListener( SOAPEvent.CONNECTION_OK, soap_initCompleteHandler );
			soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler, false, 0, true  );
			soap.addEventListener( SOAPErrorEvent.LOGIN_ERROR, loginError, false, 0, true );

			soap.logon( login, password );
		}

		function soap_loginOKHandler( event : SOAPEvent ) : void
		{
			soap.removeEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );
			soap.removeEventListener( SOAPErrorEvent.LOGIN_ERROR, loginError);


			var result : XML =  event.result as XML;

			var resultArray : Array = ["Success", result.Hostname, result.Username, result.ServerVersion]

			_resultType = SUCCESS;

			dispatchEvent( new Event( RESULT_RECEIVED ) );
		}

		function loginError( event : SOAPErrorEvent ) : void
		{
			deleteListeners( event.target);

			_resultType = ERROR;
			_result =   event.faultString  ;

			dispatchEvent( new Event( RESULT_RECEIVED ) );
		}
	}

	public function loadFilesInfo(  ):void
	{
		_state = LOAD_FILES_INFO;

		var applicationID : String = "a7c6cb0a-552b-42f7-891b-c3af8b4a670b";
		var dbTableID  : String = "51028732-e8ef-463d-8773-63a233a9468d";
		var magicstring : XML = <Arguments><CallType>rmc</CallType><HTTPSessionID /></Arguments>;

		soap.remote_call.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.remote_call.addEventListener( FaultEvent.FAULT, soapError );

		soap.remote_call(  applicationID, dbTableID, "get_data", magicstring,  ""  );
	}

	private const  applicationID : String = "a7c6cb0a-552b-42f7-891b-c3af8b4a670b";
	private const  magicString : XML = <Arguments><CallType>rmc</CallType><HTTPSessionID /></Arguments>;

	public function loadSpacesInfo(  ):void
	{
		_state = LOAD_SPACES_INFO;

		var dbTableID  : String = "908b23f9-8637-4d64-b129-1c7f4d0bdcfb";

		soap.remote_call.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.remote_call.addEventListener( FaultEvent.FAULT, soapError );

		soap.remote_call(  applicationID, dbTableID, "get_data", magicString,  ""  );
	}
	
	
	public function soapError( event : FaultEvent ) : void
	{
		deleteListeners( event.target);

		var fault : SOAPFault = event.fault as SOAPFault;
		var details : String = fault.detail;

		if ( "faultstring" in event.fault )
			_result =  fault["faultstring"] + " - " + details;
		else
			_result = fault.faultString + " - " + details;

		_resultType = ERROR;
//		Alert.show(_result.toString())

		dispatchEvent( new Event( RESULT_RECEIVED ) );
	}

	private function deleteListeners( target : Object) : void
	{
		target.removeEventListener( SOAPEvent.RESULT, resultHandler );
		target.removeEventListener( FaultEvent.FAULT, soapError );
	}

	private function resultHandler( event : * ) : void
	{
		deleteListeners( event.target);

		var result : XMLList = new XMLList( event.result );

		_result = result[0];

		_resultType = getResultType( result );

		dispatchEvent( new Event( RESULT_RECEIVED ) );
	}

	private function getResultType( value : XMLList ) : String
	{
		var xml : XML = value[0];

		if (xml.name())
		{
			if (xml.name().hasOwnProperty("localName"))
				return xml.name().localName == "Error" ? ERROR : SUCCESS;
			else
				return xml.name() == "Error" ? ERROR : SUCCESS;
		}

		return SUCCESS;
	}

	public function get result() : Object
	{
		return _result;
	}
	public function get resultType() : String
	{
		return _resultType;
	}


	public function get state():String
	{
		return _state;
	}
}
}
