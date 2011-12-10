/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 09.12.11
 * Time: 16:19
 */
package connection.protect
{

import connection.SOAP;
import connection.SOAPEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

public class SOAPApplicationLevel extends EventDispatcher
{
	public static var RESULT_GETTED : String = "rusulGetted";
	public static var ERROR : String = "error";

	public function SOAPApplicationLevel( target : IEventDispatcher = null )
	{
		super( target );
	}

	private var _errorResult : String = "";

	public function get result() : String
	{
		return _result;
	}

	private var _result : XMLList;
//	export_application
	public function loadApplication( appId : String ) : void
	{
		var soap : SOAP = SOAP.getInstance();

		soap.export_application.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.export_application.addEventListener( FaultEvent.FAULT, soapError );
		soap.addEventListener( FaultEvent.FAULT, soapError );

		soap.export_application( appId );

		function resultHandler( event : * ) : void
		{
			soap.export_application.removeEventListener( SOAPEvent.RESULT, resultHandler );
			soap.export_application.removeEventListener( FaultEvent.FAULT, soapError );
			soap.removeEventListener( FaultEvent.FAULT, soapError );

			var result : XMLList = new XMLList( event.result );
			var resultXML : XML = result[0];

			_result = resultXML.children();

			dispatchEvent( new Event( RESULT_GETTED ) );
		}
	}

	public function soapError( event : FaultEvent ) : void
	{
		var fault : Fault = event.fault;
		var faultMessage : String = ("faultstring" in event.fault) ? fault["faultstring"] : fault["faultStrin"] as String;

		_errorResult = "['error' '" + faultMessage + "']";

		dispatchEvent( new Event( ERROR ) );
	}

	public function get errorResult() : String
	{
		return _errorResult;
	}
}
}
