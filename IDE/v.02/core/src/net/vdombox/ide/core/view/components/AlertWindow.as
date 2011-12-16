package net.vdombox.ide.core.view.components
{
	import flash.display.NativeWindowSystemChrome;
	import flash.events.MouseEvent;
	
	import net.vdombox.ide.core.events.AlertWindowEvent;
	import net.vdombox.ide.core.view.skins.AlertWindowSkin;
	
	import spark.components.Window;

	public class AlertWindow extends Window
	{
		[Bindable]
		public var content : String = "";
		
		[Bindable]
		public var titleString : String = "";
		
		public function AlertWindow()
		{
			width = 400;
			height = 180;
			minWidth = 400;
			minHeight = 180;
			maxWidth = 400;
			maxHeight = 180;
			systemChrome = NativeWindowSystemChrome.NONE;
			transparent = true;
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", AlertWindowSkin );
		}
		
		public function ok_close_handler( event : MouseEvent ) : void
		{
			dispatchEvent( new AlertWindowEvent ( AlertWindowEvent.OK ) );
		}
	}
}