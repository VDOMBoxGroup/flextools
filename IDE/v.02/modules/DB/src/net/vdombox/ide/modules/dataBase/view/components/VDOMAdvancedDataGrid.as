package net.vdombox.ide.modules.dataBase.view.components
{
	import flash.events.Event;

	import mx.collections.CursorBookmark;
	import mx.collections.IViewCursor;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.skins.halo.AdvancedDataGridHeaderHorizontalSeparator;
	import mx.skins.halo.DataGridColumnDropIndicator;
	import mx.skins.halo.DataGridColumnResizeSkin;
	import mx.skins.halo.DataGridHeaderSeparator;
	import mx.skins.spark.DataGridHeaderBackgroundSkin;
	import mx.skins.spark.DataGridSortArrow;

	import net.vdombox.ide.modules.dataBase.interfaces.ISearchable;
	import net.vdombox.ide.modules.dataBase.utils.WildcardUtils;

	public class VDOMAdvancedDataGrid extends AdvancedDataGrid implements ISearchable
	{

		[Embed( source = "assets/cursor_width.png" )]
		private var stretchCursor : Class;

		override public function stylesInitialized() : void
		{
			super.stylesInitialized();
			this.setStyle( "headerSeparatorSkin", DataGridHeaderSeparator );
			this.setStyle( "headerHorizontalSeparatorSkin", AdvancedDataGridHeaderHorizontalSeparator );
			this.setStyle( "headerBackgroundSkin", DataGridHeaderBackgroundSkin );
			this.setStyle( "columnDropIndicatorSkin", DataGridColumnDropIndicator );
			this.setStyle( "columnResizeSkin", DataGridColumnResizeSkin );
			this.setStyle( "headerSeparatorSkin", DataGridHeaderSeparator );

			this.setStyle( "headerColors", [ 0xFFFFFF, 0xE6E6E6 ] );
			this.setStyle( "stretchCursor", stretchCursor );

			/*
			   this.setStyle( "headerStyleName", "advancedDataGridStyles" );
			   this.setStyle( "headerDragProxyStyleName", "headerDragProxyStyle" );
			 */

			this.setStyle( "sortArrowSkin", DataGridSortArrow );

			this.setStyle( "alternatingItemColors", [ 0xF7F7F7, 0xFFFFFF ] );

			this.setStyle( "verticalGridLineColor", 0xCCCCCC );

			this.setStyle( "sortFontFamily", "Verdana" );
			this.setStyle( "sortFontWeight", "normal" );

		}

		/**
		 * @copy com.iwobanas.core.ISearchable#found
		 */
		[Bindable( "searchResultChanged" )]
		public function get found() : Boolean
		{
			return _found;
		}

		/**
		 * @private
		 * Storage for current found value.
		 */
		protected var _found : Boolean;

		/**
		 * @private
		 * Set <code>found</code> value and dispatch "searchResultChanged" event if needed.
		 */
		protected function setFound( value : Boolean ) : void
		{
			if ( value != _found )
			{
				_found = value;
				dispatchEvent( new Event( "searchResultChanged" ) );
			}
		}


		/**
		 * @copy com.iwobanas.core.ISearchable#searchString
		 */
		[Bindable( "searchParamsChanged" )]
		public function get searchString() : String
		{
			return _searchString;
		}

		/**
		 * @private
		 * Storage for current searchString value.
		 */
		protected var _searchString : String;


		/**
		 * @copy com.iwobanas.core.ISearchable#searchExpression
		 */
		[Bindable( "searchParamsChanged" )]
		public function get searchExpression() : RegExp
		{
			return _searchExpression;
		}

		/**
		 * @private
		 * Storage for current searchExpression value.
		 */
		protected var _searchExpression : RegExp;


		/**
		 * Find item matching given wildcard and assign first match to selectedItem.
		 *
		 * <p>Unlike standard findSting() function this functions searches labels of all visible columns.
		 * It also supports wildcards containing <code>"?"</code> or <code>"*"</code> characters
		 * interpreted as any character or any character sequence respectively.</p>
		 *
		 * <p>The search starts at <code>selectedIndex</code> location and if match is find stops immediately.
		 * If it reaches the end of the data provider it starts over from the beginning.
		 * If you need to navigate between matches user <code>findNext() / findPrevious()</code> functions.</p>
		 *
		 * @param wildcard text to search for
		 * @param caseInsensitive flag indicating whether search should be case insensitive
		 * @return <code>true</code> if text was fond or <code>false</code> if not
		 *
		 * @see com.iwobanas.core.ISearchable
		 */
		public function find( wildcard : String, caseInsensitive : Boolean = true ) : Boolean
		{
			if ( !wildcard )
			{
				_searchString = null;
				_searchExpression = null;
				dispatchEvent( new Event( "searchParamsChanged" ) );
				setFound( false );
				updateList();
				return false;
			}
			_searchString = wildcard;
			_searchExpression = WildcardUtils.wildcardToRegExp( wildcard, caseInsensitive ? "ig" : "g" );
			dispatchEvent( new Event( "searchParamsChanged" ) );
			return findItem();
		}

		/**
		 * @copy com.iwobanas.core.ISearchable#findNext()
		 */
		public function findNext() : Boolean
		{
			return findItem( true, true );
		}

		/**
		 * @copy com.iwobanas.core.ISearchable#findPrevious()
		 */
		public function findPrevious() : Boolean
		{
			return findItem( false, true );
		}

		/**
		 * @private
		 * Iterate through data provider and check if it matches search condition by calling <code>matchItem()</code>.
		 * If matching item is found set <code>selectedIndex</code> to point to this item and scroll the content
		 * so that selected item can be seen.
		 *
		 * @param forward determines if items should be searched forward (from top to bottom) or backward.
		 * @param skip determines if search should start at <code>selectedIndex</code> or one item after/before.
		 */
		protected function findItem( forward : Boolean = true, skip : Boolean = false ) : Boolean
		{
			var cursor : IViewCursor = collection.createCursor();
			var itemFound : Boolean = false;

			if ( selectedIndex > 0 )
			{
				cursor.seek( CursorBookmark.FIRST, selectedIndex );
			}
			else
			{
				cursor.seek( CursorBookmark.FIRST );
			}

			if ( skip )
			{
				if ( forward )
				{
					cursor.moveNext();
				}
				else
				{
					cursor.movePrevious()
				}
			}

			// iterate through collection, note that "i" is not current index
			for ( var i : int = 0; i < collection.length; i++ )
			{
				if ( matchItem( cursor.current ) )
				{
					itemFound = true;
					break;
				}

				if ( forward )
				{
					cursor.moveNext();
				}
				else
				{
					cursor.movePrevious();
				}

				if ( cursor.afterLast )
				{
					cursor.seek( CursorBookmark.FIRST );
				}
				if ( cursor.beforeFirst )
				{
					cursor.seek( CursorBookmark.LAST );
				}
			}

			if ( itemFound )
			{
				selectedItem = cursor.current;

				//scrollToIndex(selectedIndex); scrolls the content so that selected item is always the first item
				// we wanted selected item to be at the bottom if we scroll downward so scrollToIndex is not used.
				if ( selectedIndex < verticalScrollPosition )
				{
					verticalScrollPosition = selectedIndex;
				}
				if ( selectedIndex > verticalScrollPosition + rowCount - lockedRowCount - 2 ) // 1 for header + 1 for last row
				{
					verticalScrollPosition = selectedIndex - rowCount + lockedRowCount + 2;
				}

			}
			setFound( itemFound );

			return itemFound;
		}

		/**
		 * @private
		 * Mathes search parameters against item.
		 *
		 * @param item item to be matched
		 * @return <code>true</code> if item matches search parameters, <code>false</code> otherwise.
		 */
		protected function matchItem( item : Object ) : Boolean
		{
			if ( !_searchExpression )
				return false;

			for each ( var column : AdvancedDataGridColumn in columns )
			{
				if ( column.visible && _searchExpression.test( column.itemToLabel( item ) ) )
				{
					_searchExpression.lastIndex = 0;
					return true;
				}
			}
			return false;
		}
	}
}
