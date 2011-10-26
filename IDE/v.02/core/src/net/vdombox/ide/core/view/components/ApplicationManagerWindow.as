package net.vdombox.ide.core.view.components
{
	import flash.display.NativeWindowSystemChrome;
	import flash.events.Event;
	
	import net.vdombox.ide.core.events.ApplicationManagerEvent;
	import net.vdombox.ide.core.view.skins.ApplicationManagerSkin;
	
	import spark.components.Window;

	public class ApplicationManagerWindow extends Window
	{
		
		[SkinPart( required="true" )]
		public var applicationsView : ApplicationsView;
		
		[SkinPart( required="true" )]
		public var applicationPropertiesView : ApplicationPropertiesView;
		
		public function ApplicationManagerWindow()
		{
			systemChrome = NativeWindowSystemChrome.NONE;
			transparent = true;
			width = 550;
			height = 340;
			minWidth = 550;
			minHeight = 340;
			maxWidth = 550;
			maxHeight = 340;
			title = resourceManager.getString( 'Core_General', 'application_manager_window_title' ) ;
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", ApplicationManagerSkin );
		}
	}
}