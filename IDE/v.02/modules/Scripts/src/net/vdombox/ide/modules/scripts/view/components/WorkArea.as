package net.vdombox.ide.modules.scripts.view.components
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import net.vdombox.components.tabNavigatorClasses.Tab;
	import net.vdombox.components.tabNavigatorClasses.TabNavigator;
	import net.vdombox.ide.common.events.WorkAreaEvent;
	import net.vdombox.ide.common.vo.ServerActionVO;

	public class WorkArea extends TabNavigator
	{
		
		private var _editors : Dictionary;
		
		public function WorkArea()
		{
			addEventListener( "selectedTabChanged", selectedTabChangedHandler );
			addEventListener( "tabAdded", numTabChangedHandler );
			addEventListener( "tabRemoved", numTabChangedHandler );
		}
		
		private function selectedTabChangedHandler( event : Event ) : void
		{
			// CHANGE
			dispatchEvent( new WorkAreaEvent( WorkAreaEvent.CHANGE ) );
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
		
		public function openEditor( objectVO : Object, actionVO : Object ) : ScriptEditor
		{
			var editor : ScriptEditor = new ScriptEditor();
			editor.percentHeight = 100;
			editor.percentWidth = 100;
			editor.actionVO = actionVO;
			editor.objectVO = objectVO;
			
			var tab : Tab = new Tab();
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
				delete _editors[ result ];
			
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
	}
}