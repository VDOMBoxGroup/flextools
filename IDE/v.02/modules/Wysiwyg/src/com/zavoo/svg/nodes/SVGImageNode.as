package com.zavoo.svg.nodes
{
	import com.zavoo.svg.SVGViewer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.Canvas;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.events.RendererEvent;
	
	import spark.components.Group;
	import spark.primitives.Rect;
	import spark.primitives.supportClasses.FilledElement;

	public class SVGImageNode extends SVGNode
	{
		private var bitmap : Bitmap;
		private var orignalBitmap : Bitmap;

		public var value : String;

		private var _resourceVO : ResourceVO; 
		
		private var loader : Loader;
		
		public function SVGImageNode( xml : XML ) : void
		{
			super( xml );
		}

		/**
		 * Decode the base 64 image and load it
		 **/
		protected override function draw() : void
		{
			if ( !_xml.@href[ 0 ] )
				return;

			var ea : String = getAttribute( "editable" );

			var obj : Object = {};
			obj[ ea ] = "";

			if ( ea )
				svgRoot.editableElements.push( { attributes: obj, sourceObject: this } );

			var href : String = _xml.@href[ 0 ].toString();
			value = href;
			href = href.substring( 5, href.length - 1 );

			resourceID = href;
			svgRoot.parent.addEventListener( FlexEvent.CREATION_COMPLETE, ccHandler )

		}

		public var resourceID : String;
		
		public function set resourceVO( value : ResourceVO ) : void
		{
			_resourceVO = value;
			
			if( !value.data )
			{
				BindingUtils.bindSetter( dataLoaded, value, "data",false, true );
				return;
			}
			
			dataLoaded();
			
		}
		
		private function dataLoaded( object : Object = null ) : void 
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onBytesLoaded );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onBytesLoaded );
			
			try
			{
				loader.loadBytes( _resourceVO.data );
			}
			catch ( error : Error )
			{
				// FIXME Сделать обработку исключения если не грузится изображение
			}
		}
		

		/**
		 * Display image bitmap once bytes have loaded
		 **/
		private function onBytesLoaded( event : Event ) : void
		{
			loader = null;
			
			if ( event.type == IOErrorEvent.IO_ERROR )
				return;
			
			var content : Bitmap = Bitmap( event.target.content );

			var m : Matrix = new Matrix();

			var sx : Number, sy : Number;
			var bitmapWidth : Number, bitmapHeight : Number;
			
			var repeat : Boolean;
			var repeatValue : String;
			
			var drawRectWidth : Number;
			var drawRectHeight : Number;

			var svgViewer : SVGViewer = svgRoot.parent as SVGViewer;
			//--------------------------------------------------------------------
			
			if ( _xml.@width[ 0 ])
				bitmapWidth = _xml.@width;
			else
				bitmapWidth = content.width;

			if ( _xml.@height[ 0 ])
				bitmapHeight = _xml.@height;
			else
				bitmapHeight = content.height;

			if (_xml.@repeat[0] && _xml.@repeat[0] != "")
				repeatValue = _xml.@repeat;
			else
				repeatValue = "";
			
			sx = bitmapWidth / content.width;
			sy = bitmapHeight / content.height;
			
			m.scale( sx, sy );
			
			if (bitmapWidth > svgViewer.width && svgViewer.width > 0)
				bitmapWidth = svgViewer.width;
			
			if (bitmapHeight > svgViewer.height && svgViewer.height > 0)
				bitmapHeight = svgViewer.height;
			
			switch ( repeatValue )
			{
				case "repeat":
				{
					drawRectWidth = svgViewer.width || bitmapWidth;
					drawRectHeight = svgViewer.height || bitmapHeight;
					repeat = true;
					break;
				}
				case "repeat-x":
				{
					drawRectWidth = svgViewer.width || bitmapWidth;
					drawRectHeight = bitmapHeight;
					repeat = true;
					break;
				}
				case "repeat-y":
				{
					drawRectWidth= bitmapWidth;
					drawRectHeight = svgViewer.height || bitmapHeight;
					repeat = true;
					break;
				}
				default:
				case "no-repeat":
				{
					drawRectWidth = bitmapWidth;
					drawRectHeight = bitmapHeight;
					repeat = false;
					break;
				}	
			}
			
			graphics.clear();
			graphics.beginBitmapFill(content.bitmapData, m, repeat, true);
			graphics.drawRect( 0, 0, drawRectWidth, drawRectHeight );
			graphics.endFill();
			
		}

		private function ccHandler( event : FlexEvent ) : void 
		{
			if( resourceID == "")
				return;
			
			var svgViewer : SVGViewer = svgRoot.parent as SVGViewer;
			
			if ( !svgViewer )
				return;
				
			svgViewer.getResource = this;
		}
	
	}
}