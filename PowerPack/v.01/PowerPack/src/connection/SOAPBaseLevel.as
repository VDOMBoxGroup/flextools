package connection
{

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

public class SOAPBaseLevel extends EventDispatcher
{
	public static var RESULT_GETED : String = "resultGeted";
	private var _result : * = "";

	public function SOAPBaseLevel( target : IEventDispatcher = null )
	{
		super( target );
	}

	public function get result() : String
	{
		return _result;
	}

	public function set result( value : String ) : void
	{
		_result = value;
	}

	public function soapError( event : * ) : void
	{
		if ( "faultstring" in event.fault )
			_result = "['error' '" + event.fault.faultstring + "']";
		else
			_result = "['error' '" + event.fault.faultString + "']";

		dispatchEvent( new Event( RESULT_GETED ) );
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

		}
	}

	// set_application_events //

	private function setApplicationEvents( params : Array ) : void
	{
		/*
		 appid - идентификатор приложения
		 objid - идентификатор объекта
		 events - события; xml вида
		 1 <E2vdom>
		 2    <Events>
		 3       <Event ObjSrcID='' ContainerID='' Name=''>
		 4          <Action ID=''/>
		 5          <Action ID=''/>
		 6          ...
		 7       </Event>
		 8       ...
		 9    </Events>
		 10    <ClientActions>
		 11       <Action ID='' ObjTgtID='' MethodName='name'>
		 12          <Parameter ScriptName='MyParameter'>...</Parameter>
		 13          ...
		 14       </Action>
		 15       ...
		 16    </ClientActions>
		 17    <ServerActions>
		 18       <Action ID='' Name='' Language=''>
		 19          <![CDATA[ ...code... ]]>
		 20       </Action>
		 21       ...
		 22    </ServerActions>
		 23 </E2vdom>
		 */

		var appId : String = params[0];
		var objId : String = params[1];
		var events : String = params[2];

		var soap : SOAP = SOAP.getInstance();

		soap.set_application_events.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.set_application_events.addEventListener( FaultEvent.FAULT, soapError );
		soap.set_application_events( appId, objId, events );

		function resultHandler( event : * ) : void
		{
			soap.removeEventListener( SOAPEvent.RESULT, resultHandler );
			soap.removeEventListener( FaultEvent.FAULT, soapError );

			if ( event.type == ResultEvent.RESULT )
			{
				var result : XMLList = new XMLList( event.result );
				var resultXML : XML = result[0];
				_result = "['result' '" + resultXML.children() + "']";

				dispatchEvent( new Event( RESULT_GETED ) );
			}
		}
	}

	// get_application_events //

	private function getApplicationEvents( params : Array ) : void
	{
		/*
		 appid - идентификатор приложения
		 objid - идентификатор объекта
		 */

		var appId : String = params[0];
		var objId : String = params[1];

		var soap : SOAP = SOAP.getInstance();

		soap.get_application_events.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.get_application_events.addEventListener( FaultEvent.FAULT, soapError );
		soap.get_application_events( appId, objId );

		function resultHandler( event : * ) : void
		{
			soap.removeEventListener( SOAPEvent.RESULT, resultHandler );
			soap.removeEventListener( FaultEvent.FAULT, soapError );

			if ( event.type == ResultEvent.RESULT )
			{
				var res : String;
				var result : XMLList = new XMLList( event.result );
				var resultXML : XML = result[0];
				res = resultXML.toString();

				var regExp : RegExp = /\n/g;
				res = res.replace( regExp, " " );
				_result = "['result' '" + res + "']";

				dispatchEvent( new Event( RESULT_GETED ) );
			}
		}
	}

	// set_server_actions //

	private function setServerActions( params : Array ) : void
	{
		/*
		 appid - идентификатор приложения
		 objid - идентификатор объекта
		 actions - xml вида
		 1 <ServerActions>
		 2    <Action ID='' Name='' Language=''>
		 3       <![CDATA[ ...code... ]]>
		 4    </Action>
		 5    ...
		 6 </ServerActions>
		 */

		var appId : String = params[0];
		var objId : String = params[1];
		var actions : String = params[2];

		var soap : SOAP = SOAP.getInstance();

		soap.set_server_actions.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.set_server_actions.addEventListener( FaultEvent.FAULT, soapError );
		soap.set_server_actions( appId, objId, actions );

		function resultHandler( event : * ) : void
		{
			soap.removeEventListener( SOAPEvent.RESULT, resultHandler );
			soap.removeEventListener( FaultEvent.FAULT, soapError );

			if ( event.type == ResultEvent.RESULT )
			{
				var result : XMLList = new XMLList( event.result );
				var resultXML : XML = result[0];
				_result = "['result' '" + resultXML.children() + "']";

				dispatchEvent( new Event( RESULT_GETED ) );
			}
		}
	}

	// get_server_actions //

	private function getServerActions( params : Array ) : void
	{
		/*
		 appid - идентификатор приложения
		 objid - идентификатор объекта
		 */

		var appId : String = params[0];
		var objId : String = params[1];

		var soap : SOAP = SOAP.getInstance();

		soap.get_server_actions.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.get_server_actions.addEventListener( FaultEvent.FAULT, soapError );
		soap.get_server_actions( appId, objId );

		function resultHandler( event : * ) : void
		{
			soap.removeEventListener( SOAPEvent.RESULT, resultHandler );
			soap.removeEventListener( FaultEvent.FAULT, soapError );

			if ( event.type == ResultEvent.RESULT )
			{
				var res : String;
				var result : XMLList = new XMLList( event.result );
				var resultXML : XML = result[0];
				res = resultXML.children().toString();

				var regExp : RegExp = /\n/g;
				res = res.replace( regExp, " " );
				_result = "['result' '" + res + "']";

				dispatchEvent( new Event( RESULT_GETED ) );
			}
		}
	}

	// create_object //

	private function createObject( params : Array ) : void
	{
		/*
		 appid - идентификатор приложения
		 parentid - идентификатор родительского объекта (если создается объект верхнего уровня - указываем пустую строку)
		 typeid - идентификатор типа
		 name - имя объекта (не обязательно, в этом случае передаем пустую строку)
		 attr - пустая строка, либо xml-строка вида
		 1 <Attributes>
		 2     <Attribute Name="имя атрибута">значение атрибута</Attribute>
		 3     ...
		 4 </Attributes>
		 */

		var appId : String = params[0];
		var parentId : String = params[1];
		var typeId : String = params[2];
		var name : String = params[3];
		var attr : String = params[4];

		var soap : SOAP = SOAP.getInstance();

		soap.create_object.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.create_object.addEventListener( FaultEvent.FAULT, soapError );
		soap.create_object( appId, parentId, typeId, name, attr );

		function resultHandler( event : * ) : void
		{
			soap.removeEventListener( SOAPEvent.RESULT, resultHandler );
			soap.removeEventListener( FaultEvent.FAULT, soapError );

			if ( event.type == ResultEvent.RESULT )
			{
				_result = "['result' '" + event.result + "']";

				dispatchEvent( new Event( RESULT_GETED ) );
			}
		}
	}

	// submit_object_script_presentation //

	private function submitObjectScriptPresentation( params : Array ) : void
	{
		/*
		 appid - идентификатор приложения
		 objid - идентификатор объекта
		 pres - новое xml представление объекта
		 */

		var appId : String = params[0];
		var objId : String = params[1];
		var pres : String = params[2];

		var soap : SOAP = SOAP.getInstance();

		soap.submit_object_script_presentation.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.submit_object_script_presentation.addEventListener( FaultEvent.FAULT, soapError );
		soap.submit_object_script_presentation( appId, objId, pres );

		function resultHandler( event : * ) : void
		{
			soap.removeEventListener( SOAPEvent.RESULT, resultHandler );
			soap.removeEventListener( FaultEvent.FAULT, soapError );

			if ( event.type == ResultEvent.RESULT )
			{
				var result : XMLList = new XMLList( event.result );
				var resultXML : XML = result[0];
				_result = "['result' '" + resultXML.children() + "']";

				dispatchEvent( new Event( RESULT_GETED ) );
			}
		}
	}

	// get_object_script_presentation //

	private function getObjectScriptPresentation( params : Array ) : void
	{
		/*
		 appid - идентификатор приложения
		 objid - идентификатор объекта
		 */

		var appId : String = params[0];
		var objId : String = params[1];

		var soap : SOAP = SOAP.getInstance();

		soap.get_object_script_presentation.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.get_object_script_presentation.addEventListener( FaultEvent.FAULT, soapError );
		soap.get_object_script_presentation( appId, objId );

		function resultHandler( event : * ) : void
		{
			soap.removeEventListener( SOAPEvent.RESULT, resultHandler );
			soap.removeEventListener( FaultEvent.FAULT, soapError );

			if ( event.type == ResultEvent.RESULT )
			{
				var res : String;
				var result : XMLList = new XMLList( event.result );
				var resultXML : XML = result[0];
				//					resultXML.normalize();
				res = resultXML.children().toString();

				var regExp : RegExp = /\n/g;
				res = res.replace( regExp, " " );
				_result = "['result' '" + res + "']";

				dispatchEvent( new Event( RESULT_GETED ) );
			}
		}
	}

//	export_application       //
	private function exportApplication( params : Array ) : void
	{
		/*
		 appid - идентификатор приложения
		 objid - идентификатор объекта
		 */

		var appId : String = params[0];

		var soap : SOAP = SOAP.getInstance();

		soap.export_application.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.export_application.addEventListener( FaultEvent.FAULT, soapError );
		soap.export_application( appId );

		function resultHandler( event : * ) : void
		{
			soap.export_application.removeEventListener( SOAPEvent.RESULT, resultHandler );
			soap.export_application.removeEventListener( FaultEvent.FAULT, soapError );

			if ( event.type == ResultEvent.RESULT )
			{
				var result : XMLList = new XMLList( event.result );

				_result = result[0];

				dispatchEvent( new Event( RESULT_GETED ) );
			}
		}
	}

//	installApplication
	private function installApplication( params : Array ) : void
	{
		/*
		 vhname - виртуальное имя хоста
		 appxml - xml приложения
		 */

		var vhname : String = params[0];
		var appxml : String = params[1];
		var soap : SOAP = SOAP.getInstance();

		soap.install_application.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.install_application.addEventListener( FaultEvent.FAULT, soapError );
		soap.install_application( vhname, appxml );

		function resultHandler( event : * ) : void
		{
			soap.install_application.removeEventListener( SOAPEvent.RESULT, resultHandler );
			soap.install_application.removeEventListener( FaultEvent.FAULT, soapError );

			if ( event.type == ResultEvent.RESULT )
			{
				var result : XMLList = new XMLList( event.result );

				_result = result[0];

				dispatchEvent( new Event( RESULT_GETED ) );
			}
		}
	}

	// login //

	public function soapLogin( params : Array ) : void
	{
		var server : String = params[0];
		var login : String = params[1];
		var pass : String = params[2];
		var wsdl : String = "http://" + server + "/vdom.wsdl";

		var soap : SOAP = SOAP.getInstance();

		soap.addEventListener( "loadWsdlComplete", soap_initCompleteHandler );
		soap.addEventListener( FaultEvent.FAULT, soapError );
		soap.init( wsdl );

		function soap_initCompleteHandler( event : Event ) : void
		{
			soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );
			soap.login( login, pass );
		}

		function soap_loginOKHandler( event : SOAPEvent ) : void
		{
			soap.removeEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );
			soap.removeEventListener( FaultEvent.FAULT, soapError );

			if ( event.type == SOAPEvent.LOGIN_OK )
			{
				_result = "['result' 'ok']";
				dispatchEvent( new Event( RESULT_GETED ) );
			}
		}
	}

	private function updateApplication( params : Array ) : void
	{
		/*
		 vhname - виртуальное имя хоста
		 appxml - xml приложения
		 */

		var appxml : String = params[0];
		var soap : SOAP = SOAP.getInstance();

		soap.update_application.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.update_application.addEventListener( FaultEvent.FAULT, soapError );
		soap.update_application( appxml );

		function resultHandler( event : * ) : void
		{
			soap.update_application.removeEventListener( SOAPEvent.RESULT, resultHandler );
			soap.update_application.removeEventListener( FaultEvent.FAULT, soapError );

			if ( event.type == ResultEvent.RESULT )
			{
				var result : XMLList = new XMLList( event.result );

				_result = result[0];

				dispatchEvent( new Event( RESULT_GETED ) );
			}
		}
	}

	private function getApplicationInfo( params : Array ) : void
	{
		/*
		 vhname - виртуальное имя хоста
		 applicationXML - xml приложения
		 */

		var applicationXML : String = params[0];
		var soap : SOAP = SOAP.getInstance();

		soap.get_application_info.addEventListener( ResultEvent.RESULT, resultHandler );
		soap.get_application_info.addEventListener( FaultEvent.FAULT, soapError );
		soap.get_application_info( applicationXML );

		function resultHandler( event : * ) : void
		{
			soap.get_application_info.removeEventListener( SOAPEvent.RESULT, resultHandler );
			soap.get_application_info.removeEventListener( FaultEvent.FAULT, soapError );

			if ( event.type == ResultEvent.RESULT )
			{
				var result : XMLList = new XMLList( event.result );

				_result = result[0];

				dispatchEvent( new Event( RESULT_GETED ) );
			}
		}
	}

}
}