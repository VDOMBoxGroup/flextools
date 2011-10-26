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
	import mx.utils.ObjectUtil;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.IconChooserEvent;
	import net.vdombox.ide.core.model.GalleryProxy;
	import net.vdombox.ide.core.model.vo.GalleryItemVO;
	import net.vdombox.ide.core.view.components.ApplicationsIconView;
	import net.vdombox.ide.core.view.components.ApplicationsIconsChoosWindow;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Window;
	import spark.events.IndexChangeEvent;

	public class ApplicationsIconViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "IconChooserMediator";
		
		public function ApplicationsIconViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		private var loader : Loader;
		private var applicationsIconsChoosWindow : ApplicationsIconsChoosWindow
		
		public function get iconChanged():Boolean
		{
			return _iconChanged;
		}

		public function get applicationsIconView() : ApplicationsIconView
		{
			return viewComponent as ApplicationsIconView;
		}
		
		public function get defaultIcon() : ByteArray
		{
			var galleryItemVO : GalleryItemVO = galleryProxy.items[0] as GalleryItemVO;
			
			return ObjectUtil.copy( galleryItemVO.content ) as ByteArray;
		}
		
		private var _iconChanged : Boolean = false;
		
		public function get selectedIcon() : ByteArray
		{
			return applicationsIconView.icon.source as ByteArray;
		}
		
		public function get icon() : ByteArray
		{
			return selectedIcon || defaultIcon;
		}
		
		override public function onRegister() : void
		{
			
			addHandlers()
		}
		
		private function addHandlers() : void
		{
			applicationsIconView.addEventListener( IconChooserEvent.LOAD_ICON, loadIconHandler );
			applicationsIconView.addEventListener( IconChooserEvent.OPEN_ICON_LIST, openIconListHandler );
		}
		
		private function removeHandlers() : void
		{
			applicationsIconView.removeEventListener( IconChooserEvent.LOAD_ICON, loadIconHandler );
			applicationsIconView.removeEventListener( IconChooserEvent.OPEN_ICON_LIST, openIconListHandler );
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				
			}
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		private function openIconListHandler( event : IconChooserEvent ) : void
		{
			applicationsIconsChoosWindow = new ApplicationsIconsChoosWindow();
			applicationsIconsChoosWindow.addEventListener( IconChooserEvent.CLOSE_ICON_LIST, closeIconListHandler );
			applicationsIconsChoosWindow.addEventListener( IconChooserEvent.SELECT_ICON, selectIconHandler );
			applicationsIconsChoosWindow.addEventListener( FlexEvent.CREATION_COMPLETE, createCompleteIconListHandler );
			
			WindowManager.getInstance().addWindow( applicationsIconsChoosWindow, applicationsIconView, true );
		}
		
		private function createCompleteIconListHandler( event : FlexEvent ) : void
		{	
			applicationsIconsChoosWindow.iconsList.dataProvider = new ArrayList( galleryProxy.items );
		}
		
		private function selectIconHandler(event : IconChooserEvent) : void
		{
			var galleryItemVO : GalleryItemVO = applicationsIconsChoosWindow.iconsList.selectedItem as GalleryItemVO;
			if( !galleryItemVO )
				return;
		
			applicationsIconView.icon.source = ObjectUtil.copy( galleryItemVO.content );
			_iconChanged = true;
			
		}
		
		private function closeIconListHandler( event : IconChooserEvent ) : void
		{			
			applicationsIconsChoosWindow.removeEventListener( IconChooserEvent.CLOSE_ICON_LIST, closeIconListHandler );
			applicationsIconsChoosWindow.removeEventListener( IconChooserEvent.SELECT_ICON, selectIconHandler );
			applicationsIconsChoosWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, createCompleteIconListHandler );
			
			WindowManager.getInstance().removeWindow( applicationsIconsChoosWindow );
		}
		
		
		private function loadIconHandler( CreateApplicationEvent : Event ) : void
		{
			var file : File = new File();
			var fileFilter : FileFilter = new FileFilter( "Image", "*.jpg;*.jpeg;*.gif;*.png" );
			
			file.addEventListener( Event.SELECT, file_selectHandler );
			file.browseForOpen( "Load image", [ fileFilter ] );
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
				
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loader_completeHandler, false, 0, true );
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loader_ioErrorHandler, false, 0, true );
				
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
			
			_iconChanged = true;
			applicationsIconView.icon.source = iconByteArray;
			//iconChooser.iconsList.selectedIndex = -1;
		}
		
		private function loader_ioErrorHandler( event : IOErrorEvent ) : void
		{
		}
		private function get galleryProxy(): GalleryProxy
		{
			return facade.retrieveProxy( GalleryProxy.NAME ) as GalleryProxy;
		}
	}
}