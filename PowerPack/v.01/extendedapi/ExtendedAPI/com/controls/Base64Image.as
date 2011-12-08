package ExtendedAPI.com.controls
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.controls.Image;
	import mx.utils.Base64Decoder;

	public class Base64Image extends Image
	{

		private var _base64String:String;


		public function Base64Image() :void
		{
			super();
		}

		public function get value() :String
		{
			return _base64String;
		}

		public function set value( value:String ) :void
		{
			_base64String = value;
			source = value;
		}

		/**
		 * Attempt to auto detect if we're receiving a base64 encoded string
		 * or a traditional value for the image source
		 */
		override public function set source( value:Object ) :void
		{
			var decoder:Base64Decoder = new Base64Decoder();
			var byteArray:ByteArray;

			try
			{
				decoder.decode( value as String );
				byteArray = decoder.flush();
				
				super.source = byteArray;
				
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onBytesLoaded );
				loader.loadBytes( byteArray );
			}
			catch (error:Error)
			{
				super.source = value
			}
		}

		/**
		 * After the bytearray is loaded we need to convert to a bitmap
		 * in order to set the source of the parent image
		 */
		private function onBytesLoaded( event:Event ) :void
		{
			var content:DisplayObject = LoaderInfo( event.target ).content;
			var bitmapData:BitmapData = new BitmapData( content.width, content.height, true, 0x00ffffff );
			bitmapData.draw( content );

			super.source = new Bitmap( bitmapData );

		}

	}
}