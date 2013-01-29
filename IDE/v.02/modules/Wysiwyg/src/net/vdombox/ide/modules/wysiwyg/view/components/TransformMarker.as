package net.vdombox.ide.modules.wysiwyg.view.components
{
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.view.components.VDOMImage;
	import net.vdombox.ide.modules.wysiwyg.events.RendererEvent;
	import net.vdombox.ide.modules.wysiwyg.events.TransformMarkerEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	
	import spark.components.supportClasses.ScrollBarBase;

	use namespace mx_internal;

	public class TransformMarker extends UIComponent
	{
		public static const RESIZE_NONE : uint = 0;
		public static const RESIZE_WIDTH : uint = 1;
		public static const RESIZE_HEIGHT : uint = 2;
		public static const RESIZE_ALL : uint = 3;

		public static const MOVE_TRUE : Boolean = true;
		public static const MOVE_FALSE : Boolean = false;

		public function TransformMarker()
		{
			super();

			visible = false;
			
			addEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler );
			addEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler );
			
			addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
		}

		private var tl_box : Sprite;
		private var tc_box : Sprite;
		private var tr_box : Sprite;
		private var cl_box : Sprite;
		private var cr_box : Sprite;
		private var bl_box : Sprite;
		private var bc_box : Sprite;
		private var br_box : Sprite;
		private var cc_box : Sprite;

		private var CursorID : uint

		private var moving : DisplayObject;

		private var _moveMode : Boolean;
		private var _resizeMode : uint;

		private var _selectedItem : UIComponent;

		private var _markerSelected : Boolean;

		private var mousePosition : Point;

		private var modeChanged : Boolean;
		private var boxStyleChanged : Boolean;
		private var itemChanged : Boolean;

		private var boxSize : int = 6;
		private var borderColor : uint;
		private var borderAlpha : Number;
		private var backgroundColor : uint
		private var backgroundAlpha : Number;

		private var transformation : Boolean;

		private var beforeTransform : Object;
		
		public function get resizeMode() : uint
		{
			return _resizeMode;
		}

		public function set resizeMode( modeValue : uint ) : void
		{
			if ( _resizeMode != modeValue )
			{
				_resizeMode = modeValue;

				modeChanged = true;

				invalidateDisplayList();
			}
		}

		public function get moveMode() : Boolean
		{
			return _moveMode;
		}

		public function set moveMode( modeValue : Boolean ) : void
		{
			_moveMode = modeValue;

			if ( !modeValue )
				moving = null;

			modeChanged = true;

			invalidateDisplayList();
		}

		public function get markerSelected() : Boolean
		{
			return _markerSelected;
		}

		public function get renderer() : IRenderer
		{
			return _selectedItem as IRenderer;
		}

		public function set renderer( item : IRenderer ) : void
		{
			if ( _selectedItem == item || ( transformation && _selectedItem ) )
				return;

			visible = false;

			if ( item == null || IVisualElement( item ).parent == null )
			{
				if ( stage )
				{
					stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler, true );
					stage.removeEventListener( MouseEvent.MOUSE_UP, mouseUpHandler, true );
				}

				removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );

				_selectedItem = null;
				itemChanged = true;
				invalidateDisplayList();

				return;
			}

			_selectedItem = item as UIComponent;
			
			if ( !_selectedItem )
				return;

			moving = cc_box;

			mousePosition = new Point( _selectedItem.mouseX, _selectedItem.mouseY );

			resizeMode = item.resizable;
			moveMode = item.movable;

			addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			
			if ( stage )
			{
				stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler, true );
				stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler, true );
			}
			
			_selectedItem.addEventListener( FlexEvent.UPDATE_COMPLETE, refreshCompleteHandler );
			
			beforeTransform = { x: _selectedItem.x, y: _selectedItem.y, width: _selectedItem.width, height: _selectedItem.height };

			itemChanged = true;
			invalidateSize();
		}

		private function refreshCompleteHandler( event : Event ) : void
		{
			if ( invalidateSizeFlag || transformation )
				return;

			refresh();
		}

		public function refresh() : void
		{
			if ( !visible )
				return;

			itemChanged = true;
			invalidateSize();
			invalidateDisplayList();
			
		}

		override protected function createChildren() : void
		{
			super.createChildren();

			cc_box = new Sprite();
			cc_box.name = "cc";
			cc_box.buttonMode = true;

			tl_box = createBox( "tl" );
			tc_box = createBox( "tc" );
			tr_box = createBox( "tr" );
			cl_box = createBox( "cl" );
			cr_box = createBox( "cr" );
			bl_box = createBox( "bl" );
			bc_box = createBox( "bc" );
			br_box = createBox( "br" );


			this.addChild( cc_box );
			this.addChild( tl_box );
			this.addChild( tc_box );
			this.addChild( tr_box );
			this.addChild( cl_box );
			this.addChild( cr_box );
			this.addChild( bl_box );
			this.addChild( bc_box );
			this.addChild( br_box );
			
		}

		override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );

			if ( boxStyleChanged )
			{
				boxSize = this.getStyle( "boxSize" );
				borderColor = this.getStyle( "borderColor" );
				backgroundAlpha = this.getStyle( "backgroundAlpha" )
				borderAlpha = this.getStyle( "borderAlpha" );
				updateBoxes();
				boxStyleChanged = false;
			}

			if ( modeChanged )
			{
				switch ( _resizeMode )
				{
					case RESIZE_ALL:
					{
						tl_box.visible = _moveMode;
						tc_box.visible = _moveMode;
						tr_box.visible = _moveMode;
						cl_box.visible = _moveMode;
						bl_box.visible = _moveMode;

						cr_box.visible = true;
						bc_box.visible = true;
						br_box.visible = true;
						break;
					}
					case RESIZE_WIDTH:
					{
						tl_box.visible = false;
						tc_box.visible = false;
						tr_box.visible = false;
						cl_box.visible = _moveMode;
						bl_box.visible = false;

						cr_box.visible = true;
						bc_box.visible = false;
						br_box.visible = false;
						break;
					}
					case RESIZE_HEIGHT:
					{
						tl_box.visible = false;
						tc_box.visible = _moveMode;
						tr_box.visible = false;
						cl_box.visible = false;
						bl_box.visible = false;

						cr_box.visible = false;
						bc_box.visible = true;
						br_box.visible = false;
						break;
					}
					case RESIZE_NONE:
					{
						tl_box.visible = false;
						tc_box.visible = false;
						tr_box.visible = false;
						cl_box.visible = false;
						cr_box.visible = false;
						bl_box.visible = false;
						bc_box.visible = false;
						br_box.visible = false;
						break;
					}
				}

				cc_box.visible = _moveMode
			}

			var realWidth : Number = measuredWidth ? measuredWidth : 0;
			var realHeight : Number = measuredHeight ? measuredHeight : 0;

			if ( itemChanged )
			{
				itemChanged = false

				if ( !_selectedItem )
				{
					visible = false;
					return;
				}

				tl_box.x = 0 + boxSize / 2;
				tl_box.y = 0 + boxSize / 2;
				tc_box.x = realWidth / 2;
				tc_box.y = 0 + boxSize / 2;
				tr_box.x = realWidth - boxSize / 2;
				tr_box.y = 0 + boxSize / 2;
				cl_box.x = 0 + boxSize / 2;
				cl_box.y = realHeight / 2;
				cr_box.x = realWidth - boxSize / 2;
				cr_box.y = realHeight / 2;
				bl_box.x = 0 + boxSize / 2;
				bl_box.y = realHeight - boxSize / 2;
				bc_box.x = realWidth / 2;
				bc_box.y = realHeight - boxSize / 2;
				br_box.x = realWidth - boxSize / 2;
				br_box.y = realHeight - boxSize / 2;

				var transparentValue : Number = ( resizeMode ) ? .4 : .0;

				/*if ( cc_box.visible )
				{
					var g : Graphics = cc_box.graphics;
					g.clear();
					g.lineStyle( 6, 0x333333, transparentValue, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER );
					g.drawRect( 3, 3, realWidth - 6, realHeight - 6 );
					g.endFill();
				}*/

				graphics.clear();
				graphics.lineStyle( 1, 0, 1, false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER );
				graphics.drawRect( 0, 0, realWidth, realHeight );
				graphics.endFill();

				callLater( function() : void
				{
					visible = true
				} );
			}
		}

		override protected function measure() : void
		{
			super.measure();

			if ( !_selectedItem )
				return;
			
			if ( !(_selectedItem as RendererBase).typeVO )
				refresh();
			
			var editComponent : Object = (_selectedItem as RendererBase).editableComponent;
			if (  editComponent && ( (_selectedItem as RendererBase).typeVO && (_selectedItem as RendererBase).typeVO.name == "text" || (_selectedItem as RendererBase).typeVO.name == "richtext" ))
			{
				if ( measuredWidth != editComponent.width )
				{
					measuredWidth = editComponent.width;
					_selectedItem.width = measuredWidth;
				}
			
				if ( measuredHeight != editComponent.height )
				{
					measuredHeight = editComponent.height;
					_selectedItem.height = measuredHeight;
				}
			}
			else
			{

				if ( measuredWidth != _selectedItem.width )
					measuredWidth = _selectedItem.width;

				if ( measuredHeight != _selectedItem.height )
					measuredHeight = _selectedItem.height;
			}

			var rectangle : Rectangle = getContentRectangle( _selectedItem, this );

			if ( rectangle )
			{
				if ( x != rectangle.x || y != rectangle.y )
					move( rectangle.x, rectangle.y );
			}
		}

		protected function updateBoxes() : void
		{
			graphics.clear();
			graphics.beginFill( backgroundColor, backgroundAlpha );
			graphics.lineStyle( .25, borderColor, 1, true, LineScaleMode.NONE );
			graphics.drawRect( 0, 0,  measuredWidth, measuredHeight );
			graphics.endFill();
		}

		protected function createBox( name : String ) : Sprite
		{
			var b : Sprite = new Sprite();
			b.graphics.beginFill( 0xFFFFFF, 1 )
			b.graphics.lineStyle( 1, 0x00, 1, true, LineScaleMode.NONE );
			b.graphics.drawRect( -boxSize / 2, -boxSize / 2, boxSize, boxSize );
			b.graphics.endFill();
			b.buttonMode = true
			b.useHandCursor = false;
			b.visible = false;
			b.name = name
			return b;
		}

		private function getContentRectangle( sourceContainer : DisplayObject, destinationContainer : DisplayObject ) : Rectangle
		{
			if ( !sourceContainer )
				return null;

			var pt : Point = new Point( sourceContainer.x, sourceContainer.y );
			var sc : UIComponent = sourceContainer.parent as UIComponent;
			var dc : UIComponent = destinationContainer.parent as UIComponent;

			if ( !sc || !dc )
				return null;

			pt = sc.contentToGlobal( pt );
			pt = dc.globalToContent( pt );

			return new Rectangle( pt.x, pt.y, measuredWidth, measuredHeight );
		}

		private function mouseDownHandler( event : MouseEvent ) : void
		{			
			beforeTransform = { x: _selectedItem.x, y: _selectedItem.y, width: _selectedItem.width, height: _selectedItem.height };
			
			(_selectedItem as RendererBase).beforeX = _selectedItem.x;
			(_selectedItem as RendererBase).beforeY = _selectedItem.y;

			moving = null;
			mousePosition = new Point( mouseX, mouseY );

			if ( event.target != this )
				moving = DisplayObject( event.target );
			else
				moving = this;

			transformation = true;

			this.dispatchEvent(new TransformMarkerEvent(TransformMarkerEvent.TRANSFORM_BEGIN));
			
			stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler, true, 0 , true );
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler, true, 0 , true );

			stage.addEventListener( MouseEvent.CLICK, stage_mouseClickHandler, true, 0 , true );
		}

		private function mouseOutHandler( event : MouseEvent ) : void
		{
			if ( _selectedItem && !moving )
			{
				parentApplication.cursorManager.removeAllCursors();
				_markerSelected = false;
			}
		}

		private function mouseOverHandler( event : MouseEvent ) : void
		{
			if ( _selectedItem )
			{
				var target : Sprite = Sprite( event.target );
				parentApplication.cursorManager.removeAllCursors();
				_markerSelected = true;

				switch ( target.name )
				{
					case "bc":
					case "tc":
					{
						CursorID = parentApplication.cursorManager.setCursor( VDOMImage.topDownCursor, 2, -6, -8 );
						break;
					}
					case "cl":
					case "cr":
					{
						CursorID = parentApplication.cursorManager.setCursor( VDOMImage.leftRightCursor, 2, -8, -4 );
						break;
					}
					case "tl":
					case "br":
					{
						CursorID = parentApplication.cursorManager.setCursor( VDOMImage.topLDownRCursor, 2, -8, -6 );
						break;
					}
					case "tr":
					case "bl":
					{
						CursorID = parentApplication.cursorManager.setCursor( VDOMImage.topRDownLCursor, 2, -6, -10 );
						break;
					}
					case "cc":
					{
						CursorID = parentApplication.cursorManager.setCursor( VDOMImage.moveCursor, 2, -10, -10 );
						break;
					}
					default:
					{
						_markerSelected = false;
						break;
					}
				}

				if ( markerSelected )
					dispatchEvent( new TransformMarkerEvent( TransformMarkerEvent.TRANSFORM_MARKER_SELECTED ) );
			}
		}

		private function mouseUpHandler( event : MouseEvent ) : void
		{
			//trace ("-- mouseUpHandler");
			if ( !stage )
				return;

			stage.removeEventListener( MouseEvent.MOUSE_UP, mouseUpHandler, true );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler, true );

			moving = null;
			mousePosition = null;
			mouseOutHandler( null );
			transformation = false;

			if ( !event )
				return;

			var rectangle : Rectangle = getContentRectangle( this, _selectedItem );

			var rmEvent : TransformMarkerEvent = new TransformMarkerEvent( TransformMarkerEvent.TRANSFORM_COMPLETE );

			var changeFlag : Boolean = false;
			var prop : Object = {};

			if ( !rectangle )
			{
				rmEvent.properties = prop;
				dispatchEvent( rmEvent );
				return;
			}

			for ( var name : String in beforeTransform )
			{
				if ( rectangle[ name ] != beforeTransform[ name ] )
				{
					prop[ name ] = int( rectangle[ name ] );
					changeFlag = true;
				}
			}

			if ( !changeFlag )
				return;

			rmEvent.properties = prop;
			rmEvent.renderer = _selectedItem as IRenderer;
			event.stopImmediatePropagation();
			dispatchEvent( rmEvent );
			
			dispatchEvent( new RendererEvent( RendererEvent.MOUSE_UP_MEDIATOR ) );
		}
		
		public function equallyPoint( _x : Number, _y : Number ) : Boolean
		{
			if ( Math.abs( _x - beforeTransform.x ) < 1 && Math.abs( _y - beforeTransform.y ) < 1 )
				return true;
			return false;
		}
		
		public function equallyX( _x : Number ) : Boolean
		{
			if ( Math.abs( _x - beforeTransform.x ) < 1 )
				return true;
			return false;
		}
		
		public function equallyY( _y : Number ) : Boolean
		{
			if ( Math.abs( _y - beforeTransform.y ) < 1 )
				return true;
			return false;
		}
		
		public function equallySize( _width : Number, _height : Number ) : Boolean
		{
			if ( _width == beforeTransform.width && _height == beforeTransform.height ) 
				return true;
			return false;
		}
		
		public function equallyWidth( _width : Number ) : Boolean
		{
			if ( _width == beforeTransform.width ) 
				return true;
			return false;
		}
		
		public function equallyHeight( _height : Number ) : Boolean
		{
			if ( _height == beforeTransform.height ) 
				return true;
			return false;
		}

		private function mouseMoveHandler( event : MouseEvent ) : void
		{
			if ( itemChanged )
				return;

			if ( !_selectedItem || !_selectedItem.parent )
			{
				mouseUpHandler( null );
				return;
			}

			var rect : Rectangle = new Rectangle( x, y, measuredWidth, measuredHeight );
			var rect1 : Rectangle = getContentRectangle( this, _selectedItem );
			var rect2 : Rectangle = getContentRectangle( _selectedItem.parent, this );
			var allow : Boolean = true;

			if ( moving && event.buttonDown )
			{				
				var mx : Number = mouseX;
				var my : Number = mouseY;

				switch ( moving.name )
				{
					case "br":
					{
						rect.width = mouseX;
						rect.height = mouseY;
						break;
					}
					case "bc":
					{
						rect.height = mouseY;
						break;
					}
					case "bl":
					{
						if ( rect1.x + mx < 0 )
						{
							rect.width += rect.x - rect2.x;
							rect.x = rect2.x;
						}
						else
						{
							rect.x += mx;
							rect.width -= mx;
						}
						rect.height = mouseY;
						break;
					}
					case "cr":
					{
						rect.width = mouseX;
						break;
					}
					case "cl":
					{
						if ( rect1.x + mx < 0 )
						{
							rect.width += rect.x - rect2.x;
							rect.x = rect2.x;
						}
						else
						{
							rect.x += mx;
							rect.width -= mx;
						}
						break;
					}
					case "tl":
					{
						if ( rect1.x + mx < 0 )
						{
							rect.width += rect.x - rect2.x;
							rect.x = rect2.x;
						}
						else
						{
							rect.x += mx;
							rect.width -= mx;
						}

						if ( rect1.y + my < 0 )
						{
							rect.height += rect.y - rect2.y;
							rect.y = rect2.y;
						}
						else
						{
							rect.y += my;
							rect.height -= my;
						}
						break;
					}
					case "tc":
					{
						if ( rect1.y + my < 0 )
						{
							rect.height += rect.y - rect2.y;
							rect.y = rect2.y;
						}
						else
						{
							rect.y += my;
							rect.height -= my;
						}
						break;
					}
					case "tr":
					{
						if ( rect1.y + my < 0 )
						{
							rect.height += rect.y - rect2.y;
							rect.y = rect2.y;
						}
						else
						{
							rect.y += my;
							rect.height -= my;
						}
						rect.width = mouseX;

						break;
					}
					case "cc":
					{
						if ( rect1.x + mx - mousePosition.x < 0 )
						{
							rect.x = rect2.x;
							rect1.x = 0;
						}
						else
						{
							rect.x += mx - mousePosition.x;
							rect1.x += mx - mousePosition.x;
						}
						if ( rect1.y + my - mousePosition.y < 0 )
						{
							rect.y = rect2.y;
							rect1.y = 0;
						}
						else
						{
							rect.y += my - mousePosition.y;
							rect1.y += my - mousePosition.y;
						}
						break;
					}
				}

				if ( rect.width > maxWidth || rect.width < minWidth )
					allow = false;

				if ( rect.height > maxHeight || rect.height < minHeight )
					allow = false;

				if ( rect )
				{					
					if ( rect.width > maxWidth )
						rect.width = maxWidth;

					if ( rect.width < minWidth )
						rect.width = minWidth;

					if ( rect.height > maxHeight )
						rect.height = maxHeight;

					if ( rect.height < minHeight )
						rect.height = minHeight;

					if ( allow )
					{
						move( rect.x, rect.y );

						if ( _moveMode && ( moving.name == "cc" ) )
						{

							_selectedItem.x = rect1.x;
							_selectedItem.y = rect1.y;
						}

						itemChanged = true;

						measuredWidth = rect.width;
						measuredHeight = rect.height;

						var evt : TransformMarkerEvent = new TransformMarkerEvent( TransformMarkerEvent.TRANSFORM_CHANGING );
						dispatchEvent( evt );
					}
				}

				invalidateDisplayList();

			}
			else
			{
				mouseUpHandler( null );
			}
			
			if ( rect.width != beforeTransform.width || rect.height != beforeTransform.height || 
				_selectedItem.x != beforeTransform.x || _selectedItem.y != beforeTransform.y )
			{
				var moveEvent : RendererEvent =  new RendererEvent( RendererEvent.MOVE_MEDIATOR ) ;
				moveEvent.ctrlKey = event.ctrlKey;
				dispatchEvent( moveEvent );
			}
		}

		private function stage_mouseClickHandler( event : MouseEvent ) : void
		{
			//trace ("-- stage_mouseClickHandler");
			stage.removeEventListener( MouseEvent.CLICK, stage_mouseClickHandler, true );
			
			event.stopImmediatePropagation();
		}
		
		private function addedToStageHandler( event : Event ) : void
		{
			removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			
			parent.addEventListener( Event.CHANGE, scrollHandler, true, 0, true );
			parent.addEventListener( RendererEvent.MOVED, render_movedHandler, true, 0, true );
		}
		
		private function scrollHandler( event : Event ) :void
		{ 
			if( event.target is ScrollBarBase )
				refresh();
		}
		
		private function render_movedHandler( event : RendererEvent ) : void
		{
			var renderer : IRenderer = event.target as IRenderer;
			
			if( !_selectedItem || !renderer )
				return;

			var inMovedObject:  Boolean = false;
			var parentRenderer : DisplayObjectContainer;
			
			parentRenderer = _selectedItem as DisplayObjectContainer;
			
			while( parentRenderer )
			{
				if ( parentRenderer == renderer )
				{
					inMovedObject = true;
					break;
				}
				
				if( parentRenderer == parent )
					break;
				
				parentRenderer = parentRenderer.parent;
			}
			
			if( inMovedObject )
				refresh();
		}
	}
}

