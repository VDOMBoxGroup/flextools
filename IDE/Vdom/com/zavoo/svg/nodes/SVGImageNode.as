package com.zavoo.svg.nodes
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	import vdom.managers.FileManager;
	
	public class SVGImageNode extends SVGNode
	{		
		private var bitmap:Bitmap;
		private var orignalBitmap:Bitmap;
		
		public var value:String;
		
		public function SVGImageNode(xml:XML):void {
			super(xml);
		}	
		
		/**
		 * Decode the base 64 image and load it
		 **/	
		protected override function draw():void {
			
			if(!_xml.@href[0])
				return;
			
			var ea:String = getAttribute("editable");
			
			var obj:Object = {};
			obj[ea] = "";
			
			if(ea)
				svgRoot.editableElements.push({attributes:obj, sourceObject:this});
				
			var href:String = _xml.@href[0].toString();
			value = href;
			href = href.substring(5, href.length - 1);
			
			
			var fileManager:FileManager = FileManager.getInstance();
			fileManager.loadResource("123123", href, this, "resource", true);
		}
		
		public function set resource(value:ByteArray):void
		{
			var d:* ="";
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onBytesLoaded );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onBytesLoaded );		
			loader.loadBytes( value );
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
			if(event.type == IOErrorEvent.IO_ERROR)
				return;
			var content:Bitmap = Bitmap(event.target.content);
			
			var m:Matrix = new Matrix();
			var sx:Number = _xml.@width/content.width;
			var sy:Number = _xml.@height/content.height;

			m.scale(sx, sy);
			var scaledImage:Bitmap = 
				new Bitmap(
					new BitmapData(_xml.@width, _xml.@height, true, 0x00000000), 
					PixelSnapping.AUTO,
					true
				);
			 
			scaledImage.bitmapData.draw(BitmapData(content.bitmapData), m);
			
			scaledImage.opaqueBackground = null;
			this.addChild(scaledImage);
			
			//this.addImageMask();	
			//this.transformImage();
			
		}
		
		
		/*private function transformImage():void {
			var trans:String = String(this.getAttribute('transform', ''));
			this.transform.matrix = this.getTransformMatrix(trans);
			//spriteMask.transform.matrix = bitmap.transform.matrix.clone();			
		}*/	
				
		/*override protected function transformNode():void {
			
		}*/		
		
		/*private function getTransformMatrix(transform:String):Matrix {
			var newMatrix:Matrix = new Matrix();
			var trans:String = String(this.getAttribute('transform', ''));
			
			if (trans != '') {
				var transArray:Array = trans.match(/\S+\(.*?\)/sg);
				for each(var tran:String in transArray) {
					var tranArray:Array = tran.split('(',2);
					if (tranArray.length == 2)
					{						
						var command:String = String(tranArray[0]);
						var args:String = String(tranArray[1]);
						args = args.replace(')','');
						var argsArray:Array = args.split(/[, ]/);
						//trace('Transform: ' + tran);
						switch (command) {
							case "matrix":
								if (argsArray.length == 6) {									
									newMatrix.a = argsArray[0];
									newMatrix.b = argsArray[1];
									newMatrix.c = argsArray[2];
									newMatrix.d = argsArray[3];
									newMatrix.tx = argsArray[4];
									newMatrix.ty = argsArray[5];
									return newMatrix;									
								}
								break;
								
							default:
								//trace('Unknown Transformation: ' + command);
						}
					}
				}			
			}			
			return null;
		}*/
		
	}
}