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
	import flash.display.Loader;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Image;
	
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.core.events.MainWindowEvent;
	import net.vdombox.ide.core.view.skins.MainWindowSkin;
	
	import spark.components.Group;
	import spark.components.TextInput;
	import spark.components.Window;

//	import spark.components.windowClasses.TitleBar;
	/**
	 *
	 * @author andreev ap
	 */
	public class MainWindow extends Window
	{
		/**
		 *
		 */
		public function MainWindow()
		{
			super();
			systemChrome = NativeWindowSystemChrome.NONE;
			transparent = true;
			width = 1000;
			height = 600;
			minWidth = 1000;
			minHeight = 600;
			
			addEventListener( Event.CLOSING, saveAppPosition, false, 0, true );
		}
		
		public var notCenteralize : Boolean = true;
		
		private function saveAppPosition(e:Event = null):void
		{
			removeEventListener( Event.CLOSING, saveAppPosition );
			
			var xml:XML;
			
			var scrWidth : Number = Screen.mainScreen.visibleBounds.width;
			var scrHeight : Number = Screen.mainScreen.visibleBounds.height;
			
			if ( nativeWindow.displayState == "maximized" )
				xml = new XML('<position x="'+this.nativeWindow.x+'" y="'+this.nativeWindow.y+'" width="'+this.width+'" height="'+this.height+'" full="'+true+'"/>');
			else
				xml = new XML('<position x="'+this.nativeWindow.x+'" y="'+this.nativeWindow.y+'" width="'+this.width+'" height="'+this.height+'" full="'+false+'"/>');
			
			var f:File = File.applicationStorageDirectory.resolvePath("appPosition.xml");
			var s:FileStream = new FileStream();
			try
			{
				s.open(f,flash.filesystem.FileMode.WRITE);
				
				s.writeUTFBytes(xml.toXMLString());
			}
			catch(e:Error){}
			finally
			{
				s.close();
			}
		}
		
		public function gotoLastPosition():void
		{			
			var f:File = File.applicationStorageDirectory.resolvePath("appPosition.xml");   
			if(f.exists)
			{
				var s:FileStream = new FileStream();
				s.open(f,flash.filesystem.FileMode.READ);
				var xml:XML = XML(s.readUTFBytes(s.bytesAvailable));
				
				nativeWindow.x = xml.@x;
				nativeWindow.y = xml.@y;
				
				
				if ( xml.@full == "true" )
				{
					var screen : Screen = Screen.getScreensForRectangle( nativeWindow.bounds )[ 0 ];
					
					if( screen )
						move( Math.max( screen.bounds.width / 2 - width / 2, 0 ), Math.max( screen.bounds.height / 2 - height / 2, 0 ));
					
					maximize();
				}
				else
				{
					width = xml.@width;
					height = xml.@height;
				}
				
			}
			
			if ( width < 1000 )
				width = 1000;
			
			if ( height < 600 )
				height = 600;
		}

		[SkinPart( required = "true" )]
		/**
		 *
		 * @default
		 */
		public var iconApplication : Image;

		[SkinPart( required = "true" )]
		/**
		 *
		 * @default
		 */
		public var nameApplication : TextInput;

		[SkinPart( required = "true" )]
		/**
		 *
		 * @default
		 */
		public var settingsButton : Image;


		[SkinPart( required = "true" )]
		/**
		 *
		 * @default
		 */
		public var toolsetBar : Group;


		[Bindable]
		/**
		 *
		 * @default
		 */
		public var username : String;

		private var _resourceVO : ResourceVO;

		private var loader : Loader;

		/**
		 *
		 * @param data
		 */
		public function set resourceVO( data : ResourceVO ) : void
		{
			_resourceVO = data;
			BindingUtils.bindSetter( setIcon, _resourceVO, "data", false, true );
		}

		override public function stylesInitialized() : void
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", MainWindowSkin );
		}

		/**
		 *
		 * @param value
		 */
		private function setIcon( value : Object ) : void
		{
			if ( !value )
				return;

			loader = new Loader();
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, setIconLoaded );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, setIconLoaded );
			

			try
			{
				loader.loadBytes( _resourceVO.data );
			}
			catch ( error : Error )
			{
				// FIXME Сделать обработку исключения если не грузится изображение
			}
		}

		private function setIconLoaded( event : Event ) : void
		{
			loader = null;

			if ( event.type == IOErrorEvent.IO_ERROR )
				return;
			
			iconApplication.source = Bitmap( event.target.content );
		}

	}
}
