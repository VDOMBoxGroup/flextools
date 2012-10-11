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
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.utils.VersionUtils;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class UpdateMediator extends Mediator implements IMediator
	{
		
		public static const NAME : String = "UpdateMediator";
		
		private var applicationUpdater : ApplicationUpdaterUI;
		
		private var ativeApplication : NativeApplication = NativeApplication.nativeApplication;
		
		private var dataXML : XML;
		
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
			var url : String = "http://update.vdombox.ru/ide/update.xml"
			var loader:URLLoader = new URLLoader ();
			var request:URLRequest = new URLRequest ( url );
			
			// pass the post data
			request.method = URLRequestMethod.POST;
			
			
			// Add Handlers
			loader.addEventListener ( Event.COMPLETE, on_complete );
			loader.addEventListener ( IOErrorEvent.IO_ERROR, on_error );
			loader.addEventListener ( SecurityErrorEvent.SECURITY_ERROR, on_error );
			loader.load ( request );
			
			
		}
		
		private function on_error( evt:Event ):void
		{
			
		}
		
		private function on_complete( evt:Event ):void
		{
			try
			{
				dataXML = new XML ( evt.target.data );
				
				var ftpVersion : String = dataXML.children()[0];
				
				var currentVersion : String = VersionUtils.getApplicationVersion();
				
				if ( ftpVersion <= currentVersion )
					return;
			}
			catch( e : Error )
			{
				return;
			}
			
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