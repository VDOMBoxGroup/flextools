/*
   Copyright (c) 2009 Jacob Wright

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.
 */
package gearsandcogs.text
{
	import flash.display.DisplayObjectContainer;
	import flash.display.NativeMenu;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import flight.commands.CommandHistory;
	
	import gearsandcogs.text.commands.CommandAlterText;
	import gearsandcogs.text.commands.CommandDelete;
	import gearsandcogs.text.commands.CommandType;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;

	/**
	 * Enables undo/redo functionality for all textfields inside of a given
	 * target DisplayObjectContainer. Adds menu items for undo/redo and listens
	 * for Ctrl+Z and Ctrl+Y/Ctrl+Shift+Z. Simply create a new instance of this
	 * class (be sure to keep it in memory by having a pointer to it somewhere)
	 * and set the target property to a base container (e.g. root or stage or
	 * the base of a component).
	 */
	public class UndoTextFields
	{
		protected static const ACTION_TYPE : String = "type";
		protected static const ACTION_DELETE : String = "delete";


		protected var textFieldData : Dictionary = new Dictionary( true );
		protected var _target : UIComponent;

		private var _undoLevels : uint = 40;

		public function get undoLevels() : uint
		{
			return _undoLevels;
		}

		public function set undoLevels( value : uint ) : void
		{
			_undoLevels = value;

			for each ( var data : Object in textFieldData )
			{
				CommandHistory( data.history ).undoLimit = _undoLevels;
			}
		}

		/**
		 * The container which contains textfields needing undo/redo
		 * functionality. All textfields in the display list inside of this
		 * target will receive the functionality. Add to the root or stage if
		 * you want all textfields to have undo/redo.
		 */
		public function get target() : UIComponent
		{
			return _target;
		}

		public function set target( value : UIComponent ) : void
		{
			if ( value == _target )
			{
				return;
			}

			if ( _target )
			{
				cleanupTarget( _target );
			}

			_target = value;
			initializeTarget( _target );
		}

		public function clearHistory() : void
		{
			for each ( var data : Object in textFieldData )
			{
				CommandHistory( data.history ).clearHistory();
			}
		}

		public function getHistoryByTarget( target : DisplayObjectContainer ) : CommandHistory
		{
			var data : Object = textFieldData[ target ];

			if ( data )
				return data.history;
			else
				return null;
		}

		/**
		 * Set up all the event listeners needed to provide undo/redo.
		 *
		 * @param The target container being watched.
		 */
		protected function initializeTarget( target : UIComponent ) : void
		{
			target.addEventListener( Event.CHANGE, onTextChange, true, 100, true );
			target.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler, true,
									 100, true );
			target.addEventListener( KeyboardEvent.KEY_UP, saveLastTextState, true,
									 100, true );
			target.addEventListener( MouseEvent.CLICK, saveLastTextState, true, 100,
									 true );
			target.addEventListener( FlexEvent.VALUE_COMMIT, saveLastTextState, true, 100,
									 true );
		}

		/**
		 * Remove all the event listeners added in initializeTarget.
		 *
		 * @param The target container initialized previously.
		 */
		protected function cleanupTarget( target : DisplayObjectContainer ) : void
		{
			target.removeEventListener( Event.CHANGE, onTextChange, true );
			target.removeEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler, true );
			target.removeEventListener( KeyboardEvent.KEY_UP, saveLastTextState,
										true );
			target.removeEventListener( MouseEvent.CLICK, saveLastTextState, true );
		}

		/**
		 * Listen to when the text changes in a TextField. If we know a change
		 * is coming (from a keyDown event) then we will have the last action
		 * stored to know whether it was typing or deleting. Otherwise we can
		 * safely assume it was a cut or paste operation.
		 */
		protected function onTextChange( event : Event ) : void
		{
			var textField : TextField = event.target as TextField;
			if ( !textField )
			{
				return;
			}

			var selection : Array = [ textField.selectionBeginIndex, textField.selectionEndIndex ]

			var data : Object = getData( textField );
			var history : CommandHistory = data.history;
			var lastValue : String = data.lastValue;
			var lastSelection : Array = data.lastSelection;
			var lastAction : String = data.lastAction;

			if ( lastAction == ACTION_TYPE )
			{
				history.executeCommand( new CommandType( textField, lastValue, lastSelection ) );
			}
			else if ( lastAction == ACTION_DELETE )
			{
				history.executeCommand( new CommandDelete( textField, lastValue,
														   lastSelection ) );
			}
			else
			{
				history.executeCommand( new CommandAlterText( textField, lastValue,
															  lastSelection ) );
			}

			updateMenu( textField, history );
		}

		/**
		 * Listen to various other events to save the current text in the TextField
		 */
		protected function saveLastTextState( event : Event, textField : TextField = null ) : void
		{
			var textField : TextField = textField || event.target as TextField;
			if ( !textField )
			{
				return;
			}

			var data : Object = getData( textField );

			// if the cursor is moved during typing or deletion then force a new
			// combinable command.
			if ( data.lastSelection && event )
			{
				if ( event.type == MouseEvent.CLICK || event.type == KeyboardEvent.KEY_UP )
				{
					if ( data.lastValue == textField.text && ( data.lastSelection[ 0 ] != textField.selectionBeginIndex || data.lastSelection[ 1 ] != textField.selectionEndIndex ) )
					{
						data.history.resetCombining();
					}
				}
			}

			data.lastValue = textField.text;
			data.lastSelection = [ textField.selectionBeginIndex, textField.selectionEndIndex ];
		}

		/**
		 * Look up the information for a given TextField. This will contain the
		 * CommandHistory and data about the last state of the TextField. The
		 * following properties are stored: history, lastValue, lastSelection,
		 * lastAction.
		 */
		protected function getData( textField : TextField ) : Object
		{
			var data : Object = textFieldData[ textField ];
			if ( !data )
			{
				var history : CommandHistory = new CommandHistory();
				history.undoLimit = _undoLevels;
				data = { history: history, lastValue: null, lastSelection: null, lastAction: null };
				textFieldData[ textField ] = data;
				addContextMenu( textField );
			}
			return data;
		}

		/**
		 * Listen for the key command to undo and redo. Also set the appropriate
		 * action for the keys pressed.
		 */
		protected function keyDownHandler( event : KeyboardEvent ) : void
		{
			var textField : TextField = event.target as TextField;
			if ( !textField )
			{
				return;
			}

			saveLastTextState( event );
			var cmd : String = getKeyCommand( event );

			if ( cmd == 'Ctrl+Z' )
			{
				undo( textField );
				target.addEventListener( TextEvent.TEXT_INPUT, stopInput, true, 100,
										 true );
			}
			else if ( cmd == 'Ctrl+Y' || cmd == 'Ctrl+Shift+Z' )
			{
				redo( textField );
				target.addEventListener( TextEvent.TEXT_INPUT, stopInput, true, 100,
										 true );
			}
			else
			{
				var action : String = getKeyAction( event );
				var data : Object = getData( textField );
				data.lastAction = action;
			}
		}

		/**
		 * Perform and undo action on the given TextField.
		 */
		protected function undo( textField : TextField ) : void
		{
			var history : CommandHistory = getData( textField ).history;
			history.undo();
			history.resetCombining();
			updateMenu( textField, history );
			saveLastTextState( null, textField );
		}

		/**
		 * Perform and redo action on the given TextField.
		 */
		protected function redo( textField : TextField ) : void
		{
			var history : CommandHistory = getData( textField ).history;
			history.redo();
			history.resetCombining();
			updateMenu( textField, history );
			saveLastTextState( null, textField );
		}

		/**
		 * Stop the input of the upcoming key stroke. This is to prevent a "z"
		 * being entered into the TextField when Ctrl+Z is pressed as well as
		 * the redo commands.
		 */
		protected function stopInput( event : TextEvent ) : void
		{
			event.preventDefault();
			target.removeEventListener( TextEvent.TEXT_INPUT, stopInput, true );
		}

		/**
		 * Returns a string representation of the keys being pressed.
		 */
		protected function getKeyCommand( event : KeyboardEvent ) : String
		{
			var cmd : String = "";
			if ( event.ctrlKey )
				cmd += "Ctrl+";
			if ( event.altKey )
				cmd += "Alt+";
			if ( event.shiftKey )
				cmd += "Shift+";

			cmd += String.fromCharCode( event.charCode ).toUpperCase();

			return cmd;
		}

		/**
		 * Returns the action associated with the given keyboard event. This can
		 * be "type", "delete", or nothing.
		 */
		protected function getKeyAction( event : KeyboardEvent ) : String
		{
			var keyCode : int = event.keyCode;

			if ( keyCode == Keyboard.DELETE || keyCode == Keyboard.BACKSPACE )
			{
				return ACTION_DELETE;
			}
			else if ( keyCode == Keyboard.SPACE || keyCode == Keyboard.TAB )
			{
				return null;
			}
			else if ( event.charCode )
			{
				return ACTION_TYPE;
			}
			else
			{
				return null;
			}
		}

		/**
		 * Updates a TextField's context menu undo/redo items. Will disable or
		 * enable them when there is an undo or redo that can be performed.
		 */
		protected function updateMenu( textField : TextField, history : CommandHistory ) : void
		{
			var menu : NativeMenu = textField.contextMenu;
			if ( menu )
			{
				ContextMenuItem( menu.items[ 0 ] ).enabled = history.canUndo;
				ContextMenuItem( menu.items[ 1 ] ).enabled = history.canRedo;
			}
		}

		/**
		 * Adds the undo/redo context menu items to the TextField's context
		 * menu.
		 */
		protected function addContextMenu( textField : TextField ) : void
		{
			var undoItem : ContextMenuItem = new ContextMenuItem( 'Undo Text', false,
																  false, true );
			undoItem.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, function( event : Event ) : void
				{
					undo( textField );
				} );
			var redoItem : ContextMenuItem = new ContextMenuItem( 'Redo Text', false,
																  false, true );
			redoItem.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, function( event : Event ) : void
				{
					redo( textField );
				} );
			if ( textField.contextMenu == null )
			{
				textField.contextMenu = new ContextMenu();
			}
			textField.contextMenu.items.push( undoItem );
			textField.contextMenu.items.push( redoItem );
		}
	}
}
