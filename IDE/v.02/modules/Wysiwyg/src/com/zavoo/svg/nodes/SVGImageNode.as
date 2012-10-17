package com.zavoo.svg.nodes
{
	import com.zavoo.svg.SVGViewer;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	
	import mx.binding.utils.BindingUtils;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.model._vo.ResourceVO;

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
			
			var containerWidth : Number;
			var containerHeight : Number;

			//--------------------------------------------------------------------
			
			if ( _xml.@width[ 0 ])
				bitmapWidth = _xml.@width;
			else
				bitmapWidth = content.width;

			if ( _xml.@height[ 0 ])
				bitmapHeight = _xml.@height;
			else
				bitmapHeight = content.height;

			if (_xml.@containerWidth[0] && _xml.@containerWidth[0] > 0)
				containerWidth = _xml.@containerWidth;
			else
				containerWidth = bitmapWidth;
			
			if (_xml.@containerHeight[0] && _xml.@containerHeight[0] > 0)
				containerHeight = _xml.@containerHeight;
			else
				containerHeight = bitmapHeight;
				
			if (_xml.@repeat[0] && _xml.@repeat[0] != "")
				repeatValue = _xml.@repeat;
			else
				repeatValue = "";
			
			sx = bitmapWidth / content.width;
			sy = bitmapHeight / content.height;
			
			m.scale( sx, sy );
			
			if (bitmapWidth > containerWidth && containerWidth > 0)
				bitmapWidth = containerWidth;
			
			if (bitmapHeight > containerHeight && containerHeight > 0)
				bitmapHeight = containerHeight;
			
			switch ( repeatValue )
			{
				case "repeat":
				{
					drawRectWidth = containerWidth || bitmapWidth;
					drawRectHeight = containerHeight || bitmapHeight;
					repeat = true;
					break;
				}
				case "repeat-x":
				{
					drawRectWidth = containerWidth || bitmapWidth;
					drawRectHeight = bitmapHeight;
					repeat = true;
					break;
				}
				case "repeat-y":
				{
					drawRectWidth= bitmapWidth;
					drawRectHeight = containerHeight || bitmapHeight;
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