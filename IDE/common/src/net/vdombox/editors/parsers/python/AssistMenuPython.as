package net.vdombox.editors.parsers.python
{
	import flash.display.Stage;

	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.base.AssistMenu;

	import ro.victordramba.util.vectorToArray;

	public class AssistMenuPython extends AssistMenu
	{
		private var menuDataStr : Vector.<AutoCompleteItemVO>;

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
			{
				helpWindow.dispose();
				return false;
			}

			menu.setListData( a );
			menu.selectedIndex = 0;
			return true;
		}

		public override function triggerAssist( forced : Boolean = false, text : String = '' ) : void
		{
			var pos : int = fld.caretIndex;

			var tmp : String = fld.text.substring( Math.max( 0, pos - 100 ), pos ).split( "" ).reverse().join( "" );
			var m : Array = tmp.match( /^(\w*?)\s*(\.|\()/ );
			var i : int;
			menuStr = m ? m[ 1 ] : "";

			var trigger : String = m ? m[ 2 ] : "";
			if ( vdomToolTip.showed && trigger == '(' )
				trigger = '';

			if ( m )
				menuStr = m[ 1 ];
			else
			{
				m = tmp.match( /^(\w*)\b/ );
				menuStr = m ? m[ 1 ] : '';
			}

			menuStr = menuStr.split( "" ).reverse().join( "" );
			pos -= menuStr.length + 1;

			/*
			   if ( !forced )
			   pos++;
			 */

			menuDataStr = null;

			var rt : String = trigger.split( '' ).reverse().join( '' );

			if ( text == " " && ( tmp.substr( 1, 4 ) == "morf" || tmp.substr( 1, 6 ) == "tropmi" ) )
				forced = true;
			/*
			   if (rt == 'new' || rt == 'as' || rt == 'is' || rt == ':' || rt == 'extends' || rt == 'implements')
			   menuDataStr = ctrl.getTypeOptions();
			 */
			if ( trigger == '(' )
			{
				menuDataStr = ctrl.getAllOptions( pos );
				var fd : String = ctrl.getFunctionDetails( pos );
				if ( fd )
				{
					vdomToolTip.text = fd;
					showToolTip();
					return;
				}

				if ( !autoShowAutoComplete && !forced && !showing )
					return;
			}
			else if ( !autoShowAutoComplete && !forced && !showing )
				return;
			else if ( trigger == '.' )
				menuDataStr = ctrl.getMemberList( pos );
			else if ( trigger == '' )
				menuDataStr = ctrl.getAllOptions( pos );

			if ( !menuDataStr || menuDataStr.length == 0 )
			{
				menuDispose();
				return;
			}

			menu.setListData( vectorToArray( menuDataStr ) );
			menu.selectedIndex = 0;

			var showingMenu : Boolean = true;
			if ( menuStr.length )
				showingMenu = filterMenu();
			else if ( !forced && trigger != '.' )
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