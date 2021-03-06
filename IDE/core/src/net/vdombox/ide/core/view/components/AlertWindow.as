package net.vdombox.ide.core.view.components
{
	import flash.display.NativeWindowSystemChrome;

	import net.vdombox.ide.core.events.AlertWindowEvent;
	import net.vdombox.ide.core.view.skins.AlertWindowSkin;
	import net.vdombox.utils.WindowManager;

	import spark.components.Window;

	public class AlertWindow extends Window
	{

		[Bindable]
		public var content : String = "";

		[Bindable]
		public var detail : String = "";

		public var state : String;

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

		override public function stylesInitialized() : void
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", AlertWindowSkin );
		}

		public function okClose() : void
		{
			dispatchEvent( new AlertWindowEvent( AlertWindowEvent.OK ) );
		}

		public function noClose() : void
		{
			dispatchEvent( new AlertWindowEvent( AlertWindowEvent.NO ) );
		}

		public function cancelClose() : void
		{
			WindowManager.getInstance().removeWindow( this );
		}

	}
}
