package net.vdombox.powerpack.managers
{

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

import generated.webservices.Close_sessionResultEvent;
import generated.webservices.Open_sessionResultEvent;
import generated.webservices.Vdom;

import mx.core.Window;
import mx.rpc.events.FaultEvent;

import net.vdombox.powerpack.lib.extendedapi.containers.SuperAlert;

import vdom.connection.protect.Code;
import vdom.connection.protect.MD5;

public class ConnectionManager extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private static var _instance : ConnectionManager;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance() : ConnectionManager
	{
		if ( !_instance )
		{
			_instance = new ConnectionManager();
		}

		return _instance;
	}

	/**
	 *  @private
	 */
	public static function get instance() : ConnectionManager
	{
		return getInstance();
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public function ConnectionManager()
	{
		super();

		if ( _instance )
			throw new Error( "Instance already exists." );

		vdom = new Vdom( null, ContextManager.instance.host + ":" +
				(ContextManager.instance.use_def_port ? ContextManager.instance.default_port : ContextManager.instance.port) +
				"/SOAP" );

		//vdom = new Vdom(null, "http://192.168.0.19:80/SOAP");	

		vdom.addVdomFaultEventListener( faultHandler );
		timer.addEventListener( TimerEvent.TIMER, timerHandler );
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------			

	[Bindable]
	public var vdom : Vdom = new Vdom();
	public var window : Window;

	private var timer : Timer = new Timer( 5 * 60 * 1000, 0 );

	public var loggedIn : Boolean;

	private var proc : String;
	private var listener : Function;
	private var args : Array = [];

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function set endpointURI( value : String ) : void
	{
		instance.vdom = new Vdom( null, value );
		instance.vdom.addVdomFaultEventListener( instance.faultHandler );
	}

	public static function login( listener : Function, login : String = null, pass : String = null ) : void
	{
		if ( login == null )
			login = ContextManager.instance.login;
		if ( login == null )
			login = '';

		if ( pass == null )
			pass = ContextManager.instance.pass;
		if ( pass == null )
			pass = '';

		var ws : Vdom = instance.vdom;
		var pwd_md5 : String = MD5.encrypt( pass );

		if ( instance.timer.running )
			instance.timer.reset();

		ws.addopen_sessionEventListener( instance.loginHandler );
		if ( listener != null )
			ws.addopen_sessionEventListener( listener );
		ws.open_session( login, pwd_md5 );
	}

	public static function logout( listener : Function = null ) : void
	{
		instance.timer.stop();

		if ( !instance.loggedIn )
		{
			if ( listener != null )
				listener.call( null, null );
			return;
		}

		var ws : Vdom = instance.vdom;
		var code : Code = Code.getInstance();
		var sid : String = code.sessionId;

		ws.addclose_sessionEventListener( instance.logoutHandler );
		if ( listener != null )
			ws.addclose_sessionEventListener( listener );
		ws.close_session( sid );
	}

	private function keepAlive() : void
	{
		if ( !instance.loggedIn )
		{
			return;
		}

		var ws : Vdom = instance.vdom;
		var code : Code = Code.getInstance();
		var sid : String = code.sessionId;
		var skey : String = code.skey();

		ws.keep_alive( sid, skey );
	}

	public static function exec( proc : String, listener : Function, ...args ) : void
	{
		var ws : Vdom = instance.vdom;

		if ( proc )
		{
			instance.proc = proc;
			instance.listener = listener;
			instance.args = args;
		}

		if ( !instance.proc )
			return;

		if ( !instance.loggedIn )
		{
			login( null );
		}
		else
		{
			var code : Code = Code.getInstance();
			var sid : String = code.sessionId;
			var skey : String = code.skey();

			switch ( instance.proc )
			{
				case 'list_applications':
				case 'export_application':
				case 'get_all_types':
					instance.args.unshift( sid, skey );
					break;
			}

			instance.timer.reset();

			ws['add' + instance.proc + 'EventListener'].apply( ws, [instance.listener] );
			ws[instance.proc].apply( ws, instance.args );

			instance.proc = null;
			instance.listener = null;
			instance.args = [];
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	private function timerHandler( event : TimerEvent ) : void
	{
		keepAlive();
	}

	private function loginHandler( event : Open_sessionResultEvent ) : void
	{
		var resultXML : XML = new XML( <Result/> );
		resultXML.appendChild( XMLList( event.result ) );

		if ( resultXML.Error.toString() )
		{

			loggedIn = false;

			SuperAlert.show( resultXML.Error,
					LanguageManager.sentences["fault"],
					4 )
		}
		else
		{
			// run session protector
			var code : Code = Code.getInstance();
			code.init( resultXML.Session.HashString );
			code.inputSKey( resultXML.Session.SessionKey );
			code.sessionId = resultXML.Session.SessionId;

			loggedIn = true;

			if ( !timer.running )
				timer.start();

			exec( null, null );
		}
	}

	private function logoutHandler( event : Close_sessionResultEvent ) : void
	{
		var resultXML : XML = new XML( <Result/> );
		resultXML.appendChild( XMLList( event.result ) );

		if ( resultXML.Error.toString() )
		{
		}
		else
		{
			loggedIn = false;
			timer.stop();
		}
	}

	private function faultHandler( event : FaultEvent ) : void
	{
		loggedIn = false;
		timer.stop();

		SuperAlert.show( "A fault occured contacting the server. Fault message is: " + event.fault.faultString +
				"\n" + event.fault.faultDetail +
				"\n" + event.fault.rootCause +
				"\n" + event.headers,
				LanguageManager.sentences["fault"],
				4 );

		ProgressManager.complete();
	}

}
}