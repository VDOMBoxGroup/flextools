package net.vdombox.editors.parsers.vscript
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import net.vdombox.editors.PopUpMenu;
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.parsers.base.AssistMenu;
	import net.vdombox.ide.common.events.ScriptAreaComponenrEvent;

	public class AutoCompleteCodeBlockVScript
	{
		private var fld : ScriptAreaComponent;

		private var ctrl : VScriptController;

		private var assistMenu : AssistMenu;

		public function AutoCompleteCodeBlockVScript( field : ScriptAreaComponent, ctrl : VScriptController, assistMenu : AssistMenu )
		{
			fld = field;
			this.ctrl = ctrl;
			this.assistMenu = assistMenu;

			fld.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			this.assistMenu.menu.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}

		private function onKeyDown( e : KeyboardEvent ) : void
		{
			if ( e.keyCode == Keyboard.ENTER )
			{
				var currentPos : int = fld.caretIndex;

				var curPos : int = currentPos;
				var char : String = fld.text.charAt( curPos );

				var k : int = 0;
				while ( ( ( char == "\r" ) && k < 2 ) || ( char == "\t" || char == " " ) )
				{
					if ( char == "\r" )
						k++;

					char = fld.text.charAt( --curPos );
				}

				var tokenizer : VScriptTokenizer = new VScriptTokenizer( fld.text );

				while ( tokenizer.runSlice() )
				{

				}

				//var t : VScriptToken = ctrl.getTokenByPos( curPos ) as VScriptToken;
				var t : VScriptToken = tokenizer.token2prevByPos( currentPos ) as VScriptToken;

				if ( !t )
					return;

				if ( e.keyCode == Keyboard.ENTER && !( e.target is PopUpMenu ) )
				{
					if ( t.createConstruction )
					{
						var block : VScriptToken = t.parent as VScriptToken;
						if ( !block )
							return;

						if ( block.blockClosed )
						{
							var parentBlock : VScriptToken = block.parent as VScriptToken;
							while ( parentBlock && parentBlock.mainBlockType == block.mainBlockType && parentBlock.blockClosed )
							{
								parentBlock = parentBlock.parent as VScriptToken;
							}

							if ( !parentBlock || parentBlock.mainBlockType != block.mainBlockType )
							{
								//pasteCode2( block.blockType );
								fld.replaceText( currentPos, currentPos, "\t" );
								fld.caretIndex = currentPos + 1;

								fld.dispatchEvent( new Event( Event.CHANGE, true, false ) );
								return;
							}
						}



						if ( t.blockType == BlockType.DO )
						{
							pasteCode( "Loop" );
						}
						if ( t.blockType == BlockType.TRY )
						{
							pasteCode( "End Try" );
						}
						else if ( block.blockType == BlockType.IF )
						{
							pasteCode( "End If" );
						}
						else if ( block.blockType == BlockType.FOR || block.blockType == BlockType.FOREACH )
						{
							pasteCode( "Next" );
						}
						else if ( block.blockType == BlockType.SELECT )
						{
							pasteCode( "End Select" );
						}
						else if ( block.blockType == BlockType.SUB )
						{
							pasteCode( "End Sub" );
						}
						else if ( block.blockType == BlockType.FUNCTION )
						{
							pasteCode( "End Function" );
						}
						else if ( block.blockType == BlockType.WHILE )
						{
							pasteCode( "Wend" );
						}
						else if ( block.blockType == BlockType.DO )
						{
							pasteCode( "Loop" );
						}
						else if ( block.blockType == BlockType.CLASS )
						{
							pasteCode( "End Class" );
						}
					}
					else
					{
						switch ( t.string.toLowerCase() )
						{
							case "elseif":
							{

							}
							case "else":
							{

								//pasteCode2( BlockType.ELSE, false );
								if ( t.parent && t.parent.parent )
								{
									var i : int = t.parent.pos;
									i = fld.text.lastIndexOf( "\r", i );
									var str : String = fld.text.substring( i + 1, currentPos ).match( /^\s*/ )[ 0 ];

									var pos : int = t.pos - 1;
									while ( fld.text.charAt( pos ) == " " || fld.text.charAt( pos ) == "\t" )
									{
										pos--;
									}

									i = fld.text.lastIndexOf( "\r", currentPos - 1 );
									fld.replaceText( i + 1, currentPos, str + "\t" );
									fld.replaceText( pos + 1, t.pos, str );
									fld.caretIndex = currentPos + str.length * 2 + 1 - ( t.pos - pos - 1 ) - ( currentPos - i - 1 );

									fld.dispatchEvent( new Event( Event.CHANGE, true, false ) );
								}

								break;
							}

							/*
							   case "case":
							   {
							   pasteCode2( BlockType.CASE );

							   break;
							   }

							   case "catch":
							   {
							   pasteCode2( BlockType.CATCH );

							   break;
							   }
							 */

							default:
							{
								break;
							}
						}
					}
				}
				else
				{
					switch ( t.string.toLowerCase() )
					{
						case "case":
						{
							pasteCode2( BlockType.CASE, true );

							break;
						}

						case "elseif":
						{
							pasteCode2( BlockType.ELSEIF, false );

							break;
						}

						case "catch":
						{
							pasteCode2( BlockType.CATCH, false );

							break;
						}

						default:
						{
							break;
						}
					}
				}
			}

			function pasteCode( value : String ) : void
			{
				var i : int = fld.text.lastIndexOf( "\r", currentPos - 1 );
				var str : String = fld.text.substring( i + 1, currentPos ).match( /^\s*/ )[ 0 ];

				var text : String = "\t\r" + str + value;
				fld.replaceText( currentPos, currentPos, text );
				fld.setSelection( currentPos + text.length, currentPos + text.length );

				fld.caretIndex = currentPos + 1;

				fld.dispatchEvent( new Event( Event.CHANGE, true, false ) );
			}

			function pasteCode2( value : String, addTab : Boolean ) : void
			{
				if ( t.parent && t.parent.parent && t.blockType == value )
				{
					var i : int = t.parent.pos;
					i = fld.text.lastIndexOf( "\r", i );
					var str : String = fld.text.substring( i + 1, currentPos ).match( /^\s*/ )[ 0 ];

					if ( addTab )
						str += "\t";

					var pos : int = t.pos - 1;
					while ( fld.text.charAt( pos ) == " " || fld.text.charAt( pos ) == "\t" )
					{
						pos--;
					}

					if ( t.pos - pos - 1 != str.length )
					{
						fld.replaceText( pos + 1, t.pos, str );
						fld.caretIndex = currentPos + ( str.length - ( t.pos - pos - 1 ) );
					}

					fld.dispatchEvent( new Event( Event.CHANGE, true, false ) );
				}
			}
		}

		private function applyAutocompleteCodeRun( event : ScriptAreaComponenrEvent ) : void
		{

		}
	}
}
