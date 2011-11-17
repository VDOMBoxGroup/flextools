package net.vdombox.ide.core.controller
{
	import air.update.ApplicationUpdater;
	import air.update.ApplicationUpdaterUI;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import flash.desktop.NativeApplication;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import net.vdombox.view.Alert;
	import net.vdombox.view.AlertButton;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CheckUpdateCommand extends SimpleCommand
	{
		
		//private var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();
		
		override public function execute( notification : INotification ) : void
		{
			NativeApplication.nativeApplication.addEventListener( Event.EXITING, closeOpenedWindow );  
			
			var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();
			
			// Configuration stuff - see update framework docs for more details
			appUpdater.updateURL = "http://ehb.tomsk.ru/maks/update.xml"; // Server-side XML file describing update
			//appUpdater.configurationFile =  new File ("app:/updateConfig.xml");
			appUpdater.isCheckForUpdateVisible = false; // We won't ask permission to check for an update
			appUpdater.addEventListener(UpdateEvent.INITIALIZED, onUpdate); // Once initialized, run onUpdate
			appUpdater.addEventListener(ErrorEvent.ERROR, onError); // If something goes wrong, run onError

			appUpdater.initialize(); // Initialize the update framework
			
			function closeOpenedWindow(event:Event) : void 
			{
				trace( "closeOpenedWindow" );
				var opened:Array = NativeApplication.nativeApplication.openedWindows;
				for (var i:int = 0; i < opened.length; i ++) 
					opened[i].close();
			}
			
			function onError(event:ErrorEvent) : void 
			{
				trace( "onError" );
				Alert.Show(event.toString(), AlertButton.OK);
			}
			
			function onUpdate(event:UpdateEvent) : void 
			{
				trace( "onUpdate" );
				appUpdater.checkNow(); // Go check for an update now
			}
		
		}
		
	}
}