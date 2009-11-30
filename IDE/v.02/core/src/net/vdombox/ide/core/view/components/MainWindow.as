package net.vdombox.ide.core.view.components
{
	import flash.display.NativeWindowSystemChrome;
	
	import mx.controls.Image;
	import mx.events.FlexEvent;
	
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
			width = 800;
			height = 600;
		}

		[SkinPart( required="true" )]
		public var tabBar : ButtonBar;

		[SkinPart( required="true" )]
		public var toolsetBar : Group;
		
		[SkinPart( required="true" )]
		public var settingsButton : Image;
	}
}