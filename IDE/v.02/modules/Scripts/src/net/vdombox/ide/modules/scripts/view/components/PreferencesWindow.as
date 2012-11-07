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
	import spark.components.CheckBox;
	import spark.components.DropDownList;
	import spark.components.Window;

	public class PreferencesWindow extends Window
	{
		[SkinPart( required = "true" )]
		public var colorSchemes : DropDownList;
		
		[SkinPart( required = "true" )]
		public var fontSize : DropDownList;
		
		[SkinPart( required = "true" )]
		public var autocompleteAutoShow : CheckBox;
		
		[Bindable]
		public var colorShemesList : ArrayCollection;
		
		[Bindable]
		public var fontSizeList : ArrayCollection;
		
		[Bindable]
		public var autoShowAutocomplete : Boolean;
		
		[Bindable]
		public var selectKeyByAutoComplte : String;
		
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
			
			width = 350;
			height = 250;
			
			minWidth = 350;
			minHeight = 250;
			
			this.setFocus();
			
			addEventListener( KeyboardEvent.KEY_DOWN, cancel_close_window );
			addEventListener( Event.CLOSE, closeHandler );
		}
		
		override public function stylesInitialized() : void
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", PreferencesWindowSkin );
		}
		
		public function setEnterKey() : void
		{
			selectKeyByAutoComplte = "enter";
		}
		
		public function setTabKey() : void
		{
			selectKeyByAutoComplte = "tab";
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
			dispatchEvent( new PopUpWindowEvent( PopUpWindowEvent.APPLY, null, "", { colorScheme : colorSchemes.selectedItem, fontSize : int( fontSize.selectedItem.toString() ),
																					autoShowAutoComplete : autocompleteAutoShow.selected, selectKeyByAutoComplte : selectKeyByAutoComplte } ) );
		}
		
		public function no_close_window(event: KeyboardEvent = null ) : void
		{
			dispatchEvent( new PopUpWindowEvent( PopUpWindowEvent.CANCEL ) );
		}
	}
}