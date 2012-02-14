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
	
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	import net.vdombox.powerpack.managers.ProgressManager;
	import net.vdombox.powerpack.panel.popup.AlertPopup;

	public class BuilderUpdater extends EventDispatcher
	{
		private var urlLoader : URLLoader = new URLLoader();
		
		private var updateXmlUrl : String = "http://83.172.38.197:82/updaterLink/updatePowerPack.xml";
		private var updateXml : XML;
		
		private var fileStream : FileStream = new FileStream();
		
		private var buildFile : File = File.applicationStorageDirectory.resolvePath("BuilderInstaller"+FileUtils.nativeInstallerType);
		
		
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
			
			try
			{
				updateXml = new XML(urlLoader.data);
				
				if (updateRequired)
				{
					
					AlertPopup.show(updateQuestionText, updateTitle, 
									AlertPopup.YES|AlertPopup.NO, 
									Sprite(Application.application), 
									updateAlertCloseHandler,
									null, 
									AlertPopup.YES, 
									"left");
				}
				
			}
			catch (e:Error)
			{
			}
		}
		
		private function get updateQuestionText () : String
		{
			var question	: String = "Do you want to load update?" + "\n";
			
			var curVersion : String = "<b>Current version: </b>" + Utils.getApplicationVersion() + "\n";
			var newVersion : String = "<b>Update version:  </b>" + updateVersion + "\n";
			
			var description : String = updateDescription.length == 0 ? "" : "<b>Changes:</b>\n" + updateDescription + "\n\n";
				
			return curVersion + newVersion + description + question;
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
		
		private function get updateDescription () : String
		{
			return updateXml ? updateXml.description : "";
		}
		
		private function get releaseUrl () : String
		{
			var url : String = "";
			
			switch(FileUtils.OS)
			{
				case FileUtils.OS_WINDOWS:
				{
					url = updateXml.urlWin;
					break;
				}
				case FileUtils.OS_LINUX:
				{
					url = updateXml.urlLinux;
					break;
				}
				case FileUtils.OS_MAC:
				{
					url = updateXml.urlMac;
					break;
				}	
				default:
				{
					throw Error ("Can't determine OS");
					break;
				}
			}
			
			return url;
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
					
				case URLLoaderDataFormat.BINARY: // exe/deb/rmp loaded
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