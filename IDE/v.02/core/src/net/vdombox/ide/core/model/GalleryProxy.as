package net.vdombox.ide.core.model
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import net.vdombox.ide.core.model.vo.GalleryItemVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class GalleryProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "GalleryProxy";
		
		public function GalleryProxy()
		{
			super( NAME );
			
			var f : File = File.applicationDirectory;
			
			f = f.resolvePath( "modules/ApplicationsManagment/gallery" );
			
			_items = [];
			
			fileStream = new FileStream();
			fileStream.addEventListener( Event.COMPLETE, fileStream_completeHandler );
			fileStream.addEventListener( IOErrorEvent.IO_ERROR, fileStream_ioErrorHandler );	
			
			if ( f.exists )
			{
				_galleryItemsQue = f.getDirectoryListing();
			}
			
			loadFile( _galleryItemsQue.pop() )
			
		}
		
		private var _galleryItemsQue : Array
		private var _items : Array
		
		private var fileStream : FileStream;
		private var currentFile : File;
		
		public function get items () : Array
		{
			return _items.slice();
		}
		
		private function loadFile( file : File ) : void
		{
			if( file && file.exists && !file.isDirectory )
			{
				currentFile = file;
				fileStream.openAsync( file, FileMode.READ );
			}
		}
		
		private function fileStream_completeHandler( event : Event ) : void
		{
			var byteArray : ByteArray = new ByteArray();
			var name : String = currentFile.name;
			//			name = name.substr( 0, name.length - currentFile.extension.length - 1 );
			fileStream.readBytes( byteArray );
			
			_items.push( new GalleryItemVO( name, byteArray ) );
			
			if ( _galleryItemsQue.length > 0 )
				loadFile( _galleryItemsQue.pop() );
		}
		
		private function fileStream_ioErrorHandler ( event : IOErrorEvent ) : void
		{
			var d : * = "";
		}
	}
}