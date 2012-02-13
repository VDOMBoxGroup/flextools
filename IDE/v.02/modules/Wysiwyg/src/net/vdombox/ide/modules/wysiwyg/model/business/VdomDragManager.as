package net.vdombox.ide.modules.wysiwyg.model.business
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.DragSource;
	import mx.core.IFlexDisplayObject;
	import mx.core.IFlexModule;
	import mx.core.IFlexModuleFactory;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.managers.DragManager;
	import mx.managers.ISystemManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.IStyleManager2;
	import mx.styles.StyleManager;

	/**
	 *  @private
	 */
	public class VdomDragManager
	{

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 *  @private
		 */
		private static var sm : ISystemManager;

		/**
		 *  @private
		 */
		private static var instance : VdomDragManager;

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 *  @private
		 */
		public static function getInstance() : VdomDragManager
		{
			if ( !instance )
			{
				//sm = SystemManagerGlobals.topLevelSystemManagers[0];
				instance = new VdomDragManager();
			}

			return instance;
		}

		static private function getStyleManager(dragInitiator:IUIComponent):IStyleManager2
		{
			// If the dragInitiator has a styleManager, use that one.
			// In a situation where a main application that loads a module with drag initiator,
			// the main application may not link in the DragManager and appropriate styles.
			// We want to use the styles of the module of the dragInitiator. See SDK-24324.
			if (dragInitiator is IFlexModule)
				return StyleManager.getStyleManager(IFlexModule(dragInitiator).moduleFactory);
			
			return StyleManager.getStyleManager(sm as IFlexModuleFactory);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 *  @private
		 */
		public function VdomDragManager()
		{
			super();

			if ( instance )
				throw new Error( "Instance already exists." );

		/*if (sm.isTopLevel())
		   {
		   //sm.addEventListener(MouseEvent.MOUSE_DOWN, sm_mouseDownHandler);
		   //sm.addEventListener(MouseEvent.MOUSE_UP, sm_mouseUpHandler);
		 }*/
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 *  @private
		 *  Object that initiated the drag.
		 */
		private var dragInitiator : IUIComponent;

		/**
		 *  @private
		 *  Object being dragged around.
		 */
		public var dragProxy : VdomDragProxy;

		/**
		 *  @private
		 */
		private var bDoingDrag : Boolean = false;

		/**
		 *  @private
		 */
		private var mouseIsDown : Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function doDrag( dragInitiator : IUIComponent, dragSource : DragSource, mouseEvent : MouseEvent, dragImage : IFlexDisplayObject = null,
								// instance of dragged item(s)
			xOffset : Number = 0, yOffset : Number = 0, imageAlpha : Number = 0.5, allowMove : Boolean = true ) : void
		{
			var proxyWidth : Number;
			var proxyHeight : Number;

			// Can't start a new drag if we're already in the middle of one...
			if ( bDoingDrag )
				return;

			// Can't do a drag if the mouse isn't down
			if ( !( mouseEvent.type == MouseEvent.MOUSE_DOWN || mouseEvent.type == MouseEvent.CLICK || mouseIsDown || mouseEvent.buttonDown ) )
			{
				return;
			}

			bDoingDrag = true;

			this.dragInitiator = dragInitiator;

			// The drag proxy is a UIComponent with a single child -
			// an instance of the dragImage.
			dragProxy = new VdomDragProxy( dragInitiator, dragSource );
			dragInitiator.systemManager.popUpChildren.addChild( dragProxy );

			if ( !dragImage )
			{
				// No drag image specified, use default
				var dragManagerStyleDeclaration:CSSStyleDeclaration =
					getStyleManager(dragInitiator).getMergedStyleDeclaration("mx.managers.DragManager");
				var dragImageClass : Class = dragManagerStyleDeclaration.getStyle( "defaultDragImageSkin" );
				dragImage = new dragImageClass();
				dragProxy.addChild( DisplayObject( dragImage ) );
				proxyWidth = dragInitiator.width;
				proxyHeight = dragInitiator.height;
			}
			else
			{
				dragProxy.addChild( DisplayObject( dragImage ) );
				//if (dragImage is ILayoutManagerClient )
				//UIComponentGlobals.layoutManager.validateClient(ILayoutManagerClient(dragImage), true);
				if ( dragImage is IUIComponent )
				{
					proxyWidth = ( dragImage as IUIComponent ).getExplicitOrMeasuredWidth();
					proxyHeight = ( dragImage as IUIComponent ).getExplicitOrMeasuredHeight();
				}
				else
				{
					proxyWidth = dragImage.measuredWidth;
					proxyHeight = dragImage.measuredHeight;
				}
			}

			dragImage.setActualSize( proxyWidth, proxyHeight );
			dragProxy.setActualSize( proxyWidth, proxyHeight );

			// Alpha
			dragProxy.alpha = imageAlpha;

			dragProxy.allowMove = allowMove;

			var point : Point = new Point( mouseEvent.localX, mouseEvent.localY );
			point = DisplayObject( mouseEvent.target ).localToGlobal( point );
			point = DisplayObject( dragInitiator.systemManager.topLevelSystemManager ).globalToLocal( point );
			var mouseX : Number = point.x;
			var mouseY : Number = point.y;

			// Set dragProxy.offset to the mouse offset within the drag proxy.
			var proxyOrigin : Point = DisplayObject( mouseEvent.target ).localToGlobal( new Point( mouseEvent.localX, mouseEvent.localY ) );
			proxyOrigin = DisplayObject( dragInitiator ).globalToLocal( proxyOrigin );
			dragProxy.xOffset = proxyOrigin.x + xOffset;
			dragProxy.yOffset = proxyOrigin.y + yOffset;

			// Call onMouseMove to setup initial position of drag proxy and cursor.
			dragProxy.x = mouseX - dragProxy.xOffset;
			dragProxy.y = mouseY - dragProxy.yOffset;

			// Remember the starting location of the drag proxy so it can be
			// "snapped" back if the drop was refused.
			dragProxy.startX = dragProxy.x;
			dragProxy.startY = dragProxy.y;

			// Turn on caching.
			if ( dragImage is DisplayObject )
				DisplayObject( dragImage ).cacheAsBitmap = true;

			var delegate : Object = dragProxy.automationDelegate;
			if ( delegate )
				delegate.recordAutomatableDragStart( dragInitiator, mouseEvent );
		}

		public function acceptDragDrop( target : IUIComponent ) : void
		{
			if ( dragProxy )
			{
				dragProxy.target = target;
			}
		}
		
		public function hitTarget( target : IUIComponent ) : void
		{
			if ( dragProxy )
			{
				dragProxy.dispGragExit( target );
			}
		}

		public function endDrag() : void
		{
			if ( dragProxy )
			{
				var sm : ISystemManager = dragInitiator.systemManager;
				sm.popUpChildren.removeChild( dragProxy );

				dragProxy.removeChildAt( 0 ); // The drag image is the only child
				dragProxy = null;
			}

			dragInitiator = null;
			bDoingDrag = false;
		}
	}

}

