package net.vdombox.ide.core.view.components
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindowSystemChrome;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.LoaderContext;
	
	import mx.controls.Image;
	
	import net.vdombox.ide.core.events.MainWindowEvent;
	import net.vdombox.ide.core.view.skins.MainWindowSkin;
	
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.Window;
	import spark.components.windowClasses.TitleBar;

	public class MainWindow extends Window
	{
		public function MainWindow()
		{
			super();
			systemChrome	= NativeWindowSystemChrome.NONE;
			transparent 	= true;
			width 			= 800;
			height 			= 600;	
			minWidth		= 800;
			minHeight		= 600;
		}

		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", MainWindowSkin );
		}

		
		[Bindable]
		public var username : String;

		[SkinPart( required="true" )]
		public var toolsetBar : Group;

		[SkinPart( required="true" )]
		public var settingsButton : Image;
		
		[SkinPart( required="true" )]
		public var nameApplication : Label;
		
		[SkinPart( required="true" )]
		public var iconApplication : Image;
		
		/*[SkinPart( required="true" )]
		public var applicationManagerButton : Button;*/


	}
}