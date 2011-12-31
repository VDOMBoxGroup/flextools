package connection
{

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import net.vdombox.powerpack.gen.parse.ListParser;

public class SOAPBaseLevel extends EventDispatcher
{
	public static var RESULT_RECEIVED  : String = "resultReceived";

	private var _result : Object;

	private var soap : SOAP;


	public function SOAPBaseLevel( target : IEventDispatcher = null )
	{
		super( target );

		soap = SOAP.getInstance();
	}

	public function get result() : Object
	{
		return _result;
	}

	private function resultHandler( event : * ) : void
	{
		deleteListeners( event.target);

		var result : XMLList = new XMLList( event.result );

		_result = result[0];

		dispatchEvent( new Event( RESULT_RECEIVED ) );
	}

	private function deleteListeners( target : Object) : void
	{
		target.removeEventListener( SOAPEvent.RESULT, resultHandler );
		target.removeEventListener( FaultEvent.FAULT, soapError );
	}


	public function soapError( event : FaultEvent ) : void
	{
		trace("soapError")

		deleteListeners( event.target);

		if ( "faultstring" in event.fault )
			_result = "['Error' '" + event.fault["faultstring"] + "']";
		else
			_result = "['Error' '" + event.fault.faultString + "']";

		dispatchEvent( new Event( RESULT_RECEIVED ) );
	}

	public function execute( functionName : String, args : Array ) : void
	{
		switch ( functionName )
		{
			case 'login':
				soapLogin( args );
				break;

			case 'get_object_script_presentation':
				getObjectScriptPresentation( args );
				break;

			case 'submit_object_script_presentation':
				submitObjectScriptPresentation( args );
				break;

			case 'create_object':
				createObject( args );
				break;

			case 'get_server_actions':
				getServerActions( args );
				break;

			case 'set_server_actions':
				setServerActions( args );
				break;

			case 'get_application_events':
				getApplicationEvents( args );
				break;

			case 'export_application':
				exportApplication( args );
				break;

			case 'install_application':
				installApplication( args );
				break;

			case 'update_application':
				updateApplication( args );
				break;

			case 'get_application_info':
				getApplicationInfo( args );
				break;

			case 'set_application_events':
				setApplicationEvents( args );
				break;

			case 'close_session':
				closeSession( );
				break;

			case 'check_application_exists':
				checkApplicationExists( args );
				break;

		}
	}

	// set_application_events //

	private function setApplicationEvents( params : Array ) : void
	{
		var appId : String = params[0];
		var objId : String = params[1];
		var events : String = params[2];

		soap.set_application_events.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.set_application_events.addEventListener( FaultEvent.FAULT, soapError );
		soap.set_application_events( appId, objId, events );


	}

	// get_application_events //

	private function getApplicationEvents( params : Array ) : void
	{
		var appId : String = params[0];
		var objId : String = params[1];

		soap.get_application_events.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.get_application_events.addEventListener( FaultEvent.FAULT, soapError );

		soap.get_application_events( appId, objId );
	}

	// set_server_actions //

	private function setServerActions( params : Array ) : void
	{
		var appId : String = params[0];
		var objId : String = params[1];
		var actions : String = params[2];

		soap.set_server_actions.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.set_server_actions.addEventListener( FaultEvent.FAULT, soapError );

		soap.set_server_actions( appId, objId, actions );
	}

	// get_server_actions //

	private function getServerActions( params : Array ) : void
	{
		var appId : String = params[0];
		var objId : String = params[1];

		soap.get_server_actions.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.get_server_actions.addEventListener( FaultEvent.FAULT, soapError );

		soap.get_server_actions( appId, objId );
	}

	// create_object //

	private function createObject( params : Array ) : void
	{
		var appId : String = params[0];
		var parentId : String = params[1];
		var typeId : String = params[2];
		var name : String = params[3];
		var attr : String = params[4];


		soap.create_object.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.create_object.addEventListener( FaultEvent.FAULT, soapError );

		soap.create_object( appId, parentId, typeId, name, attr );
	}

	// submit_object_script_presentation //

	private function submitObjectScriptPresentation( params : Array ) : void
	{
		var appId : String = params[0];
		var objId : String = params[1];
		var pres : String = params[2];

		soap.submit_object_script_presentation.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.submit_object_script_presentation.addEventListener( FaultEvent.FAULT, soapError );

		soap.submit_object_script_presentation( appId, objId, pres );
	}

	// get_object_script_presentation //

	private function getObjectScriptPresentation( params : Array ) : void
	{
		var appId : String = params[0];
		var objId : String = params[1];

		soap.get_object_script_presentation.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.get_object_script_presentation.addEventListener( FaultEvent.FAULT, soapError );
		soap.get_object_script_presentation( appId, objId );
	}

//	export_application       //
	private function exportApplication( params : Array ) : void
	{
		trace( "exportApplication" );
		var appId : String = params[0];



		soap.export_application.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.export_application.addEventListener( FaultEvent.FAULT, soapError );

		soap.export_application( appId );


	}

//	installApplication
	private function installApplication( params : Array ) : void
	{
		var virtualHostName : String = params[0];
		var applicationXML : String = params[1];

		soap.install_application.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.install_application.addEventListener( FaultEvent.FAULT, soapError );
		soap.addEventListener( FaultEvent.FAULT, soapError);

		soap.install_application( virtualHostName, applicationXML );
	}

	// login //

	public function soapLogin( params : Array ) : void
	{
		var server : String = params[0];
		var login : String = params[1];
		var pass : String = params[2];
		var wsdl : String = "http://" + server + "/vdom.wsdl";
trace(wsdl)
		soap.addEventListener( "loadWsdlComplete", soap_initCompleteHandler );
		soap.addEventListener( FaultEvent.FAULT, soapError );
		soap.init( wsdl );

		function soap_initCompleteHandler( event : Event ) : void
		{
			trace("soap_initCompleteHandler"); 
			soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );

            trace(login+" : "+ pass)
			soap.login( login, pass );
		}

		function soap_loginOKHandler( event : SOAPEvent ) : void
		{
			trace("soap_loginOKHandler"); 
			soap.removeEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );


			var result : XML =  event.result as XML;
            trace(result)

//            [Success 195.167.233.27 root 1.2.7817]
             var resultArray : Array = ["Success", result.Hostname, result.Username, result.ServerVersion]

            _result = ListParser.array2List(resultArray);
            trace(_result)

			dispatchEvent( new Event( RESULT_RECEIVED ) );
		}
	}


	private function updateApplication( params : Array ) : void
	{
		var applicationXML : String = params[0];

		soap.update_application.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.update_application.addEventListener( FaultEvent.FAULT, soapError );

		soap.update_application( applicationXML );
	}

	private function getApplicationInfo( params : Array ) : void
	{
		var applicationID : String = params[0];

		soap.get_application_info.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.get_application_info.addEventListener( FaultEvent.FAULT, soapError );

		soap.get_application_info(  applicationID );
	}

	public function closeSession() : void
	{
		soap.close_session();
		_result = "Ok";

		dispatchEvent( new Event( RESULT_RECEIVED ) );
	}

	private function checkApplicationExists( params : Array ) : void
	{
		var applicationID : String = params[0];

		soap.check_application_exists.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.check_application_exists.addEventListener( FaultEvent.FAULT, soapError );

		soap.check_application_exists(  applicationID );
	}
}
}