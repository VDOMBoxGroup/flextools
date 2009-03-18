import flash.events.Event;
import flash.events.InvokeEvent;
import flash.geom.Rectangle;

import mx.controls.Alert;
import mx.core.Application;
import mx.core.Singleton;
import mx.core.UIComponent;
import mx.core.Window;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;
import mx.managers.PopUpManager;
import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;

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
import vdom.managers.UpdateManager;
import vdom.managers.configClasses.Config;
import vdom.utils.StringUtils;
import vdom.utils.VersionUtils;

[Embed( source="/assets/main/vdom_logo.png" )]
[Bindable]
public var vdomLogo : Class;

private const SERVER_VERSION : String = "0.9.4051";

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

private function initDataManager() : void
{
	viewstack.selectedChild = main;
	contentStack.selectedIndex = 0;
	
	dataManager.addEventListener( DataManagerEvent.INIT_COMPLETE, dataManager_initCompleteHandler );
	dataManager.init();
}

public function switchToModule( moduleName : String ) : void
{
	switch( moduleName.toLowerCase() )
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
	}
}

private function switchToLogin() : void
{
	if( viewstack )
	{ 
		if( viewstack.selectedChild != loginForm )
			moduleTabNavigator.selectedChild.dispatchEvent( new FlexEvent( FlexEvent.HIDE ));
		
		viewstack.selectedChild = loginForm;
		callLater( showLoginFormHandler );
	}
}

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
	var argArray : Array = event.arguments;
	
	if( argArray.length == 0 )
		return;
	
	for each ( var argValue : String in argArray )
	{
		switch ( argValue )
		{
			case "debug" :
			{
				editorModule.debugButton.visible = true;
				break;
			}
			case "darkstyle" :
			{
				editorModule.scriptCanv.textEditor.codeEditor.setStyle( "color", "white" );
				editorModule.scriptCanv.textEditor.codeEditor.setStyle( "backgroundColor", "black" );
				break;
			}
		}
	}			
}

private function preinitalizeHandler() : void
{	
	dataManager.addEventListener( DataManagerEvent.CLOSE, dataManager_close );
	dataManager.addEventListener( DataManagerErrorEvent.GLOBAL_ERROR, dataManager_globalErrorHandler );
	
	soap.addEventListener( FaultEvent.FAULT, soap_faultHandler );
	
	Singleton.registerClass( "vdom.managers::IVdomDragManager", 
		Class( getDefinitionByName( "vdom.managers::VdomDragManagerImpl" )) );
	
	languageManager.init( languageList );
	cacheManager.init();
	
	configManager.init();
	
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

private function creationCompleteHandler() : void
{
	moduleTabNavigator.addEventListener( IndexChangedEvent.CHANGE, moduleChangedHandler );
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

private function showLoginFormHandler() : void
{	
	nativeWindow.restore();
	showStatusBar = false;
	showGripper = false;
	
	minWidth = 800;
	minHeight = 600;
	
	validateNow();

	var sx : Number = ( Capabilities.screenResolutionX - nativeWindow.width ) / 2;
	var sy : Number = ( Capabilities.screenResolutionY - nativeWindow.height ) / 2;
	
	bounds = new Rectangle( sx, sy, 800, 600 );
}

private function showMainHandler() : void
{	
	showStatusBar = true;
	showGripper = true;
	minWidth = 1000;
	minHeight = 800;
	
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
	dataManager.removeEventListener( DataManagerEvent.INIT_COMPLETE, dataManager_initCompleteHandler );
	
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
	
	contentStack.selectedIndex = 1;
	
	if( moduleTabNavigator )
	{
		if( moduleTabNavigator.selectedIndex != 0 )
			moduleTabNavigator.selectedIndex = 0;
		else
			moduleTabNavigator.selectedChild.dispatchEvent( new FlexEvent( FlexEvent.SHOW ));
	}
	
	applicationVersion.text = "(" + VersionUtils.getApplicationVersion() + ")";
}

private function dataManager_close( event : DataManagerEvent ) : void
{
	switchToLogin();
}

private function dataManager_globalErrorHandler( event : DataManagerErrorEvent ) : void
{
	checkError( event.fault );
	
}

private function logoutHandler() : void
{
	if( moduleTabNavigator && moduleTabNavigator.selectedChild )
		moduleTabNavigator.selectedChild.dispatchEvent( new FlexEvent( FlexEvent.HIDE ) );
	
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