/*
 Copyright (c) 2008 James Hight

 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

package com.zavoo.svg.nodes
{
import com.zavoo.svg.SVGViewer;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Matrix;
import flash.utils.ByteArray;

import com.zavoo.svg.utils.Base64Decoder;

import mx.binding.utils.BindingUtils;

import mx.events.FlexEvent;

import net.vdombox.ide.common.model._vo.ResourceVO;

public class SVGImageNode extends SVGNode
{
	private var bitmap:Bitmap;

	public var value : String;

	public var resourceID : String;

	private var _resourceVO : ResourceVO;

	private var loader : Loader;

	public function SVGImageNode(xml:XML):void {
		super(xml);
	}

	/**
	 * Decode the base 64 image and load it
	 **/
	protected override function draw():void
	{
		var base64String:String = this._xml.@xlink::href;

		if (base64String.match(/^data:[a-z\/]*;base64,/))
		{
			var decoder:Base64Decoder = new Base64Decoder();
			var byteArray:ByteArray;

			base64String = base64String.replace(/^data:[a-z\/]*;base64,/, '');

			decoder.decode( base64String );
			byteArray = decoder.flush();

			loadBytes(byteArray);

		}
		else
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
			getResource();
		}

	}

	/**
	 * Load image byte array
	 **/
	private function loadBytes(byteArray:ByteArray):void {

		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onBytesLoaded );
		loader.loadBytes( byteArray );
	}

	/**
	 * Display image bitmap once bytes have loaded
	 **/
	private function onBytesLoaded( event:Event ) :void
	{
		var content:DisplayObject = LoaderInfo( event.target ).content;
		var bitmapData:BitmapData = new BitmapData( content.width, content.height, true, 0x00000000 );
		bitmapData.draw( content );

		bitmap = new Bitmap( bitmapData );
		bitmap.opaqueBackground = null;

		this.addChild(bitmap);

	}

	public function set resourceVO( value : ResourceVO ) : void
	{
		_resourceVO = value;

		if( !value.data )
		{
			BindingUtils.bindSetter( resourceDataLoaded, value, "data",false, true );
			return;
		}

		resourceDataLoaded();

	}

	private function resourceDataLoaded( object : Object = null ) : void
	{
		loader = new Loader();
		loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onResourceBytesLoaded );
		loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onResourceBytesLoaded );

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
	private function onResourceBytesLoaded( event : Event ) : void
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

	private function getResource() : void
	{
		var svgViewer : SVGViewer = svgRoot.parent as SVGViewer;

		if ( !svgViewer )
			return;

		if (!svgViewer.creationCompleted)
		{
			svgViewer.addEventListener( FlexEvent.CREATION_COMPLETE, viewerCreationCompleteHandler);
		}

		if( resourceID == "")
			return;

		svgViewer.getResource = this;
	}

	private function viewerCreationCompleteHandler( event : FlexEvent ) : void
	{
		var svgViewer : SVGViewer = event.target as SVGViewer;

		svgViewer.removeEventListener( FlexEvent.CREATION_COMPLETE, viewerCreationCompleteHandler);

		getResource();
	}
}
} 