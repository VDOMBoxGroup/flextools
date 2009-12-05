package vdom.components.wysiwyg.containers
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.Label;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;

	import vdom.containers.IItem;
	import vdom.controls.IToolBar;
	import vdom.controls.ImageToolBar;
	import vdom.controls.RichTextToolBar;
	import vdom.controls.TextToolBar;
	import vdom.events.RenderManagerEvent;
	import vdom.events.ResizeManagerEvent;
	import vdom.events.WorkAreaEvent;
	import vdom.managers.DataManager;
	import vdom.managers.RenderManager;
	import vdom.managers.ResizeManager;
	import vdom.managers.VdomDragManager;
	import vdom.utils.DisplayUtils;

	use namespace mx_internal;

	public class WorkArea extends VBox
	{
		private var dataManager : DataManager = DataManager.getInstance();
		private var renderManager : RenderManager = RenderManager.getInstance();
		private var resizeManager : ResizeManager = ResizeManager.getInstance();

		private var _pageId : String;
		private var _objectId : String;

		private var bPageIdChanged : Boolean = false;
		private var bObjectIdChanged : Boolean = false;

		private var selectedObject : Container;
		private var focusedObject : Container;
		private var contentHolder : Canvas;

		private var _contentToolbar : IToolBar;
		private var showed : Boolean;

		public function WorkArea()
		{
			super();

			addEventListener( FlexEvent.SHOW, showHandler );
			addEventListener( FlexEvent.HIDE, hideHandler )
		}

		public function set pageId( value : String ) : void
		{
			if ( showed && value != _pageId )
			{
				bPageIdChanged = true;
				invalidateProperties();
			}

			_pageId = value;
		}

		public function set objectId( value : String ) : void
		{
			if ( showed && value != _objectId )
			{
				bObjectIdChanged = true;
				invalidateProperties();
			}

			_objectId = value;
		}

		/*
		   public function deleteObjects() : void
		   {
		   if( !showed )
		   return;

		   resizeManager.selectItem();
		   removeAllChildren();
		 } */

		/**
		 * Удаление объекта по его идентификатору
		 * @param objectId идентификатор объекта
		 *
		 */
		public function deleteObject( objectId : String ) : void
		{
			if ( !showed )
				return;

			renderManager.deleteItem( objectId );
		}

		public function lockItem( objectId : String ) : void
		{
			if ( !showed )
				return;

			renderManager.lockItem( objectId );
		}

		public function updateObject( value : String ) : void
		{
			if ( !showed )
				return;

			var objectId : String = value;

			if ( selectedObject && objectId == IItem( selectedObject ).objectId && resizeManager.itemTransform )
				return;

			var item : IItem = renderManager.getItemById( objectId );

//		if( _contentToolbar )
//			_contentToolbar.close();

			if ( item )
			{
				if ( !item.waitMode )
				{
					var itemDescription : XML = dataManager.getObject( item.objectId );

					if ( itemDescription )
					{
						DisplayObject( item ).x = itemDescription.Attributes.Attribute.( @Name == "left" )[ 0 ];
						DisplayObject( item ).y = itemDescription.Attributes.Attribute.( @Name == "top" )[ 0 ];

						resizeManager.refresh();
					}
				}
				else
				{
					renderManager.updateItem( value /* , result.ParentId */  );
				}
			}
		}

		public function createObject( result : XML ) : void
		{
			if ( !showed )
				return;

			renderManager.createItem( result.Object.@ID, result.ParentId );
		}

		override protected function createChildren() : void
		{

			super.createChildren();

			if ( !contentHolder )
			{

				contentHolder = new Canvas();
				contentHolder.forceClipping = true;
			}

			contentHolder.clipContent = true;
			contentHolder.horizontalScrollPolicy = "off";
			contentHolder.verticalScrollPolicy = "off";
			contentHolder.percentWidth = 100;
			contentHolder.percentHeight = 100;

			addChild( contentHolder );
		}

		override protected function commitProperties() : void
		{
			super.commitProperties();

			if ( !showed )
				return;

			if ( bPageIdChanged )
			{
				bPageIdChanged = false;

				if ( !_pageId )
				{
					var warning : Label = new Label();
					warning.text = "no page selected";
					contentHolder.addChild( warning );
					return;
				}

				resizeManager.selectItem();

				renderManager.init( contentHolder );
				renderManager.createItem( _pageId );
			}

			if ( bObjectIdChanged )
			{
				bObjectIdChanged = false;

				if ( _objectId )
				{
					var item : IItem = renderManager.getItemById( _objectId );

					if ( item )
						resizeManager.selectItem( item );
				}
			}
		}

		private function applyChanges( objectId : String, attributes : Object ) : void
		{
			var newAttributes : XML = 
				<Attributes/>

			for ( var attributeName : String in attributes )
			{
				newAttributes.appendChild( 
					new XML( "<Attribute Name=\"" + attributeName + "\">" + attributes[ attributeName ] + "</Attribute>")
				);
			}

			var wae : WorkAreaEvent = new WorkAreaEvent( WorkAreaEvent.PROPS_CHANGED );
			wae.objectId = objectId;
			wae.props = newAttributes;
			dispatchEvent( wae );
		}

		private function initToolbar( item : IItem ) : void
		{
			var interfaceType : uint;

			if ( item && item.wysiwygableAttributes.length && item.objectId )
			{
				var type : XML = dataManager.getTypeByObjectId( IItem( selectedObject ).objectId );
				interfaceType = type.Information.InterfaceType;
			}
			else
			{
				interfaceType = 0;
			}

			var flag : Boolean = false;
			var newContentToolBar : IToolBar;

			switch ( interfaceType )
			{
				case 2 : 
				{
					if ( !( _contentToolbar is RichTextToolBar ) )
						newContentToolBar = new RichTextToolBar();
					else
						newContentToolBar = _contentToolbar;

					flag = true;

					break
				}
				case 3 : 
				{
					if ( !( _contentToolbar is TextToolBar ) )
						newContentToolBar = new TextToolBar();
					else
						newContentToolBar = _contentToolbar;

					flag = true;

					break
				}
				case 4 : 
				{
					if ( !( _contentToolbar is ImageToolBar ) )
						newContentToolBar = new ImageToolBar();
					else
						newContentToolBar = _contentToolbar;

					flag = true;
					break;
				}
			/* case 5:
			   {
			   if( !( _contentToolbar is TableToolBar ) )
			   newContentToolBar = new TableToolBar();
			   else
			   newContentToolBar = _contentToolbar;

			   flag = true;
			   break;
			 }  */
			}

			if ( !flag && _contentToolbar && DisplayObject( _contentToolbar ).parent )
			{
				removeChild( DisplayObject( _contentToolbar ) );
				_contentToolbar = null;
				return;
			}

			if ( flag )
			{
				if ( !DisplayObject( newContentToolBar ).parent && _contentToolbar && DisplayObject( _contentToolbar ).parent )
					removeChild( DisplayObject( _contentToolbar ) );

				_contentToolbar = newContentToolBar;

				if ( _contentToolbar && !DisplayObject( _contentToolbar ).parent )
					addChild( DisplayObject( _contentToolbar ) );

				_contentToolbar.init( IItem( selectedObject ) );
			}
		}

		private function registerEvent( flag : Boolean ) : void
		{
			if ( flag )
			{
				addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
				addEventListener( DragEvent.DRAG_OVER, dragOverHandler );
				addEventListener( DragEvent.DRAG_DROP, dragDropHandler );
				addEventListener( DragEvent.DRAG_EXIT, dragExitHandler );

				addEventListener( MouseEvent.MOUSE_WHEEL, mouseWheelHandler, true );

				addEventListener( MouseEvent.ROLL_OUT, rollOutHandler );

				renderManager.addEventListener( RenderManagerEvent.RENDER_COMPLETE,
												renderManager_renderCompleteHandler );

				resizeManager.addEventListener( ResizeManagerEvent.OBJECT_SELECT,
												resizeManager_objectSelectHandler );

				resizeManager.addEventListener( ResizeManagerEvent.RESIZE_COMPLETE,
												resizeManager_resizeCompleteHandler );
			}
			else
			{
				removeEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
				removeEventListener( DragEvent.DRAG_OVER, dragOverHandler );
				removeEventListener( DragEvent.DRAG_DROP, dragDropHandler );
				removeEventListener( DragEvent.DRAG_EXIT, dragExitHandler );

				removeEventListener( MouseEvent.MOUSE_WHEEL, mouseWheelHandler, true );

				removeEventListener( MouseEvent.ROLL_OUT, rollOutHandler );

				renderManager.removeEventListener( RenderManagerEvent.RENDER_COMPLETE,
												   renderManager_renderCompleteHandler );

				resizeManager.removeEventListener( ResizeManagerEvent.OBJECT_SELECT,
												   resizeManager_objectSelectHandler );

				resizeManager.removeEventListener( ResizeManagerEvent.RESIZE_COMPLETE,
												   resizeManager_resizeCompleteHandler );
			}
		}

		private function scrollToObject( objectID : String ) : void
		{
			var pageContainer : Container = contentHolder.getChildAt( 0 )as Container;

			if ( pageContainer == null || pageContainer.horizontalScrollBar == null && pageContainer.verticalScrollBar == null )
				return;

			var item : IItem = renderManager.getItemById( objectID );

			if ( item == null || UIComponent( item ).parent )
				return;

			var currentHScrollPosition : Number = contentHolder.horizontalScrollPosition;
			var currentVScrollPosition : Number = contentHolder.horizontalScrollPosition;

			var pt : Point = DisplayUtils.getConvertedPoint( DisplayObject( item ),
															 contentHolder );

			var dummy : * = ""; // FIXME remove dummy
		}

		private function showHandler( event : FlexEvent ) : void
		{
			registerEvent( true );
			showed = true;
			
			if ( _pageId == null || _pageId != dataManager.currentPageId )
			{
				_pageId = dataManager.currentPageId;
				bPageIdChanged = true;
			}
			
			if( _objectId == null || _objectId != dataManager.currentObjectId )
			{
				_objectId = dataManager.currentObjectId
				bObjectIdChanged = true;
			}
			
			if( bPageIdChanged || bObjectIdChanged )
				invalidateProperties();
		}

		private function hideHandler( event : FlexEvent ) : void
		{
			registerEvent( false );
			_objectId = null;
			_pageId = null;
			showed = false;
		}



		private function dragEnterHandler( event : DragEvent ) : void
		{
			resizeManager.itemDrag = true;
			VdomDragManager.acceptDragDrop( UIComponent( event.currentTarget ) );
			focusedObject = null
		}

		private function dragOverHandler( event : DragEvent ) : void
		{
			var typeDescription : Object = event.dragSource.dataForFormat( "typeDescription" );

			if ( !typeDescription )
				return;

			var filterFunction : Function = function( item : IItem ) : Boolean
			{
				return !item.isStatic;
			}

			var stack : Array = DisplayUtils.getObjectsUnderMouse( this, "vdom.containers::IItem",
																   filterFunction );

			if ( stack.length == 0 )
				return;

			var currentItem : Container = stack[ 0 ];

			//trace("WorkArea - dragOverHandler " + stack.length )

			if ( focusedObject == currentItem || IItem( currentItem ).waitMode )
				return;

			if ( focusedObject )
				IItem( focusedObject ).drawHighlight( "none" );


			var containersRE : RegExp = /(\w+)/g;
			var aviableContainers : Array = typeDescription.aviableContainers.match( containersRE );

			var currentItemDescription : XML = dataManager.getTypeByObjectId( IItem( currentItem ).objectId );

			var currentItemName : String = currentItemDescription.Information.Name;


			if ( aviableContainers.indexOf( currentItemName ) != -1 )
			{
				IItem( currentItem ).drawHighlight( "0x00FF00" );
			}
			else if ( currentItemDescription.Information.Container != 1 )
			{
				IItem( currentItem ).drawHighlight( "0xFF0000" );
			}
			else if ( currentItem.parent is IItem )
			{
				currentItem = Container( currentItem.parent );

				currentItemDescription = dataManager.getTypeByObjectId( IItem( currentItem ).objectId );

				currentItemName = currentItemDescription.Information.Name;

				if ( aviableContainers.indexOf( currentItemName ) != -1 )

					IItem( currentItem ).drawHighlight( "0x00FF00" );
				else
					IItem( currentItem ).drawHighlight( "0xFF0000" );
			}

			focusedObject = currentItem;
		}

		private function dragDropHandler( event : DragEvent ) : void
		{

			resizeManager.itemDrag = false;

			var typeDescription : Object = event.dragSource.dataForFormat( "typeDescription" );

			var currentContainer : Container = focusedObject;

			if ( focusedObject is IItem )
				IItem( focusedObject ).drawHighlight( "none" );

			if ( currentContainer )
				currentContainer.drawFocus( false );
			else
				return;

			var currentItemName : String = dataManager.getTypeByObjectId( IItem( currentContainer ).objectId ).Information.Name;

			var re : RegExp = /\s+/g;

			var aviableContainers : Array = typeDescription.aviableContainers.replace( re,
																					   "" ).split( "," );

			var bool : Number = aviableContainers.indexOf( currentItemName );

			if ( bool != -1 )
			{

				var objectLeft : Number = currentContainer.mouseX - 25 + currentContainer.horizontalScrollPosition;
				var objectTop : Number = currentContainer.mouseY - 25 + currentContainer.verticalScrollPosition;

				objectLeft = ( objectLeft < 0 ) ? 0 : objectLeft;
				objectTop = ( objectTop < 0 ) ? 0 : objectTop;

				var attributes : XML = 
					<Attributes>
						<Attribute Name="top">
							{objectTop}</Attribute>
						<Attribute Name="left">
							{objectLeft}</Attribute>
					</Attributes>

				var wae : WorkAreaEvent = new WorkAreaEvent( WorkAreaEvent.CREATE_OBJECT )
				wae.typeId = typeDescription.typeId;
				wae.objectId = IItem( currentContainer ).objectId;
				wae.props = attributes;

				dispatchEvent( wae );

				focusedObject = null;
			}
		}

		private function dragExitHandler( event : DragEvent ) : void
		{
			resizeManager.itemDrag = false;

			if ( focusedObject is IItem )
				IItem( focusedObject ).drawHighlight( "none" );
		}

		private function mouseWheelHandler( event : MouseEvent ) : void
		{
			event.stopPropagation();
		}

		private function rollOutHandler( event : MouseEvent ) : void
		{
			cursorManager.removeAllCursors();
		}

		private function renderManager_renderCompleteHandler( event : RenderManagerEvent ) : void
		{

			if ( !event.result )
				return;

			if ( event.result is IItem && IItem( event.result ).objectId == _pageId )
			{
				resizeManager.init( contentHolder );

				if ( _objectId )
				{
					var item : IItem = renderManager.getItemById( _objectId );

					if ( item )
						resizeManager.selectItem( item );
				}
			}


			initToolbar( IItem( selectedObject ) );
		}

		private function resizeManager_resizeCompleteHandler( event : ResizeManagerEvent ) : void
		{
			var currentObject : Container = Container( event.item );
			var currentProperties : Object = event.properties;
			var currentToolBar : IToolBar;

			if ( !currentObject || !currentProperties )
				return;

			var currentObjectId : String = IItem( currentObject ).objectId;
			var changeFlag : Boolean = false;
			var newAttributes : Object = {};
			var objectDescription : XML = dataManager.getObject( currentObjectId );

			if ( !objectDescription )
				return;

			for ( var name : String in currentProperties )
			{
				if ( name == "width" && objectDescription.Attributes.Attribute.( @Name == name )[ 0 ] || name == "height" && objectDescription.Attributes.Attribute.( @Name == name )[ 0 ] )
				{
					currentObject[ name ] = currentProperties[ name ];
					changeFlag = true;
				}

				if ( changeFlag )
				{
					if ( event.properties[ "top" ] )
						currentObject.y = currentProperties[ "top" ];
					if ( event.properties[ "left" ] )
						currentObject.x = currentProperties[ "left" ];
				}

				newAttributes[ name ] = event.properties[ name ];
			}

			if ( _objectId != currentObjectId || !changeFlag )
			{
				applyChanges( currentObjectId, newAttributes );
				return;
			}

			if ( _contentToolbar && DisplayObject( _contentToolbar ).parent )
				currentToolBar = _contentToolbar;

			if ( currentToolBar )
				currentToolBar.close();

			if ( changeFlag && IItem( currentObject ).wysiwygableAttributes[ 0 ] && currentToolBar && !currentToolBar.selfChanged )
			{
				var attributes : Object = IItem( currentObject ).wysiwygableAttributes[ 0 ].attributes;
				var attributeValue : String;
				var xmlCharRegExp : RegExp = /[<>&"]+/;

				for ( var attributeName : String in attributes )
				{
					attributeValue = attributes[ attributeName ];

					if ( attributeValue.search( xmlCharRegExp ) != -1 )
					{
						attributeValue = attributeValue.replace(/\]\]>/g, "]]]]"+"><![CDATA[>" );
						attributeValue = "<![CDATA[" + attributeValue + "]" + "]>"
						newAttributes[ attributeName ] = attributeValue;
					}
					else
					{
						newAttributes[ attributeName ] = attributeValue;
					}
				}
			}

			applyChanges( currentObjectId, newAttributes );
		}

		private function resizeManager_objectSelectHandler( event : ResizeManagerEvent ) : void
		{

			var currentToolBar : IToolBar;

//		callLater( scrollToObject, [ _objectId ] );

			if ( _contentToolbar && DisplayObject( _contentToolbar ).parent )
				currentToolBar = _contentToolbar;

			if ( currentToolBar )
				currentToolBar.close();

			if ( selectedObject && IItem( selectedObject ).wysiwygableAttributes[ 0 ] && currentToolBar && !currentToolBar.selfChanged )
			{

				var attributes : Object = IItem( selectedObject ).wysiwygableAttributes[ 0 ].attributes;
				var attributeValue : String;
				var xmlCharRegExp : RegExp = /[<>&"]+/;
				var newAttribute : Object = {};

				for ( var attributeName : String in attributes )
				{
					attributeValue = attributes[ attributeName ] ? attributes[ attributeName ] : "";

					if ( attributeValue.search( xmlCharRegExp ) != -1 )
					{
						attributeValue = attributeValue.replace(/\]\]>/g, "]]]]"+"><![CDATA[>" );
						attributeValue = "<![CDATA[" + attributeValue + "]" + "]>"
						newAttribute[ attributeName ] = attributeValue;
					}
					else
					{
						newAttribute[ attributeName ] = attributeValue;
					}
				}

				applyChanges( IItem( selectedObject ).objectId, newAttribute );
			}

			selectedObject = event.item;

			initToolbar( IItem( selectedObject ) );

			if ( !selectedObject )
				return;

			var wae : WorkAreaEvent = new WorkAreaEvent( WorkAreaEvent.CHANGE_OBJECT );
			wae.objectId = IItem( selectedObject ).objectId;
			dispatchEvent( wae );
		}
	}
}