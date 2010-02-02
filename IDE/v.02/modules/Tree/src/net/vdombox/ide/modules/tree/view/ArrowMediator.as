package net.vdombox.ide.modules.tree.view
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.geom.Point;

	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.StructureElementVO;
	import net.vdombox.ide.modules.tree.view.components.Arrow;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ArrowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ArrowMediator";

		private static var count : uint = 0;

		public function ArrowMediator( viewComponent : Object, linkageVO : LinkageVO )
		{
			super( NAME + ApplicationFacade.DELIMITER + count, viewComponent );

			_linkageVO = linkageVO;

			count++;
		}

		private var _linkageVO : LinkageVO;

		public function get arrow() : Arrow
		{
			return viewComponent as Arrow;
		}

		public function get linkageVO() : LinkageVO
		{
			return _linkageVO;
		}

		override public function onRegister() : void
		{
			var sourceBX : int = linkageVO.source.left + linkageVO.source.width / 2;
			var sourceBY : int = linkageVO.source.top + linkageVO.source.height / 2;

			var sourceEX : int = linkageVO.target.left + linkageVO.target.width / 2;
			var sourceEY : int = linkageVO.target.top + linkageVO.target.height / 2;

			calculatePoints();

			zzz( sourceBX, sourceBY, sourceEX, sourceEY );

//			arrow.x = linkageVO.source.left;
//			arrow.y = linkageVO.source.top;

//			arrow.width = Math.abs( linkageVO.source.left - linkageVO.target.left );
//			arrow.height = Math.abs( linkageVO.source.top - linkageVO.target.top );
		}

		override public function onRemove() : void
		{

		}

		private function zzz( sourceBX : Number, sourceBY : Number, sourceEX : Number, sourceEY : Number ) : void
		{
			var x0 : Number = 0;
			var y0 : Number = 0;
			var x1 : Number = arrow.width;
			var y1 : Number = arrow.height;

			var dX : Number;
			var dY : Number;

			var middleX : Number;
			var middleY : Number;

			var alf : Number;
			var dA : Number = 0.2;
			var dDist : Number = 10;

			var _numColor : Number = 0xFFF000;

			dX = x0 - x1;
			dY = y0 - y1;


			var dist : Number = dX * dX + dY * dY;
			//			trace(dist);
			middleX = x0 - dX / 2;
			middleY = y0 - dY / 2;

			alf = Math.atan( dY / dX );
			if ( dX < 0 )
				alf += Math.PI;


			var btX : Number = x0 - dX / 2;
			var btY : Number = y0 - dY / 2;

			arrow.graphics.clear();

			arrow.graphics.lineStyle( 8, _numColor, 0, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER );

			arrow.graphics.moveTo( x0, y0 );
			arrow.graphics.lineTo( x1, y1 );

			if ( true )
			{
				arrow.graphics.lineStyle( 10, _numColor, .1, false, LineScaleMode.NONE, CapsStyle.SQUARE,
										  JointStyle.MITER );
				arrow.graphics.moveTo( x0, y0 );
				arrow.graphics.lineTo( x1, y1 );

				arrow.graphics.lineTo( x1 + Math.cos( alf + dA ) * dDist, y1 + Math.sin( alf + dA ) * dDist );
				arrow.graphics.lineTo( x1 + Math.cos( alf - dA ) * dDist, y1 + Math.sin( alf - dA ) * dDist );
				arrow.graphics.lineTo( x1, y1 );



				arrow.graphics.lineStyle( 3, _numColor, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE,
										  JointStyle.MITER );
				arrow.graphics.moveTo( x0, y0 );
				arrow.graphics.lineTo( x1, y1 );

				arrow.graphics.lineStyle( 3, 0x000000, .4, false, LineScaleMode.NONE, CapsStyle.SQUARE,
										  JointStyle.MITER );
				arrow.graphics.moveTo( x0, y0 );
				arrow.graphics.lineTo( x1, y1 );

				arrow.graphics.lineStyle( 1, _numColor, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE,
										  JointStyle.MITER );

				arrow.graphics.moveTo( x0, y0 );
				arrow.graphics.lineTo( x1, y1 );

				//	this.graphics.beginFill(_numColor);

				arrow.graphics.lineStyle( 3, _numColor, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE,
										  JointStyle.MITER );
				arrow.graphics.lineTo( x1 + Math.cos( alf + dA ) * dDist, y1 + Math.sin( alf + dA ) * dDist );
				arrow.graphics.lineTo( x1 + Math.cos( alf - dA ) * dDist, y1 + Math.sin( alf - dA ) * dDist );
				arrow.graphics.lineTo( x1, y1 );

			}
			else
			{

				arrow.graphics.lineStyle( 3, _numColor, 1 * _alpha, false, LineScaleMode.NONE, CapsStyle.SQUARE,
										  JointStyle.MITER );
				arrow.graphics.moveTo( x0, y0 );
				arrow.graphics.lineTo( x1, y1 );

				arrow.graphics.lineStyle( 3, 0x000000, .4 * _alpha, false, LineScaleMode.NONE, CapsStyle.SQUARE,
										  JointStyle.MITER );
				arrow.graphics.moveTo( x0, y0 );
				arrow.graphics.lineTo( x1, y1 );

				arrow.graphics.lineStyle( 1, _numColor, 1 * _alpha, false, LineScaleMode.NONE, CapsStyle.SQUARE,
										  JointStyle.MITER );

				arrow.graphics.moveTo( x0, y0 );
				arrow.graphics.lineTo( x1, y1 );

				//	this.graphics.beginFill(_numColor);

				arrow.graphics.lineStyle( 3, _numColor, _alpha, false, LineScaleMode.NONE, CapsStyle.SQUARE,
										  JointStyle.MITER );
				arrow.graphics.lineTo( x1 + Math.cos( alf + dA ) * dDist, y1 + Math.sin( alf + dA ) * dDist );
				arrow.graphics.lineTo( x1 + Math.cos( alf - dA ) * dDist, y1 + Math.sin( alf - dA ) * dDist );
				arrow.graphics.lineTo( x1, y1 );
					//this.graphics.endFill();
			}
		}

		private function calculatePoints() : void
		{
			var nLeft : Number = 0;
			var nRight : Number = 0;
			var nTop : Number = 0;
			var nBottom : Number = 0;

			var _pFromObj : Point;
			var _pToObj : Point;
			var pFromObj : Point;
			var pToObj : Point;
			var pArrow1 : Point;
			var pArrow2 : Point;

			var fromObjWidth : Number = 0;
			var fromObjHeight : Number = 0;
			var fromObjHalfWidth : Number = 0;
			var fromObjHalfHeight : Number = 0;

			var toObjWidth : Number = 0;
			var toObjHeight : Number = 0;
			var toObjHalfWidth : Number = 0;
			var toObjHalfHeight : Number = 0;

			var fromObjVertCross : Boolean = false;
			var toObjVertCross : Boolean = false;

			var sourceObject : StructureElementVO = linkageVO.source;
			var targetObject : StructureElementVO = linkageVO.target;

			if ( sourceObject )
			{
				/**
				 * Calculates fromObject center coordinates
				 */
				fromObjWidth = sourceObject.width;
				fromObjHeight = sourceObject.height;

				fromObjHalfWidth = fromObjWidth / 2;
				fromObjHalfHeight = fromObjHeight / 2;
			}

			if ( targetObject )
			{
				/**
				 * Calculates toObject center coordinates
				 */
				toObjWidth = targetObject.width;
				toObjHeight = targetObject.height;

				toObjHalfWidth = toObjWidth / 2;
				toObjHalfHeight = toObjHeight / 2;
			}

			pFromObj = new Point( sourceObject.left + fromObjHalfWidth, sourceObject.top + fromObjHalfHeight );
			pToObj = new Point( targetObject.left + toObjHalfWidth, targetObject.top + toObjHalfHeight );

			if ( sourceObject )
			{
				var arrowWidth : Number = Math.abs( pToObj.x - pFromObj.x );
				var arrowHeight : Number = Math.abs( pToObj.y - pFromObj.y );

				var arrowRatio : Number = arrowWidth / arrowHeight;
				var sourceObjectRatio : Number = fromObjWidth / fromObjHeight;
				var targetObjectRatio : Number = toObjWidth / toObjHeight;

				/**
				 * If objects overlay each other then return from function
				 */
				if ( arrowWidth <= fromObjHalfWidth + toObjHalfWidth && arrowHeight <= fromObjHalfHeight + toObjHalfHeight )
					return;

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
				{
					nLeft = pFromObj.x += dX;
				}
				else
				{
					nLeft = pFromObj.x -= dX;
				}

				if ( pFromObj.y < pToObj.y )
				{
					nTop = pFromObj.y += dY;
				}
				else
				{
					nTop = pFromObj.y -= dY;
				}

				if ( targetObject )
				{
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
					{
						nRight = pToObj.x -= dX;
					}
					else
					{
						nRight = pToObj.x += dX;
					}

					if ( pFromObj.y < pToObj.y )
					{
						nBottom = pToObj.y -= dY;
					}
					else
					{
						nBottom = pToObj.y += dY;
					}
				}

			}

			arrow.x = pFromObj.x;
			arrow.y = pFromObj.y;

			arrow.width = pToObj.x - pFromObj.x;
			arrow.height = pToObj.y - pFromObj.y;
		}
	}
}