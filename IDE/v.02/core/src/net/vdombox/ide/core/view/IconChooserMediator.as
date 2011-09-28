package net.vdombox.ide.core.view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayList;
	import mx.graphics.codec.PNGEncoder;
	
	import net.vdombox.ide.core.events.IconChooserEvent;
	import net.vdombox.ide.core.model.GalleryProxy;
	import net.vdombox.ide.core.view.components.IconChooser;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.events.IndexChangeEvent;

	public class IconChooserMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "IconChooserMediator";
		
		public function IconChooserMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		private var loader : Loader;
		
		public function get iconChooser() : IconChooser
		{
			return viewComponent as IconChooser;
		}
		
		public function get defaultIcon() : ByteArray
		{
			return null;
		}
		
		public function get selectedIcon() : ByteArray
		{
			return iconChooser.selectedIcon.source as ByteArray;
		}
		
		override public function onRegister() : void
		{
			var gp : GalleryProxy = facade.retrieveProxy( GalleryProxy.NAME ) as GalleryProxy;
			
			iconChooser.iconsList.addEventListener( IndexChangeEvent.CHANGE, iconList_changeHandler )
			iconChooser.addEventListener( IconChooserEvent.LOAD_ICON, loadIconHandler )
			iconChooser.iconsList.dataProvider = new ArrayList( gp.items );
			iconChooser.iconsList.selectedIndex = 0;
			
			showIcon();
		}
		
		private function showIcon() : void
		{
			if( iconChooser.iconsList.selectedItem )
				iconChooser.selectedIcon.source = iconChooser.iconsList.selectedItem.content;
		}
		
		private function loadIconHandler( CreateApplicationEvent : Event ) : void
		{
			var file : File = new File();
			var fileFilter : FileFilter = new FileFilter( "Image", "*.jpg;*.jpeg;*.gif;*.png" );
			
			file.addEventListener( Event.SELECT, file_selectHandler );
			file.browseForOpen( "Load image", [ fileFilter ] );
		}
		
		private function iconList_changeHandler( event : IndexChangeEvent ) : void
		{
			showIcon();
		}
		
		private function file_selectHandler( event : Event ) : void
		{
			var file : File = event.currentTarget as File;
			
			if ( !file || !file.exists )
				return;
			
			file.removeEventListener( Event.SELECT, file_selectHandler );
			
			var fileStream : FileStream = new FileStream();
			var byteArray : ByteArray = new ByteArray();
			
			try
			{
				fileStream.open( file, FileMode.READ );
				fileStream.readBytes( byteArray );
			}
			catch ( error : Error )
			{
				return;
			}
			
			if ( byteArray.length > 0 )
			{
				loader = new Loader();
				
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loader_completeHandler, false,
					0, true );
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loader_ioErrorHandler,
					false, 0, true );
				
				try
				{
					loader.loadBytes( byteArray );
				}
				catch ( error : Error )
				{
					
				}
			}
		}
		
		private function loader_completeHandler( event : Event ) : void
		{
			var image : Bitmap = loader.content as Bitmap;
			
			var matrix : Matrix = new Matrix();
			var scaleX : Number = 55 / image.width;
			var scaleY : Number = 55 / image.height;
			
			matrix.scale( scaleX, scaleY );
			var scaledImage : Bitmap = new Bitmap( new BitmapData( 55, 55, true, 0x00ffffff ), PixelSnapping.AUTO,
				true );
			scaledImage.bitmapData.draw( image.bitmapData, matrix );
			
			var pnge : PNGEncoder = new PNGEncoder();
			var iconByteArray : ByteArray = pnge.encode( scaledImage.bitmapData );
			
			iconChooser.selectedIcon.source = iconByteArray;
			iconChooser.iconsList.selectedIndex = -1;
		}
		
		private function loader_ioErrorHandler( event : IOErrorEvent ) : void
		{
		}
	}
}