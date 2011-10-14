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
	import mx.events.FlexEvent;
	import mx.graphics.codec.PNGEncoder;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.IconChooserEvent;
	import net.vdombox.ide.core.model.GalleryProxy;
	import net.vdombox.ide.core.view.components.IconChooser;
	import net.vdombox.ide.core.view.components.IconChooserWindow;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Window;
	import spark.events.IndexChangeEvent;

	public class IconChooserMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "IconChooserMediator";
		
		public function IconChooserMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		private var loader : Loader;
		private var iconChooserWindow : IconChooserWindow
		
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
			facade.registerProxy( new GalleryProxy() );
			
			addHandlers()
		}
		
		private function addHandlers() : void
		{
			iconChooser.addEventListener( IconChooserEvent.LOAD_ICON, loadIconHandler );
			iconChooser.addEventListener( IconChooserEvent.OPEN_ICON_LIST, openIconListHandler );
		}
		
		private function removeHandlers() : void
		{
			iconChooser.removeEventListener( IconChooserEvent.LOAD_ICON, loadIconHandler );
			iconChooser.removeEventListener( IconChooserEvent.OPEN_ICON_LIST, openIconListHandler );
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.CLOSE_APPLICATION_MANAGER:
				{
					facade.removeMediator( mediatorName );
					
					break;
				}	
			}
		}
		
		override public function onRemove() : void
		{
//			closeWindows();
//			removeHandlers();
			facade.removeProxy( GalleryProxy.NAME );
			
			removeHandlers();
		}
		
		private function openIconListHandler( event : IconChooserEvent ) : void
		{
			iconChooserWindow = new IconChooserWindow();
			iconChooserWindow.addEventListener( IconChooserEvent.CLOSE_ICON_LIST, closeIconListHandler );
			iconChooserWindow.addEventListener( FlexEvent.CREATION_COMPLETE, createCompleteIconListHandler );
			
			WindowManager.getInstance().addWindow( iconChooserWindow, iconChooser, true );
		}
		
		private function createCompleteIconListHandler( event : FlexEvent ) : void
		{	
			var gp : GalleryProxy = facade.retrieveProxy( GalleryProxy.NAME ) as GalleryProxy;
			iconChooserWindow.iconsList.addEventListener( IndexChangeEvent.CHANGE, iconList_changeHandler );
			
			iconChooserWindow.iconsList.dataProvider = new ArrayList( gp.items );
			iconChooserWindow.iconsList.selectedIndex = 0;
			
			showIcon();
		}
		
		private function closeIconListHandler( event : IconChooserEvent ) : void
		{			
			iconChooserWindow.removeEventListener( IconChooserEvent.CLOSE_ICON_LIST, closeIconListHandler );
			iconChooserWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, createCompleteIconListHandler );
			
			WindowManager.getInstance().removeWindow( iconChooserWindow );
		}
		
		private function showIcon() : void
		{
			if( iconChooserWindow.iconsList.selectedItem )
				iconChooser.selectedIcon.source = iconChooserWindow.iconsList.selectedItem.content;
		}
		
		/*private function showIcon() : void
		{
			if( iconChooserWindow.iconsList.selectedItem )
			{
				var loader : Loader = new Loader();
			
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, backgroundContentLoaded );
				//loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, backgroundContentLoaded );
			
				try
				{
					loader.loadBytes( iconChooserWindow.iconsList.selectedItem.content );
				}
				catch ( error : Error )
				{
					// FIXME Сделать обработку исключения если не грузится изображение
				}
			}
		}
		
		private function backgroundContentLoaded( event : Event ) : void
		{
			iconChooser.selectedIcon.source = event.target.content;
			//selectIcon2 = iconChooserWindow.iconsList.selectedItem.content;
		}*/
		
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
			//iconChooser.iconsList.selectedIndex = -1;
		}
		
		private function loader_ioErrorHandler( event : IOErrorEvent ) : void
		{
		}
	}
}