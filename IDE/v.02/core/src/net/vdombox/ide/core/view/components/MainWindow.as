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

	public class MainWindow extends Window
	{
		public function MainWindow()
		{
			setStyle( "skinClass", MainWindowSkin );
			systemChrome = NativeWindowSystemChrome.NONE;
			width = 1024;
			height = 768;
			
			addEventListener( Event.CLOSE, closeHandler );
		}

		[SkinPart( required="true" )]
		public var tabBar : ButtonBar;

		[SkinPart( required="true" )]
		public var toolsetBar : Group;
		
		[SkinPart( required="true" )]
		public var settingsButton : Image;
		
		private function closeHandler( event : Event ) : void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
}