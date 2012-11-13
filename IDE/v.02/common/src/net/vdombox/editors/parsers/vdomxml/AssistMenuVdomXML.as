package net.vdombox.editors.parsers.vdomxml
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.base.AssistMenu;
	import net.vdombox.ide.common.events.ScriptAreaComponenrEvent;
	import net.vdombox.ide.common.view.components.VDOMImage;
	
	import ro.victordramba.util.vectorToArray;

	public class AssistMenuVdomXML extends AssistMenu
	{
		public function AssistMenuVdomXML( field : ScriptAreaComponent, ctrl : VdomXMLController, stage : Stage, onComplete : Function )
		{
			super( field, ctrl, stage, onComplete );
			
			fld.removeEventListener( ScriptAreaComponenrEvent.TEXT_INPUT, onTextInput );
		}

		protected override function filterMenu() : Boolean
		{
			var a : Array = [];
			for each ( var s : Object in menuData )
				if ( s.value.toLowerCase().indexOf( menuStr.toLowerCase() ) == 0 )
					a.push( s );

			if ( a.length == 0 )
				return false;
			menu.setListData( a );
			menu.selectedIndex = 0;

			return true;
		}

		private function onKeyDown( e : KeyboardEvent ) : void
		{
			if ( e.keyCode == Keyboard.SPACE && e.ctrlKey)
				triggerAssist();
		}
		
		private function onKeyUp( e : Event ) : void
		{
			//triggerAssist();
		}

		public override function triggerAssist( forced : Boolean = false ) : void
		{
			var pos : int = fld.caretIndex;

			var tmp : String = fld.text.substring( Math.max( 0, pos - 100 ), pos ).split( "" ).reverse().join( "" );
			var m : Array = tmp.match( /^(\w*)\b/ );
			var i : int;
			menuStr = m ? m[ 1 ] : "";

			menuStr = menuStr.split( "" ).reverse().join( "" )

			menuData = null;

			if ( VdomXMLController( ctrl ).isInTag( pos ) )
			{
				menuData = VdomXMLController( ctrl ).getAllTypes();

				/*if ( menuData && menuData.length > 0 )
				{
					for ( i = 0; i < menuData.length; i++ )
					{
						menuData[ i ] = { label: menuData[ i ], value: menuData[ i ].toUpperCase() };
					}
				}*/

				if ( !menuData )
					menuData = new Vector.<AutoCompleteItemVO>;

				menuData.push( new AutoCompleteItemVO( VDOMImage.Standard, "ATTRIBUTE" ) );
			}
			else if ( VdomXMLController( ctrl ).isInAttribute( pos ) )
			{
				menuData = VdomXMLController( ctrl ).getAttributesList( pos );
				var eqStr : String = "=\"\"";

				/*if ( menuData && menuData.length > 0 )
				{
					for ( i = 0; i < menuData.length; i++ )
					{
						menuData[ i ] = { label: menuData[ i ], value: menuData[ i ] /*+ eqStr*//* };
					}
				}*/

			}

			if ( !menuData || menuData.length == 0 )
			{
				menuDispose();
				return;
			}
			
			var showingMenu : Boolean = true;
			if ( menuStr.length )
				showingMenu = filterMenu();

			if ( showingMenu )
				showMenu( pos + 1 );
			else
				menuDispose();
		}

		protected override function showMenu( index : int ) : void
		{
			fld.assistMenuOpened = true;
			
			var p : Point;
			menu.setListData( vectorToArray( menuData ) );
			menu.selectedIndex = 0;

			p = fld.getPointForIndex( index );
			p.x += fld.scrollH;

			p = fld.localToGlobal( p );

			//menu.show(stage, p.x, p.y + 15);
			menu.show( fld, p.x, 0 );

			stage.addEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, false, 0, true );

			//stage.focus = menu;
//			FocusManager.getManager( stage ).setFocusOwner( menu );
		}

	}
}