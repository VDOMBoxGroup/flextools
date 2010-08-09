package
{
	import events.TabEvent;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayList;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.events.ListEvent;
	
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	import spark.components.TabBar;
	import spark.events.IndexChangeEvent;
	import spark.skins.spark.ListSkin;
	import spark.skins.spark.TabBarSkin;

	public class TabNavigator extends SkinnableContainer
	{
		[SkinPart( required="true" )]
		public var tabBar : TabBar;

		private var _numTabs : int;

		[Bindable( event="selectedTabChanged" )]
		public function get selectedTab() : Tab
		{
			return tabBar.selectedItem as Tab;
		}

		public function set selectedTab( tab : Tab ) : void
		{
			tabBar.selectedItem = tab;
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

			tabBar.dataProvider.removeItemAt( index );
		}

		public function getTabAt( index : int ) : Tab
		{
			return tabBar.dataProvider.getItemAt( index ) as Tab;
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

		private function closeTabHandler( event : ListEvent ) : void
		{
			var index : int = event.rowIndex;

			if ( index >= 0 )
				removeTabAt( index );
		}

		private function tabBar_changeHandler( event : IndexChangeEvent ) : void
		{
			var oldIndex : int = event.oldIndex;
			var oldTab : Tab = getTabAt( oldIndex );

			var element : IVisualElement;

			var i : int;

			for ( i = 0; i < oldTab.numElements; i++ )
			{
				element = oldTab.getElementAt( i );
				element.visible = false;
				element.includeInLayout = false;
			}

			var newIndex : int = event.newIndex;
			var newTab : Tab = getTabAt( newIndex );

			for ( i = 0; i < newTab.numElements; i++ )
			{
				element = newTab.getElementAt( i );
				element.visible = true;
				element.includeInLayout = true;
			}
			
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
					
					while( prevTabIndex > 0 )
					{
						prevTab = tabBar.dataProvider.getItemAt( tIndex - 1 ) as Tab;
						
						if( prevTab.numElements == 0 )
						{
							prevTabIndex--;
							continue;
						}
						else
						{
							prevElement = prevTab.getElementAt( prevTab.numElements - 1 );
						}
					}
				}

				if( prevElement )
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