import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowSystemChrome;
import flash.events.Event;
import flash.events.InvokeEvent;

import mx.core.Application;
import mx.core.Window;
import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;

import net.vdombox.ide.ApplicationFacade;

import vdom.components.loginForm.LoginForm;
import vdom.components.main.Main;
import vdom.connection.SOAP;
import vdom.controls.AlertWindow;
import vdom.controls.alertWindowClasses.AlertWindowForm;
import vdom.events.AuthenticationEvent;
import vdom.events.DataManagerErrorEvent;
import vdom.events.DataManagerEvent;
import vdom.events.LoginFormEvent;
import vdom.events.SOAPEvent;
import vdom.managers.AuthenticationManager;
import vdom.managers.CacheManager;
import vdom.managers.ConfigManager;
import vdom.managers.DataManager;
import vdom.managers.FileManager;
import vdom.managers.LanguageManager;
import vdom.managers.PopUpWindowManager;
import vdom.managers.UpdateManager;
import vdom.managers.configClasses.Config;
import vdom.utils.StringUtils;
import vdom.utils.VersionUtils;

include "SERVER_VERSION.as";

public static const NAME:String = "vdomIDE"; 

public var arguments : Array = [];

private var soap : SOAP = SOAP.getInstance();

private var dataManager : DataManager = DataManager.getInstance();
private var authenticationManager : AuthenticationManager = AuthenticationManager.getInstance();
private var languageManager : LanguageManager = LanguageManager.getInstance();
private var fileManager : FileManager = FileManager.getInstance();
private var cacheManager : CacheManager = CacheManager.getInstance();
private var updateManager : UpdateManager = UpdateManager.getInstance();
private var configManager : ConfigManager = ConfigManager.getInstance();
private var popUpWindowManager : PopUpWindowManager = PopUpWindowManager.getInstance();

private var loginWindow : Window;
private var mainWindow : Window;

private var currentWindow : Window;

private var configMain : Config;

private var tempStorage : Object = {};

private var isServerVersionOld : Boolean = false;

private var facade : ApplicationFacade = ApplicationFacade.getInstance( stage );	

private function registerEvent( flag : Boolean ) : void
{
	if ( flag )
	{
		dataManager.addEventListener( DataManagerEvent.CLOSE, dataManager_close );
		dataManager.addEventListener( DataManagerErrorEvent.GLOBAL_ERROR, dataManager_globalErrorHandler );

		soap.addEventListener( FaultEvent.FAULT, soap_faultHandler );
	}
	else
	{
		dataManager.removeEventListener( DataManagerEvent.CLOSE, dataManager_close );
		dataManager.removeEventListener( DataManagerErrorEvent.GLOBAL_ERROR, dataManager_globalErrorHandler );

		soap.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
	}
}

private function initManagers() : void
{
	languageManager.init( languageList );
	cacheManager.init();
	configManager.init();
}

private function initConfig() : void
{
	configMain = configManager.getConfig( "main" );

	if ( !configMain )
	{
		configMain = configManager.createConfig( "main" );
		configMain.updater = { enabled : "1" };
		configManager.saveConfig( configMain );
	}

	if ( configMain.server && configMain.server.version )
	{

	}
	else
	{
		configMain.server = { version : SERVER_VERSION };
		configManager.saveConfig( configMain );
	}
}

/* private function initDataManager() : void
{
//	viewstack.selectedChild = main;
//	contentStack.selectedIndex = 0;

	dataManager.init();
} */

/* private function switchToLogin() : void
   {
   if( viewstack )
   {
   if( viewstack.selectedChild != loginForm )
   moduleTabNavigator.selectedChild.dispatchEvent( new FlexEvent( FlexEvent.HIDE ));

   viewstack.selectedChild = loginForm;
   }
 } */

private function openLoginWindow() : Window
{
	if ( mainWindow && mainWindow.visible )
		mainWindow.visible = false;

	if ( !loginWindow )
	{
		var loginForm : LoginForm = new LoginForm();

		loginForm.addEventListener( LoginFormEvent.SUBMIT_BEGIN, loginForm_submitBeginHandler );
		loginForm.addEventListener( LoginFormEvent.QUIT, loginForm_quitHandler );

		var windowOptions : NativeWindowInitOptions = new NativeWindowInitOptions();
		windowOptions.systemChrome = NativeWindowSystemChrome.NONE;
		windowOptions.resizable = false;
		windowOptions.maximizable = false;
		windowOptions.minimizable = false;
		windowOptions.transparent = true;

		loginWindow = popUpWindowManager.addPopUp( loginForm, "VDOM IDE - Login",
												   null, false, null, windowOptions );

		loginWindow.showTitleBar = false;
		loginWindow.showGripper = false;
		loginWindow.showStatusBar = false;

		loginWindow.setStyle( "borderStyle", "none" );
		loginWindow.setStyle( "backgroundAlpha", .0 );
	}
	else
	{
		if ( !loginWindow.visible )
			loginWindow.visible = true;
	}
	
	currentWindow = loginWindow;
	
	return loginWindow;
}

private function openMainWindow() : Window
{
	if ( loginWindow.visible )
		loginWindow.visible = false;

	if ( !mainWindow )
	{
		var main : Main = new Main();

		var windowOptions : NativeWindowInitOptions = new NativeWindowInitOptions();
		windowOptions.systemChrome = NativeWindowSystemChrome.NONE;
		windowOptions.resizable = true;
		windowOptions.maximizable = true;
		windowOptions.minimizable = true;
		windowOptions.transparent = true;

		mainWindow = popUpWindowManager.addPopUp( main, "VDOM IDE", null, false,
												  null, windowOptions );

		mainWindow.showTitleBar = false;
		mainWindow.showGripper = true;
		mainWindow.showStatusBar = true;
	}
	else
	{
		if ( !mainWindow.visible )
			mainWindow.visible = true;

	}
	
	currentWindow = mainWindow;
	
	return mainWindow;
}

private function checkError( fault : Fault ) : void
{
	var errorCode : String = StringUtils.getLocalName( fault.faultCode );

	switch ( errorCode )
	{
		case "i101" : 
		{
			break;
		}
		case "203" : 
		{
//			initDataManager();
			break;
		}
		default : 
		{
			dataManager.close();
			break;
		}
	}
}

private function invokeHandler( event : InvokeEvent ) : void
{
	facade.invoke( event.arguments );
}

private function preinitalizeHandler() : void
{
	facade.preinitalize( this );
	
//	NativeApplication.nativeApplication.idleThreshold = IDLE_TIME;

//	registerEvent( true );
//	initManagers();
//	initConfig();
}

private function creationCompleteHandler() : void
{
	openLoginWindow();
}

private function applicationCompleteHandler() : void 
{
	facade.startup( this );
}

/* private function moduleChangedHandler( event : IndexChangedEvent ) : void
   {
   while ( systemManager.popUpChildren.numChildren > 0 )
   {
   PopUpManager.removePopUp( UIComponent( systemManager.popUpChildren.getChildAt( 0 ) ) );
   }
 } */

/* private function showLoginFormHandler() : void
   {
   nativeWindow.restore();
   Application.application.showStatusBar = false;
   Application.application.showGripper = false;
   Application.application.minWidth = 800;
   Application.application.minHeight = 600;
   Application.application.width = 800;
   Application.application.height = 600;
   nativeWindow.width = 800;
   nativeWindow.height = 600;
   var sx : Number = ( Capabilities.screenResolutionX - nativeWindow.width ) / 2;
   var sy : Number = ( Capabilities.screenResolutionY - nativeWindow.height ) / 2;

   nativeWindow.x = sx;
   nativeWindow.y = sy;
 } */

/* private function showMainHandler() : void
   {
   Application.application.showStatusBar = true;
   Application.application.showGripper = true;
   Application.application.minWidth = 1000;
   Application.application.minHeight = 800;

   var newWidth : Number = nativeWindow.width;

   if( newWidth < 1000 )
   newWidth = 1000;

   var newHeight : Number = nativeWindow.height;

   if( newHeight < 800 )
   newHeight = 800;

   var sx : Number = Math.max( nativeWindow.x + 400 - newWidth / 2, 0 );
   var sy : Number = Math.max( nativeWindow.y + 300 - newHeight / 2, 0 );

   nativeWindow.x = sx;
   nativeWindow.y = sy
 } */

private function loginForm_submitBeginHandler( event : LoginFormEvent ) : void
{
	var loginForm : LoginForm = event.currentTarget as LoginForm;

	if ( !loginForm || !loginWindow || !loginWindow.visible )
		return;

//	alertManager.showMessage( "Authentication process" );

	var hostname : String = event.formData.hostname;

	tempStorage = event.formData;

	var wsdl : String = "http://" + hostname + "/vdom.wsdl";
	soap.addEventListener( SOAPEvent.INIT_COMPLETE, soap_initCompleteHandler );
	soap.init( wsdl );
}

private function loginForm_quitHandler( event : LoginFormEvent ) : void
{
	var loginForm : LoginForm = event.currentTarget as LoginForm;

	loginWindow.removeEventListener( LoginFormEvent.SUBMIT_BEGIN, loginForm_submitBeginHandler );
	loginWindow.removeEventListener( LoginFormEvent.QUIT, loginForm_quitHandler );

	popUpWindowManager.removePopUp( loginWindow );

	Application.application.exit();
}

private function authenticationManager_loginComleteHandler( event : AuthenticationEvent ) : void
{
	authenticationManager.removeEventListener( AuthenticationEvent.LOGIN_COMPLETE,
											   authenticationManager_loginComleteHandler );
	authenticationManager.addEventListener( AuthenticationEvent.LOGIN_ERROR, authenticationManager_loginErrorHandler );
	
	openMainWindow();
}

private function authenticationManager_loginErrorHandler( event : Event ) : void
{
	authenticationManager.removeEventListener( AuthenticationEvent.LOGIN_COMPLETE,
											   authenticationManager_loginComleteHandler );
	authenticationManager.removeEventListener( AuthenticationEvent.LOGIN_ERROR, authenticationManager_loginErrorHandler );

	
	var awm : AlertWindowForm = new AlertWindowForm();
	AlertWindow.show( "Login Error", "Alert", 0x4, loginWindow );
//	dataManager.close();
}

/* private function dataManager_initCompleteHandler( event : DataManagerEvent ) : void
{
	alertManager.showMessage( "Load Types" );

	dataManager.addEventListener( DataManagerEvent.LOAD_TYPES_COMPLETE, dataManager_typesLoadedHandler );
	dataManager.loadTypes();
} */

/* private function dataManager_typesLoadedHandler( event : DataManagerEvent ) : void
{
	dataManager.removeEventListener( DataManagerEvent.LOAD_TYPES_COMPLETE, dataManager_typesLoadedHandler );
	alertManager.showMessage( "" );

	if ( isServerVersionOld )
		alertManager.showAlert( "Server version is out of date. Instable work is possible. Please update your server firmware." );

	languageManager.parseLanguageData( dataManager.listTypes );

	openMainWindow();
 contentStack.selectedIndex = 1;

   if( moduleTabNavigator )
   {
   if( moduleTabNavigator.selectedIndex != 0 )
   moduleTabNavigator.selectedIndex = 0;
   else
   moduleTabNavigator.selectedChild.dispatchEvent( new FlexEvent( FlexEvent.SHOW ));
   }

 applicationVersion.text = "(" + VersionUtils.getApplicationVersion() + ")"; 
} */

private function dataManager_close( event : DataManagerEvent ) : void
{
//	switchToLogin();
}

private function dataManager_globalErrorHandler( event : DataManagerErrorEvent ) : void
{
	checkError( event.fault );
}

private function soap_initCompleteHandler( event : Event ) : void
{
	fileManager.init();

	var username : String = tempStorage.username;
	var password : String = tempStorage.password;
	var hostname : String = tempStorage.hostname;

	soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler )

	authenticationManager.addEventListener( AuthenticationEvent.LOGIN_COMPLETE, authenticationManager_loginComleteHandler );
	authenticationManager.addEventListener( AuthenticationEvent.LOGIN_ERROR, authenticationManager_loginErrorHandler );

	authenticationManager.login( hostname, username, password );
}

private function soap_loginOKHandler( event : SOAPEvent ) : void
{
	var serverVersion : String = "old";
	var configServerVersion : String = "none";

	try
	{
		serverVersion = event.result.ServerVersion[ 0 ].toString();
		configServerVersion = configMain.server.version;
	}
	catch ( eror : Error )
	{
	}
	;

	if ( serverVersion == "old" || configServerVersion != "none" && VersionUtils.isUpdateNeeded( configServerVersion,
																								 serverVersion ) )
	{
		//alertManager.showMessage("");
		isServerVersionOld = true;
		//dataManager.close();
		//event.stopImmediatePropagation();
	}
}

private function soap_faultHandler( event : FaultEvent ) : void
{
	checkError( event.fault );
}