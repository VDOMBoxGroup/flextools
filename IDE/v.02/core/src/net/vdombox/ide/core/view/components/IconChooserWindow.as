package net.vdombox.ide.core.view.components
{
	import flash.display.NativeWindowSystemChrome;
	
	import net.vdombox.ide.core.events.IconChooserEvent;
	import net.vdombox.ide.core.view.skins.IconChooserWindowSkin;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.Window;
	

	public class IconChooserWindow extends Window
	{
		[SkinPart( required="true" )]
		public var iconsList : List;
		
		[SkinPart( required="true" )]
		public var btnOK : Button;
		
		public function IconChooserWindow()
		{
			width = 550;
			height = 340;
			minWidth = 550;
			minHeight = 340;
			maxWidth = 550;
			maxHeight = 340;
			systemChrome = NativeWindowSystemChrome.NONE;
			transparent = true;
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", IconChooserWindowSkin );
		}

		public function selectIcon() : void
		{
			dispatchEvent( new IconChooserEvent( IconChooserEvent.SELECT_ICON ) );
			close();
		}
		
		public function closeWindow() : void
		{
			dispatchEvent( new IconChooserEvent( IconChooserEvent.CLOSE_ICON_LIST ) );
		}
	}
}