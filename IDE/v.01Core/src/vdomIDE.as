import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowSystemChrome;
import flash.events.Event;
import flash.events.InvokeEvent;

import mx.controls.Alert;
import mx.core.Application;
import mx.core.UIComponent;
import mx.core.Window;
import mx.events.IndexChangedEvent;
import mx.managers.PopUpManager;
import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;

import vdom.components.loginForm.LoginForm;
import vdom.connection.SOAP;
import vdom.events.AuthenticationEvent;
import vdom.events.DataManagerErrorEvent;
import vdom.events.DataManagerEvent;
import vdom.events.LoginFormEvent;
import vdom.events.SOAPEvent;
import vdom.managers.AlertManager;
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

public var arguments : Array = [];

[Embed( source="/assets/main/vdom_logo.png" )]
[Bindable]
private var vdomLogo : Class;

[Bindable]
private var dataManager : DataManager = DataManager.getInstance();

[Bindable]
private var authenticationManager : AuthenticationManager = AuthenticationManager.getInstance();

private var languageManager : LanguageManager = LanguageManager.getInstance();

private var fileManager : FileManager = FileManager.getInstance();
private var cacheManager : CacheManager = CacheManager.getInstance();
private var alertManager : AlertManager= AlertManager.getInstance();

private var updateManager : UpdateManager = UpdateManager.getInstance();

private var configManager : ConfigManager = ConfigManager.getInstance();

private var configMain : Config;

private var soap : SOAP = SOAP.getInstance();

private var tempStorage : Object = {};

private var isServerVersionOld : Boolean = false;

private function registerEvent( flag : Boolean ) : void
{
	if( flag )
	{
		dataManager.addEventListener( DataManagerEvent.INIT_COMPLETE, dataManager_initCompleteHandler );
		dataManager.addEventListener( DataManagerEvent.CLOSE, dataManager_close );
		dataManager.addEventListener( DataManagerErrorEvent.GLOBAL_ERROR, dataManager_globalErrorHandler );
	
		soap.addEventListener( FaultEvent.FAULT, soap_faultHandler );
	}
	else
	{
		dataManager.removeEventListener( DataManagerEvent.INIT_COMPLETE, dataManager_initCompleteHandler );
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
	
	if( configMain == null )
	{
		configMain = configManager.createConfig( "main" );
		configMain.updater = { enabled : "1" };
		configManager.saveConfig( configMain );
	}
	
	if( configMain.server && configMain.server.version )
	{
		
	}
	else
	{
		configMain.server = { version : SERVER_VERSION };
		configManager.saveConfig( configMain );
	}
}

private function initDataManager() : void
{
//	viewstack.selectedChild = main;
//	contentStack.selectedIndex = 0;
	
	dataManager.init();
}

public function switchToModule( moduleName : String ) : void
{
	/* switch( moduleName.toLowerCase() )
	{
		case "applicationmanagment":
		{
			moduleTabNavigator.selectedChild = applicationManagmentModule;
			break;	
		}
		
		case "editor":
		{
			moduleTabNavigator.selectedChild = editorModule;
			break;
		}
	} */
}

/* private function switchToLogin() : void
{
	if( viewstack )
	{ 
		if( viewstack.selectedChild != loginForm )
			moduleTabNavigator.selectedChild.dispatchEvent( new FlexEvent( FlexEvent.HIDE ));
		
		viewstack.selectedChild = loginForm;
	}
} */

private function checkError( fault : Fault ) : void
{
	var errorCode : String = StringUtils.getLocalName( fault.faultCode );
	
	switch( errorCode )
	{
		case "i101":
		{
			break;
		}
		case "203":
		{
			initDataManager();
			break;
		}
		default :
		{
			dataManager.close();
			break;
		}
	}
	
	alertManager.showAlert( fault.faultString );
	alertManager.showMessage( "" );
}

private function invokeHandler( event : InvokeEvent ) : void 
{
	arguments = event.arguments;
	
	if( arguments.length == 0 )
		return;
	
	for each ( var argValue : String in arguments )
	{
		/* switch ( argValue )
		{
			case "debug" :
			{
				editorModule.debugButton.visible = true;
				break;
			}
			case "darkstyle" :
			{
				editorModule.scriptCanv.textArea.codeEditor.setStyle( "color", "white" );
				editorModule.scriptCanv.textArea.codeEditor.setStyle( "backgroundColor", "black" );
				break;
			}
		} */
	}			
}

private function preinitalizeHandler() : void
{	
//	Singleton.registerClass( "vdom.managers::IVdomDragManager", 
//		Class( getDefinitionByName( "vdom.managers::VdomDragManagerImpl" )) );
	nativeWindow.close();
	NativeApplication.nativeApplication.autoExit = false;
//	NativeApplication.nativeApplication.idleThreshold = IDLE_TIME;
	
	registerEvent( true );
	initManagers();
	initConfig();	
}

private function creationCompleteHandler() : void
{
//	moduleTabNavigator.addEventListener( IndexChangedEvent.CHANGE, moduleChangedHandler );
	var loginForm : LoginForm = new LoginForm();
	
	var windowOptions : NativeWindowInitOptions = new NativeWindowInitOptions();
	windowOptions.systemChrome = NativeWindowSystemChrome.NONE;
	windowOptions.resizable = false;
	windowOptions.maximizable = false;
	windowOptions.minimizable = false;
	windowOptions.transparent = true;
	
	var puwm : PopUpWindowManager = new PopUpWindowManager();
	var loginWindow : Window = puwm.addPopUp( loginForm, "", null, false, null, windowOptions );
	loginWindow.showTitleBar = false;
	loginWindow.showGripper = false;
	loginWindow.showStatusBar = false;
}

private function windowCompleteHandler() : void 
{
	try
	{
		if( configMain.updater.enabled == "1" )
			callLater( updateManager.init );
	}
	catch( error : Error ) {}
}

private function moduleChangedHandler( event : IndexChangedEvent ) : void
{
	while( systemManager.popUpChildren.numChildren > 0 )
	{
		PopUpManager.removePopUp( UIComponent( systemManager.popUpChildren.getChildAt( 0 )) );
	}
}

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

private function showMainHandler() : void
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
}

private function changeLanguageHandler( event : Event ) : void
{	
	languageManager.changeLocale( event.currentTarget.selectedItem.@code );
}

private function submitBeginHandler( event : LoginFormEvent ) : void
{	
	alertManager.showMessage( "Authentication process" );
	
	var hostname : String = event.formData.hostname;
	
	tempStorage = event.formData;
	
	var wsdl : String = "http://" + hostname + "/vdom.wsdl";
	soap.addEventListener( "loadWsdlComplete", soap_initCompleteHandler );
	soap.init( wsdl );
}

private function authenticationManager_loginComleteHandler( event : AuthenticationEvent ) : void
{	
	authenticationManager.removeEventListener(
		AuthenticationEvent.LOGIN_COMPLETE, 
		authenticationManager_loginComleteHandler
	);
	
	initDataManager();
}

private function authenticationManager_loginErrorHandler( event : Event ) : void
{
	authenticationManager.addEventListener(
		AuthenticationEvent.LOGIN_ERROR, 
		authenticationManager_loginErrorHandler
	);
	
	Alert.show( "Login Error", "Login Error" );
	alertManager.showMessage( "" );
	dataManager.close();
}
private function dataManager_initCompleteHandler( event : DataManagerEvent ) : void
{	
	alertManager.showMessage( "Load Types" );
	
	dataManager.addEventListener( DataManagerEvent.LOAD_TYPES_COMPLETE, dataManager_typesLoadedHandler );
	dataManager.loadTypes();	
}

private function dataManager_typesLoadedHandler( event : DataManagerEvent ) : void
{
	dataManager.removeEventListener( DataManagerEvent.LOAD_TYPES_COMPLETE, dataManager_typesLoadedHandler );
	alertManager.showMessage( "" );
	
	if( isServerVersionOld )
		alertManager.showAlert( "Server version is out of date. Instable work is possible. Please update your server firmware." );
	
	languageManager.parseLanguageData( dataManager.listTypes );
	
	/* contentStack.selectedIndex = 1;
	
	if( moduleTabNavigator )
	{
		if( moduleTabNavigator.selectedIndex != 0 )
			moduleTabNavigator.selectedIndex = 0;
		else
			moduleTabNavigator.selectedChild.dispatchEvent( new FlexEvent( FlexEvent.SHOW ));
	}
	
	applicationVersion.text = "(" + VersionUtils.getApplicationVersion() + ")"; */
}

private function dataManager_close( event : DataManagerEvent ) : void
{
//	switchToLogin();
}

private function dataManager_globalErrorHandler( event : DataManagerErrorEvent ) : void
{
	checkError( event.fault );
	
}

private function logoutHandler() : void
{
//	if( moduleTabNavigator && moduleTabNavigator.selectedChild )
//		moduleTabNavigator.selectedChild.dispatchEvent( new FlexEvent( FlexEvent.HIDE ) );
	
	dataManager.close();
} 

private function soap_initCompleteHandler( event : Event ) : void
{
	fileManager.init();
	
	var username : String = tempStorage.username;
	var password : String = tempStorage.password;
	var hostname : String = tempStorage.hostname;
	
	soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler )
	
	authenticationManager.addEventListener(
		AuthenticationEvent.LOGIN_COMPLETE,
		authenticationManager_loginComleteHandler
	);
	
	authenticationManager.addEventListener(
		AuthenticationEvent.LOGIN_ERROR, 
		authenticationManager_loginErrorHandler
	);
	
	authenticationManager.login( hostname, username, password );
}

private function soap_loginOKHandler( event : SOAPEvent ) : void 
{	
	var serverVersion : String = "old";
	var configServerVersion : String = "none";
	
	try
	{
		serverVersion = event.result.ServerVersion[0].toString();
		configServerVersion = configMain.server.version;
	}
	catch( eror : Error ) {};
	
	if( serverVersion == "old" ||
		configServerVersion != "none" &&
		VersionUtils.isUpdateNeeded( configServerVersion, serverVersion )
	)
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