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

package com.zavoo.svg {
	import com.zavoo.svg.events.SVGEvent;
import com.zavoo.svg.nodes.SVGImageNode;
import com.zavoo.svg.nodes.SVGNode;
	import com.zavoo.svg.nodes.SVGRoot;
import com.zavoo.svg.nodes.SVGTextNode;

import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
import mx.events.FlexEvent;
import mx.graphics.codec.PNGEncoder;
	import mx.utils.Base64Encoder;

import net.vdombox.ide.modules.wysiwyg.events.RendererEvent;

public class SVGViewer extends UIComponent {
			
		public var svgRoot:SVGRoot;		
				
		private var _urlLoader:URLLoader;
		private var _loader:Loader;
		
		private var _backgroundColor:int = -1;

		public var creationCompleted : Boolean;
				
		public function SVGViewer()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler)

			super();
			
			svgRoot = new SVGRoot();

			this.addChild(svgRoot);
						
			svgRoot.addEventListener(SVGEvent.SVG_LOAD, onSvgLoad);			
			svgRoot.addEventListener(Event.RESIZE, resizeContainer);

		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler)

			creationCompleted = true;
		}

		public function setXML(value:XML):Array
		{
			this.xml = value;

			return this.svgRoot.editableElements;
		}

		public function set source(value:*):void {
						
			var xml:XML = null;
			if (value is XML) {
				xml = XML(value);
			}
			else if (value is BitmapData) {
				xml = this.bitmapDataToXml(BitmapData(value));
			}
			else if (value is String) {
				var string:String = String(value);
				if (string.indexOf('<svg') == -1) {				
					xml = null;		
					_urlLoader = new URLLoader();
					_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
					_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
					_urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
					_urlLoader.addEventListener(Event.COMPLETE, onComplete);
					_urlLoader.load(new URLRequest(string));						
				}
				else {
					xml = new XML(string);
				}
			}
			
			if (xml != null) {
				this.xml = xml;
			}
		}	
		
		public function get source():XML {
			if (svgRoot == null) {
				return null;
			}
			return svgRoot.xml;
		}
		
		public function getAttribute(nodeID:String, attribute:String):String {
			var elem:* = null;
       		if (this.svgRoot.xml.@id == nodeID) {
               elem = this.svgRoot;
       		}
       		else {
            	elem = this.svgRoot.getElement(nodeID);
       		}

       		if (elem == null) {
            	return null;
       		}

       		return elem.getAttribute(attribute);
   		}

   		public function setAttribute(nodeID:String, attribute:String, attrValue:String):void {
       		var elem:* = null;
       		if (this.svgRoot.xml.@id == nodeID) {
            	elem = this.svgRoot;
       		}
       		else {
            	elem = this.svgRoot.getElement(nodeID);
      		}

      		if (elem != null) {
            	elem.setAttribute(attribute, attrValue);
       		}
   		}
   		
   		public function appendDomChild(xmlStr:String, parentId:String):void {
       		var node:SVGNode = this.svgRoot.getElement(parentId);
      		var xml:XML = new XML(xmlStr);
       		node.appendDomChild(xml, parentId);
   		}

   		public static function debug(msg:String):void{
       		ExternalInterface.call('__svg__debug', msg);
   		}
		
		private function onComplete(event:Event):void {
			var event:Event = new Event(event.type, event.bubbles, event.cancelable);
			this.dispatchEvent(event);
			
			var byteArray:ByteArray = ByteArray(_urlLoader.data);
						
			var readCount:uint = 512;
			if (byteArray.bytesAvailable < readCount) {
				readCount = byteArray.bytesAvailable;
			}
			
			var head:String = byteArray.readUTFBytes(readCount);
			if (head.indexOf('<svg') == -1) {
				
				_loader = new Loader();
				_loader.loadBytes(byteArray);
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);				
			}
			else {
				byteArray.position = 0;
				this.xml = new XML(byteArray.readUTFBytes(byteArray.bytesAvailable));
			}
		}
		
		private function onLoaderComplete(event:Event):void {
			this.xml = bitmapDataToXml(Bitmap(_loader.content).bitmapData);
		}
		
		private function onIOError(event:IOErrorEvent):void {
			var newEvent:IOErrorEvent = new IOErrorEvent(event.type, event.bubbles, event.cancelable, event.text);
			this.dispatchEvent(newEvent);
		}
		
		private function onProgress(event:ProgressEvent):void {
			var newEvent:ProgressEvent = new ProgressEvent(event.type, event.bubbles, event.cancelable, event.bytesLoaded, event.bytesTotal);
			this.dispatchEvent(newEvent);
		}
		
		private function bitmapDataToXml(bitmapData:BitmapData):XML {
			var pngEncoder:PNGEncoder = new PNGEncoder();
				
			var pngByteArray:ByteArray = pngEncoder.encode(bitmapData);
			
			var base64Encoder:Base64Encoder = new Base64Encoder();
			base64Encoder.encodeBytes(pngByteArray);
			
			var xmlString:String = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'
									+ '<svg width="' + bitmapData.width + '" height="' + bitmapData.height + '" viewBox="0 0 ' + 
									+ bitmapData.width + ' ' + bitmapData.height 
									+ '" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1">'
									+ '<g id="image"><image xlink:href="data:image/;base64,'
									+ base64Encoder.toString()
									+ '" /></g></svg>'; 	
									
			return new XML(xmlString);
		}		
		
		private function onSvgLoad(event:SVGEvent):void {
			var newEvent:SVGEvent = new SVGEvent(SVGEvent.SVG_LOAD, event.bubbles, event.cancelable);
			this.dispatchEvent(newEvent);
			
			this.resizeContainer();
		}	
				
		private function resizeContainer(event:Event = null):void {
			 			
			super.width = svgRoot.width;
			super.height = svgRoot.height;
			
			this.graphics.clear();
			if (this._backgroundColor >= 0) {
				this.graphics.clear();
				this.graphics.beginFill(this._backgroundColor);
				this.graphics.drawRect(0, 0, svgRoot.width, svgRoot.height);
				this.graphics.endFill(); 
			}
		}

		/*
		 * Getters / Setters
		 */
			
		public function set scale(value:Number):void {						
			svgRoot.scale = value;	
		}
		
		public function get scale():Number {
			return svgRoot.scale;
		}	
		
		override public function set scaleX(value:Number):void {						
			svgRoot.scaleX = value;			
		}
		
		override public function get scaleX():Number {
			return svgRoot.scaleX;
		}
		
		override public function set scaleY(value:Number):void {						
			svgRoot.scaleY = value;				
		}
		
		override public function get scaleY():Number {
			return svgRoot.scaleY;
		}
		
		public function set xml(value:XML):void {			
			svgRoot.xml = value;
        }
		
		public function get xml():XML {
			return svgRoot.xml;	
		}

		public function set backgroundColor(color:int):void {
			this._backgroundColor = color;
			this.resizeContainer();
		}
		
		public function get backGroundColor():int {
			return this._backgroundColor;
		}
		
		
		override public function set width(value:Number):void {
			//Do Nothing
		}
		
		/*override public function get width():Number {
			return svgRoot.width;
		}*/ 
		
		override public function set height(value:Number):void {
			//Do Nothing
		}
		
		/*override public function get height():Number {
			return svgRoot.height;
		}*/

		public function set getResource( svgImageNode : SVGImageNode ):void
		{
			var renderEvent : RendererEvent = new RendererEvent( RendererEvent.GET_RESOURCE );
			renderEvent.object = svgImageNode;

			dispatchEvent( renderEvent );
		}

		public function getTextTranslation (svgTextNode : SVGTextNode) : void
		{
			var renderEvent : RendererEvent = new RendererEvent( RendererEvent.TRANSLATE_SVG_TEXT );
			renderEvent.object = svgTextNode;

			dispatchEvent( renderEvent );
		}
		
	}
}