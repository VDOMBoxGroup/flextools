package net.vdombox.ide.view.components
{
	import flash.display.NativeWindowSystemChrome;

	import mx.events.FlexEvent;

	import net.vdombox.ide.view.skins.MainWindowSkin;

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

			addEventListener( FlexEvent.CREATION_COMPLETE, mainWindow_creationCompleteHandler );
		}

		[SkinPart( required="true" )]
		public var tabBar : ButtonBar;

		[SkinPart( required="true" )]
		public var toolsetBar : Group;

		private function mainWindow_creationCompleteHandler( event : FlexEvent ) : void
		{

		}
	}
}