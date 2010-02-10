package net.vdombox.ide.modules.tree.view
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.geom.Point;
	
	import mx.binding.utils.BindingUtils;
	
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.view.components.Linkage;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class LinkageMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ArrowMediator";

		private static var count : uint = 0;

		public function LinkageMediator( viewComponent : Object, linkageVO : LinkageVO )
		{
			super( NAME + ApplicationFacade.DELIMITER + count, viewComponent );

			_linkageVO = linkageVO;

			count++;
		}

		private const RTL : Number = 0;

		private const LTR : Number = 1;

		private const UTD : Number = 0;

		private const DTU : Number = 1;


		private var _linkageVO : LinkageVO;

		private var directionalX : uint;

		private var directionalY : uint;

		private var isActive : Boolean;

		private var activeChanged : Boolean;

		public function get arrow() : Linkage
		{
			return viewComponent as Linkage;
		}

		public function get linkageVO() : LinkageVO
		{
			return _linkageVO;
		}

		override public function onRegister() : void
		{
			BindingUtils.bindSetter( sourceTargetChange, _linkageVO, "source" );
			BindingUtils.bindSetter( sourceTargetChange, _linkageVO, "target" );

			BindingUtils.bindSetter( visibleChange, _linkageVO.level, "visible" );

			calculatePositionAndSize();
			drawArrow();
		}

		override public function onRemove() : void
		{

		}

		private function commitProperties() : void
		{
			if ( activeChanged )
			{
				activeChanged = false;

				if ( isActive )
				{
					BindingUtils.bindSetter( objectsChanged, _linkageVO.source, "left" );
					BindingUtils.bindSetter( objectsChanged, _linkageVO.source, "top" );
					BindingUtils.bindSetter( objectsChanged, _linkageVO.source, "width" );
					BindingUtils.bindSetter( objectsChanged, _linkageVO.source, "height" );

					BindingUtils.bindSetter( objectsChanged, _linkageVO.target, "left" );
					BindingUtils.bindSetter( objectsChanged, _linkageVO.target, "top" );
					BindingUtils.bindSetter( objectsChanged, _linkageVO.target, "width" );
					BindingUtils.bindSetter( objectsChanged, _linkageVO.target, "height" );
				}
			}
		}

		private function calculatePositionAndSize() : void
		{
			var sourceObject : TreeElementVO = linkageVO.source;
			var targetObject : TreeElementVO = linkageVO.target;

			var pFromObj : Point;
			var pToObj : Point;

			var fromObjHalfWidth : Number = 0;
			var fromObjHalfHeight : Number = 0;

			var toObjHalfWidth : Number = 0;
			var toObjHalfHeight : Number = 0;

			var fromObjVertCross : Boolean = false;
			var toObjVertCross : Boolean = false;

			fromObjHalfWidth = sourceObject.width / 2;
			fromObjHalfHeight = sourceObject.height / 2;

			toObjHalfWidth = targetObject.width / 2;
			toObjHalfHeight = targetObject.height / 2;

			pFromObj = new Point( sourceObject.left + fromObjHalfWidth, sourceObject.top + fromObjHalfHeight );
			pToObj = new Point( targetObject.left + toObjHalfWidth, targetObject.top + toObjHalfHeight );

			var arrowWidth : Number = Math.abs( pToObj.x - pFromObj.x );
			var arrowHeight : Number = Math.abs( pToObj.y - pFromObj.y );

			var arrowRatio : Number = arrowWidth / arrowHeight;
			var sourceObjectRatio : Number = fromObjHalfWidth / fromObjHalfHeight;
			var targetObjectRatio : Number = toObjHalfWidth / toObjHalfHeight;

			/**
			 * If objects overlay each other then return from function
			 */
			if ( arrowWidth <= fromObjHalfWidth + toObjHalfWidth && arrowHeight <= fromObjHalfHeight + toObjHalfHeight )
			{
				arrow.width = 0;
				arrow.height = 0;
				return;
			}

			var dX : Number = 0;
			var dY : Number = 0;

			/**
			 * If arrowRatio > sourceObjectRatio then arrow crosses vertical border of fromObject else - horisontal
			 */
			if ( arrowRatio > sourceObjectRatio )
				fromObjVertCross = true;

			/**
			 * Calculates delta X and delta Y for arrow start point
			 */
			if ( fromObjVertCross )
			{
				dX = fromObjHalfWidth;
				dY = dX / arrowRatio;
			}
			else
			{
				dY = fromObjHalfHeight;
				dX = dY * arrowRatio;
			}

			if ( pFromObj.x < pToObj.x )
				pFromObj.x += dX;
			else
				pFromObj.x -= dX;


			if ( pFromObj.y < pToObj.y )
				pFromObj.y += dY;
			else
				pFromObj.y -= dY;


			if ( arrowRatio > targetObjectRatio )
				toObjVertCross = true;
			/**
			 * Calculates delta X and delta Y for arrow end point
			 */
			if ( toObjVertCross )
			{
				dX = toObjHalfWidth;
				dY = dX / arrowRatio;
			}
			else
			{
				dY = toObjHalfHeight;
				dX = dY * arrowRatio;
			}

			if ( pFromObj.x < pToObj.x )
				pToObj.x -= dX;
			else
				pToObj.x += dX;


			if ( pFromObj.y < pToObj.y )
				pToObj.y -= dY;
			else
				pToObj.y += dY;

			if ( pFromObj.x <= pToObj.x )
			{
				arrow.x = pFromObj.x;
				arrow.width = pToObj.x - pFromObj.x;
				directionalX = LTR;
			}
			else
			{
				arrow.x = pToObj.x;
				arrow.width = pFromObj.x - pToObj.x;
				directionalX = RTL;
			}

			if ( pFromObj.y <= pToObj.y )
			{
				arrow.y = pFromObj.y;
				arrow.height = pToObj.y - pFromObj.y;
				directionalY = UTD;
			}
			else
			{
				arrow.y = pToObj.y;
				arrow.height = pFromObj.y - pToObj.y;
				directionalY = DTU;
			}
		}

		private function drawArrow() : void
		{
			var alphaAngle : Number;
			var arrowHeadAngle : Number = 0.2;
			var arrowHeadLength : Number = 10;

			var startPoint : Point = new Point();
			var endPoint : Point = new Point();

			var graphics : Graphics = arrow.graphics;

			if ( directionalX == LTR )
				endPoint.x = arrow.width;
			else
				startPoint.x = arrow.width;

			if ( directionalY == UTD )
				endPoint.y = arrow.height;
			else
				startPoint.y = arrow.height;

			if ( Math.abs( Point.distance( startPoint, endPoint ) ) <= arrowHeadLength )
				return;

			var dX : Number;
			var dY : Number;

			var _numColor : Number = linkageVO.level.color;

			dX = startPoint.x - endPoint.x;
			dY = startPoint.y - endPoint.y;

			alphaAngle = Math.atan( dY / dX );

			if ( dX < 0 )
				alphaAngle += Math.PI;

			graphics.lineStyle( 3, _numColor, 1, true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.BEVEL );

			graphics.moveTo( startPoint.x, startPoint.y );
			graphics.lineTo( endPoint.x, endPoint.y );

			graphics.lineTo( endPoint.x + Math.cos( alphaAngle + arrowHeadAngle ) * arrowHeadLength,
													endPoint.y + Math.sin( alphaAngle + arrowHeadAngle ) * arrowHeadLength );

			graphics.lineTo( endPoint.x + Math.cos( alphaAngle - arrowHeadAngle ) * arrowHeadLength,
													endPoint.y + Math.sin( alphaAngle - arrowHeadAngle ) * arrowHeadLength );

			graphics.lineTo( endPoint.x, endPoint.y );
		}

		private function sourceTargetChange( source : Object ) : void
		{
			if ( _linkageVO.source && _linkageVO.target && !isActive )
				isActive = true;
			else if ( ( !_linkageVO.source || !_linkageVO.target ) && !isActive )
				isActive = false;
			else
				return;

			activeChanged = true;
			commitProperties();
		}

		private function objectsChanged( source : Object ) : void
		{
			if ( arrow.visible )
			{
				arrow.graphics.clear();
				calculatePositionAndSize();
				drawArrow();
			}
		}

		private function visibleChange( source : Object ) : void
		{	
			if( _linkageVO.level.visible )
			{
				arrow.graphics.clear();
				calculatePositionAndSize();
				drawArrow();
			}
			else
			{
				arrow.graphics.clear();
			}
			
			arrow.visible = _linkageVO.level.visible;
		}
	}
}