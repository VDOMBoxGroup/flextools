package net.vdombox.helpeditor.controller
{
	import air.update.ApplicationUpdater;
	import air.update.ApplicationUpdaterUI;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusFileUpdateErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.UpdateEvent;
	
	import com.adobe.protocols.dict.events.ErrorEvent;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	
	import mx.controls.Alert;

	public class AutoUpdateManager
	{
		public var updateURL : String = "http://ehb.tomsk.ru/help_editor/update_editor.xml";
		
		private var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();
		
		public function AutoUpdateManager()
		{
		}
		
		public function checkNow():void
		{
			NativeApplication.nativeApplication.addEventListener( Event.EXITING, closeOpenedWindow );
			
			appUpdater.updateURL = updateURL;
			appUpdater.isCheckForUpdateVisible = true;
			appUpdater.isFileUpdateVisible = true;
			
			appUpdater.addEventListener(UpdateEvent.INITIALIZED, onUpdate);
			appUpdater.addEventListener(ErrorEvent.ERROR, onError);
			
			appUpdater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, onError);
			appUpdater.addEventListener(StatusFileUpdateErrorEvent.FILE_UPDATE_ERROR, onError);
			appUpdater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, onError);
			
			appUpdater.initialize();
		}
		
		private function closeOpenedWindow(event:Event) : void 
		{
			trace( "closeOpenedWindow" );
		}
		
		private function onError(event:ErrorEvent):void {
			Alert.show(event.toString());
		}
		
		private function onUpdate(event:UpdateEvent):void {
			appUpdater.checkNow(); // Go check for an update now
		}
	}
}