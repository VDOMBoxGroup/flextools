package net.vdombox.ide.core.view
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.core.ApplicationFacade;
	
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
		
		override public function onRegister() : void
		{
			initialize();	
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
			
			applicationUpdater = null;
		}
		
		private function initialize():void
		{		
			if (! applicationUpdater )
				applicationUpdater = new ApplicationUpdaterUI();
			
			applicationUpdater.updateURL = "http://update.vdombox.ru/ide/update.xml"
			
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
			try
			{
				if ( applicationUpdater )
				{
					removeHandlers();
					
					applicationUpdater.checkNow();
				}
			}
			catch ( e : Error )
			{
				
			}
		}
		
		private function onError( event : ErrorEvent ) : void
		{
			removeHandlers();
			
			Alert.show( event.toString(), event.toString() );
		}
		
		
		
	}
}