package vdom.managers
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusFileUpdateErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import flash.events.ErrorEvent;
	
	import mx.core.Application;
	import mx.logging.Log;
	
	import vdom.managers.configClasses.Config;
	
public class UpdateManager
{
	private static var instance : UpdateManager;
	
	private var applicationUpdater : ApplicationUpdaterUI = new ApplicationUpdaterUI();
	private var configManager : ConfigManager = ConfigManager.getInstance();
	private var updaterConfig : Config = configManager.getConfig( "updater.config" );
	private var urlList : Array;
	private var currentServerNumber : uint;
	private var isInitalized : Boolean = false;
	
	public static function getInstance() : UpdateManager
	{
		if ( !instance )
			instance = new UpdateManager();
		
		return instance;
	}
	
	public function UpdateManager()
	{
		if ( instance )
			throw new Error( "Instance already exists." );
	}
	
	public function init() : void
	{
		if( !updaterConfig )
		{
			createConfigFile();
		}
		
		urlList = updaterConfig.urllist.url as Array;
		if( !urlList || urlList.length == 0 )
			return;
		
		applicationUpdater.delay = 0;
		
		try
		{
			applicationUpdater.isCheckForUpdateVisible = Boolean( updaterConfig.checkforupdate );
			applicationUpdater.isDownloadUpdateVisible = Boolean( updaterConfig.downloadupdate );
			applicationUpdater.isDownloadProgressVisible = Boolean( updaterConfig.downloadprogress );
			applicationUpdater.isInstallUpdateVisible = Boolean( updaterConfig.installupdate );
			applicationUpdater.isFileUpdateVisible = Boolean( updaterConfig.fileupdate );
			applicationUpdater.isUnexpectedErrorVisible = Boolean( updaterConfig.unexpectederror );
		}
		catch ( error : Error )
		{
			return;
		}
		
		applicationUpdater.addEventListener( UpdateEvent.INITIALIZED, applicationUpdater_initalizeHandler );
		applicationUpdater.addEventListener( StatusUpdateEvent.UPDATE_STATUS, applicationUpdater_updateStatus );
				
		applicationUpdater.addEventListener( ErrorEvent.ERROR, applicationUpdater_errorHandler );
		applicationUpdater.addEventListener( StatusFileUpdateErrorEvent.FILE_UPDATE_ERROR, applicationUpdater_errorHandler );
		applicationUpdater.addEventListener( StatusUpdateErrorEvent.UPDATE_ERROR, applicationUpdater_errorHandler );
		applicationUpdater.addEventListener( DownloadErrorEvent.DOWNLOAD_ERROR, applicationUpdater_errorHandler );
		
		isInitalized = true;
		
		checkForUpdate( 0 );
	}
	
	public function checkNow() : void 
	{
		if( isInitalized )
			applicationUpdater.checkNow();
	}
	
	private function createConfigFile() : void
	{
		updaterConfig = configManager.createConfig( "updater.config" );
		
		if( updaterConfig )
		{
			updaterConfig.urllist = {
				url : 
					[
						"file:////Segroup/exchange/vdomide/update/update.xml1",
						"file:////Segroup/exchange/vdomide/update/update.xml"
					]
			};
			updaterConfig.delay = "0";
			updaterConfig.checkforupdate = "";
			updaterConfig.downloadupdate = "1";
			updaterConfig.downloadprogress = "";
			updaterConfig.installupdate = "1";
			updaterConfig.fileupdate = "1";
			updaterConfig.unexpectederror =  "1";
			
			configManager.saveConfig( updaterConfig );
		}
	}
	
	private function checkForUpdate( serverNumber : int ) : void
	{
		var urlListLength : uint = Math.abs( urlList.length );
		
		if( serverNumber >= urlListLength )
			return;
		
		var url : String = urlList[ serverNumber ];
		
 		if( url != null && url != "" )
		{
			applicationUpdater.updateURL = url;
			currentServerNumber = serverNumber;
			
			if( serverNumber == 0 )
			{
				applicationUpdater.initialize();
			}
			else
			{
				applicationUpdater.cancelUpdate();
				applicationUpdater.updateURL = url;
				
				Application.application.callLater( applicationUpdater.checkNow )
			}
		}
	}
	
	private function checkNextServer() : void
	{
		if( currentServerNumber < urlList.length - 1 )
			checkForUpdate( currentServerNumber + 1 );
	}
	
	private function applicationUpdater_initalizeHandler( event:UpdateEvent ) : void
	{
		applicationUpdater.checkNow();
	}
	
	private function applicationUpdater_updateStatus( event : StatusUpdateEvent ) : void
	{
		if( !event.available )
			checkNextServer();
	}
	
	private function applicationUpdater_errorHandler( event : ErrorEvent ) : void
	{
		checkNextServer();
	}
}
}