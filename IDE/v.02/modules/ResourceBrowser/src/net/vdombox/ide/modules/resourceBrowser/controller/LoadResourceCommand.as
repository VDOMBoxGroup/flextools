package net.vdombox.ide.modules.resourceBrowser.controller
{
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayList;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.resourceBrowser.model.StatesProxy;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class LoadResourceCommand extends SimpleCommand
	{
		private var openFile : File;
		private var pendingFiles : ArrayList;
		private var statesProxy : StatesProxy;
		private var fileDictionary : Dictionary;
		private var countLoadingResources : int = 0;
		private var countTotalResources : int = 0;
		private var loadingBytesResources : Number = 0;
		private var totalBytesResources : Number = 0;
		private var tickCount : int = 0;
		
		override public function execute( notification : INotification ) : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			openFile = new File();
			openFile.addEventListener(FileListEvent.SELECT_MULTIPLE, fileSelected); 
			
			var allFilesFilter : FileFilter = new FileFilter( "All Files (*.*)", "*.*" );
			var imagesFilter : FileFilter   = new FileFilter( 'Images (*.jpg;*.jpeg;*.gif;*.png)', '*.jpg;*.jpeg;*.gif;*.png' );
			var docFilter : FileFilter      = new FileFilter( 'Documents (*.pdf;*.doc;*.txt)', '*.pdf;*.doc;*.txt' );
			
			openFile.browseForOpenMultiple( "open", [ allFilesFilter, imagesFilter, docFilter ] );
		}
		
		private function fileSelected( event:FileListEvent ) : void
		{			
			openFile.removeEventListener(Event.SELECT, fileSelected);
			
			pendingFiles = new ArrayList();
			pendingFiles.addAll( new ArrayList( event.files ) );
			
			fileDictionary = new Dictionary();
			
			if ( pendingFiles.length > 0 )
			{
				sendNotification( Notifications.START_LOADING_RESOURCES );
				
				countLoadingResources = 0;
				countTotalResources = pendingFiles.length;
				
				for each ( var file : File in pendingFiles.source )
				{
					totalBytesResources += file.size;
				}
				
				addHandlersFile( pendingFiles.removeItemAt( 0 ) as File );
			}
		}
		
		private function addHandlersFile( file : File ) : void 
		{
			var urlLoader : URLLoader = new URLLoader();
			fileDictionary[ urlLoader ] = file;
			
			urlLoader.addEventListener(Event.OPEN, openHandler);
			urlLoader.addEventListener(Event.COMPLETE, completeHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			var urlRequest : URLRequest = new URLRequest( file.nativePath );
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.load( urlRequest );
		}
		
		private function removeHandlersFile( urlLoader : URLLoader ) : void 
		{
			urlLoader.removeEventListener(Event.OPEN, openHandler);
			urlLoader.removeEventListener(Event.COMPLETE, completeHandler);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		}
		
		private function openHandler( event : Event ) : void
		{
			var urlLoader : URLLoader = event.target as URLLoader;
			var file : File = fileDictionary[ urlLoader ];
			
			sendNotification( Notifications.OPEN_RESOURCES_BY_LOADING, { resourceName : file.name, resourceStatus : "Loading" } );
		}
		
		private function completeHandler( event : Event ) : void
		{
			var urlLoader : URLLoader = event.target as URLLoader;
			
			removeHandlersFile( urlLoader );
			
			var file : File = fileDictionary[ urlLoader ];
			
			var resourceVO : ResourceVO = new ResourceVO( statesProxy.selectedApplication.id );
			resourceVO.setID( file.name ); //?
			resourceVO.setData( urlLoader.data );
			resourceVO.name = file.name;
			resourceVO.type = file.type ? file.type.slice(1) : ""; // type has "."
			
			loadingBytesResources += file.size;
			
			setTimeout( sendNotifications, 100 )
			
			
			setTimeout( uploadResource, 300 )
			
			function sendNotifications( ) : void
			{
				sendNotification( Notifications.LOADED_RESOURCES_BY_LOADING, { totalProgtess :  { loading : countTotalResources - pendingFiles.length, total : countTotalResources },
					resourceStatus : "Export to base64" } );
				
			}
			
			function uploadResource( ) : void
			{
				
				sendNotification( Notifications.UPLOAD_RESOURCE, resourceVO );
				
				//progressLoadResourceWindow.resourceStatus.text = "Complete!";
				
				if ( pendingFiles.length > 0 )
					addHandlersFile( pendingFiles.removeItemAt( 0 ) as File );
				else
					sendNotification( Notifications.FINISH_LOADING_RESOURCES );
			}
		}
		
		private function ioErrorHandler( event : IOErrorEvent ) : void
		{
			trace('ioErrorHandler');
		}
		
		private function securityErrorHandler( event : SecurityErrorEvent ) : void
		{
			trace('securityErrorHandler');
		}
	}
}