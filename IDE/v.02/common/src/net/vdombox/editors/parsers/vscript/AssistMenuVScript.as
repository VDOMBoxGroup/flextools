package net.vdombox.editors.parsers.vscript
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import mx.core.UIComponent;
	
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.parsers.base.AssistMenu;
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.ide.common.events.ScriptAreaComponenrEvent;
	
	import ro.victordramba.util.vectorToArray;

	public class AssistMenuVScript extends AssistMenu
	{		
		private var menuDataStr : Vector.<AutoCompleteItemVO>;
		
		
		public function AssistMenuVScript( field : ScriptAreaComponent, ctrl : VScriptController, stage : Stage, onComplete : Function )
		{
			super( field, ctrl, stage, onComplete );
		}
		
		protected override function filterMenu() : Boolean
		{
			var a : Array = [];
			for each ( var s : Object in menuDataStr )
			{
				if ( s.hasOwnProperty( "value" ) )
				{
					if ( s.value.toLowerCase().indexOf( menuStr.toLowerCase() ) == 0 )
						a.push( s );
				}
				else
				{
					if ( s.toLowerCase().indexOf( menuStr.toLowerCase() ) == 0 )
						a.push( s );
				}
			}
			
			if ( a.length == 0 )
				return false;
			menu.setListData( a );
			menu.setSelectedIndex( 0 );
			
			rePositionMenu();
			return true;
		}
		
		public override function triggerAssist( forced : Boolean = false ) : void
		{
			var pos : int = fld.caretIndex;
			
			var tmp : String = fld.text.substring( Math.max( 0, pos - 100 ), pos ).split( "" ).reverse().join( "" );
			var m:Array = tmp.match(/^(\w*?)\s*(\.|\()/);
			var i : int;
			menuStr = m ? m[ 1 ] : "";
			
			var trigger:String = m ? m[2] : "";
			
			if (m) menuStr = m[1];
			else
			{
				m = tmp.match(/^(\w*)\b/);
				menuStr = m ? m[1] : '';
			}
			
			menuStr = menuStr.split( "" ).reverse().join( "" );
			pos -= menuStr.length + 1;
			
			menuDataStr = null;
			
			var rt : String =  tmp.replace( /^\s+|\s+$/g, '' );
			var tt : String = rt.substr( 3, 1 );
			if ( rt.length > 3 )
				rt = rt.substr( 0, 3 ).toLowerCase();
			
			if ( rt != "wen" || ( tt != " " && tt != "=" ) )
			{
				tt = rt.substr( 2, 1 );
				rt = rt.substr( 0, 2 );
			}
				
			if (rt == 'wen' || rt == 'sa' && tt == " " || tt == "=" )
				menuDataStr = ctrl.getTypeOptions();
			else if (trigger == '.')
				menuDataStr = ctrl.getMemberList(pos);
			else if (trigger == '')
				menuDataStr = ctrl.getAllOptions(pos);
			/*else if (trigger == '(')
			{
			var fd:String = ctrl.getFunctionDetails(pos);
			if (fd)
			{
			tooltip.setTipText(fd);
			var p:Point = fld.getPointForIndex(fld.caretIndex-1);
			p = fld.localToGlobal(p);
			tooltip.showToolTip();
			tooltip.moveLocationRelatedTo(new IntPoint(p.x, p.y));
			tooltipCaret = fld.caretIndex;
			return;
			}
			}*/
			
			if ( !menuDataStr || menuDataStr.length == 0 )
			{
				menuDispose();
				return;
			}
			
			menu.setListData( vectorToArray( menuDataStr ) );
			menu.setSelectedIndex( 0 );
			
			var showingMenu : Boolean = true;
			if ( menuStr.length )
				showingMenu = filterMenu();
			else if ( !forced && trigger != '.'  )
			{
				menuDispose();
				return;
			}
			
			if ( showingMenu )
				showMenu( pos + 1 );
			else
				menuDispose();
				
		}
	}
}