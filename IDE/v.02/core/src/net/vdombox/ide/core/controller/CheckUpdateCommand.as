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

		override public function execute( notification : INotification ) : void
		{
			return;

			var appUpdater : ApplicationUpdaterUI = new ApplicationUpdaterUI();

			appUpdater.updateURL = "http://ehb.tomsk.ru/maks/update.xml"; // Server-side XML file describing update
			appUpdater.isCheckForUpdateVisible = false; // We won't ask permission to check for an update
			
			appUpdater.addEventListener( UpdateEvent.INITIALIZED, onUpdate ); // Once initialized, run onUpdate
			appUpdater.addEventListener( ErrorEvent.ERROR, onError ); // If something goes wrong, run onError

			appUpdater.addEventListener( Event.DEACTIVATE, onDeactive, false, 0, true );
			appUpdater.initialize(); // Initialize the update framework



			function onError( event : ErrorEvent ) : void
			{
				Alert.Show( event.toString(), AlertButton.OK );
			}

			function onUpdate( event : UpdateEvent ) : void
			{
				appUpdater.checkNow(); // Go check for an update now
			}
			
			function onDeactive( event : Event ) : void
			{
				trace("************* !  onDeactive  ************************");
			}

		}

	}
}
