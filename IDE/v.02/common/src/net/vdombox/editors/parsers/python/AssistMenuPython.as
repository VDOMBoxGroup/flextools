package net.vdombox.editors.parsers.python
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import mx.core.UIComponent;
	
	import net.vdombox.editors.HashLibraryArray;
	import net.vdombox.editors.PopUpMenu;
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.parsers.AssistMenu;
	import net.vdombox.ide.common.events.ScriptAreaComponenrEvent;
	
	import ro.victordramba.util.vectorToArray;

	public class AssistMenuPython extends AssistMenu
	{
		private var menuDataStr : Vector.<String>;

		public function AssistMenuPython( field : ScriptAreaComponent, ctrl : PythonController, stage : Stage, onComplete : Function )
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
			
			/*if ( !forced )
				pos++;*/

			menuDataStr = null;
			
			var rt:String = trigger.split('').reverse().join('');
			/*if (rt == 'new' || rt == 'as' || rt == 'is' || rt == ':' || rt == 'extends' || rt == 'implements')
				menuDataStr = ctrl.getTypeOptions();*/
			if (trigger == '.')
				menuDataStr = ctrl.getMemberList(pos);
			else if (trigger == '')
			{
				menuDataStr = ctrl.getAllOptions(pos);
			}
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
				return;
			
			menu.setListData( vectorToArray( menuDataStr ) );
			menu.setSelectedIndex( 0 );

			var showingMenu : Boolean = true;
			if ( menuStr.length )
				showingMenu = filterMenu();
			else if ( !forced && trigger != '.' )
				return;
			
			if ( showingMenu )
				showMenu( pos + 1 );
		}

		private var menuRefY : int;

		private function showMenu( index : int ) : void
		{
			var p : Point = fld.getPointForIndex( index );
			p.x += fld.scrollH;

			p = fld.localToGlobal( p );
			menuRefY = p.y;

			//menu.show(stage, p.x, p.y + 15);
			menu.show( fld, p.x, 0 );

			stage.addEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, false, 0, true );

			stage.focus = menu;
			trace( "stage" );
//			FocusManager.getManager( stage ).setFocusOwner( menu );

			rePositionMenu();
		}

		private function rePositionMenu() : void
		{
			var menuH : int = 8 //Math.min( 8, menu.getModel().getSize() ) * 17;
			if ( menuRefY + 15 + menuH > fld.height )
				menu.y = menuRefY - menuH - 2;
			else
				menu.y = menuRefY + 15;
		}

		private function stage_mouseDownHandler( event : MouseEvent ) : void
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
				menu.dispose();
			}
		}
	}
}