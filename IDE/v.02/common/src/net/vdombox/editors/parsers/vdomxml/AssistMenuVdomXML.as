package net.vdombox.editors.parsers.vdomxml
{
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
	import net.vdombox.editors.parsers.AssistMenu;
	
	import ro.victordramba.util.vectorToArray;

	public class AssistMenuVdomXML extends AssistMenu
	{
		private var ctrl : VdomXMLController;

		public function AssistMenuVdomXML( field : ScriptAreaComponent, ctrl : VdomXMLController, stage : Stage, onComplete : Function )
		{
			fld = field;
			this.ctrl = ctrl;
			this.onComplete = onComplete;
			this.stage = stage;

			_menu = new net.vdombox.editors.PopUpMenu();
			//restore the focus to the textfield, delayed			
			menu.addEventListener( Event.REMOVED_FROM_STAGE, onMenuRemoved );
			//menu in action
			menu.addEventListener( KeyboardEvent.KEY_DOWN, onMenuKey );
			/*menu.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:Event):void {
			   var c:int = fld.caretIndex;
			   fldReplaceText(c-menuStr.length, c, menu.getSelectedValue());
			   ctrl.sourceChanged(fld.text);
			   menu.dispose();
			 })*/

//			tooltip = new JToolTip;

			//used to close the tooltip
			fld.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			//fld.addEventListener( Event.CHANGE, onKeyUp );
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
			menu.setSelectedIndex( 0 );

			rePositionMenu();
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

		

		

		private function onMenuRemoved( e : Event ) : void
		{
			setTimeout( function() : void
			{
				stage.focus = fld;
			}, 1 );
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

			if ( ctrl.isInTag( pos ) )
			{
				menuData = ctrl.getAllTypes();

				if ( menuData && menuData.length > 0 )
				{
					for ( i = 0; i < menuData.length; i++ )
					{
						menuData[ i ] = { label: menuData[ i ], value: menuData[ i ].toUpperCase() };
					}
				}

				if ( !menuData )
					menuData = new Vector.<Object>;

				menuData.push( { label: "attribute", value: "ATTRIBUTE" } );
			}
			else if ( ctrl.isInAttribute( pos ) )
			{
				menuData = ctrl.getAttributesList( pos );
				var eqStr : String = "=\"\"";

				if ( menuData && menuData.length > 0 )
				{
					for ( i = 0; i < menuData.length; i++ )
					{
						menuData[ i ] = { label: menuData[ i ], value: menuData[ i ] /*+ eqStr*/ };
					}
				}

			}

			if ( !menuData || menuData.length == 0 )
				return;

			showMenu( pos + 1 );

			if ( menuStr.length )
				filterMenu();
		}

		private var menuRefY : int;

		private function showMenu( index : int ) : void
		{
			var p : Point;
			menu.setListData( vectorToArray( menuData ) );
			menu.setSelectedIndex( 0 );

			p = fld.getPointForIndex( index );
			p.x += fld.scrollH;

			p = fld.localToGlobal( p );
			menuRefY = p.y;

			//menu.show(stage, p.x, p.y + 15);
			menu.show( fld, p.x, 0 );

			stage.addEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, false, 0, true );

			stage.focus = menu;
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