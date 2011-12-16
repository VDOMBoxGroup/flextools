package net.vdombox.components
{
	import flash.display.NativeWindowSystemChrome;
	import flash.events.KeyboardEvent;
	
	import net.vdombox.ide.common.events.StringAttributeEditWindowEvent;
	import net.vdombox.utils.WindowManager;
	import net.vdombox.view.skins.StringAttributeEditWindowSkin;
	
	import spark.components.RichEditableText;
	import spark.components.Window;
	
	public class StringAttributeEditWindow extends Window
	{
		
		[Bindable]
		public var value : String;
		
		[Bindable]
		public var editable : Boolean = true;
		
		
		[SkinPart( required="true" )]
		public var textAreaContainer : RichEditableText;
		
		public function StringAttributeEditWindow()
		{
			super();
			
			//systemChrome	= NativeWindowSystemChrome.NONE;
			//transparent 	= true;
			
			width = 400;
			height = 550;
			
			minWidth = 400;
			minHeight = 300;
			
			this.setFocus();
			//addEventListener( KeyboardEvent.KEY_DOWN, cancel_close_window );	
		}
		
		override public function stylesInitialized():void 
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", StringAttributeEditWindowSkin );
		}
		
		public function ok_close_window(event: KeyboardEvent = null ) : void
		{
			dispatchEvent( new StringAttributeEditWindowEvent( StringAttributeEditWindowEvent.APPLY, textAreaContainer.text ) );
			
		}
		
		public function no_close_window(event: KeyboardEvent = null ) : void
		{
			dispatchEvent( new StringAttributeEditWindowEvent( StringAttributeEditWindowEvent.CANCEL ) );
			
		}
	}
}