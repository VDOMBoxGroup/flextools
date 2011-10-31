//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.core.view.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
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
	
	import net.vdombox.ide.core.events.IconChooserEvent;
	import net.vdombox.ide.core.model.vo.GalleryItemVO;
	import net.vdombox.ide.core.view.skins.ApplicationsIconsChoosWindowSkin;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.Window;

	public class ApplicationsIconsChoosWindow extends Window
	{
		public static var ADD_IMAGE : String = "addImage";
		
		private var _newImage : ByteArray;
		
		public function ApplicationsIconsChoosWindow()
		{
			width = 550;
			height = 340;
			minWidth = 550;
			minHeight = 340;
			maxWidth = 550;
			maxHeight = 340;
			systemChrome = NativeWindowSystemChrome.NONE;
			transparent = true;
			
			title = resourceManager.getString( 'Core_General', 'iconchooser_select_icon' ) ;
			
			addEventListener(FlexEvent.CREATION_COMPLETE , creatComleateHandler, false, 0, true );
			addEventListener(FlexEvent.REMOVE, removeHandler, false, 0, true );
		}
		
		[SkinPart( required="true" )]
		public var addImageBt : Button;
		
		[SkinPart( required="true" )]
		public var canselBt : Button;
		
		[SkinPart( required="true" )]
		public var iconsList : List;
		
		[SkinPart( required="true" )]
		public var selectBt : Button;
		
		private var loader : Loader;
		
		public function get newImage():ByteArray
		{
			return _newImage;
		}

		public function set dataProvider ( value : Array ) : void
		{
			iconsList.dataProvider = new ArrayList( value );
		}
		
		public function get imageSource():ByteArray
		{
			var galleryItemVO : GalleryItemVO = iconsList.selectedItem as GalleryItemVO;
			
			return ObjectUtil.copy( galleryItemVO.content ) as ByteArray;
		}

		public function selectIcon() : void
		{
			if (iconsList.selectedItem)
				dispatchEvent( new IconChooserEvent( IconChooserEvent.SELECT_ICON ) );
			close();
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", ApplicationsIconsChoosWindowSkin );
		}
		
		private function creatComleateHandler( event : FlexEvent ) : void
		{
			addImageBt.addEventListener(MouseEvent.CLICK , loadIconHandler, false, 0, true );
		}
		
		private function removeHandler( event : FlexEvent ) : void
		{
			addImageBt.removeEventListener( MouseEvent.CLICK , loadIconHandler);
		}
		
		
		private function file_selectHandler( event : Event ) : void
		{
			if ( !file || !file.exists )
				return;
			
			file.removeEventListener( Event.SELECT, file_selectHandler );
			
			var fileStream : FileStream = new FileStream();
			
			_newImage = new ByteArray();
			try
			{
				fileStream.open( file, FileMode.READ );
				fileStream.readBytes( _newImage );
			}
			catch ( error : Error )
			{
				// TODO: send a warning message;
				_newImage = null;
				return;
			}
			
			if ( _newImage.length > 0 )
			{
				loader = new Loader();
				
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, scaleImage, false, 0, true );
				
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loader_ioErrorHandler, false, 0, true );
				
				try
				{
					loader.loadBytes( _newImage );
				}
				catch ( error : Error )
				{
					
				}
			}
		}
		
		private var file : File;
		private function loadIconHandler( CreateApplicationEvent : Event ) : void
		{
			var fileFilter : FileFilter = new FileFilter( "Image", "*.jpg;*.jpeg;*.gif;*.png" );
			
			file = new File();
			file.addEventListener( Event.SELECT, file_selectHandler, false, 0, true );
			file.browseForOpen( "Load image", [ fileFilter ] );
		}
		
		private function scaleImage( event : Event ) : void
		{
			var originalImage : Bitmap;
			var scaledImageBtm : Bitmap;
			var scaledImageBtAr : ByteArray;
			
			var newWidth : Number = 55;
			var newHeight : Number = 55;
			var matrix : Matrix = new Matrix();
			var pngEncoder : PNGEncoder = new PNGEncoder();
			var bitmapData : BitmapData;
			
			originalImage = loader.content as Bitmap;
			
			matrix.scale( newWidth / originalImage.width, newHeight / originalImage.height );
			
			bitmapData = new BitmapData( newWidth, newHeight, true, 0x00ffffff );
			
			scaledImageBtm = new Bitmap( bitmapData, PixelSnapping.AUTO, true );
			scaledImageBtm.bitmapData.draw( originalImage.bitmapData, matrix );
			
			scaledImageBtAr = pngEncoder.encode( scaledImageBtm.bitmapData );
			
			addIcon( scaledImageBtAr );
		}
		
		private function addIcon( value : ByteArray ):void
		{
			var galleryItemVO : GalleryItemVO = new GalleryItemVO("name",  value );
			
			iconsList.dataProvider.addItem( galleryItemVO );
		}
		
		private function loader_ioErrorHandler( event : IOErrorEvent ) : void
		{
		}
		
	}
}