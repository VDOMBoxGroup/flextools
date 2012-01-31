package net.vdombox.ide.core.view
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import flash.desktop.NativeApplication;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class UpdateMediator extends Mediator implements IMediator
	{
		
		public static const NAME : String = "UpdateMediator";
		
		private var applicationUpdater : ApplicationUpdaterUI = new ApplicationUpdaterUI();
		
		private var ativeApplication : NativeApplication = NativeApplication.nativeApplication;
		
		public function UpdateMediator( viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			
			switch ( notification.getName() )
			{
				case ApplicationFacade.CHECK_UPDATE:
				{
//					if ( initialized ) 
//						applicationUpdater.checkNow();
//					
					break;
				}
			}
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.CHECK_UPDATE );
			
			return interests;
		}
		
		override public function onRegister() : void
		{
			initialize();	
		}
		
		override public function onRemove() : void
		{
//			removeHandlers();
			
			applicationUpdater = null;
		}
		
		private function initialize():void
		{
			//applicationUpdater.updateURL = "http://ehb.tomsk.ru/maks/update.xml"; 
			
			applicationUpdater.updateURL = "http://83.172.38.197:82/updaterLink/update.xml"
			//applicationUpdater.updateURL = "http://83.172.38.197:82/updaterLink/updateRelise.xml"
			
			applicationUpdater.isCheckForUpdateVisible = false; // We won't ask permission to check for an update
			
			addHandlers();
			
			applicationUpdater.initialize();
		}
		
		private function addHandlers() : void
		{
			
			applicationUpdater.addEventListener( UpdateEvent.INITIALIZED, onUpdate, false, 0, true ); // Once initialized, run onUpdate
		
			applicationUpdater.addEventListener( ErrorEvent.ERROR, onError, false, 0, true );
			
			
			
		}
		
		private function removeHandlers() : void
		{
			applicationUpdater.removeEventListener( UpdateEvent.INITIALIZED, onUpdate ); // Once initialized, run onUpdate
			
			applicationUpdater.removeEventListener( ErrorEvent.ERROR, onError );
			
		}
		
		
		
		private function onUpdate( event : UpdateEvent ) : void
		{
				applicationUpdater.checkNow();
		}
		
		private function onError( event : ErrorEvent ) : void
		{
//			Alert.show( event.toString(), AlertButton.OK );
		}
		
		
		
	}
}