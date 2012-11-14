package net.vdombox.powerpack.lib.player.connection
{

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.core.Application;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.StringUtil;

import net.vdombox.powerpack.lib.player.connection.protect.MD5;
import net.vdombox.powerpack.lib.player.events.SOAPErrorEvent;
import net.vdombox.powerpack.lib.player.gen.parse.ListParser;

public class SOAPBaseLevel extends EventDispatcher
{
	public static var RESULT_RECEIVED  : String = "resultReceived";

    public static var SUCCESS  : String = "Success";

    public static var ERROR  : String = "Error";

	private var _result : Object;

    private var _resultType : String = ERROR;

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

    public function get resultType() : String
    {
        return _resultType;
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

	private function deleteListeners( target : Object) : void
	{
		target.removeEventListener( SOAPEvent.RESULT, resultHandler );
		target.removeEventListener( FaultEvent.FAULT, soapError );
	}


	public function soapError( event : FaultEvent ) : void
	{
		deleteListeners( event.target);
		
		var fault : Object = event.fault;
		var faultstring : String = ( "faultstring" in fault ) 	? fault["faultstring"] 	: fault.faultString
		var details 	: String = ( "details"     in fault) 	? fault["details"] 		: "" ;

		
		 _result = "['Error' '" + faultstring + " - " + details+ "']"; 
		
        _resultType = ERROR;
		
		Application.application.addEventListener( Event.ENTER_FRAME, callLater);
	}
	
	private function callLater( event : Event):void
	{
		Application.application.removeEventListener( Event.ENTER_FRAME, callLater);
		dispatchEvent( new Event( RESULT_RECEIVED ) );
	}

	public static const wholeMethodFunctions : Array = 
		[	"login",
			"get_object_script_presentation",
			"submit_object_script_presentation",
			"create_object",
			"get_server_actions",
			"set_server_actions",
			"get_application_events",
			"export_application",
			"install_application",
			"update_application",
			"get_application_info",
			"set_application_events",
			"close_session",
			"check_application_exists",
			"remote_call",
			"list_applications",
			"list_backup_drivers",
			"restore_application",
			"backup_application",
			"set_type"
		];
	
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
			
			case 'remote_call':
				remoteCall( args );
				break;
			
			case 'list_applications':
				listApplications( args );
				break;
			
			case 'backup_application':
				backupApplication( args );
				break;
			
			case 'restore_application':
				restoreApplication( args );
				break;
			
			case 'list_backup_drivers':
				listBackupDrivers(  );
				break;
			
			case 'set_type':
				setType(args);
				break;
			
			
			default:
			{
				_result = "['Error' 'function: " + functionName +" - does not exist ']";
				
				_resultType = ERROR;
				
				Application.application.callLater(dispathRusult);
				
				break;
			}

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

		soap.install_application.addEventListener( ResultEvent.RESULT, resultHandler , false, 0, true );
		soap.install_application.addEventListener( FaultEvent.FAULT, soapError, false, 0, true  );
		soap.addEventListener( FaultEvent.FAULT, soapError);

		soap.install_application( virtualHostName, applicationXML );
	}

	// login //

	public function soapLogin( params : Array ) : void
	{
		if ( soap.ready )
			soap.disconnect();
		
		var server : String = params[0];
		var login : String =  params[1] ;
		var pass : String = MD5.encrypt( params[2] );
		
		var wsdl : String = "http://" + server + "/vdom.wsdl";

		soap.addEventListener( SOAPEvent.CONNECTION_OK , soap_initCompleteHandler );
		soap.addEventListener( FaultEvent.FAULT, soapError );
		
		soap.connect( wsdl );
		
		function soap_initCompleteHandler( event : Event ) : void
		{
			soap.removeEventListener( SOAPEvent.CONNECTION_OK, soap_initCompleteHandler );
			soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler, false, 0, true  );
			soap.addEventListener( SOAPErrorEvent.LOGIN_ERROR, loginError, false, 0, true );

			soap.logon( login, pass );
		}
                                              
		function soap_loginOKHandler( event : SOAPEvent ) : void
		{
			soap.removeEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );
			soap.removeEventListener( SOAPErrorEvent.LOGIN_ERROR, loginError);

			
			var result : XML =  event.result as XML;

			var resultArray : Array = ["Success", result.Hostname, result.Username, result.ServerVersion]

            _result = ListParser.array2List(resultArray);

            _resultType = SUCCESS;

			dispatchEvent( new Event( RESULT_RECEIVED ) );
		}
		
		function loginError( event : SOAPErrorEvent ) : void
		{
			var resultArray : Array = ["Error", event.faultString ]
			
			_result = ListParser.array2List(resultArray);
			
			_resultType = ERROR;
			
			dispatchEvent( new Event( RESULT_RECEIVED ) );
		}
	}


	private function updateApplication( params : Array ) : void
	{
		var applicationXML : String = params[0];

		soap.update_application.addEventListener( ResultEvent.RESULT, resultHandler, false, 0, true  );
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
        _resultType = SUCCESS;

		dispatchEvent( new Event( RESULT_RECEIVED ) );
	}

	private function checkApplicationExists( params : Array ) : void
	{
		var applicationID : String = params[0];

		soap.check_application_exists.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.check_application_exists.addEventListener( FaultEvent.FAULT, soapError );

		soap.check_application_exists(  applicationID );
	}
	
	
	private function remoteCall(params  : Array ) : void
	{
		var applicationID : String = params[0];
		
		soap.remote_call.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.remote_call.addEventListener( FaultEvent.FAULT, soapError );
		
		soap.remote_call(   params[0], params[1], params[2], params[3],  params[4]  );
	}
	
	private function listApplications( params  : Array ) : void
	{
		soap.list_applications.addEventListener( ResultEvent.RESULT, listAppResultHandler );
		soap.list_applications.addEventListener( FaultEvent.FAULT, soapError );
		
		soap.list_applications();
		
		function listAppResultHandler( event : ResultEvent ) : void
		{
			deleteListeners( event.target);

			var result : XMLList = new XMLList( event.result );
			var applicationsXML : XML = new XML(result[0]); 
			var applicationsArr : Array = [];
			
			
			for each (var application:XML in applicationsXML.children()) 
			{
				applicationsArr.push( [application.Information.Name[0],  application.@ID])
			}
			
			_result = ListParser.array2List( applicationsArr );
			
			_resultType = SUCCESS;
			
			dispatchEvent( new Event( RESULT_RECEIVED ) );
		}

	}
	
	private function backupApplication( params : Array ) : void
	{
		var applicationID : String = params[0];
		var driverID : String = params[1];
		
		
		soap.backup_application.addEventListener( ResultEvent.RESULT, backup_applicationResultHandler );
		soap.backup_application.addEventListener( FaultEvent.FAULT, soapError );
		
		soap.backup_application(  applicationID, driverID );
		
		function backup_applicationResultHandler(event : ResultEvent) : void
		{
			deleteListeners( event.target);
			
			var result : XMLList = new XMLList( event.result );
			
			_resultType = getResultType( result );;
			_result = _resultType == SUCCESS ? result[0].Revision : result[0];
				
			
			dispatchEvent( new Event( RESULT_RECEIVED ) );
		}
	}
	
	
	private function restoreApplication( params : Array ) : void
	{
		var applicationID : String = params[0];
		var driverID : String = params[1];
		var revision : String = params[2];
		
		soap.restore_application.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.restore_application.addEventListener( FaultEvent.FAULT, soapError );
		
		soap.restore_application(  applicationID, driverID,  revision );
	}
	
	private function  listBackupDrivers(  ) : void
	{
		soap.list_backup_drivers.addEventListener( ResultEvent.RESULT, listBackupDriversHandler );
		soap.list_backup_drivers.addEventListener( FaultEvent.FAULT, soapError );
		
		soap.list_backup_drivers(    );
		
		
		function listBackupDriversHandler( event : ResultEvent ) : void
		{
			deleteListeners( event.target);
			
			var result : XMLList = new XMLList( event.result );
			var backupDriversXML : XML = new XML(result[0]); 
			var backupDrivers : Array = [];
			
			
			for each (var driver:XML in backupDriversXML.children()) 
			{
				backupDrivers.push( [driver.Name[0],  driver.ID[0], driver.Description[0] ] );
			}
			
			_result = ListParser.array2List( backupDrivers );
			
			_resultType = SUCCESS;
			
			dispatchEvent( new Event( RESULT_RECEIVED ) );
		}
	}
	
	private function setType( params : Array ) : void
	{
		var typeXML : String = params[0];
		
		if (StringUtil.trim(typeXML).indexOf('<?xml') != 0)
			typeXML = '<?xml version="1.0" encoding="UTF-8" ?>' + typeXML;
		
		soap.set_type.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.set_type.addEventListener( FaultEvent.FAULT, soapError );
		
		soap.set_type( typeXML );
	}

	
	
	
	private function dispathRusult():void
	{
		dispatchEvent( new Event( RESULT_RECEIVED ) );
	}
		
}
}