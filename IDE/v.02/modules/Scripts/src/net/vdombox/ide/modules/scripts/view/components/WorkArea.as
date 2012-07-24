package net.vdombox.ide.modules.scripts.view.components
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.events.ListEvent;
	
	import net.vdombox.ide.common.events.TabEvent;
	import net.vdombox.ide.common.events.WorkAreaEvent;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.common.view.components.tabnavigator.Tab;
	import net.vdombox.ide.common.view.components.tabnavigator.TabNavigator;
	import net.vdombox.ide.modules.scripts.events.ScriptEditorEvent;
	import net.vdombox.ide.modules.scripts.view.ScriptsMediator;
	
	public class WorkArea extends TabNavigator
	{
		
		private var _editors : Dictionary;
		
		public function WorkArea()
		{
			addEventListener( "selectedTabChanged", selectedTabChangedHandler );
			addEventListener( "tabAdded", numTabChangedHandler );
			addEventListener( "tabRemoved", numTabChangedHandler );
			
			addEventListener( ScriptEditorEvent.SAVED, savedActionHandler, true, 0, true );
			addEventListener( ScriptEditorEvent.NOT_SAVED, notSavedActionHandler, true, 0, true );
		}
		
		private function selectedTabChangedHandler( event : Event ) : void
		{
			// CHANGE
			dispatchEvent( new WorkAreaEvent( WorkAreaEvent.CHANGE ) );
			if ( selectedEditor.scriptEditor )
				selectedEditor.scriptEditor.scriptAreaComponent.setFocus();
		}
		
		protected override function closeTabHandler( event : ListEvent ) : void
		{
			var index : int = event.rowIndex;
			
			if ( index >= 0 )
			{
				var tab : Tab = getTabAt( index );
				
				var scriptEditor : ScriptEditor = tab.getElementAt( 0 ) as ScriptEditor;
				
				if ( scriptEditor.actionVO && !scriptEditor.actionVO.saved )
				{
					var tabEvent : TabEvent = new TabEvent( TabEvent.ELEMENT_REMOVE );
					tabEvent.element = scriptEditor;
					tabEvent.index = index;
					dispatchEvent( tabEvent );	
				}
				else
				{
					closeTab( index );
				}
			}
			
		}
		
		public function closeTab( index : int ) : void
		{
			removeTabAt( index );
			
			dispatchEvent( new Event( "tabRemoved" ) );
			showTabElements( selectedTab );
			dispatchEvent( new Event( "selectedTabChanged" ) );
		}
		
		private function numTabChangedHandler( event : Event ) : void
		{
			if( tabBar.dataProvider && tabBar.dataProvider.length == 0 )
				return;
			
			var tab0 : Tab = tabBar.dataProvider.getItemAt( 0 ) as Tab;
			var tab1 : Tab
			
			if( tabBar.dataProvider.length == 1 )
			{
				tab0.closable = false;
			}
			else if( tabBar.dataProvider.length == 2 )
			{
				tab0.closable = true;
				
				tab1 = tabBar.dataProvider.getItemAt( 1 ) as Tab;
				if( tab1 )
					tab1.closable = true;
			}
		}
		
		private function savedActionHandler( event : ScriptEditorEvent ) : void
		{
			setSaveAction( true, event.target as ScriptEditor );
		}
		
		private function notSavedActionHandler( event : ScriptEditorEvent ) : void
		{
			setSaveAction( false, event.target as ScriptEditor );
		}
		
		public function openEditor( objectVO : Object, actionVO : Object ) : ScriptEditor
		{
			var editor : ScriptEditor = new ScriptEditor();
			editor.percentHeight = 100;
			editor.percentWidth = 100;
			editor.actionVO = actionVO;
			editor.objectVO = objectVO;
			
			var tab : Tab = new Tab();
			if ( actionVO is ServerActionVO )
				tab.label = actionVO.name + ':' + objectVO.name;
			else
				tab.label = actionVO.name;
			
			addTab( tab );
			
			tab.addElement( editor );
			
			if ( !_editors )
				_editors = new Dictionary( true );
			
			_editors[ editor ] = tab;
			
			selectedEditor = editor;
			
			return editor;
		}
		
		public function closeEditor( objectVO : Object ) : ScriptEditor
		{
			var result : ScriptEditor;
			var tab : Tab;
			
			result = getEditorByVO( objectVO );
			
			if ( result )
			{				
				delete _editors[ result ];
			}
			
			return result;
		}
		
		public function closeTabByAction( objectVO : Object ) : ScriptEditor
		{
			var result : ScriptEditor;
			var tab : Tab;
			
			result = getEditorByVO( objectVO );
			
			var index : int = getElementIndex( result );
			
			if ( result )
			{								
				tab = _editors[ result ];
				removeTab( tab );
		
				showTabElements( selectedTab );
			}
			
			return result;
		}
		
		public function getEditorByVO( objectVO : Object ) : ScriptEditor
		{
			var result : ScriptEditor;
			var editor : *;
			
			if ( !objectVO )
				return null;
			
			if ( objectVO is ServerActionVO )
			{
				for ( editor in _editors )
				{ 
					if ( editor.actionVO is ServerActionVO && editor.actionVO.id == objectVO.id )
					{
						result = editor;
						break;
					}
				}
			}
			else 
			{
				for ( editor in _editors )
				{ 
					if ( !(editor.actionVO is ServerActionVO) && editor.actionVO.name == objectVO.name )
					{
						result = editor;
						break;
					}
				}
			}
			
			return result;
		}
		
		public function closeAllEditors() : void
		{
			//			затычка нада разобраться в чем дело
			if (tabBar.dataProvider == null )
				return 
			
			var tab : Tab;
			while ( tabBar.dataProvider.length  > 0 ) 
			{
				tab = tabBar.dataProvider.getItemAt( 0 ) as Tab;
				removeTab( tab );
			}			
		}
		
		public function get selectedEditor() : ScriptEditor
		{
			var result : ScriptEditor;
			var editor : *;
			
			for ( editor in _editors )
			{
				if ( _editors[ editor ] == selectedTab )
				{
					result = editor as ScriptEditor;
					break;
				}
			}
			
			return result;
		}
		
		public function set selectedEditor( value : ScriptEditor ) : void
		{
			if ( !value )
				return;
			
			var tab : Tab;
			
			tab = _editors[ value ];
			
			if ( tab )
				selectedTab = tab;
		}
		
		public function setSaveAction( saved : Boolean, scriptEditor : ScriptEditor) : void
		{
			var tab : Tab= _editors[ scriptEditor ];
			if ( !tab ) 
				return;
			
			if ( !saved && tab.label.charAt(0) != '*')
				tab.label = "*" + tab.label;
			else if ( saved && tab.label.charAt(0) == '*' )
				tab.label = tab.label.slice( 1 );
			
		}
	}
}