package net.vdombox.editors.parsers.base
{
	import flash.display.Screen;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;

	import mx.core.UIComponent;
	import mx.events.ListEvent;

	import net.vdombox.editors.AutoCompleteItemRenderer;
	import net.vdombox.editors.PopUpHelpAutocomplete;
	import net.vdombox.editors.PopUpMenu;
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.VDOMToolTip;
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.StandardWordsProxy;
	import net.vdombox.ide.common.events.ItemRendererEvent;
	import net.vdombox.ide.common.events.ScriptAreaComponenrEvent;

	public class AssistMenu
	{
		protected var menuData : Vector.<AutoCompleteItemVO>;

		protected var fld : ScriptAreaComponent;

		protected var ctrl : Controller;

		protected var _menu : PopUpMenu;

		public function get menu() : PopUpMenu
		{
			return _menu;
		}

		protected var helpWindow : PopUpHelpAutocomplete;

		protected var onComplete : Function;

		protected var stage : Stage;

		protected var menuStr : String;

		protected var tooltipCaret : int;

		public var autoShowAutoComplete : Boolean = true;

		private var screenHeight : int = Screen.mainScreen.bounds.height;

		private var screenWidth : int = Screen.mainScreen.bounds.width;

		private const menuHeight : int = 300;

		private const menuWidth : int = 400;

		protected var vdomToolTip : VDOMToolTip;

		protected var showing : Boolean = false;



		public function AssistMenu( field : ScriptAreaComponent, ctrl : Controller, stage : Stage, onComplete : Function )
		{
			fld = field;
			this.ctrl = ctrl;
			this.onComplete = onComplete;
			this.stage = stage;

			_menu = new net.vdombox.editors.PopUpMenu();
			vdomToolTip = new VDOMToolTip();

			helpWindow = new PopUpHelpAutocomplete();
			//restore the focus to the textfield, delayed			
			_menu.addEventListener( Event.REMOVED_FROM_STAGE, onMenuRemoved );
			//menu in action
			//_menu.addEventListener( KeyboardEvent.KEY_DOWN, onMenuKey );

			_menu.addEventListener( MouseEvent.DOUBLE_CLICK, doubleClickMouseHandler );
			_menu.addEventListener( ItemRendererEvent.SELECTED, selectedAutocompleteItemVOHandler, true, 0, true );
			/*
			   menu.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:Event):void {
			   var c:int = fld.caretIndex;
			   fldReplaceText(c-menuStr.length, c, menu.getSelectedValue());
			   ctrl.sourceChanged(fld.text);
			   menu.dispose();
			   })
			 */

			//			tooltip = new JToolTip;

			//used to close the tooltip
			fld.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			fld.addEventListener( ScriptAreaComponenrEvent.TEXT_INPUT, onTextInput );
			fld.addEventListener( ScriptAreaComponenrEvent.PRESS_NAVIGATION_KEY, onPressNavigationKeyHandler, true, 0, true );
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
			if ( vdomToolTip.showed )
			{
				if ( e.keyCode == Keyboard.ESCAPE || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN || String.fromCharCode( e.charCode ) == ')' || fld.caretIndex < tooltipCaret )
					vdomToolTip.dispose();
			}

			if ( e.keyCode == Keyboard.SPACE && e.ctrlKey )
			{
				triggerAssist( true );
				showing = true;
			}
			else if ( e.keyCode == Keyboard.BACKSPACE || e.keyCode == Keyboard.DELETE || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT )
			{
				if ( menu.showed )
					triggerAssist( false );
			}
			else if ( e.keyCode == Keyboard.ESCAPE )
			{
				showing = false;
				menu.dispose();
			}
		}

		protected function onTextInput( e : ScriptAreaComponenrEvent ) : void
		{
			triggerAssist( false, e.detail as String );
		}

		private function onPressNavigationKeyHandler( e : ScriptAreaComponenrEvent ) : void
		{
			var detail : String = e.detail as String;

			switch ( detail )
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
						menu.selectedIndex = menu.length - 1;

					updateMenuScrollPosition();

					break;
				}

				case "Down":
				{
					if ( menu.selectedIndex < menu.length - 1 )
						menu.selectedIndex++;
					else
						menu.selectedIndex = 0;

					updateMenuScrollPosition();

					break;
				}

				default:
				{
					menuDispose();
					break;
				}
			}
		}

		private function updateMenuScrollPosition() : void
		{
			var currentPosition : int = menu.selectedIndex * 20;
			if ( currentPosition < menu.scroller.viewport.verticalScrollPosition )
				menu.scroller.viewport.verticalScrollPosition = currentPosition;
			else if ( currentPosition > menu.scroller.viewport.verticalScrollPosition + menu.measuredHeight - 30 )
				menu.scroller.viewport.verticalScrollPosition = currentPosition - menu.measuredHeight + 30;

		}

		private function doubleClickMouseHandler( e : MouseEvent ) : void
		{
			fldReplaceText( fld.caretIndex - menuStr.length, fld.caretIndex, menu.getSelectedValue() );
			onComplete();

			menuDispose();
		}

		private function selectedAutocompleteItemVOHandler( event : ItemRendererEvent ) : void
		{
			if ( !menu.showed )
				return;

			var autoCompleteItemVO : AutoCompleteItemVO = menu.selectedItem;
			if ( autoCompleteItemVO.transcription == "" && autoCompleteItemVO.description == "" )
				autoCompleteItemVO = StandardWordsProxy.getAutocompleteItemVOByName( autoCompleteItemVO.value, fld.getScriptLang() );

			if ( !autoCompleteItemVO )
				return;

			helpWindow.setData( autoCompleteItemVO.transcription, autoCompleteItemVO.description );

			var xHelp : int = menu.x + menu.width;
			if ( xHelp + menuWidth + 1 > screenWidth )
				xHelp = menu.x - menuWidth - 1;

			helpWindow.show( fld, xHelp, menu.y );
		}

		protected function menuDispose() : void
		{
			fld.assistMenuOpened = false;
			showing = false;

			_menu.dispose();
			helpWindow.dispose();
		}


		protected function showMenu( index : int ) : void
		{
			fld.assistMenuOpened = true;
			var p : Point = fld.getPointForIndex( index );

			p = fld.localToGlobal( p );
			p.x -= fld.scrollH;
			p.y += fld.letterBoxHeight;

			menu.show( fld, p.x, p.y );

			stage.addEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, false, 0, true );

			//rePositionMenu();
		}

		protected function showToolTip() : void
		{
			var p : Point = fld.getPointForIndex( fld.caretIndex - 1 );
			p = fld.localToGlobal( p );
			vdomToolTip.show( fld, p.x, p.y - 18 );
			tooltipCaret = fld.caretIndex;

			stage.addEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, false, 0, true );
		}



		/*
		   protected function rePositionMenu() : void
		   {
		   var menuH : int = 8 //Math.min( 8, menu.getModel().getSize() ) * 17;
		   if ( menuRefY + 15 + menuH > fld.height )
		   menu.y = menuRefY - menuH - 2;
		   else
		   menu.y = menuRefY + 15;
		   }
		 */

		protected function stage_mouseDownHandler( event : MouseEvent ) : void
		{
			var parent : Object = event.target;
			var isMenu : Boolean;

			while ( parent )
			{
				if ( parent == menu || parent == helpWindow )
				{
					isMenu = true;
					break;
				}

				parent = parent.parent;
			}

			if ( !isMenu )
			{
				stage.removeEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler );
				menuDispose();
				vdomToolTip.dispose();
			}
		}

		/*
		   protected function onMenuKey( e : KeyboardEvent ) : void
		   {
		   tempForNikolasArray1 += ( e.keyCode == Keyboard.PERIOD ).toString() + " " + e.keyCode + ":" + e.charCode + "
		   ";

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
		   }
		 */

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

		public function triggerAssist( forced : Boolean = false, text : String = '' ) : void
		{
		}
	}
}
