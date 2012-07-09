package net.vdombox.editors.parsers
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import net.vdombox.editors.PopUpMenu;
	import net.vdombox.editors.ScriptAreaComponent;

	public class AssistMenu
	{
		protected var menuData : Vector.<Object>;
		protected var fld : ScriptAreaComponent;
		protected var menu : PopUpMenu;
		protected var onComplete : Function;
		protected var stage : Stage;
		
		protected var menuStr : String;
		protected var tooltipCaret : int;
		
		public function AssistMenu()
		{
		}
		
		protected function onMenuKey( e : KeyboardEvent ) : void
		{
			if ( e.charCode != 0 )
			{
				var c : int = fld.caretIndex;
				
				if ( e.ctrlKey )
				{
					
				}
				else if ( e.keyCode == Keyboard.BACKSPACE )
				{
					fldReplaceText( c - 1, c, '' );
					if ( menuStr.length > 0 )
					{
						menuStr = menuStr.substr( 0, -1 );
						if ( filterMenu() )
							return;
					}
				}
				else if ( e.keyCode == Keyboard.DELETE )
				{
					fldReplaceText( c, c + 1, '' );
				}
				else if ( e.charCode > 31 && e.charCode < 127 )
				{
					var ch : String = String.fromCharCode( e.charCode );
					menuStr += ch.toLowerCase();
					fldReplaceText( c, c, ch );
					if ( filterMenu() )
						return;
				}
				else if ( e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.TAB )
				{
					fldReplaceText( c - menuStr.length, c, menu.getSelectedValue() );
					onComplete();
				}
				
				menu.dispose();
			}
		}
		
		private function fldReplaceText( begin : int, end : int, text : String ) : void
		{
			fld.replaceText( begin, end, text );
			fld.setSelection( begin + text.length, begin + text.length );
		}
		
		protected function filterMenu() : Boolean
		{
			return true;
		}
	}
}