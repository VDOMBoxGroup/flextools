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
import com.zavoo.svg.data.SVGColors;
import com.zavoo.svg.data.SVGUnits;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextLineMetrics;

/** SVG Text element node **/
public class SVGTextNode extends SVGNode
{

	/**
	 * Hold node's text
	 **/
	public var rawText : String = '';

	/**
	 * TextField to render nodes text
	 **/
	private var _textField:TextField;

	/**
	 * Bitmap to display text rendered by _textField
	 **/
	private var _textBitmap:Bitmap;

	public function SVGTextNode(xml:XML):void {
		super(xml);
	}

	/**
	 * Get any child text (not text inside child nodes)
	 * If this node has any text create a TextField at this._textField
	 * Call SVGNode.parse()
	 **/
	override protected function parse():void {
		this.rawText = '';
		this.text = "";

		for each(var childXML:XML in this._xml.children()) {
			if (childXML.nodeKind() == 'text') {
				this.rawText += childXML.toString();
			}
		}

		getTextTranslation();

		super.parse();
	}

	private var _text : String = "";
	public function set text (value : String) : void
	{
		_text = value;

		if (_text != '' || rawText != '')
		{
			this._textField = new TextField();
			setAttributes();
			draw();
		}
	}

	public function get text () : String
	{
		return _text || rawText;
	}

	/**
	 * Call SVGNode.setAttributes()
	 * If this node contains text load text format (font, font-size, color, etc...)
	 * Render text to a bitmap and add bitmap to node
	 **/
	override protected function setAttributes():void {
		var currentNode:SVGNode;

		super.setAttributes();

		var embeddedFonts:Array = Font.enumerateFonts();

		if (this._textField != null)
		{
			var moveToLeft : Boolean = true;

			var fontFamily:String = this.getStyle('font-family');
			var fontSize:String = this.getStyle('font-size');
			var fill:String = this.getStyle('fill');
			var fontWeight:String = this.getStyle('font-weight');
			var textWidth : Number = Number(this.getStyle('width'));
			var textHeight : Number = Number(this.getStyle('height'));
			var textAlign : String = this.getStyle('align');

			var textAnchor:String = this.getStyle('text-anchor');
			if (/^\s*$/.test(textAnchor)) {
				textAnchor = null;
			}

			var textFormat:TextFormat = this._textField.getTextFormat();

			if (embeddedFonts.length == 0) { //No embedded fonts, use system fonts
				this._textField.embedFonts = false;
				if (fontFamily != null) {
					fontFamily = fontFamily.replace("'", '');
					textFormat.font = fontFamily;
				}
			}
			else { //Use embedded fonts
				this._textField.embedFonts = true;
				textFormat.font = Font(embeddedFonts[0]).fontName;
			}

			if (fontSize != null) {
				//Handle floating point font size
				var fontSizeNum:Number = SVGUnits.cleanNumber(fontSize);

				//Font size can be in user units, pixels (px), or points (pt); if no
				//measurement type given defaults to user units
				if (SVGUnits.getType(fontSize) == SVGUnits.PT) {
					fontSizeNum = SVGUnits.pointsToPixels(fontSizeNum);
				}

				var fontScale:Number = Math.floor(fontSizeNum);
				textFormat.size = fontScale;

				fontScale = fontSizeNum / fontScale;

				_textField.scaleX = fontScale;
				_textField.scaleY = fontScale;

			}

			if (fill != null) {
				textFormat.color = SVGColors.getColor(fill);
			}

			if (textAlign != null) {
				this._textField.autoSize = TextFieldAutoSize.NONE;
				textFormat.align = textAlign;

				moveToLeft = false;
			}

			if (!isNaN(textWidth) && textWidth != 0)
			{
				this._textField.width = textWidth;
			}

			if (!isNaN(textHeight) && textHeight != 0)
			{
				this._textField.height = textHeight;
			}

			// only bold/no bold supported for now (SVG has many levels of bold)
			currentNode = this;
			while (fontWeight == 'inherit') {
				if (currentNode.parent is SVGNode) {
					currentNode = SVGNode(currentNode.parent);
					fontWeight = currentNode.getStyle('font-weight');
				}
				else {
					fontWeight = null;
				}
			}
			if (fontWeight != null && fontWeight != 'normal') {
				textFormat.bold = true;
			}

			this._textField.defaultTextFormat = textFormat;
			this._textField.text = this.text;

			var textLineMetrics:TextLineMetrics = this._textField.getLineMetrics(0);

			currentNode = this;
			while (textAnchor == 'inherit') {
				if (currentNode.parent is SVGNode) {
					currentNode = SVGNode(currentNode.parent);
					textAnchor = currentNode.getStyle('text-anchor');
				}
				else {
					textAnchor = null;
				}
			}

			//Handle text-anchor attribute
			switch (textAnchor) {
				case 'middle':
					this._textField.x = textLineMetrics.x - 2 - Math.floor(textLineMetrics.width / 2);
					break;
				case 'end':
					this._textField.x = textLineMetrics.x - 2 - textLineMetrics.width;
					break;
				default: //'start'
					// 2 pixel gutter
					this._textField.x = -2;
					break;
			}

			//SVG Text elements position y attribute as baseline of text, not the
			//top
			this._textField.y = 0 - textLineMetrics.ascent - 2;

			if (this._textBitmap != null) {
				if (this.contains(this._textBitmap)) {
					this.removeChild(this._textBitmap);
				}
				this._textBitmap = null;
			}

			if (this.contains(this._textField)) {
				this.removeChild(this._textField);
			}

			if (embeddedFonts.length == 0) { //No embedded fonts, so we need to render the text to bitmap to support rotated text
				var bitmapData:BitmapData = new BitmapData(this._textField.width, this._textField.height, true, 0x000000);

				bitmapData.draw(this._textField);

				this._textBitmap = new Bitmap(bitmapData);
				this._textBitmap.smoothing = true;

				this._textBitmap.x = this._textField.x;
				this._textBitmap.y =  this._textField.y;

				if (moveToLeft)
				{
					textLineMetrics = this._textField.getLineMetrics(0);
					this._textBitmap.x = -textLineMetrics.x - 2; //account for 2px gutter
					this._textBitmap.y =  -textLineMetrics.ascent - 2; //account for 2px gutter
				}

				this._textField = null;
			}
			else { //There is an embedded font so display TextField

				this._textField.x = -2; //account for 2px gutter
				this._textField.y = -textLineMetrics.ascent - 2; //account for 2px gutter

			}
		}
	}

	/**
	 * Add _textBitmap to node
	 **/
	override protected function draw():void {
		super.draw();
		if (this._textBitmap != null) {
			this.addChild(this._textBitmap);
		}
		if (this._textField != null) {
			this.addChild(this._textField);
		}
	}

	private function getTextTranslation () : void
	{
		if (!rawText)
			return;

		var svgViewer : SVGViewer = svgRoot.parent as SVGViewer;
		if ( svgViewer != null)
			svgViewer.getTextTranslation(this);
	}


}
}
