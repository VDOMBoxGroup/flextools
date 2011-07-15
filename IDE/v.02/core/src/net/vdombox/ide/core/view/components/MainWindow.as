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
	
	import spark.components.ButtonBar;
	import spark.components.Group;
	import spark.components.Window;
	import spark.components.windowClasses.TitleBar;

	public class MainWindow extends Window
	{
		public function MainWindow()
		{
			//setStyle( "skinClass", MainWindowSkin );
			super();
			systemChrome	= NativeWindowSystemChrome.NONE;
			transparent 	= true;
			width 			= 800;
			height 			= 600;			
		}

		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", MainWindowSkin );
		}

		
		[Bindable]
		public var username : String;

		[SkinPart( required="true" )]
		public var tabBar : ButtonBar;

		[SkinPart( required="true" )]
		public var toolsetBar : Group;

		[SkinPart( required="true" )]
		public var settingsButton : Image;

		[SkinPart( required="true" )]
		public var loginButton : LoginButton;
		
		

		override protected function partAdded( partName : String, instance : Object ) : void
		{
			super.partAdded( partName, instance );

			if ( instance === loginButton )
			{
				loginButton.addEventListener( MouseEvent.CLICK, loginButton_clickHandler );
			}
		}

		private function loginButton_clickHandler( event : MouseEvent ) : void
		{
			dispatchEvent( new MainWindowEvent( MainWindowEvent.LOGOUT ) );
		}
	}
}