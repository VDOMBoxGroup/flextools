package net.vdombox.editors.parsers
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import mx.core.UIComponent;
	
	import net.vdombox.editors.PopUpMenu;
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.ide.common.events.ScriptAreaComponenrEvent;

	public class AssistMenu
	{
		protected var menuData : Vector.<AutoCompleteItemVO>;
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
			//_menu.addEventListener( KeyboardEvent.KEY_DOWN, onMenuKey );
			
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
			fld.addEventListener( ScriptAreaComponenrEvent.PRESS_NAVIGATION_KEY, onPressNavigationKeyHandler, true, 0 , true );
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
			else if ( e.keyCode == Keyboard.BACKSPACE || e.keyCode == Keyboard.DELETE || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT )
			{
				if ( menu.showed )
					triggerAssist(false);
			}
		}
		
		protected function onTextInput( e : ScriptAreaComponenrEvent ) : void
		{				
			triggerAssist(false);
		}	
		
		private function onPressNavigationKeyHandler( e : ScriptAreaComponenrEvent ) : void
		{
			var detail : String = e.detail as String;
			
			switch(detail)
			{
				case "Enter":
				{
					var c : int = fld.caretIndex;
					
					fldReplaceText( c - menuStr.length, c, menu.getSelectedValue() );
					onComplete();
					
					menuDispose();
					
					break;
				}
					
				case "Up":
				{
					if ( menu.selectedIndex > 0 )
						menu.selectedIndex--;
					else
						menu.selectedIndex = menu.dataProvider.length - 1;
					
					updateMenuScrollPosition();
					
					break;
				}
					
				case "Down":
				{
					if ( menu.selectedIndex < menu.dataProvider.length - 1 )
						menu.selectedIndex++;
					else
						menu.selectedIndex = 0;
					
					updateMenuScrollPosition();
					
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		
		private function updateMenuScrollPosition() : void
		{
			var currentPosition : int = menu.selectedIndex * 16;
			if ( currentPosition < menu.scroller.viewport.verticalScrollPosition )
				menu.scroller.viewport.verticalScrollPosition = currentPosition;
			else if ( currentPosition > menu.scroller.viewport.verticalScrollPosition + menu.measuredHeight - 16)
				menu.scroller.viewport.verticalScrollPosition = currentPosition - menu.measuredHeight + 16;
			
		}
		
		private function doubleClickMouseHandler( e : MouseEvent ) : void
		{
			fldReplaceText( fld.caretIndex - menuStr.length, fld.caretIndex, menu.getSelectedValue() );
			onComplete();
			
			menuDispose();
		}
		
		protected function menuDispose() : void
		{
			fld.assistMenuOpened = false;
			
			_menu.dispose();
		}
		
		protected var menuRefY : int;
		
		protected function showMenu( index : int ) : void
		{
			fld.assistMenuOpened = true;
			var p : Point = fld.getPointForIndex( index );
			p.x += fld.scrollH;
			
			p = fld.localToGlobal( p );
			menuRefY = p.y;
			menu.show( fld, p.x, 0 );
			
			stage.addEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, false, 0, true );
			
			rePositionMenu();
		}
		
		protected function rePositionMenu() : void
		{
			var menuH : int = 8 //Math.min( 8, menu.getModel().getSize() ) * 17;
			if ( menuRefY + 15 + menuH > fld.height )
				menu.y = menuRefY - menuH - 2;
			else
				menu.y = menuRefY + 15;
		}
		
		protected function stage_mouseDownHandler( event : MouseEvent ) : void
		{
			var parent : UIComponent = event.target as UIComponent;
			var isMenu : Boolean;
			
			while ( parent )
			{
				if ( parent == menu )
				{
					isMenu = true;
					break;
				}
				
				parent = parent.parent as UIComponent;
			}
			
			if ( !isMenu )
			{
				stage.removeEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler );
				menuDispose();
			}
		}
		
		/*protected function onMenuKey( e : KeyboardEvent ) : void
		{		
			tempForNikolasArray1 += ( e.keyCode == Keyboard.PERIOD ).toString() + " " + e.keyCode + ":" + e.charCode + "     ";
			
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
					
					tempForNikolasArray2 += ch;
					if ( e.keyCode == Keyboard.PERIOD )
						tempForNikolas = ch;
					
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
		}*/
		
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
			//_menu.removeEventListener( KeyboardEvent.KEY_DOWN, onMenuKey );
			_menu.removeEventListener( MouseEvent.DOUBLE_CLICK, doubleClickMouseHandler );
			fld.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			fld.removeEventListener( ScriptAreaComponenrEvent.TEXT_INPUT, onTextInput );
			fld.removeEventListener( ScriptAreaComponenrEvent.PRESS_NAVIGATION_KEY, onPressNavigationKeyHandler, true );
		}
		
		public function triggerAssist( forced : Boolean = false ) : void
		{
		}
	}
}