package net.vdombox.ide.modules.events.view.components
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.geom.Point;
	
	import mx.binding.utils.BindingUtils;
	
	import spark.components.Group;

	public class Linkage extends Group
	{
		public function Linkage()
		{
			watchers = {};
		}

		private const RTL : Number = 0;
		private const LTR : Number = 1;
		private const UTD : Number = 0;
		private const DTU : Number = 1;

		private var SOURCE_WATCHERS : String = "sourceWatchers";
		private var TARGET_WATCHERS : String = "targetWatchers";

		private var directionalX : uint;

		private var directionalY : uint;

		private var isActive : Boolean;

		private var activeChanged : Boolean;

		private var _target : ActionElement;
		private var _source : EventElement;

		private var sourceChanged : Boolean;
		private var targetChanged : Boolean;

		private var watchers : Object;

		public function get source() : EventElement
		{
			return _source;
		}

		public function set source( value : EventElement ) : void
		{
			if ( _source != value )
			{
				_source = value;
				sourceChanged = true;
				invalidateProperties();
			}
		}

		public function get target() : ActionElement
		{
			return _target;
		}

		public function set target( value : ActionElement ) : void
		{
			if ( _target != value )
			{
				_target = value;
				targetChanged = true;
				invalidateProperties();
			}
		}

		override protected function commitProperties() : void
		{
			super.commitProperties();

			var i : uint;

			if ( sourceChanged )
			{
				sourceChanged = false;

				var sourceWatchers : Array = watchers[ SOURCE_WATCHERS ];

				if ( sourceWatchers )
				{
					for ( i = 0; i < sourceWatchers.length; i++ )
					{
						sourceWatchers[ i ].unwatch();
					}
				}

				sourceWatchers = [];

				if ( _source )
				{
					sourceWatchers.push( BindingUtils.bindSetter( objectsChanged, _source, "x", true, true ) );
					sourceWatchers.push( BindingUtils.bindSetter( objectsChanged, _source, "y", true, true ) );
					sourceWatchers.push( BindingUtils.bindSetter( objectsChanged, _source, "width", true, true ) );
					sourceWatchers.push( BindingUtils.bindSetter( objectsChanged, _source, "height", true, true ) );
				}

				watchers[ SOURCE_WATCHERS ] = sourceWatchers;
			}

			if ( targetChanged )
			{
				targetChanged = false;

				var targetWatchers : Array = watchers[ TARGET_WATCHERS ];

				if ( targetWatchers )
				{
					for ( i = 0; i < targetWatchers.length; i++ )
					{
						targetWatchers[ i ].unwatch();
					}
				}

				targetWatchers = [];

				if ( _source )
				{
					targetWatchers.push( BindingUtils.bindSetter( objectsChanged, _target, "x", true, true ) );
					targetWatchers.push( BindingUtils.bindSetter( objectsChanged, _target, "y", true, true ) );
					targetWatchers.push( BindingUtils.bindSetter( objectsChanged, _target, "width", true, true ) );
					targetWatchers.push( BindingUtils.bindSetter( objectsChanged, _target, "height", true, true ) );
				}

				watchers[ TARGET_WATCHERS ] = targetWatchers;
			}
		}

		private function calculatePositionAndSize() : void
		{
			var sourceObject : EventElement = _source;
			var targetObject : ActionElement = _target;

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

			pFromObj = new Point( sourceObject.x + fromObjHalfWidth, sourceObject.y + fromObjHalfHeight );
			pToObj = new Point( targetObject.x + toObjHalfWidth, targetObject.y + toObjHalfHeight );

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
				width = 0;
				height = 0;
				return;
			}

			var dX : Number = 0;
			var dY : Number = 0;

			/**
			 * If arrowRatio > sourceObjectRatio then linkage crosses vertical border of fromObject else - horisontal
			 */
			if ( arrowRatio > sourceObjectRatio )
				fromObjVertCross = true;

			/**
			 * Calculates delta X and delta Y for linkage start point
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
			 * Calculates delta X and delta Y for linkage end point
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
				x = pFromObj.x;
				width = pToObj.x - pFromObj.x;
				directionalX = LTR;
			}
			else
			{
				x = pToObj.x;
				width = pFromObj.x - pToObj.x;
				directionalX = RTL;
			}

			if ( pFromObj.y <= pToObj.y )
			{
				y = pFromObj.y;
				height = pToObj.y - pFromObj.y;
				directionalY = UTD;
			}
			else
			{
				y = pToObj.y;
				height = pFromObj.y - pToObj.y;
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

			var graphics : Graphics = graphics;

			if ( directionalX == LTR )
				endPoint.x = width;
			else
				startPoint.x = width;

			if ( directionalY == UTD )
				endPoint.y = height;
			else
				startPoint.y = height;

			if ( Math.abs( Point.distance( startPoint, endPoint ) ) <= arrowHeadLength )
				return;

			var dX : Number;
			var dY : Number;

			var _numColor : Number = 0x2FDD00;

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

		private function objectsChanged( source : Object ) : void
		{
			if ( visible )
			{
				graphics.clear();
				calculatePositionAndSize();
				drawArrow();
			}
		}
	}
}