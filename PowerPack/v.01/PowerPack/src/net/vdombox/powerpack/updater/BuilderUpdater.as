package net.vdombox.powerpack.updater
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusFileUpdateErrorEvent;
	import air.update.events.UpdateEvent;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import mx.core.Application;
	import mx.core.WindowedApplication;
	import mx.events.CloseEvent;
	import mx.utils.StringUtil;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	import net.vdombox.powerpack.managers.ProgressManager;
	import net.vdombox.powerpack.panel.popup.AlertPopup;

	public class BuilderUpdater extends EventDispatcher
	{
		private var urlLoader : URLLoader = new URLLoader();
		
		private var updateXmlUrl : String = "http://83.172.38.197:82/updaterLink/updatePowerPack.xml";
		private var updateXml : XML;
		
		private var fileStream : FileStream = new FileStream();
		
		private var buildUrl : String = "";
		private var buildFile : File = File.applicationStorageDirectory.resolvePath("BuilderInstaller.exe");
		
		
		public function BuilderUpdater()
		{
		}
		
		public function checkForUpdate():void
		{
			loadFile(updateXmlUrl, URLLoaderDataFormat.TEXT);
		}
		
		private function updateXmlLoaded () : void
		{
			var updateTitle	: String = "Update available";
			var updateMsg	: String = "Do you want to load update?";
			
			try
			{
				updateXml = new XML(urlLoader.data);
				
				if (updateRequired)
				{
					
					AlertPopup.show(updateMsg, updateTitle, AlertPopup.YES|AlertPopup.NO, Sprite(Application.application), updateAlertCloseHandler);
				}
				
			}
			catch (e:Error)
			{
			}
		}
		
		private function updateAlertCloseHandler(event : CloseEvent) : void
		{
			if ( event.detail == AlertPopup.YES )
			{
				ProgressManager.source = urlLoader;
				ProgressManager.show(ProgressManager.WINDOW_MODE, true);
				
				loadFile(releaseUrl, URLLoaderDataFormat.BINARY);
				return;
			}
			
			if (event.detail == AlertPopup.NO)
			{
				return;
			}
		}
		
		private function get updateRequired() : Boolean
		{
			if (!updateXml)
				return false;
			
			return updateVersion > Utils.getApplicationVersion() && releaseUrl;
		}
		
		private function releaseLoaded() : void
		{
			
			var distribFileGenerated : Boolean = generateDistribFile();
			
			if (!distribFileGenerated)
			{
				showUpdateError();
				return;
			}
			
			updateBuilder();
			
		}
		
		private function generateDistribFile () : Boolean
		{
			try {
				fileStream.open(buildFile, FileMode.WRITE);
				fileStream.writeBytes(urlLoader.data);
				fileStream.close();
				
			} catch ( error : IOError ) 
			{
				return false;
			}
			
			return true;
		}
		
		private function updateBuilder () : void
		{
			buildFile.openWithDefaultApplication();
			
			ProgressManager.complete();
		}
		
		private function get updateVersion () : String
		{
			return updateXml ? updateXml.version : "";
		}
		
		private function get releaseUrl () : String
		{
			return updateXml ? StringUtil.trim(updateXml.url) : "";
		}
		
		private function loadFile(url:String, dataFormat:String):void
		{
			var urlRequest : URLRequest = new URLRequest(url);
			
			urlLoader.dataFormat = dataFormat;
			
			addHandlers ();
			
			urlLoader.load(urlRequest);
		}
		
		private function addHandlers() : void
		{
			urlLoader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
		}
		
		private function removeHandlers() : void
		{
			urlLoader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
		}
		
		private function loadCompleteHandler( event : Event ) : void
		{
			removeHandlers();

			switch(urlLoader.dataFormat)
			{
				case URLLoaderDataFormat.TEXT: // xml loaded
				{
					updateXmlLoaded();
					break;
				}
					
				case URLLoaderDataFormat.BINARY: // exe loaded
				{
					releaseLoaded();
					break;
				}
					
				default:
				{
					showUpdateError();
					break;
				}
			}
		}
		
		private function loadErrorHandler( event : Event ) : void
		{
			removeHandlers();
			
			if (urlLoader.dataFormat == URLLoaderDataFormat.BINARY)
				showUpdateError();
		}
		
		private function showUpdateError () : void
		{
			AlertPopup.show("Error loading update");
			
			ProgressManager.complete();
		}
		
	}
}