//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.core.model
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.vo.GalleryItemVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class GalleryProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "GalleryProxy";

		public function GalleryProxy()
		{
			super( NAME );

			init();

		}

		private var _galleryItemsQue : Array

		private var _items : Array

		private var currentFile : File;

		private var fileStream : FileStream;
		
		public static var errorWritten : Boolean;

		public function get items() : Array
		{
			return _items.slice();
		}

		private var loader : Loader;

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

		private function fileStream_ioErrorHandler( event : IOErrorEvent ) : void
		{
			var d : * = "";
			if ( !errorWritten )
			{
				errorWritten = true;
				sendNotification( ApplicationFacade.WRITE_ERROR, event.text );
			}
		}

		private function init() : void
		{
			errorWritten = false;
			
			var f : File = File.applicationDirectory;

			f = f.resolvePath( "gallery" );

			_items = [];

			fileStream = new FileStream();
			fileStream.addEventListener( Event.COMPLETE, fileStream_completeHandler );
			fileStream.addEventListener( IOErrorEvent.IO_ERROR, fileStream_ioErrorHandler );

			if ( f.exists )
			{
				_galleryItemsQue = f.getDirectoryListing();

			}

			if ( _galleryItemsQue )
				loadFile( _galleryItemsQue.pop() )
		}

		private function loadFile( file : File ) : void
		{
			if ( file && file.exists && !file.isDirectory )
			{
				currentFile = file;
				fileStream.openAsync( file, FileMode.READ );
			}
		}
	}
}
