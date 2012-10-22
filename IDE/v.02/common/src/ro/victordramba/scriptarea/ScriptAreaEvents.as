package ro.victordramba.scriptarea
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.resources.ResourceManager;
	
	import net.vdombox.editors.HashLibraryArray;
	import net.vdombox.editors.parsers.base.BackwardsParser;
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.editors.parsers.base.Token;
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.events.ScriptAreaComponenrEvent;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.common.view.components.windows.ScriptStructureWindow;
	import net.vdombox.utils.WindowManager;

	/*import flash.desktop.Clipboard;
	   import flash.desktop.ClipboardFormats;
	   import flash.events.Event;
	   import flash.events.FocusEvent;
	   import flash.events.KeyboardEvent;
	   import flash.events.MouseEvent;
	   import flash.geom.Point;
	 import flash.ui.Keyboard;*/

	public class ScriptAreaEvents extends ScriptArea
	{
		private var lastCol : int = 0;
		private var extChar : int;
		private var inputTF : TextField;
		
		public var scriptLang : String = "pytnon";
		
		private var token : Token;
		
		public var assistMenuOpened : Boolean = false;
		
		private var str : String;
		
		private var t : Timer;
		private var blocked : Boolean = false;

		public function ScriptAreaEvents()
		{
			
			doubleClickEnabled = true;
			focusRect = false;

			inputTF = new TextField();
			inputTF.type = TextFieldType.INPUT;
			inputTF.addEventListener( TextEvent.TEXT_INPUT, onInputText );
			var me : ScriptAreaEvents = this;
			inputTF.addEventListener( KeyboardEvent.KEY_UP, function( e : KeyboardEvent ) : void
			{
				if ( stage )
					stage.focus = me;
			} );


			addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown);
			addEventListener( FocusEvent.KEY_FOCUS_CHANGE, function( e : FocusEvent ) : void
			{
				e.preventDefault();
				e.stopImmediatePropagation();
			} );
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			addEventListener( MouseEvent.CLICK, onMouseClick );
			addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			addEventListener( KeyboardEvent.KEY_UP, onKeyUp );

			addEventListener( FocusEvent.FOCUS_IN, function( e : FocusEvent ) : void
			{
				cursor.alpha = 1;
			} );


			addEventListener( FocusEvent.FOCUS_OUT, function( e : FocusEvent ) : void
			{
				if ( e.relatedObject != inputTF )
					cursor.alpha = 0;
			} );

			addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );

			addEventListener( MouseEvent.DOUBLE_CLICK, function( e : Event ) : void
			{
				var pos : int = getIndexForPoint( new Point( mouseX, mouseY ) );
				_setSelection( findWordBound( pos, true ), findWordBound( pos, false ), true );
			} );

			/*addEventListener( Event.CUT, onCut );
			addEventListener( Event.COPY, onCopy );
			addEventListener( Event.PASTE, onPaste );
			addEventListener( Event.SELECT_ALL, onSelectAll );*/

			addEventListener( MouseEvent.ROLL_OVER, function( e : MouseEvent ) : void
			{
				Mouse.cursor = MouseCursor.IBEAM;
			} );
			addEventListener( MouseEvent.ROLL_OUT, function( e : MouseEvent ) : void
			{
				Mouse.cursor = MouseCursor.AUTO;
			} );
			
			addEventListener( MouseEvent.CONTEXT_MENU, contextMenuHandler, false, 0 , true );
			
			t = new Timer( 1200, 1 );
			
			t.addEventListener( TimerEvent.TIMER, timerHandler, false, 0, true );
		}
		
		private function contextMenuHandler( event : MouseEvent ) : void
		{
			if ( !contextMenu )
				contextMenu = new ContextMenu();
			
			contextMenu.removeAllItems();
			
			var copyItem : ContextMenuItem = new ContextMenuItem(ResourceManager.getInstance().getString( 'Wysiwyg_General', 'contextMenu_copy' ));
			copyItem.addEventListener( Event.SELECT, copyContextMenuHandler, false, 0, true );
			contextMenu.addItem( copyItem );
			
			var cutItem : ContextMenuItem = new ContextMenuItem(ResourceManager.getInstance().getString( 'Wysiwyg_General', 'contextMenu_cut' ));
			cutItem.addEventListener( Event.SELECT, cutContextMenuHandler, false, 0, true );
			contextMenu.addItem( cutItem );
			
			if ( _selStart == _selEnd )
			{
				copyItem.enabled = false;
				cutItem.enabled = false;
			}
			
			var pasteItem : ContextMenuItem = new ContextMenuItem(ResourceManager.getInstance().getString( 'Wysiwyg_General', 'contextMenu_paste' ));
			pasteItem.addEventListener( Event.SELECT, pasteContextMenuHandler, false, 0, true );
			contextMenu.addItem( pasteItem );
			
			str = text.substring( _selStart, _selEnd );
			str = controller.getRegisterWord( str );
			token = controller.getTokenByPos( _selStart );
			
			if ( token.hasMember( str ) )
			{
				var renameItem : ContextMenuItem = new ContextMenuItem(ResourceManager.getInstance().getString( 'Wysiwyg_General', 'contextMenu_rename' ));
				renameItem.addEventListener( Event.SELECT, renameContextMenuHandler, false, 0, true );
				contextMenu.addItem( renameItem );
				
				if ( ( controller.actionVO is LibraryVO ) && !token.scope.parent || ( token.scope.parent.name == "top" && token.string == token.scope.name ) )
				{
					var globalRenameItem : ContextMenuItem = new ContextMenuItem(ResourceManager.getInstance().getString( 'Wysiwyg_General', 'contextMenu_global_rename' ));
					globalRenameItem.addEventListener( Event.SELECT, globalRenameContextMenuHandler, false, 0, true );
					contextMenu.addItem( globalRenameItem );
				}
			}
			
		}
		
		private function copyContextMenuHandler( event : Event ) : void
		{
			onCopy();
		}
		
		private function cutContextMenuHandler( event : Event ) : void
		{
			onCut();
		}
		
		private function pasteContextMenuHandler( event : Event ) : void
		{
			onPaste();
		}
		
		private function renameContextMenuHandler( event : Event ) : void
		{
			dispatchEvent( new ScriptAreaComponenrEvent ( ScriptAreaComponenrEvent.RENAME, false, false, { oldName : str, controller : controller } ) );
		}
		
		private function globalRenameContextMenuHandler( event : Event ) : void
		{
			dispatchEvent( new ScriptAreaComponenrEvent ( ScriptAreaComponenrEvent.GLOBAL_RENAME, false, false, { oldName : str, controller : controller } ) );
		}
		
		private function findWordBound( start : int, left : Boolean ) : int
		{
			if ( left )
			{
				while ( /\w/.test( _text.charAt( start ) ) )
					start--;
				return start + 1;
			}
			else
			{
				while ( /\w/.test( _text.charAt( start ) ) )
					start++;
				return start;
			}
		}

		private function onMouseWheel( e : MouseEvent ) : void
		{
			scrollV -= e.delta;
			e.preventDefault(); //this both don't work :((, the html page still scrolls
			e.stopImmediatePropagation();
		}

		private function onPaste( e : Event = null ) : void
		{
			try
			{
				if ( !Clipboard.generalClipboard.hasFormat( ClipboardFormats.TEXT_FORMAT ) )
					return;
				var str : String = Clipboard.generalClipboard.getData( ClipboardFormats.TEXT_FORMAT ) as String;
				if ( str )
				{
					replaceSelection( str );
					dipatchChange();
					dipatchChangeText();
				}
			}
			catch ( e : SecurityError )
			{
			}
			; //can't paste
		}

		private function onCopy( e : Event = null ) : void
		{
			if ( _selStart != _selEnd )
			{
				Clipboard.generalClipboard.clear();
				Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, _text.substring( _selStart, _selEnd ) );
			}
		}

		private function onCut( e : Event = null ) : void
		{
			onCopy();
			replaceSelection( '' );
			dipatchChange();
			dipatchChangeText();
		}

		private function onSelectAll( e : Event ) : void
		{
			_setSelection( 0, _text.length, true );
		}

		public function onMouseDown( e : MouseEvent ) : void
		{
			var dragStart : int;
			if ( e.shiftKey )
			{
				if ( _selStart == _selEnd )
					dragStart = _caret;
				else
					dragStart = _start;
				
				_setSelection( dragStart, getIndexForPoint( new Point( mouseX, mouseY ) ), true );
			}
			else
			{
				dragStart = getIndexForPoint( new Point( mouseX, mouseY ) );
				_setSelection( dragStart, dragStart, true );
			}
			
			ClearLineGoToToken();
			selectedSkobki( dragStart );

			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );

			var IID : int = setInterval( intervalScroll, 30 );
			var scrollDelta : int = 0;

			function onMouseMove( e : MouseEvent ) : void
			{
				if ( mouseY < 0 )
					scrollDelta = -1;
				else if ( mouseY > height )
					scrollDelta = 1;
				else
					scrollDelta = 0;
				_setSelection( dragStart, getIndexForPoint( new Point( mouseX, mouseY ) ) );
			}

			function onMouseUp( e : MouseEvent ) : void
			{ 
				stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
				_setSelection( dragStart, getIndexForPoint( new Point( mouseX, mouseY ) ), true );
				clearInterval( IID );
				saveLastCol();
			}

			function intervalScroll() : void
			{
				if ( scrollDelta != 0 )
				{
					scrollV += scrollDelta;
					_setSelection( dragStart, getIndexForPoint( new Point( mouseX, mouseY ) ) );
				}
			}
		}
		
		private function selectedSkobki( pos : int ) : void
		{
			var token1 : Token = controller.getTokenByPos( pos - 1 );
			var token2 : Token;
			
			if ( !token1 || token1.type != Token.SYMBOL || token1.pos != pos - 1 )
				return;
			
			var pos2 : int = pos - 1;
			
			var tempPos : int;
			var tempPos2 : int;
			var step : int = 0;
			var flag : Boolean = false;
			
			if ( token1.string == "(" )
			{
				while ( true )
				{
					tempPos = text.indexOf( ")", pos2 + 1 );
					tempPos2 = text.indexOf( "(", pos2 + 1 );
					if ( tempPos < 0 )
					{
						flag = false;
						break;
					}
					
					if ( tempPos > tempPos2 && tempPos2 > 0 )
					{
						token2 = controller.getTokenByPos( tempPos2 );
						pos2 = tempPos2;
						if ( token2.type == Token.SYMBOL )
							step++;
						else
						{
							continue;
						}
					}
					else
						pos2 = tempPos;
					
					token2 = controller.getTokenByPos( pos2 );
					if ( token2.type == Token.SYMBOL && token2.string == ")" )
					{
						if ( step == 0)
						{
							flag = true;
							break;
						}
						else
							step--;
						
					}
				}
			}
			else if ( token1.string == ")" )
			{
				while ( true )
				{					
					tempPos = text.lastIndexOf( "(", pos2 - 1 );
					tempPos2 = text.lastIndexOf( ")", pos2 - 1 );
					
					if ( tempPos < 0 )
					{
						flag = false;
						break;
					}
					
					if ( tempPos < tempPos2 )
					{
						token2 = controller.getTokenByPos( tempPos2 );
						pos2 = tempPos2;
						if ( token2.type == Token.SYMBOL )
							step++;
						else
						{
							continue;
						}
					}
					else
						pos2 = tempPos;
					
					token2 = controller.getTokenByPos( pos2 );
					if ( token2.type == Token.SYMBOL && token2.string == "("  )
					{
						if ( step == 0)
						{
							flag = true;
							break;
						}
						else
							step--;
					}
				}
				
			}
			else
				return;
			
			if (!flag)
				return;
			
			drawSkobki( pos-1, pos2 );
			
			
		}
		
		public function onMouseClick( e : MouseEvent ) : void
		{
			if ( e.ctrlKey )
			{
				CheckGoTo( true );
				ClearLineGoToToken();
			}
		}
		
		public function onMouseMove( e : MouseEvent ) : void
		{
			if ( e.ctrlKey )
			{
				if ( !CheckGoTo( false ) )
					ClearLineGoToToken();
			}
		}
		
		private function onKeyUp( event : KeyboardEvent ):void
		{
			ClearLineGoToToken();
		}
		
		private function CheckGoTo( needGo : Boolean ):Boolean
		{
			var cursorPosition : int = getIndexForPoint( new Point( mouseX, mouseY ) );
			token = controller.getTokenByPos( cursorPosition );
			if ( !token )
				return false;
			
			var bp : BackwardsParser = new BackwardsParser;
			if ( !bp.parse( text, token.pos + token.string.length ) )
				return false;
			
			if ( controller.lang == "vscript" )
				bp.toLowerCase();
			
			var f : Field = token.scope.getLastRecursionField( bp.names[0] );
			
			var info : Object;
			var position : int;
			
			if ( f && f.className && bp.names.length > 1 )
			{
				var className : String = f.className.toLowerCase();
				var f2 : Field = token.scope.getRecursionField( className );
				if ( !f2 )
				{
					var importField : Object = token.findImport( className );
					if ( importField )
					{
						info = HashLibraryArray.getPositionToken( importField.source, importField.systemName, bp, controller.lang );
						if ( !info )
							return false;
						position = info.position;
						
						if ( position != -1 )
						{
							if ( needGo )
								dispatchEvent( new ScriptAreaComponenrEvent( ScriptAreaComponenrEvent.GO_TO_DEFENITION, false, false, info ) );
							else
								drawGoToToken( token.pos, token.string.length );
							return true;
						}
					}
				}
				else
				{
					for ( var i : int = 1; i < bp.names.length; i++ )
					{
						name = bp.names[i];
						
						f2 = f2.getField( name );
						
						if ( !f2 || ( f2 != token.scope && f2.fieldType == "top" && controller.actionVO is ServerActionVO ) )
							return false;
					}
					
					if ( needGo )
						goToPos( f2.pos, token.string.length );
					else
						drawGoToToken( token.pos, token.string.length );
					return true;
				}
			}
			
			if ( token.parent && token.parent.scope.imports && token.parent.scope.imports.hasKey( bp.names[0] ) )
			{
				var lib : Object = token.parent.scope.imports.getValue( bp.names[0] );
				info = HashLibraryArray.getPositionToken( lib.source, lib.systemName, bp, controller.lang );
				if ( !info )
					return false;
				position = info.position;
				
				if ( position != -1 )
				{
					if ( needGo )
						dispatchEvent( new ScriptAreaComponenrEvent( ScriptAreaComponenrEvent.GO_TO_DEFENITION, false, false, info ) );
					else
						drawGoToToken( token.pos, token.string.length );
					return true;
				}
			}
			
			return getFiled( token, bp, needGo );
		}
		
		private function getFiled( t : Token, bp : BackwardsParser, needGo : Boolean ) : Boolean
		{
			if ( !t )
				return false;
			
			if ( getFiled( t.parent, bp, needGo ) )
				return true;
			
			var scope : Field = t.scope;
			var name : String;
			
			for ( var i : int = 0; i < bp.names.length; i++ )
			{
				name = bp.names[i];
				
				scope = scope.getField( name );
				
				if ( !scope /*|| ( t.scope.fieldType == "class" && scope.fieldType != "def" ) */|| ( t.scope != token.scope && t.scope.fieldType == "top" && controller.actionVO is ServerActionVO ) )
					return false;
			}
			
			if ( needGo )
				goToPos( scope.pos, token.string.length );
			else
				drawGoToToken( token.pos, token.string.length );
			return true;
		}
		
		public function undo_fun() : void
		{
			undo();
			dipatchChange();
			dipatchChangeText();
		}
		
		public function redo_fun() : void
		{
			redo();
			dipatchChange();
			dipatchChangeText();
		}
		
		private var eventPressNavigetionKey : ScriptAreaComponenrEvent = new ScriptAreaComponenrEvent( ScriptAreaComponenrEvent.PRESS_NAVIGATION_KEY );

		private function onKeyDown( e : KeyboardEvent ) : void
		{	
			if ( assistMenuOpened && ( e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.UP  || e.keyCode == Keyboard.DOWN ) )
			{
				if ( e.keyCode == Keyboard.ENTER )
					eventPressNavigetionKey.detail = "Enter";
				else if ( e.keyCode == Keyboard.UP )
					eventPressNavigetionKey.detail = "Up";
				else if ( e.keyCode == Keyboard.DOWN )
					eventPressNavigetionKey.detail = "Down";
				
				dispatchEvent( eventPressNavigetionKey );
				
				e.stopImmediatePropagation();
				return;
			}		
			
			var c : String = String.fromCharCode( e.charCode );
			var k : int = e.keyCode;
			var i : int;
			if (e.ctrlKey &&  (k == Keyboard.INSERT  || c ==  'c' || c == 'C' ))
			{
				onCopy();
			}
			else if (  e.shiftKey && k == Keyboard.INSERT 
				|| e.ctrlKey  &&  ( c ==  'v' || c ==  'V') )
			{
				onPaste();
				//dipatchChange(); //?
			}
				
			else if (  e.altKey && k == Keyboard.BACKSPACE 
				|| e.ctrlKey  &&  ( c ==  'z' || c ==  'Z')) // z & Z ?
			{
				undo_fun();
				return;
			}
			else if ( e.ctrlKey &&  ( c ==  'y' || c ==  'Y') )
			{
				redo_fun();
				return;
			}
			else if (  e.shiftKey && k == Keyboard.DELETE 
				|| e.ctrlKey  &&  ( c ==  'x' || c ==  'X') )
			{
				onCopy();
				
				if ( _caret < length && _selStart == _selEnd )
					replaceText( _caret, _caret + 1, '' );
				else
					replaceSelection( '' );
				
				dipatchChange();
				dipatchChangeText();
				return;
				
			}
			else if ( e.ctrlKey  &&  ( c ==  'a' || c ==  'A') )
			{
				_setSelection( 0, this.length, false );
				return;
			}
			else if ( e.ctrlKey  &&  ( c ==  'd' || c ==  'D') )
			{
				var p : int = text.lastIndexOf( "\r", _caret - 1 );
				
				_selStart = p != -1 ? p + 1 : 0;
				_selEnd = text.indexOf("\r", _caret ) + 1;
				replaceSelection('');
				
				return;
			}
			else if ( e.ctrlKey  &&  ( c ==  'o' || c ==  'O') )
			{
				token = controller.getTokenByPos( 0 );
				
				if ( !token )
					return;
				
				var scriptStructureWindow : ScriptStructureWindow = new ScriptStructureWindow();
				scriptStructureWindow.structure = token.scope.members;
				scriptStructureWindow.addEventListener( PopUpWindowEvent.APPLY, applyHandler );
				scriptStructureWindow.addEventListener( PopUpWindowEvent.CANCEL, cancelHandler );
				stage.addEventListener( MouseEvent.MOUSE_DOWN, closeScriptStructureWindowHandler );
				
				WindowManager.getInstance().addWindow( scriptStructureWindow, null, false );
				
				return;
			}
			
			
			
			/*if (extChar==0 && e.charCode > 127)
			{
			extChar = e.charCode;
			return;
			}
			
			if (extChar > 0)
			{
			c = Util.decodeUTF(e.charCode, extChar);
			extChar = 0;
			}*/
			
			
			
			
			if ( k == Keyboard.CONTROL || k == Keyboard.SHIFT || e.keyCode == 3 /*ALT*/ || e.keyCode == Keyboard.ESCAPE )
				return;
			
			//debug(e.charCode+' '+e.keyCode);
			
			//var line:TextLine = getLineAt(_caret);
			var re : RegExp;
			var pos : int;
			
			if ( k == Keyboard.RIGHT )
			{
				if ( e.ctrlKey )
				{
					re = /\b/g;
					re.lastIndex = _caret + 1;
					re.exec( _text );
					_caret = re.lastIndex;
					if ( e.shiftKey )
						extendSel( false );
				}
				else
				{
					//if we have a selection, goto end of selection
					if ( !e.shiftKey && _selStart != _selEnd )
						_caret = _selEnd;
					else if ( _caret < length )
					{
						_caret += 1;
						if ( e.shiftKey )
							extendSel( false );
					}
				}
			}
			else if ( k == Keyboard.LEFT )
			{
				if ( e.ctrlKey )
				{
					_caret = Math.max( 0, findWordBound( _caret - 2, true ) );
					if ( e.shiftKey )
						extendSel( true );
				}
				else
				{
					//if we have a selection, goto begin of selection
					if ( !e.shiftKey && _selStart != _selEnd )
						_caret = _selStart;
					else if ( _caret > 0 )
					{
						_caret -= 1;
						if ( e.shiftKey )
							extendSel( true );
					}
				}
			}
			else if ( k == Keyboard.DOWN )
			{
				//look for next NL
				i = _text.indexOf( NL, _caret );
				if ( i != -1 )
				{
					_caret = i + 1;
					
					//line = lines[line.index+1];
					
					i = _text.indexOf( NL, _caret );
					if ( i == -1 )
						i = _text.length;
					
					
					//restore col
					if ( i - _caret > lastCol )
						_caret += lastCol;
					else
						_caret = i;
					
					if ( e.shiftKey )
						extendSel( false );
				}
			}
			else if ( k == Keyboard.UP )
			{
				i = _text.lastIndexOf( NL, _caret - 1 );
				var lineBegin : int = i;
				if ( i != -1 )
				{
					i = _text.lastIndexOf( NL, i - 1 );
					if ( i != -1 )
						_caret = i + 1;
					else
						_caret = 0;
					
					//line = lines[line.index - 1];
					//_caret = line.start;
					
					//restore col
					if ( lineBegin - _caret > lastCol )
						_caret += lastCol;
					else
						_caret = lineBegin;
					
					if ( e.shiftKey )
						extendSel( true );
				}
			}
			else if ( k == Keyboard.HOME )
			{
				if ( e.ctrlKey )
					_caret = 0;
				else
				{
					var start : int = i = _text.lastIndexOf( NL, _caret - 1 ) + 1;
					var ch : String;
					while ( ( ch = _text.charAt( i ) ) == '\t' || ch == ' ' )
						i++;
					_caret = _caret == i ? start : i;
				}
				if ( e.shiftKey )
					extendSel( true );
			}
			else if ( k == Keyboard.END )
			{
				if ( e.ctrlKey )
					_caret = _text.length;
				else
				{
					i = _text.indexOf( NL, _caret );
					_caret = i == -1 ? _text.length : i;
				}
				if ( e.shiftKey )
					extendSel( false );
			}
			else if ( k == Keyboard.PAGE_UP )
			{
				for ( i = 0, pos = _caret; i <= visibleRows; i++ )
				{
					pos = _text.lastIndexOf( NL, pos - 1 );
					if ( pos == -1 )
					{
						_caret = 0;
						break;
					}
					_caret = pos + 1;
				}
			}
			else if ( k == Keyboard.PAGE_DOWN )
			{
				for ( i = 0, pos = _caret; i <= visibleRows; i++ )
				{
					pos = _text.indexOf( NL, pos + 1 );
					if ( pos == -1 )
					{
						_caret = _text.length;
						break;
					}
					_caret = pos + 1;
				}
			}
			else if ( k == Keyboard.BACKSPACE )
			{
				if ( _caret > 0 && _selStart == _selEnd )
				{
					replaceText( _caret - 1, _caret, '' );
					_caret--;
				}
				else
					replaceSelection( '' );
				dipatchChange();
				dipatchChangeText();
			}
			else if ( k == Keyboard.DELETE )
			{
				if ( _caret < length && _selStart == _selEnd )
					replaceText( _caret, _caret + 1, '' );
				else
					replaceSelection( '' );
				dipatchChange();
				dipatchChangeText();
			}
			else if ( k == Keyboard.TAB )
			{
				if ( _text.substring( _selStart, _selEnd ).indexOf( NL ) == -1 && !e.shiftKey )
				{
					replaceSelection( '\t' );
				}
				else
				{
					//extend selection to full lines
					var end : int = _text.indexOf( NL, _selEnd - 1 );
					if ( end == -1 )
						end = _text.length - 1;
					var begin : int = _text.lastIndexOf( NL, _selStart - 1 ) + 1;
					var str : String = _text.substring( begin, end );
					
					if ( e.shiftKey )
						str = str.replace( /\r\s/g, '\r' ).replace( /^\s/, '' );
					else
						str = '\t' + str.replace( /\r/g, '\r\t' );
					
					replaceText( begin, end, str );
					_setSelection( begin, begin + str.length + 1, true );
				}
				dipatchChange();
				dipatchChangeText();
			}
			else if ( k == Keyboard.SLASH && e.ctrlKey )
			{
				//extend selection to full lines
				end = _text.indexOf( NL, _selEnd );
				if ( end == -1 )
					end = _text.length - 1;
				
				begin = _text.lastIndexOf( NL, _selStart ) + 1;
				
				if ( begin > end )
					return;
				
				str = _text.substring( begin, end );
				
				var t : Token;
				var addComment : Boolean = false;
				i = end;

				while ( !addComment && i > begin )
				{
					t = controller.getTokenByPos( i );
					if ( !t )
						return;
					
					if ( t.type != Token.COMMENT && t.type != Token.ENDLINE )
					{
						addComment = true;
					}
					i = t.pos - 1;
				}
				
				var commentString : String = controller.commentString;
				
				if ( addComment )
				{
					var string : String = "\r" + commentString ;
					str = commentString + str.replace( /\r/g, string );
				}
				else
				{
					var index1 : int = 0;
					
					while ( index1 < str.length && index1 != -1 )
					{
						var index2 : int = str.indexOf( commentString, index1 );
						str = str.substring( 0, index2 ) + str.substring( index2 + 1, end );
						index1 = str.indexOf( "\r", index2 );
					}
				}
				
				replaceText( begin, end, str );
				_setSelection( begin, begin + str.length + 1, true );
					
				dipatchChange();
				dipatchChangeText();
			}			
			else if ( k == Keyboard.ENTER )
			{
				i = _text.lastIndexOf( NL, _caret - 1 );
				str = _text.substring( i + 1, _caret ).match( /^\s*/ )[ 0 ];
				
				switch(scriptLang)
				{
					case "vscript":
					{
						
						
						break;
					}
						
					default:
					{
						if ( _text.charAt( _caret - 1 ) == ':' )
							str += '\t';
						
						break;
					}
				}
				
				
				
				
				replaceSelection( '\r' + str );
				dipatchChange();
				dipatchChangeText();
			}
			/*else if ( c == '}' && _text.charAt( _caret - 1 ) == '\t' )
			{
				replaceText( _caret - 1, _caret, '}' );
				dipatchChange();
			}*/
				//else if (e.ctrlKey) return;
			else if ( e.charCode != 0 )
			{
				//replaceSelection(c);
				//dipatchChange();
				
				//don't capture CTRL+Key
				if ( e.ctrlKey && !e.altKey )
					return;
				captureInput();
				return;
			}
			else
				return;
			
			if ( !e.shiftKey && k != Keyboard.TAB )
				_setSelection( _caret, _caret );
			
			updateCaret();
			updateSize();
			
			//save last column
			if ( k != Keyboard.UP && k != Keyboard.DOWN && k != Keyboard.TAB )
				saveLastCol();
			
			checkScrollToCursor();
			e.updateAfterEvent();
			
			//local function
			function extendSel( left : Boolean ) : void
			{
				if ( left )
				{
					if ( _caret < _selStart )
						_setSelection( _caret, _selEnd );
					else
						_setSelection( _selStart, _caret );
				}
				else
				{
					if ( _caret > _selEnd )
						_setSelection( _selStart, _caret );
					else
						_setSelection( _caret, _selEnd );
				}
			}
			
			function applyHandler( event : PopUpWindowEvent ) : void
			{
				if ( event.detail )
					goToPos( event.detail.pos, event.detail.len );
				
				WindowManager.getInstance().removeWindow( event.target );
				stage.removeEventListener( MouseEvent.MOUSE_DOWN, closeScriptStructureWindowHandler );
			}
			
			function cancelHandler( event : PopUpWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( event.target );
				stage.removeEventListener( MouseEvent.MOUSE_DOWN, closeScriptStructureWindowHandler );
			}
			
			
			function closeScriptStructureWindowHandler( event : MouseEvent ) : void
			{
				WindowManager.getInstance().removeWindow( scriptStructureWindow );
			}
		}
		
		
		

		private function captureInput() : void
		{
			if ( stage && stage.focus == this )
				stage.focus = inputTF;
		}

		private function onInputText( e : TextEvent ) : void
		{
			replaceSelection( e.text );
			//_setSelection( _caret, _caret );
			updateCaret();
			saveLastCol();
			checkScrollToCursor();
			e.preventDefault();
			if ( stage )
				stage.focus = this;
			dipatchChange(e.text);
			dipatchChangeText();
			dispatchEvent( new ScriptAreaComponenrEvent( ScriptAreaComponenrEvent.TEXT_INPUT ) );
		}

		private function saveLastCol() : void
		{
			lastCol = _caret - _text.lastIndexOf( NL, _caret - 1 ) - 1;
		}

		public function dipatchChange(text : String = "") : void
		{
			if ( text == ".")
			{
				timerHandler( null );
			}
			else if ( !blocked )
			{
				blocked = true;
				t.start();
			}
		}
		
		private function timerHandler( event : TimerEvent ) : void
		{
			dispatchEvent( new Event( Event.CHANGE, true, false ) );
			blocked = false;
		}
		
		public function dipatchChangeText() : void
		{
			dispatchEvent( new ScriptAreaComponenrEvent( ScriptAreaComponenrEvent.TEXT_CHANGE, true, false ) );
		}
		
		public function renameByArray( words : Array, oldName : String, newName : String ) : void
		{
			var oldNameLength : int = oldName.length;
			var index : int;
			for each ( var xml : XML in words )
			{
				index = xml.@index;
				replaceText( index, index + oldNameLength, newName );
			}
			
			dipatchChange();
			dipatchChangeText();
		}
	}
}
