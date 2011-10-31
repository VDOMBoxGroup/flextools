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
				dispatchEvent( new Event( ADD_IMAGE));
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
		
		
	}
}