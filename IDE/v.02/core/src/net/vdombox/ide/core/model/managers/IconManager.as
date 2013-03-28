package net.vdombox.ide.core.model.managers
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	import mx.charts.CategoryAxis;
	import mx.graphics.codec.PNGEncoder;
	
	import net.vdombox.ide.common.model._vo.ResourceVO;

	public class IconManager extends EventDispatcher
	{
		/**
		 *
		 * @default
		 */
		public static const ICON_LOADING_COMPLETED : String = "iconLoadingCompleted";

		/**
		 *
		 * @default
		 */
		public static const ICON_LOADING_ERROR : String = "iconLoadingError";

		/**
		 *
		 * @default
		 */
		public var icon : Object = { avi: avi_Icon, bin: bin_Icon, blank: bmp_Icon, bmp: bmp_Icon, c: c_Icon, cfg: cfg_Icon, cpp: cpp_Icon, css: css_Icon, dll: dll_Icon, doc: doc_Icon, docx: doc_Icon
				, dvi: dvi_Icon
				, gif: gif_Icon, jv: java_Icon, htm: htm_Icon, html: htm_Icon, mht: htm_Icon, mid: htm_Icon, None: blank_Icon, pdf: pdf_Icon, swf: swf_Icon, txt: txt_Icon, wav: wav_Icon, xls: xls_Icon
				, xlsx: xls_Icon };


		private static const avi_Icon : String = "resourceBrowserIcons/resourceType/avi.png";

		private static const bin_Icon : String = "resourceBrowserIcons/resourceType/bin.png";

		private static const blank_Icon : String = "resourceBrowserIcons/resourceType/blank.png";

		private static const bmp_Icon : String = "resourceBrowserIcons/resourceType/bmp.png";

		private static const c_Icon : String = "resourceBrowserIcons/resourceType/c.png";

		private static const cfg_Icon : String = "resourceBrowserIcons/resourceType/cfg.png";

		private static const cpp_Icon : String = "resourceBrowserIcons/resourceType/cpp.png";

		private static const css_Icon : String = "resourceBrowserIcons/resourceType/css.png";

		private static const dll_Icon : String = "resourceBrowserIcons/resourceType/dll.png";

		private static const doc_Icon : String = "resourceBrowserIcons/resourceType/doc.png";

		private static const dvi_Icon : String = "resourceBrowserIcons/resourceType/dvi.png";

		private static const gif_Icon : String = "resourceBrowserIcons/resourceType/gif.png";

		private static const htm_Icon : String = "resourceBrowserIcons/resourceType/htm.png";

		private static const java_Icon : String = "resourceBrowserIcons/resourceType/java.png";

		private static const mid_Icon : String = "resourceBrowserIcons/resourceType/mid.png";

		private static const pdf_Icon : String = "resourceBrowserIcons/resourceType/pdf.png";

		private static const swf_Icon : String = "resourceBrowserIcons/resourceType/swf.png";

		private static const txt_Icon : String = "resourceBrowserIcons/resourceType/txt.png";

		private static const wav_Icon : String = "resourceBrowserIcons/resourceType/wav.png";

		private static const xls_Icon : String = "resourceBrowserIcons/resourceType/xls.png";

		private static const file_broken_Icon : String = "assets/resourceBrowserIcons/resourceType/file_broken.png";


		private var cacheManager : CacheManager = CacheManager.getInstance();

		/**
		 *
		 */
		public function IconManager( resourceVO : ResourceVO )
		{
			_resourceVO = resourceVO;

		}



		/**
		 *
		 * @default
		 */


		private var _resourceVO : ResourceVO = null;

		/**
		 *
		 * @default
		 */
		public function get resourceVO() : ResourceVO
		{
			return _resourceVO;
		}

		/**
		 * @private
		 */
		public function set resourceVO( value : ResourceVO ) : void
		{
			_resourceVO = value;
		}


		private function loadLocalIcon() : Boolean
		{

			return true;

		}

		private function getCahedFile( name : String ) : File
		{
			var fileIcon : File;

			fileIcon = File.applicationStorageDirectory.resolvePath( "cache" );

			return fileIcon.resolvePath( name );
		}

		private function getStandartIcon() : File
		{
			var fileIcon : File;

			fileIcon = File.applicationDirectory;

			return fileIcon.resolvePath( path );
		}

		private function fileExists( file : File ) : Boolean
		{
			return file && file.exists;
		}

		public function setIconForResourceVO() : void
		{
			var data : ByteArray = new ByteArray();

			var file : File; // = getIconFile();
			var fileStream : FileStream = new FileStream();


			if ( _resourceVO.mastHasPreview )
			{
				file = getCahedFile( _resourceVO.iconId );

				if ( !fileExists( file ) )
				{
					createIcon();
					
				}
			}
			else if ( !fileExists( file ) )
				file = getStandartIcon();


			try
			{
				fileStream.open( file, FileMode.READ );
				fileStream.readBytes( data );
			}
			catch ( error : Error )
			{
				return;
			}

			if ( !data || data.bytesAvailable == 0 )
				return;

			_resourceVO.icon = data;

		}

		private function get path() : String
		{
			return icon[ _resourceVO.type ] || icon[ "blank" ];
		}

		private function getIconFile() : File
		{
			var fileIcon : File;

			if ( _resourceVO.mastHasPreview )
			{
				fileIcon = File.applicationStorageDirectory.resolvePath( "cache" );
				return fileIcon.resolvePath( _resourceVO.iconId );
			}
			else
			{
				fileIcon = File.applicationDirectory;
				return fileIcon.resolvePath( path );
			}

			return fileIcon;
		}



		private function createIcon() : void
		{
			var resourceData : ByteArray = cacheManager.getCachedFileById( _resourceVO.id );

			//file is located in the file system user
			if ( resourceData )
			{
				resourceVO.setData( resourceData );
				resourceVO.setStatus( ResourceVO.LOADED );
				createIconFromResourceVO();
			}
			else
			{
				dispatchEvent( new Event( "loadResourceRequest" ) );
			}
		}

		private function createIconFromResourceVO() : void
		{
			var loader : Loader = new Loader();
			loader.name = _resourceVO.id;
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, contentLoaderInfoCompleteHandler );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onBytesLoaded );
			loader.loadBytes( _resourceVO.data );
		}




		private function contentLoaderInfoCompleteHandler( event : Event ) : void
		{
			var loaderInfo : LoaderInfo = event.target as LoaderInfo;


			var icon : ByteArray = getResizedData( loaderInfo );
			var cacheManager : CacheManager = CacheManager.getInstance();

			if ( !icon )
				return;

			_resourceVO.icon = icon;
			cacheManager.cacheFile( _resourceVO.iconId, icon );

		}
		
		private function onBytesLoaded(event:Event):void
		{
			trace("ttt");
		}

		//convert to bitmapData 
		private function getResizedData( loaderInfo : LoaderInfo ) : ByteArray
		{
			var ratio : Number = 1;
			var width : int;
			var height : int;
			var resultBitmapData2 : BitmapData;

			var loaderInfo : LoaderInfo;
			var originalBitmapData : BitmapData;
			var resultBitmap : Bitmap;

			var encoder : PNGEncoder = new PNGEncoder();
			var matrix : Matrix = new Matrix();

			var cacheManager : CacheManager = CacheManager.getInstance();


			try
			{
				originalBitmapData = new BitmapData( loaderInfo.width, loaderInfo.height, false, 0xFFFFFF );


				originalBitmapData.draw( loaderInfo.loader );
			}
			catch ( e : Error )
			{
				return null;
			}

			resultBitmap = new Bitmap( originalBitmapData );



			if ( resultBitmap.height > ResourceVO.ICON_SIZE || resultBitmap.width > ResourceVO.ICON_SIZE )
			{

				if ( resultBitmap.width >= resultBitmap.height )
					ratio = ResourceVO.ICON_SIZE / resultBitmap.width;
				else
					ratio = ResourceVO.ICON_SIZE / resultBitmap.height;

				width = ( int( resultBitmap.width * ratio ) > 0 ) ? int( resultBitmap.width * ratio ) : 1;
				height = ( int( resultBitmap.height * ratio ) > 0 ) ? int( resultBitmap.height * ratio ) : 1;

				resultBitmapData2 = new BitmapData( width, height, false );
				resultBitmap.smoothing = true;


				matrix.scale( ratio, ratio );
				resultBitmapData2.draw( resultBitmap.bitmapData, matrix );

				//				cacheManager.cacheFile(loaderInfo.loader.name + "_icon", encoder.encode(resultBitmapData2)); // not nice			
				//				requestedResourceForIcon[ loaderInfo.loader.name ].setStatus( ResourceVO.ICON_LOADED );

				//				creationIconCompleted( tempResourceVO[ loaderInfo.loader.name ], encoder.encode( btm ) );
				return encoder.encode( resultBitmapData2 );
			}
			else
			{
				return encoder.encode( resultBitmap.bitmapData );
					//				var encoder1 : PNGEncoder = new PNGEncoder();
					//				creationIconCompleted( tempResourceVO[ loaderInfo.loader.name ], encoder1.encode( bitmap.bitmapData ) );
			}

			//			delete requestedResourceForIcon[ loaderInfo.loader.name ];
		}
	}
}
