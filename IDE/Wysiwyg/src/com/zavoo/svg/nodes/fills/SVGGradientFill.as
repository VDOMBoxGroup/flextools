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

package com.zavoo.svg.nodes.fills
{
	import com.zavoo.svg.data.SVGColors;
	import com.zavoo.svg.nodes.SVGDefsNode;
	import com.zavoo.svg.nodes.SVGNode;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	
	import mx.utils.StringUtil;
	
	public class SVGGradientFill
	{
		public namespace xlink = 'http://www.w3.org/1999/xlink';
		
		public static function gradientFill(svgNode:SVGNode, fillXml:XML):void {
			
			var xml:XML = fillXml.copy();
			
			var type:String;
			var colors:Array = new Array();
			var ratios:Array = new Array();
			var alphas:Array = new Array();
			var matrix:Matrix = new Matrix();
			
			var node:XML;
			var offset:Number;
			var stop_color:Number;			
			var stop_opacity:Number;
			
			var spreadMethod:String;
			var interpolationMethod:String = InterpolationMethod.RGB;
			
			var tmp:String;
			var attributes:Object
			
			var graphics:Graphics = svgNode.graphics;
			
			var name:String = xml.localName().toString().toLowerCase();
			
			var href:String = xml.@xlink::href;
			if (href) {
				href = href.replace(/^#/,'');
				var hrefNode:SVGNode = svgNode.svgRoot.getElement(href);
				if (hrefNode is SVGDefsNode) {
					var tmpXML:XML = SVGDefsNode(hrefNode).getDef(href);
					xml.setChildren(tmpXML.children());
				}
			}
			
			if (name == 'lineargradient') {
				type = GradientType.LINEAR;
			}
			else if (name == 'radialgradient') {
				type = GradientType.RADIAL;
			}
			else {
				return;
			}
			
			var offset_total:Number = 0;
			
			var nodes:XMLList = xml.children();
			for each(node in nodes) {
				//Defaults
				stop_color = 0;
				stop_opacity = 1;
				spreadMethod = SpreadMethod.PAD; 
				
				tmp = node.@offset;
				offset = SVGColors.cleanNumber(node.@offset);
				if (tmp.indexOf('%') > -1) {
					offset /= 100; 
				}			
				
				offset_total += offset;
				offset = offset_total;
				
				if (offset > 1) {
					offset = 1;
				}					
				else if (offset < 0) {
					offset = 0;
				}
				
				offset *= 255;
				
				tmp = node.@spreadMethod;
				if (tmp == 'reflect') {
					spreadMethod = SpreadMethod.REFLECT;
				}
				else if (tmp == 'repeat') {
					spreadMethod = SpreadMethod.REPEAT;
				}
				
				tmp = node.@gradientTransform;
				if (tmp) {
					var matrixArray:Array = tmp.match(/matrix\(([^\)])\)/si);
					if (matrixArray) {
						matrixArray = String(matrixArray[1]).split(' ');
						matrix.a = matrixArray[0];
						matrix.b = matrixArray[1];
						matrix.c = matrixArray[2];
						matrix.d = matrixArray[3];
						matrix.tx = matrixArray[4];
						matrix.ty = matrixArray[5];					
					}					
				}
				else {
					var width:Number = svgNode.width;
					var height:Number = svgNode.height;
					matrix.createGradientBox(svgNode.getRoughWidth(), svgNode.getRoughHeight(), 0, 0);
				}
				
				tmp = xml.@fx;
				if (tmp) {
					matrix.tx = SVGColors.cleanNumber(tmp);
				}
				
				tmp = xml.@fy;
				if (tmp) {
					matrix.ty = SVGColors.cleanNumber(tmp);
				}
				
				attributes = getAttributes(node);
				
				if (attributes.hasOwnProperty('stop-color')) {
					stop_color = SVGColors.getColor(attributes['stop-color']);
				}
				
				if (attributes.hasOwnProperty('stop-opacity')) {
					stop_opacity = SVGColors.cleanNumber(attributes['stop-opacity']);			
				}				
								
				ratios.push(offset);
				colors.push(stop_color);
				alphas.push(stop_opacity);
			}
			
			graphics.beginGradientFill(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod);
		}
				
		public static function getAttributes(xml:XML):Object {
			var attributes:Object = new Object();
			var style:String = xml.@style;
			
			var attributeList:Array = new Array("stop-color", "stop-opacity");
			
			if (style) {
				var styleArray:Array = style.split(';');				
				var fields:Array;
				for (var i:uint=0; i < styleArray.length; i++) {
					if (styleArray[i]) {
						fields = String(styleArray[i]).split(':');					
						attributes[StringUtil.trim(fields[0])] = StringUtil.trim(fields[1]);
					}
				}
			}
			
			for each (var attribute:String in attributeList) {
				var value:String = xml.attribute(attribute).toString();
				if (value) {
					attributes[attribute] = value;
				}
			}
			
			return attributes;			
		}
	}
}