package net.vdombox.ide.modules.tree.view.components
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.modules.tree.events.LinkageEvent;
	import net.vdombox.ide.modules.tree.events.TreeElementEvent;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	
	import spark.components.Group;

	public class Linkage extends UIComponent
	{
		public function Linkage()
		{
			watchers = {};

			useHandCursor = true;
			buttonMode = true;

			addEventListener( MouseEvent.CLICK, clickHandler, false, 0, true );
			addEventListener( FlexEvent.CREATION_COMPLETE, createionCompleteHandler, false, 0, true );
		}

		[Embed( source="assets/delete_linkage.png" )]
		private var deleteLinkageClass : Class;

		private const RTL : Number = 0;
		private const LTR : Number = 1;
		private const UTD : Number = 0;
		private const DTU : Number = 1;

		private var SOURCE_WATCHERS : String = "sourceWatchers";
		private var TARGET_WATCHERS : String = "targetWatchers";

		private var _linkageVO : LinkageVO;

		private var directionalX : uint;

		private var directionalY : uint;

		private var isActive : Boolean;

		private var activeChanged : Boolean;

		private var _target : TreeElementVO;
		private var _source : TreeElementVO;

		private var sourceChanged : Boolean;
		private var targetChanged : Boolean;

		private var watchers : Object;

		private var deleteImage : SmoothImage;
		private var signatureGroup : SignatureGroup;

		private var _signatureVisible : Boolean;
		private var isSignatureVisibleChanged : Boolean;

		public function get linkageVO() : LinkageVO
		{
			return _linkageVO;
		}

		public function get source() : TreeElementVO
		{
			return _source;
		}

		public function set source( value : TreeElementVO ) : void
		{
			if ( _source != value )
			{
				_source = value;
				sourceChanged = true;
				invalidateProperties();
			}
		}

		public function get target() : TreeElementVO
		{
			return _target;
		}

		public function set target( value : TreeElementVO ) : void
		{
			if ( _target != value )
			{
				_target = value;
				targetChanged = true;
				invalidateProperties();
			}
		}

		public function set linkageVO( value : LinkageVO ) : void
		{
			_linkageVO = value;

			if ( _linkageVO )
			{
				BindingUtils.bindProperty( this, "source", _linkageVO, "source" );
				BindingUtils.bindProperty( this, "target", _linkageVO, "target" );

				BindingUtils.bindSetter( linkageVOChange, _linkageVO.level, "visible" );
			}
		}

		public function get signatureVisible() : Boolean
		{
			return _signatureVisible;
		}

		public function set signatureVisible( value : Boolean ) : void
		{
			if ( value == _signatureVisible )
				return;

			_signatureVisible = value;
			isSignatureVisibleChanged = true;

			invalidateProperties();
		}

		override protected function createChildren() : void
		{
			if ( !deleteImage )
			{
				deleteImage = new SmoothImage();
				deleteImage.width = 26;
				deleteImage.height = 26;
				deleteImage.source = deleteLinkageClass;
				deleteImage.addEventListener( MouseEvent.CLICK, deleteImage_clickHandler, false, 0, true );
			}

			if ( !signatureGroup )
			{
				signatureGroup = new SignatureGroup();
				signatureGroup.addEventListener( MouseEvent.CLICK, signatureGroup_clickHandler, false, 0, true );
				
				if( _linkageVO )
				{
					signatureGroup.color = _linkageVO.level.color;
					signatureGroup.number = _linkageVO.index;
				}
						
			}
		}

		override protected function commitProperties() : void
		{
			super.commitProperties();

			var i : uint;

			if ( isSignatureVisibleChanged )
			{
				isSignatureVisibleChanged = false;

				if ( _signatureVisible )
				{
					signatureGroup.x = width / 2 - signatureGroup.width / 2;
					signatureGroup.y = height / 2 - signatureGroup.height / 2;
					addChild( signatureGroup );
				}
				else
				{
					if( signatureGroup.parent == this )
						removeChild( signatureGroup );
				}
			}

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
					sourceWatchers.push( BindingUtils.bindSetter( objectsChanged, _source, "left", true, true ) );
					sourceWatchers.push( BindingUtils.bindSetter( objectsChanged, _source, "top", true, true ) );
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
					targetWatchers.push( BindingUtils.bindSetter( objectsChanged, _target, "left", true, true ) );
					targetWatchers.push( BindingUtils.bindSetter( objectsChanged, _target, "top", true, true ) );
					targetWatchers.push( BindingUtils.bindSetter( objectsChanged, _target, "width", true, true ) );
					targetWatchers.push( BindingUtils.bindSetter( objectsChanged, _target, "height", true, true ) );
				}

				watchers[ TARGET_WATCHERS ] = targetWatchers;
			}
		}

		private function calculatePositionAndSize() : void
		{
			var sourceObject : TreeElementVO = _source;
			var targetObject : TreeElementVO = _target;

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

			if ( signatureGroup )
			{
				signatureGroup.x = width / 2 - signatureGroup.width / 2;
				signatureGroup.y = height / 2 - signatureGroup.height / 2;
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

		private function linkageVOChange( object : Object ) : void
		{
			if ( !_linkageVO )
				return;

			if ( visible != _linkageVO.level.visible )
			{
				visible = _linkageVO.level.visible;
				graphics.clear();

				if ( visible )
				{
					calculatePositionAndSize();
					drawArrow();
				}
			}

			if ( _linkageVO.source != _source )
				source = _linkageVO.source;

			if ( _linkageVO.target != _target )
				target = _linkageVO.target;

			invalidateProperties();
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

		private function createionCompleteHandler( event : FlexEvent ) : void
		{
			dispatchEvent( new LinkageEvent( LinkageEvent.CREATED ) );
		}

		private function clickHandler( event : MouseEvent ) : void
		{
			if ( !stage )
				return;

			if( event.target is SignatureGroup )
				return;
			
			stage.addEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, false, 0, true );

			var buttonX : int = event.localX - deleteImage.width / 2;
			var buttonY : int = event.localY - deleteImage.height / 2;

			deleteImage.x = buttonX;
			deleteImage.y = buttonY;

			addChild( deleteImage );
		}

		private function stage_mouseDownHandler( event : MouseEvent ) : void
		{
			if ( stage && event.target != this && event.target != deleteImage )
			{
				stage.removeEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler );

				if ( deleteImage.parent == this )
					removeChild( deleteImage );
			}
		}

		private function deleteImage_clickHandler( event : MouseEvent ) : void
		{
			dispatchEvent( new TreeElementEvent( TreeElementEvent.DELETE_LINKAGE ) );
			
			event.stopImmediatePropagation();
		}

		private function signatureGroup_clickHandler( event : MouseEvent ) : void
		{
			event.stopImmediatePropagation();
		}
	}
}