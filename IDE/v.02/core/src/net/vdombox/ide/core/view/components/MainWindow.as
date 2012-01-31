//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.core.view.components
{
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.NativeWindowSystemChrome;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.system.LoaderContext;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Image;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.core.events.MainWindowEvent;
	import net.vdombox.ide.core.view.skins.MainWindowSkin;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	
	import spark.components.Group;
	import spark.components.Label;
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
			width = 800;
			height = 600;
			minWidth = 800;
			minHeight = 600;
			
//			addEventListener( Event.CLOSE, closeEvent);
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
