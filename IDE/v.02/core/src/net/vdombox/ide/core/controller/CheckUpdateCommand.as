package net.vdombox.ide.core.controller
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;
	
	import flash.desktop.NativeApplication;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import net.vdombox.view.Alert;
	import net.vdombox.view.AlertButton;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CheckUpdateCommand extends SimpleCommand
	{
		
		private var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();
		
		override public function execute( notification : INotification ) : void
		{
			NativeApplication.nativeApplication.addEventListener( Event.EXITING, 
				function(e:Event):void {
					var opened:Array = NativeApplication.nativeApplication.openedWindows;
					for (var i:int = 0; i < opened.length; i ++) {
						opened[i].close();
					}
				});    
			
			// Configuration stuff - see update framework docs for more details
			appUpdater.updateURL = "http://ehb.tomsk.ru/maks/update.xml"; // Server-side XML file describing update
			appUpdater.isCheckForUpdateVisible = false; // We won't ask permission to check for an update
			appUpdater.addEventListener(UpdateEvent.INITIALIZED, onUpdate); // Once initialized, run onUpdate
			appUpdater.addEventListener(ErrorEvent.ERROR, onError); // If something goes wrong, run onError
			appUpdater.initialize(); // Initialize the update framework
		}
		
		private function onError(event:ErrorEvent):void {
			Alert.Show(event.toString(), AlertButton.OK);
		}
		
		private function onUpdate(event:UpdateEvent):void {
			appUpdater.checkNow(); // Go check for an update now
		}
	}
}