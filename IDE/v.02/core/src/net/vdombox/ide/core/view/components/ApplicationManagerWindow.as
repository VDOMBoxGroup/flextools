package net.vdombox.ide.core.view.components
{
	import flash.display.NativeWindowSystemChrome;
	
	import net.vdombox.ide.core.events.ApplicationManagerWindowEvent;
	import net.vdombox.ide.core.view.skins.ApplicationManagerWindowSkin;
	
	import spark.components.Window;

	public class ApplicationManagerWindow extends Window
	{
		
		[SkinPart( required="true" )]
		public var changeApplicationView : ChangeApplicationView;
		
		public function ApplicationManagerWindow()
		{
			systemChrome	= NativeWindowSystemChrome.NONE;
			width = 550;
			height = 340;
			minWidth = 550;
			minHeight = 340;
			maxWidth = 550;
			maxHeight = 340;
			title = resourceManager.getString( 'Core_General', 'application_manager_window_title' ) 
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", ApplicationManagerWindowSkin );
		}
		
		public function closeHandler() : void
		{
			dispatchEvent( new ApplicationManagerWindowEvent( ApplicationManagerWindowEvent.CLOSE_WINDOW ) );
		}
	}
}