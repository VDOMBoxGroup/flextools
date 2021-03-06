package net.vdombox.ide.modules.wysiwyg.model.business
{
	import com.zavoo.svg.SVGViewer;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.collections.IViewCursor;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.VectorCollection;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.rpc.events.FaultEvent;
	import mx.utils.StringUtil;
	import mx.utils.UIDUtil;

	/**
	 * Dos not used !?!
	 * @author andreev ap
	 *
	 */
	public class RenderManager implements IEventDispatcher
	{
		private static var instance : RenderManager;

		public static const styleList : Array = [ [ "opacity", "backgroundAlpha" ], [ "backgroundcolor", "backgroundColor" ], [ "backgroundimage", "backgroundImage" ], [ "backgroundrepeat", "backgroundRepeat" ], [ "borderwidth", "borderThickness" ], [ "bordercolor", "borderColor" ], [ "color", "color" ], [ "fontfamily", "fontFamily" ], [ "fontsize", "fontSize" ], [ "fontweight", "fontWeight" ], [ "fontstyle", "fontStyle" ], [ "textdecoration", "textDecoration" ], [ "textalign", "textAlign" ], [ "align", "horizontalAlign" ], [ "valign", "verticalAlign" ] ];

		public static const propertyList : Array = [ [ "left", "x" ], [ "top", "y" ], [ "width", "width" ], [ "height", "height" ], [ "colspan", "colSpan" ], [ "rowspan", "rowSpan" ], ];

		//		private var soap : SOAP = SOAP.getInstance();
		//		private var dataManager : DataManager = DataManager.getInstance();
		//		private var dispatcher : EventDispatcher = new EventDispatcher();
		//		private var fileManager : FileManager = FileManager.getInstance();
		//		private var cacheManager : CacheManager = CacheManager.getInstance();

		private var applicationId : String;

		private var rootContainer : Container;

		private var items : VectorCollection = new VectorCollection();

		private var cursor : IViewCursor;

		private var lockedItems : Object = {};

		private var lastKey : String;

		/**
		 *
		 * @return instance of RenderManager class ( Singleton )
		 *
		 */
		public static function getInstance() : RenderManager
		{
			if ( !instance )
				instance = new RenderManager();

			return instance;
		}

		public function RenderManager()
		{
			if ( instance )
				throw new Error( "Instance already exists." );

			//		soap.render_wysiwyg.addEventListener( SOAPEvent.RESULT, renderWysiwygOkHandler );
			//			dataManager.addEventListener( DataManagerEvent.UPDATE_ATTRIBUTES_BEGIN, updateAttributesBeginHandler );

			cursor = items.createCursor();

			items.sort = new Sort();
			items.sort.fields = [ new SortField( "itemId" ) ];
			items.refresh();
		}

		public function init( destContainer : Container, applicationId : String = null ) : void
		{
			//			soap.render_wysiwyg.addEventListener( SOAPEvent.RESULT, renderWysiwygOkHandler );
			//			soap.render_wysiwyg.addEventListener( FaultEvent.FAULT, renderWysiwygFaultHandler );

			rootContainer = destContainer;

			//			if( !applicationId )
			//				this.applicationId = dataManager.currentApplicationId;

		}

		public function createItem( itemId : String, parentId : String = "" ) : void
		{
			if ( !applicationId )
				return;

			if ( !parentId )
			{

				rootContainer.removeAllChildren();
				items.removeAll();
			}

			//		createItemDescription( itemId, parentId );

			//			lastKey = soap.render_wysiwyg( applicationId, itemId, parentId, 0 );
		}

		public function updateItem( itemId : String /* , parentId : String */ ) : void
		{
			if ( !applicationId )
				return;

			var itemDescription : ItemDescription = getItemDescriptionById( itemId );
			//			lastKey = soap.render_wysiwyg( applicationId, itemId, itemDescription.parentId, 0 );
		}

		public function deleteItem( itemId : String ) : void
		{
			if ( !applicationId )
				return;

			items.filterFunction = function( item : Object ) : Boolean
			{
				return ( item.fullPath.indexOf( itemId ) != -1 );
			}

			items.refresh();

			cursor.findAny( { itemId: itemId } );

			if ( !cursor.current )
				return;

			var currentItem : Container = ItemDescription( cursor.current ).item as Container;

			if ( currentItem && currentItem.parent )
				currentItem.parent.removeChild( currentItem );

			items.removeAll();

			items.filterFunction = null;
			items.refresh();
		}

		public function lockItem( itemId : String ) : void
		{
			if ( !itemId && lockedItems[ itemId ] )
				return;

			var itemDescription : ItemDescription = getItemDescriptionById( itemId );
			if ( itemDescription && itemDescription.item )
			{
				IItem( itemDescription.item ).waitMode = true;
				lockedItems[ itemId ] = "";
			}
		}

		public function getItemById( itemId : String ) : IItem
		{
			if ( itemId )
			{

				var itemDescription : ItemDescription = getItemDescriptionById( itemId );

				if ( itemDescription )
					return itemDescription.item;
			}

			return null;
		}

		public function hideItemById( objectId : String, visible : Boolean = false ) : IItem
		{
			var itemDescription : ItemDescription = getItemDescriptionById( objectId );
			var item : IItem;

			if ( itemDescription )
			{
				item = itemDescription.item;
				UIComponent( item ).visible = false;
			}

			return item;
		}

		public function getItemDescriptionById( itemId : String ) : ItemDescription
		{
			if ( !itemId )
				return null;

			var searchObject : Object = { itemId: itemId };

			var isResult : Boolean = cursor.findAny( searchObject );
			var result : ItemDescription;

			if ( isResult )
				result = ItemDescription( cursor.current );

			return result;
		}

		public function renderItem( parentId : String, itemXMLDescription : XML ) : UIComponent
		{
			var itemId : String = itemXMLDescription.@id[ 0 ];

			deleteItemChildren( itemId );

			var item : UIComponent = render( parentId, itemXMLDescription );

			return item;
		}

		private function deleteItemChildren( itemId : String ) : void
		{
			if ( !itemId )
				return;

			var itemDescription : ItemDescription = getItemDescriptionById( itemId );
			var result : Container;

			if ( !itemDescription )
				return;

			if ( itemDescription.item )
			{
				result = itemDescription.item as Container;
				result.removeAllChildren();
			}

			items.filterFunction = function( item : Object ) : Boolean
			{
				return ( item.fullPath.indexOf( itemId + "." ) != -1 );
			}
			items.refresh();
			items.removeAll();

			items.filterFunction = null;
			items.refresh();
		}

		private function createItemDescription( itemId : String = "", parentId : String = "" ) : ItemDescription
		{
			var fullPath : String = "";
			var staticFlag : String = "none";

			if ( !itemId || itemId == "" )
			{
				itemId = UIDUtil.createUID();
				staticFlag = "self";
			}

			if ( !parentId || parentId == "" )
			{

				fullPath = itemId;
			}
			else
			{

				fullPath = getItemDescriptionById( parentId ).fullPath;
				fullPath = fullPath + "." + itemId;
			}

			var itemDescription : ItemDescription = new ItemDescription();

			itemDescription.itemId = itemId;
			itemDescription.staticFlag = staticFlag;
			itemDescription.parentId = parentId;
			itemDescription.fullPath = fullPath;
			itemDescription.zindex = 0;
			itemDescription.hierarchy = 0;
			itemDescription.order = 0;
			itemDescription.item = null;

			items.addItem( itemDescription );

			return itemDescription;
		}

		private function updateItemDescription( itemId : String, itemXMLDescription : XML ) : ItemDescription
		{
			var itemDescription : ItemDescription = getItemDescriptionById( itemId );
			var parentDescription : ItemDescription;
			var newStaticFlag : String;

			if ( !itemDescription )
				return null;

			parentDescription = getItemDescriptionById( itemDescription.parentId );
			newStaticFlag = itemDescription.staticFlag;

			if ( parentDescription )
			{
				if ( parentDescription.staticFlag == "children" || parentDescription.staticFlag == "all" )
					newStaticFlag = "all";

				else if ( itemXMLDescription.@contents == "static" )
					newStaticFlag = "children";

			}
			else if ( itemXMLDescription.@contents == "static" )
				newStaticFlag = "children";

			itemDescription.zindex = uint( itemXMLDescription.@zindex );
			itemDescription.hierarchy = uint( itemXMLDescription.@hierarchy );
			itemDescription.order = uint( itemXMLDescription.@order );
			itemDescription.staticFlag = newStaticFlag;
			itemDescription.XMLPresentation = itemXMLDescription;

			return itemDescription;
		}

		private function sortItems( parentId : String ) : Array
		{
			items.filterFunction = function( item : Object ) : Boolean
			{
				return item.parentId == parentId && !ItemDescription( item ).item.isStatic;
			}

			items.sort.fields = [ new SortField( "zindex" ), new SortField( "hierarchy" ), new SortField( "order" ) ];

			items.refresh();

			var arrayOfSortedItems : Array = [];

			for each ( var collectionItem : Object in items )
			{

				arrayOfSortedItems.push( collectionItem.item );
			}

			items.filterFunction = null;
			items.sort.fields = [ new SortField( "itemId" ) ];

			items.refresh();

			if ( arrayOfSortedItems.length > 0 )
				return arrayOfSortedItems
			else
				return []

		}

		//		private function updateAttributesBeginHandler( event : DataManagerEvent ) : void
		//		{
		//			if( lockedItems[event.objectId] !== null )
		//				lockedItems[event.objectId] = event.key;
		//		}

		private function arrangeItem( itemId : String ) : void
		{
			var arrayOfItems : Array = sortItems( itemId );

			if ( !arrayOfItems )
				return;

			var collectionItem : UIComponent;
			var indexArray : Array = [];

			for each ( collectionItem in arrayOfItems )
			{
				if ( collectionItem.parent )
				{
					indexArray.push( collectionItem.parent.getChildIndex( collectionItem ) );
				}
			}

			indexArray.sort( Array.NUMERIC );

			var count : uint = 0;
			for each ( collectionItem in arrayOfItems )
			{
				if ( collectionItem.parent )
				{
					collectionItem.parent.setChildIndex( collectionItem, indexArray[ count ] );
					count++;
				}
			}
		}

		private function insertEditableAttributes( parentItem : IItem, currentElement : UIComponent, editableAttributes : * ) : void
		{
			if ( parentItem && parentItem.isStatic )
				return;

			var item : IItem;
			var str : String = "";
			var atrArray : Array = [];

			if ( currentElement is IItem && IItem( currentElement ).objectId )
				item = IItem( currentElement );
			else
				item = parentItem;

			if ( !item )
				return;

			if ( editableAttributes is XML )
			{
				if ( !editableAttributes.hasOwnProperty( "@editable" ) )
					return;

				str = editableAttributes.@editable.toString();
			}
			else if ( editableAttributes is String )
			{
				str = editableAttributes;
			}
			else if ( editableAttributes is Array )
			{
				item.editableAttributes = item.editableAttributes.concat( editableAttributes as Array );
				return;
			}

			str = StringUtil.trimArrayElements( str, "," );

			if ( str.length != 0 )
			{
				atrArray = str.split( "," );
			}

			var attributes : Object = {};

			for each ( var atrName : String in atrArray )
			{
				attributes[ atrName ] = "";
			}

			item.editableAttributes.push( { attributes: attributes, sourceObject: currentElement } );
		}

		private function applyStyles( item : UIComponent, itemXMLDescription : XML ) : void
		{
			var _style : Object = {};
			var hasStyle : Boolean = false;

			item.styleName = "WYSIWYGItem";


			var xmlList : XMLList;
			for each ( var attribute : Array in styleList )
			{
				xmlList = itemXMLDescription.attribute( attribute[ 0 ] );
				if ( xmlList.length() > 0 )
				{
					_style[ attribute[ 1 ] ] = xmlList[ 0 ].toString().toLowerCase();
					hasStyle = true;
				}
			}

			if ( !hasStyle )
				return;

			if ( _style.hasOwnProperty( "backgroundColor" ) && !_style.hasOwnProperty( "backgroundAlpha" ) )
				// FIXME : Сделать правильное значение -> 1.0 не работает
				_style[ "backgroundAlpha" ] = 100;

			if ( _style.hasOwnProperty( "borderColor" ) )
				_style[ "borderStyle" ] = "solid";

			if ( _style.hasOwnProperty( "textDecoration" ) )
				if ( !( _style[ "textDecoration" ] != "none" || _style[ "textDecoration" ] != "underline" ) )
				{
					_style[ "textDecoration" ] = "none";
				}

			for ( var atrName : String in _style )
			{
				if ( _style[ atrName ] != "" )
					item.setStyle( atrName, _style[ atrName ] )
			}

			//repeat, no-repeat, repeat-x, repeat-y
			//item.setStyle( "repeatedBackgroundImage", "beb4fd88-7fc2-4079-8a82-ffe1b9743352" )
			//item.setStyle( "backgroundRepeat", "repeat" );
		}

		private function applyProperties( item : UIComponent, itemXMLDescription : XML ) : void
		{
			var _properties : Object = {};
			var hasProperties : Boolean = false;

			var xmlList : XMLList;
			for each ( var attribute : Array in propertyList )
			{
				xmlList = itemXMLDescription.attribute( attribute[ 0 ] );
				if ( xmlList.length() > 0 )
				{
					_properties[ attribute[ 1 ] ] = xmlList[ 0 ].toString();
					hasProperties = true;
				}
			}

			for ( var atrName : String in _properties )
			{
				item[ atrName ] = _properties[ atrName ];
			}

			if ( !_properties[ "width" ] )
				item.explicitWidth = NaN;

			if ( !_properties[ "height" ] )
				item.explicitHeight = NaN;
		}

		private function render( parentId : String, itemXMLDescription : XML ) : UIComponent
		{
			var itemName : String = itemXMLDescription.name().localName;
			var item : UIComponent;
			var itemId : String = "";
			var itemDescription : ItemDescription;

			var parentItemDescription : ItemDescription = getItemDescriptionById( parentId );
			var parentItem : IItem;

			var hasChildren : Boolean = false;
			var editableAttributes : *;

			var isStatic : Boolean = false;

			/*
			   if( parentId == "static" )
			   {
			   isStatic = true;
			   }
			   else
			 */
			if ( parentItemDescription && parentItemDescription.item )
			{
				parentItem = parentItemDescription.item;
				isStatic = parentItemDescription.staticFlag != "none" ? true : false;
			}

			switch ( itemName )
			{
				case "container":
				{
				}

				case "table":
				{

				}

				case "row":
				{

				}

				case "cell":
				{
					if ( !isStatic )
						itemId = itemXMLDescription.@id[ 0 ];

					itemDescription = getItemDescriptionById( itemId );

					if ( itemDescription && itemDescription.item )
					{
						item = itemDescription.item as UIComponent;
						Container( item ).removeAllChildren();
						item.graphics.clear();
						itemDescription.item.editableAttributes = [];
					}
					else
					{
						itemDescription = createItemDescription( itemId, parentId );
						itemId = itemDescription.itemId;

						item = insertItem( itemName, itemId ) as UIComponent;
					}

					itemDescription = updateItemDescription( itemId, itemXMLDescription );

					if ( !itemDescription || itemDescription.staticFlag == "self" || itemDescription.staticFlag == "all" )
						IItem( item ).isStatic = true;

					hasChildren = true;
					break;
				}

				case "text":
				{
					if ( itemXMLDescription.@editable[ 0 ] && parentItem && !parentItem.isStatic )
					{
						item = new EditableText();
						item.setStyle( "borderStyle", "none" );
						insertEditableAttributes( parentItem, item, itemXMLDescription );
					}
					else
					{
						item = new SimpleText();
					}

					var text : String = itemXMLDescription.text().toString();

					item[ "text" ] = text;
					item[ "selectable" ] = false;

					break;
				}

				case "htmltext":
				{
					item = new EditableHTML();

					item[ "paintsDefaultBackground" ] = false;

					var HTMLText : String = itemXMLDescription.text().toString();

					item.setStyle( "backgroundAlpha", .0 );

					if ( HTMLText == "" )
						HTMLText = ""; //"<div>simple text</div>";

					HTMLText = "<html>" + "<head>" + "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />" + "</head>" + "<body style=\"margin : 0px;\" >" + HTMLText + "</body>" + "</html>";

					item[ "htmlText" ] = HTMLText;

					break;
				}

				case "svg":
				{
					try
					{
						item = new SVGViewer();
						editableAttributes = SVGViewer( item ).setXML( itemXMLDescription );
					}
					catch ( error : Error )
					{
						item = null;
					}

					break;
				}
			}

			if ( !editableAttributes )
				editableAttributes = itemXMLDescription;

			insertEditableAttributes( parentItem, item, editableAttributes );

			if ( !item )
				return null;

			// FIXME : Применять ли свойства к SVG или нет?
			if ( !( item is SVGViewer ) )
			{
				applyProperties( item, itemXMLDescription );
				applyStyles( item, itemXMLDescription );
			}

			if ( !hasChildren )
				return item;

			var childList : XMLList = itemXMLDescription.*;
			var graphArr : Array = [];
			var parId : String = itemId;
			var elm : UIComponent;

			//		if( itemXMLDescription.@contents == "static" )
			//			parId = "static";
			//		else 
			//		if( itemId )
			//		parId = itemId;
			//		else
			//			parId = parentId;

			for each ( var child : XML in childList )
			{
				if ( child.nodeKind() == "element" )
				{
					elm = render( parId, child );

					if ( !( elm is IItem ) || IItem( elm ).isStatic )
						graphArr.push( elm );
				}
			}

			var length : uint = graphArr.length;
			var i : uint;

			for ( i = 0; i < length; i++ )
			{
				if ( graphArr[ i ] )
				{
					item.addChild( graphArr[ i ] );
				}
			}

			var itemArr : Array = sortItems( itemId );
			length = itemArr.length;
			i = 0;

			for ( i = 0; i < length; i++ )
			{
				item.addChild( itemArr[ i ] );
			}

			return item;
		}

		private function insertItem( itemName : String, itemId : String ) : IItem
		{
			var itemDescription : ItemDescription;
			var isStatic : Boolean = false;

			itemDescription = getItemDescriptionById( itemId );

			//		if( !itemDescription )
			//			return null

			if ( itemDescription && itemDescription.item && Container( itemDescription.item ).parent )
				return itemDescription.item;

			var container : IItem;

			switch ( itemName )
			{
				case "container":
				{
					container = new Item( itemId );
					break;
				}
				case "table":
				{
					container = new Table( itemId );
					Table( container ).setStyle( "horizontalGap", 0 );
					Table( container ).setStyle( "verticalGap", 0 );
					break;
				}
				case "row":
				{
					container = new TableRow( itemId );
					TableRow( container ).percentWidth = 100;
					TableRow( container ).percentHeight = 100;
					TableRow( container ).minHeight = 10;
					break;
				}
				case "cell":
				{
					container = new TableCell( itemId );
					TableCell( container ).minWidth = 10;
					TableCell( container ).minHeight = 10;
					break;
				}

			}

			container.editableAttributes = [];

			if ( itemDescription )
				itemDescription.item = container;

			return container;
		}

		//		private function renderWysiwygOkHandler( event : SOAPEvent ) : void
		//		{
		//			var itemXMLDescription : XML = event.result.Result.*[ 0 ];
		//			var itemId : String = itemXMLDescription.@id[ 0 ];
		//			var parentId : String = event.result.ParentID[ 0 ];
		//			
		//			if( !itemId )
		//				return;
		//			
		//			var key : String = event.result.Key[0];
		//			
		//			if( key != lastKey )
		//				return;
		//			
		//			if( lockedItems[itemId] && lockedItems[itemId] != key )
		//				return;
		//			
		//			renderItem( parentId, itemXMLDescription );
		//		}

		private function renderWysiwygFaultHandler( event : FaultEvent ) : void
		{
			var dummy : * = "" // FIXME remove dummy;
		}

		/**
		 * @private
		 */
		public function addEventListener( type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false ) : void
		{
			dispatcher.addEventListener( type, listener, useCapture, priority );
		}

		/**
		 * @private
		 */
		public function dispatchEvent( evt : Event ) : Boolean
		{
			return dispatcher.dispatchEvent( evt );
		}

		/**
		 * @private
		 */
		public function hasEventListener( type : String ) : Boolean
		{
			return dispatcher.hasEventListener( type );
		}

		/**
		 * @private
		 */
		public function removeEventListener( type : String, listener : Function, useCapture : Boolean = false ) : void
		{
			dispatcher.removeEventListener( type, listener, useCapture );
		}

		/**
		 * @private
		 */
		public function willTrigger( type : String ) : Boolean
		{
			return dispatcher.willTrigger( type );
		}
	}
}
