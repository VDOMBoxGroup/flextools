package net.vdombox.ide.modules.scripts.view.components
{
	import flash.display.NativeWindowSystemChrome;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.model._vo.ColorSchemeVO;
	import net.vdombox.ide.modules.scripts.view.skins.PreferencesWindowSkin;
	import net.vdombox.utils.WindowManager;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.Window;

	public class PreferencesWindow extends Window
	{
		[SkinPart( required = "true" )]
		public var colorSchemes : DropDownList;
		
		[SkinPart( required = "true" )]
		public var fontSize : DropDownList;
		
		[Bindable]
		public var colorShemesList : ArrayCollection;
		
		[Bindable]
		public var fontSizeList : ArrayCollection;
		
		public var selectedColorSheme: ColorSchemeVO;
		
		public var selectedFontSize: int;
		
		[SkinPart( required = "true" )]
		public var ok : Button;
		
		[SkinPart( required = "true" )]
		public var cancel : Button;
		
		public function PreferencesWindow()
		{
			super();
			
			systemChrome = NativeWindowSystemChrome.NONE;
			transparent = true;
			
			width = 300;
			height = 150;
			
			minWidth = 300;
			minHeight = 150;
			
			this.setFocus();
			
			addEventListener( KeyboardEvent.KEY_DOWN, cancel_close_window );
			addEventListener( Event.CLOSE, closeHandler );
		}
		
		override public function stylesInitialized() : void
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", PreferencesWindowSkin );
		}
		
		public function cancel_close_window( event: KeyboardEvent ) : void
		{
			if ( event.charCode == Keyboard.ESCAPE )
				close();
		}

		
		public function closeHandler(event:Event) : void
		{
			removeEventListener( Event.CLOSE, closeHandler );
			
			WindowManager.getInstance().removeWindow(this);
		}
		public function ok_close_window(event: KeyboardEvent = null ) : void
		{
			dispatchEvent( new PopUpWindowEvent( PopUpWindowEvent.APPLY, null, "", { colorScheme : colorSchemes.selectedItem, fontSize : int( fontSize.selectedItem.toString() ) } ) );
		}
		
		public function no_close_window(event: KeyboardEvent = null ) : void
		{
			dispatchEvent( new PopUpWindowEvent( PopUpWindowEvent.CANCEL ) );
		}
	}
}