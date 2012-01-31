package net.vdombox.ide.common.view.components.tabnavigator
{
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.IVisualElement;
	import mx.events.ListEvent;
	
	import net.vdombox.ide.common.events.TabEvent;
	import net.vdombox.ide.common.view.skins.tabnavigator.TabNavigatorSkin;
	
	import spark.components.SkinnableContainer;
	import spark.components.TabBar;
	import spark.events.IndexChangeEvent;
	
	public class TabNavigator extends SkinnableContainer
	{
		public function TabNavigator()
		{
			setStyle( "skinClass", net.vdombox.ide.common.view.skins.tabnavigator.TabNavigatorSkin );
		}
		
		[SkinPart( required="true" )]
		public var tabBar : TabBar;
		
		private var _numTabs : int;
		
		private var historyStack : Array;
		
		[Bindable( event="selectedTabChanged" )]
		public function get selectedTab() : Tab
		{
			return tabBar.selectedItem as Tab;
		}
		
		private function get isFirstTab() : Boolean
		{
			return tabBar.dataProvider && tabBar.dataProvider.length == 1;
		}
			
		public function set selectedTab( tab : Tab ) : void
		{
			var currentTab : Tab = tabBar.selectedItem as Tab;
			
			if ( currentTab == tab )
				return;
			
			if ( currentTab )
				hideTabElements( tabBar.selectedItem as Tab );
			
			tabBar.selectedItem = tab;
			
			showTabElements( tab );
			
			updateHistory()
			
			dispatchEvent( new Event( "selectedTabChanged" ) );
		}
		
		public function addTab( tab : Tab ) : Tab
		{
			
			if ( !tabBar )
				throw new Error( "Tab bar not initialized" );
			
			if ( !tabBar.dataProvider )
				tabBar.dataProvider = new ArrayList();
			
			tab.addEventListener( TabEvent.ELEMENT_ADD, tab_elementAdd, false, 0, true );
			tab.addEventListener( TabEvent.ELEMENT_REMOVE, tab_elementRemove, false, 0, true );
			
			tabBar.dataProvider.addItem( tab );
			
			if( tabBar.selectedIndex == -1 )
				tabBar.selectedIndex = 0;
			
			dispatchEvent( new Event( "tabAdded" ) );
			
			updateHistory();
			
			return tab;
		}
		
		public function removeTab( tab : Tab ) : void
		{
			if ( !tabBar.dataProvider || tabBar.dataProvider.length <= 0 )
				return;
			
			var index : int = tabBar.dataProvider.getItemIndex( tab );
			
			if ( index != -1 )
				removeTabAt( index );
		}
		
		public function removeTabAt( index : uint ) : void
		{
			if ( !tabBar.dataProvider || tabBar.dataProvider.length <= 0 )
				return;
			
			var tab : Tab = getTabAt( index );
			
			var element : IVisualElement;
			
			var i : int;
			
			for ( i = 0; i < tab.numElements; i++ )
			{
				element = tab.getElementAt( i );
				
				if ( getElementIndex( element ) != -1 )
					removeElement( element );
			}
			
			if ( historyStack && historyStack.length > 0 )
			{
				var historyIndex : int = historyStack.indexOf( tab );
				
				if ( historyIndex != -1 )
					historyStack.splice( historyIndex, 1 );
			}
			
			if ( selectedTab == tab && historyStack.length > 0 )
				selectedTab = historyStack[ historyStack.length - 1 ];
			
			tabBar.dataProvider.removeItemAt( index );
			
		}
		
		public function getTabAt( index : int ) : Tab
		{
			return tabBar.dataProvider.getItemAt( index ) as Tab;
		}
		
		public function getTabByID( id : String ) : Tab
		{
			var result : Tab;
			var tab : Tab;
			
			if ( !tabBar.dataProvider )
				return result;
			
			for ( var i : int = 0; i < tabBar.dataProvider.length; i++ )
			{
				tab = tabBar.dataProvider.getItemAt( i ) as Tab;
				
				if ( tab.id == id )
				{
					result = tab;
					break;
				}
			}
			
			return result;
		}
		
		override protected function partAdded( partName : String, instance : Object ) : void
		{
			super.partAdded( partName, instance );
			
			if ( instance == tabBar )
			{
				tabBar.addEventListener( TabBarButton.CLOSE_TAB, closeTabHandler, false, 0, true );
				tabBar.addEventListener( IndexChangeEvent.CHANGE, tabBar_changeHandler, false, 0, true );
			}
		}
		
		override protected function partRemoved( partName : String, instance : Object ) : void
		{
			super.partRemoved( partName, instance );
			
			if ( instance == tabBar )
				tabBar.removeEventListener( TabBarButton.CLOSE_TAB, closeTabHandler );
		}
		
		private function showTabElements( tab : Tab ) : void
		{
			var element : IVisualElement;
			var i : int;
			
			if ( !tab )
				return;
			
			for ( i = 0; i < tab.numElements; i++ )
			{
				element = tab.getElementAt( i );
				element.visible = true;
				element.includeInLayout = true;
			}
		}
		
		private function hideTabElements( tab : Tab ) : void
		{
			var element : IVisualElement;
			var i : int;
			
			if ( !tab )
				return;
			
			for ( i = 0; i < tab.numElements; i++ )
			{
				element = tab.getElementAt( i );
				element.visible = false;
				element.includeInLayout = false;
			}
		}
		
		private function updateHistory() : void
		{
			if ( !selectedTab )
				return;
			
			if ( !historyStack )
				historyStack = [];
			
			var tabHistoryIndex : int = historyStack.indexOf( selectedTab );
			
			if ( tabHistoryIndex != -1 && tabHistoryIndex != historyStack.length - 1 )
			{
				historyStack.splice( tabHistoryIndex, 1 );
				historyStack.push( selectedTab );
			}
			else if ( tabHistoryIndex == -1 )
			{
				historyStack.push( selectedTab );
			}
		}
		
		private function closeTabHandler( event : ListEvent ) : void
		{
			var index : int = event.rowIndex;
			
			if ( index >= 0 )
				removeTabAt( index );
			
			dispatchEvent( new Event( "tabRemoved" ) );
			
			showTabElements( selectedTab );
			
			dispatchEvent( new Event( "selectedTabChanged" ) );
		}
		
		private function tabBar_changeHandler( event : IndexChangeEvent ) : void
		{
			var oldIndex : int = event.oldIndex;
			var oldTab : Tab = getTabAt( oldIndex );
			
			var newIndex : int = event.newIndex;
			var newTab : Tab = getTabAt( newIndex );
			
			hideTabElements( oldTab );
			showTabElements( newTab );
			
			updateHistory();
			
			dispatchEvent( new Event( "selectedTabChanged" ) );
		}
		
		private function tab_elementAdd( event : TabEvent ) : void
		{
			var tab : Tab = event.target as Tab;
			
			var tIndex : int = tabBar.dataProvider.getItemIndex( tab );
			
			var index : int = event.index;
			
			var newElementIndex : int;
			
			var prevTab : Tab;
			var prevTabIndex : int;
			var prevElement : IVisualElement;
			
			if ( tIndex == 0 && index == 0 )
			{
				newElementIndex = 0;
			}
			else
			{
				if ( index > 0 )
				{
					prevElement = tab.getElementAt( index - 1 );
				}
				else if ( tIndex > 0 )
				{
					prevTabIndex = tIndex - 1;
					
					while ( prevTabIndex > 0 )
					{
						prevTab = tabBar.dataProvider.getItemAt( tIndex - 1 ) as Tab;
						
						if ( prevTab.numElements == 0 )
						{
							prevTabIndex--;
							continue;
						}
						else
						{
							prevElement = prevTab.getElementAt( prevTab.numElements - 1 );
							break;
						}
					}
				}
				
				if ( prevElement )
					newElementIndex = contentGroup.getElementIndex( prevElement ) + 1;
				else
					newElementIndex = 0
			}
			
			if ( tabBar.selectedIndex != tIndex )
				event.element.visible = false;
			
			addElementAt( event.element, newElementIndex );
		}
		
		private function tab_elementRemove( event : TabEvent ) : void
		{
		}
	}
}