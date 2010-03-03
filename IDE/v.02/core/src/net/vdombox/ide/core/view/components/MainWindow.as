package net.vdombox.ide.core.view.components
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindowSystemChrome;
	import flash.events.Event;
	
	import mx.controls.Image;
	
	import net.vdombox.ide.core.view.skins.MainWindowSkin;
	
	import spark.components.ButtonBar;
	import spark.components.Group;
	import spark.components.Window;
	import spark.components.windowClasses.TitleBar;

	public class MainWindow extends Window
	{
		public function MainWindow()
		{
			setStyle( "skinClass", MainWindowSkin );
			systemChrome = NativeWindowSystemChrome.NONE;
			width = 1200;
			height = 1024;
			
			addEventListener( Event.CLOSE, closeHandler );
		}

		[SkinPart( required="true" )]
		public var tabBar : ButtonBar;

		[SkinPart( required="true" )]
		public var toolsetBar : Group;
		
		[SkinPart( required="true" )]
		public var settingsButton : Image;
		
//		[SkinPart( required="true" )]
//		public var titleBar : TitleBar;
		
		private function closeHandler( event : Event ) : void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
}