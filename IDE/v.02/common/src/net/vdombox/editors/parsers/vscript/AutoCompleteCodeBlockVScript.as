package net.vdombox.editors.parsers.vscript
{	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import net.vdombox.editors.PopUpMenu;
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.parsers.AssistMenu;

	public class AutoCompleteCodeBlockVScript
	{
		private var fld : ScriptAreaComponent;
		private var ctrl : Controller;
		private var assistMenu : AssistMenu;
		
		public function AutoCompleteCodeBlockVScript( field : ScriptAreaComponent, ctrl : Controller, assistMenu : AssistMenu )
		{
			fld = field;
			this.ctrl = ctrl;
			this.assistMenu = assistMenu;
			
			fld.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			this.assistMenu.menu.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}
		
		private function onKeyDown( e : KeyboardEvent ) : void
		{
			if ( e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.SPACE )
			{
				var currentPos : int = fld.caretIndex;
				var curPos : int = currentPos;
				var char : String = fld.text.charAt( curPos );
				
				var k : int = 0;
				while ( ( ( char == "\r") && k < 2 ) || ( char == "\t" || char == " " ) )
				{
					if ( char == "\r" )
						k++;
					
					char = fld.text.charAt( --curPos );
				}
				
				var t : Token = ctrl.getTokenByPos( curPos );
				
				if ( !t )
					return;
				if ( e.keyCode == Keyboard.ENTER && !( e.target is PopUpMenu ) )
				{
					if ( t.createConstruction )
					{   
						var block : Token = t.parent;
						if( !block )
							return;
						
						if( block.blockClosed )
						{
							var parentBlock : Token = block.parent;
							while ( parentBlock && parentBlock.mainBlockType == block.mainBlockType && parentBlock.blockClosed )
							{
								parentBlock = parentBlock.parent;
							}
							
							if ( !parentBlock || parentBlock.mainBlockType != block.mainBlockType )
							{
								fld.replaceText( currentPos, currentPos, "\t" );
								fld.caretIndex = currentPos + 1;
								
								fld.dispatchEvent( new Event( Event.CHANGE, true, false ) );
								return;
							}
						}
						
						if ( block.blockType == BlockType.IF )
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
						else if ( block.blockType == BlockType.DO || t.blockType == BlockType.DO )
						{
							pasteCode( "Loop" );
						}
					}
					else
					{
						switch(t.string.toLowerCase())
						{
							case "elseif":
							{
								
							}
							case "else":
							{
								if ( t.parent && t.parent.parent )
								{
									var i : int = t.parent.pos;
									i = fld.text.lastIndexOf( "\r", i );
									var  str : String = fld.text.substring( i + 1, currentPos ).match( /^\s*/ )[ 0 ];
									
									var pos : int = t.pos - 1;
									while ( fld.text.charAt( pos ) == " " || fld.text.charAt( pos ) == "\t" )
									{
										pos--;
									}
									
									i = fld.text.lastIndexOf( "\r", currentPos - 1);
									fld.replaceText( i + 1, currentPos, str + "\t" );
									fld.replaceText( pos + 1, t.pos, str );
									fld.caretIndex = currentPos + str.length * 2 + 1 - ( t.pos - pos - 1) - ( currentPos - i - 1 );
									
									fld.dispatchEvent( new Event( Event.CHANGE, true, false ) );
								}
								
								break;
							}
								
							default:
							{
								break;
							}
						}
					}
				}
				else
				{
					switch(t.string.toLowerCase())
					{				
						case "case":
						{
							if ( t.parent && t.parent.parent && t.blockType == BlockType.CASE )
							{
								i = t.parent.pos;
								i = fld.text.lastIndexOf( "\r", i );
								str = fld.text.substring( i + 1, currentPos ).match( /^\s*/ )[ 0 ] + "\t";
								
								pos = t.pos - 1;
								while ( fld.text.charAt( pos ) == " " || fld.text.charAt( pos ) == "\t" )
								{
									pos--;
								}
								
								if ( t.pos - pos - 1 != str.length )
								{
									fld.replaceText( pos + 1, t.pos, str );
									fld.caretIndex = currentPos + ( str.length - ( t.pos - pos - 1)) ;
								}
								
								fld.dispatchEvent( new Event( Event.CHANGE, true, false ) );
							}
							
							
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
		}
	}
}