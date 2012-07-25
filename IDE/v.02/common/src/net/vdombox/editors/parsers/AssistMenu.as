package net.vdombox.editors.parsers
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import net.vdombox.editors.PopUpMenu;
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.ide.common.events.ScriptAreaComponenrEvent;

	public class AssistMenu
	{
		protected var menuData : Vector.<Object>;
		protected var fld : ScriptAreaComponent;
		protected var ctrl : Controller;
		protected var _menu : PopUpMenu;

		public function get menu():PopUpMenu
		{
			return _menu;
		}

		protected var onComplete : Function;
		protected var stage : Stage;
		
		protected var menuStr : String;
		protected var tooltipCaret : int;
		
		public function AssistMenu( field : ScriptAreaComponent, ctrl : Controller, stage : Stage, onComplete : Function )
		{
			fld = field;
			this.ctrl = ctrl;
			this.onComplete = onComplete;
			this.stage = stage;
			
			_menu = new net.vdombox.editors.PopUpMenu();
			//restore the focus to the textfield, delayed			
			_menu.addEventListener( Event.REMOVED_FROM_STAGE, onMenuRemoved );
			//menu in action
			_menu.addEventListener( KeyboardEvent.KEY_DOWN, onMenuKey );
			
			_menu.addEventListener( MouseEvent.DOUBLE_CLICK, doubleClickMouseHandler );
			/*menu.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:Event):void {
			var c:int = fld.caretIndex;
			fldReplaceText(c-menuStr.length, c, menu.getSelectedValue());
			ctrl.sourceChanged(fld.text);
			menu.dispose();
			})*/
			
			//			tooltip = new JToolTip;
			
			//used to close the tooltip
			fld.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			fld.addEventListener( ScriptAreaComponenrEvent.TEXT_INPUT, onTextInput );
		}
		
		protected function onMenuRemoved( e : Event ) : void
		{
			setTimeout( function() : void
			{
				if ( !_menu.showed )
					stage.focus = fld;
			}, 1 );
		}
		
		private function onKeyDown( e : KeyboardEvent ) : void
		{
			if ( e.keyCode == Keyboard.SPACE && e.ctrlKey )
				triggerAssist(true);
		}
		
		protected function onTextInput( e : ScriptAreaComponenrEvent ) : void
		{				
			triggerAssist(false);
		}	
		
		private function doubleClickMouseHandler( e : MouseEvent ) : void
		{
			fldReplaceText( fld.caretIndex - menuStr.length, fld.caretIndex, menu.getSelectedValue() );
			onComplete();
			
			_menu.dispose();
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
				
				_menu.dispose();
				
				if ( e.keyCode == Keyboard.PERIOD )
					triggerAssist( false );
			}
		}
		
		private function fldReplaceText( begin : int, end : int, text : String ) : void
		{
			fld.replaceText( begin, end, text );
			fld.setSelection( begin + text.length, begin + text.length );
			
			fld.dispatchEvent( new Event( Event.CHANGE, true, false ) );
		}
		
		protected function filterMenu() : Boolean
		{
			return true;
		}
		
		public function clear() : void
		{
			_menu.removeEventListener( Event.REMOVED_FROM_STAGE, onMenuRemoved );
			_menu.removeEventListener( KeyboardEvent.KEY_DOWN, onMenuKey );
			_menu.removeEventListener( MouseEvent.DOUBLE_CLICK, doubleClickMouseHandler );
			fld.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			fld.removeEventListener( ScriptAreaComponenrEvent.TEXT_INPUT, onTextInput );
		}
		
		public function triggerAssist( forced : Boolean = false ) : void
		{
		}
	}
}