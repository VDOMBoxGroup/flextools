package PowerPack.com.gen.parse
{
	import ExtendedAPI.com.utils.Utils;
	
	import GraphicAPI.drawing.BrushPatternStyle;
	import GraphicAPI.drawing.PStroke;
	import GraphicAPI.drawing.StrokePatternStyle;
	
	import PowerPack.com.gen.RunTimeError;
	
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientBevelFilter;
	import flash.filters.GradientGlowFilter;
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;
	
	
public class ListParser
{
	
	public static function processElmType(type:*):int
	{
		var _type:int = -1;
		var strType:String;
		
		/**
		 * 1 - Word
		 * 2 - String
		 * 3 - List
		 * 4 - Variable  
		 */
		 
		switch(typeof type)
		{
			case 'number':
				_type = int(type);
				break;
			
			case 'string':
				strType = type.toString().toLowerCase();
				
			case 'object':			
				if(!strType)
					if(type && type.hasOwnProperty('type') && type.type=='n' && type.hasOwnProperty('value'))
						strType = type.value.toLowerCase()
				
				if(int(strType)==0)
				{
					switch(strType)
					{
						case 'word':
							_type = 1;
							break;
						case 'string':
							_type = 2;
							break;
						case 'list':
							_type = 3;
							break;
						case 'variable':
							_type = 4;
							break;
					}
				}
				else
					_type = int(strType)
				break;
		}
		
		return _type;	
	}
	
	public static function processElmPosition(list:String, position:*, operation:String=null):int
	{
		var _position:int = -1;
		var str:String;
		var len:int = length(list);
		
		switch(typeof position)
		{
			case 'number':
				_position = int(position)-1;
				break;
			
			case 'string':
				str = position.toString().toLowerCase();
			case 'object':
				if(!str)
					if(position && position.hasOwnProperty('type') && position.type=='n' && position.hasOwnProperty('value'))
						str = position.value.toLowerCase();
				
				if(isNaN(Number(str)))
				{
					switch(str)
					{
						case 'head':
							_position = 0;
							break;
						case 'tail':
							_position = (operation=='put' ? len : len-1);
							break;
					}
				}
				else
					_position = int(position)-1;
					
				break;
		}
		
		return _position;	
	}

	public static function processElmValue(value:Object):String
	{
		var str:String = "";
		
		if(value!=null && value.hasOwnProperty('type') && value.hasOwnProperty('value'))
		{
			str = value.value;
		}
		else if(value!=null)
		{
			str = value.toString();
		}
		
		return str;
	}	
	
	public static function processPoints(list:String, contexts:Array):Array
	{
		var len:int = length(list);
		var arr:Array = [];
		
		for(var i:int=0; i<len; i++)
		{
			var strList:String = getElm(list,i+1);
			
			if(length(strList)!=2)
				throw new RunTimeError(null, 9007, [2]);
				
			arr.push(new Point(	int(getElmValue(strList,1,contexts)),
								int(getElmValue(strList,2,contexts))	));
		}
			
		return arr;
	}
	
	public static function processFlipDirection(type:*):int
	{
		var _type:int = 0;
		var _str:String = null;
		
		switch(typeof type)
		{
			case 'number':
				_type = int(type);
				break;
			
			case 'string':
				if(!_str && type) 
					_str = type.toString().toLowerCase();
			case 'object':
				if(!_str && type && type.hasOwnProperty('type') && type.type=='n' && type.hasOwnProperty('value'))
					_str = type.value.toLowerCase();
		
				switch(_str)
				{
					case 'horizontal':
						_type = 0;
						break;
	
					case 'vertical':
						_type = 1;
						break;
	
					default:
						_type = int(type)
						break;
				}
				break;
		}
		
		return _type;	
	}
	
	public static function processStrokeType(type:*):*
	{
		var ret:* = StrokePatternStyle.SOLID;
		var _type:int = 0;
		var _str:String = null;
		
		switch(typeof type)
		{
			case 'number':
				_type = int(type);
				break;
			
			case 'string':
				if(!_str && type) 
					_str = type.toString().toLowerCase();
			case 'object':
				if(!_str && type && type.hasOwnProperty('type') && type.type=='n' && type.hasOwnProperty('value'))
					_str = type.value.toLowerCase();
		
				switch(_str)
				{
					case null:
					case '':
					case 'solid':
						_type = 0;
						break;
						
					case 'dash':
						_type = 1;
						break;
						
					case 'dot':
						_type = 2;
						break;
						
					case 'dashdot':
						_type = 3;
						break;
						
					case 'dashdotdot':
						_type = 4;
						break;
						
					case 'clear':
					case 'none':
						_type = 5;
						break;
						
					case 'insideframe':
						_type = 6;
						break;
						
					default:
						_type = int(type)
						break;
				}
				break;
		}
		
		switch(_type)
		{
			case 0:
				ret = StrokePatternStyle.SOLID;
				break;
			case 1:
				ret = StrokePatternStyle.DASH;
				break;
			case 2:
				ret = StrokePatternStyle.DOT;
				break;
			case 3:
				ret = StrokePatternStyle.DASHDOT;
				break;
			case 4:
				ret = StrokePatternStyle.DASHDOTDOT;
				break;
			case 5:
				ret = StrokePatternStyle.NONE;
				break;
			case 6:
				ret = StrokePatternStyle.INSIDEFRAME;
				break;
		}
		
		return ret;	
	}
	
	public static function processBrushType(type:*, color:uint):*
	{
		var ret:* = null
		var _type:int = 0;
		var _str:String = null;
		
		switch(typeof type)
		{
			case 'number':
				_type = int(type);
				break;
			
			case 'string':
				if(!_str && type) 
					_str = type.toString().toLowerCase();
			case 'object':
				if(!_str && type && type.hasOwnProperty('type') && type.type=='n' && type.hasOwnProperty('value'))
					_str = type.value.toLowerCase();
		
				switch(_str)
				{
					case '':
					case 'solid':
						_type = 0;
						break;
						
					case null:
					case 'clear':
					case 'none':
						_type = 1;
						break;
						
					case 'bdiagonal':
						_type = 2;
						break;
						
					case 'fdiagonal':
						_type = 3;
						break;
						
					case 'cross':
						_type = 4;
						break;
						
					case 'diagcross':
						_type = 5;
						break;
						
					case 'horizontal':
						_type = 6;
						break;
						
					case 'vertical':
						_type = 7;
						break;
						
					default:
						_type = int(type)
						break;
				}
				break;
		}
		
		switch(_type)
		{
			case 0:
				ret = color;
				break;
			case 1:
				ret = null;
				break;
			case 2:
				ret = BrushPatternStyle.BDiagonal(color);
				break;
			case 3:
				ret = BrushPatternStyle.FDiagonal(color);
				break;
			case 4:
				ret = BrushPatternStyle.Cross(color);
				break;
			case 5:
				ret = BrushPatternStyle.DiagCross(color);
				break;
			case 6:
				ret = BrushPatternStyle.Horizontal(color);
				break;
			case 7:
				ret = BrushPatternStyle.Vertical(color);
				break;
		}
		
		return ret;	
	}
		
	public static function processSubFunc(sublist:String, contexts:Array):*
	{
		var len:int = length(sublist);
		
		if(len==0)
			return null;
		
		var strVal:String = getElm(sublist, 1);
		var ret:*;
		
		switch(strVal.toLowerCase())
		{
			case 'pen':
				if(len!=4)
					throw new RunTimeError(null, 9007, [4]);
					
				ret = new PStroke(
								uint(getElmValue(sublist, 2, contexts)),
								uint(getElmValue(sublist, 4, contexts)),
								processStrokeType(getElmValue(sublist, 3, contexts)));													
				break;
				
			case 'brush':
				if(len!=3)
					throw new RunTimeError(null, 9007, [3]);
					
				var bColor:uint = uint(getElmValue(sublist, 3, contexts));
				ret = processBrushType(getElmValue(sublist, 2, contexts), bColor);				
				break;
				
			case 'gradientoneway':
			case 'gradienttwoway':
				if(len!=4)
					throw new RunTimeError(null, 9007, [4]);		
	
				var gCol1:uint = uint(getElmValue(sublist, 2, contexts));
				var gCol2:uint = uint(getElmValue(sublist, 3, contexts));
				var gAngle:int = int(getElmValue(sublist, 4, contexts));
				
				var alpha1:Number = 1.0; 
				var alpha2:Number = 1.0;
				
				alpha1 = gCol1>0x00ffffff ? ((gCol1&0xff000000)>>>24)/255 : (gCol1==0 ? 0.0 : 1.0);
				alpha2 = gCol2>0x00ffffff ? ((gCol2&0xff000000)>>>24)/255 : (gCol2==0 ? 0.0 : 1.0);
				
				ret = new Object();
				ret.name = strVal.toLowerCase();
				ret.type = GradientType.LINEAR;
				ret.colors = [gCol1, gCol2];
				ret.alphas = [alpha1, alpha2];
				ret.ratios = [0, 255];
				ret.rotation = 2*Math.PI * (gAngle/360);
				ret.spreadMethod = SpreadMethod.REFLECT;			
				break;
				
			case 'texture':
				if(len!=2)
					throw new RunTimeError(null, 9007, [2]);
					
				ret = getElmValue(sublist, 2, contexts);		
				break;
				
			case 'filter':
				if(len<2)
					throw new RunTimeError(null, 9007, ['>1']);

				var fName:String = getElmValue(sublist, 2, contexts).toString().toLowerCase();
				var filter:*;
				var params:Object = {};				
				var index:int = 2;
				
				switch( fName )
				{
					case 'bevelfilter':
						if(len>index++)
							params.distance = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.angle = Number(getElmValue(sublist, index, contexts));
							
						if(len>index++)
							params.hColor = uint(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.hAlpha = Number(getElmValue(sublist, index, contexts))/100;
						if(len>index++)
							params.sColor = uint(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.sAlpha = Number(getElmValue(sublist, index, contexts))/100;
							
						if(len>index++)
							params.blurX = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.blurY = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.strength = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.type = getElmValue(sublist, index, contexts).toString();

						filter = new BevelFilter(
							params.hasOwnProperty('distance') ? params.distance : 4,
							params.hasOwnProperty('angle') ? params.angle : 45,
							params.hasOwnProperty('hColor') ? params.hColor : 16777215,
							params.hasOwnProperty('hAlpha') ? params.hAlpha : 1,
							params.hasOwnProperty('sColor') ? params.sColor : 0,
							params.hasOwnProperty('sAlpha') ? params.sAlpha : 1,
							params.hasOwnProperty('blurX') ? params.blurX : 4,
							params.hasOwnProperty('blurY') ? params.blurY : 4,
							params.hasOwnProperty('strength') ? params.strength : 1,
							params.hasOwnProperty('quality') ? params.quality : 1,
							params.hasOwnProperty('type') ? params.type : 'inner',
							params.hasOwnProperty('knockout') ? params.knockout : false);
						break;
						
					case 'blurfilter':
						if(len>index++)
							params.blurX = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.blurY = Number(getElmValue(sublist, index, contexts));

						filter = new BlurFilter(
							params.hasOwnProperty('blurX') ? params.blurX : 4,
							params.hasOwnProperty('blurY') ? params.blurY : 4,
							params.hasOwnProperty('quality') ? params.quality : 1);
						break;

					case 'colormatrixfilter':
						if(len>index++) {
							params.matrixList = getElm(sublist, index).toString();
							params.matrixListLen = length(params.matrixList);
							
							if(params.matrixListLen!=20)
								throw new RunTimeError(null, 9007, ['20']);		
							
							params.matrix = [];
							for (var i:int=0; i<params.matrixListLen; i++)
								params.matrix.push(Number(getElmValue(params.matrixList, i+1, contexts)));
						}
							
						filter = new ColorMatrixFilter(params.hasOwnProperty('matrix') ? params.matrix : null);
						break;
						
					case 'convolutionfilter':
						if(len>index++)
							params.matrixX = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.matrixY = Number(getElmValue(sublist, index, contexts));
						
						if(len>index++) {
							params.matrixList = getElm(sublist, index).toString();
							params.matrixListLen = length(params.matrixList);
							
							if(params.matrixListLen != params.matrixX*params.matrixY)
								throw new RunTimeError(null, 9007, [params.matrixX*params.matrixY]);		
							
							params.matrix = [];
							for (var ci:int=0; ci<params.matrixListLen; ci++)
								params.matrix.push(Number(getElmValue(params.matrixList, ci+1, contexts)));
						}
													
						if(len>index++)
							params.divisor = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.bias = Number(getElmValue(sublist, index, contexts));
							
						if(len>index++)
							params.preserveAlpha = getElmValue(sublist, index, contexts);							
						if(len>index++)
							params.clamp = getElmValue(sublist, index, contexts);
							
						if(len>index++)
							params.color = uint(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.alpha = Number(getElmValue(sublist, index, contexts))/100;
												
						filter = new ConvolutionFilter(
							params.hasOwnProperty('matrixX') ? params.matrixX : 0,
							params.hasOwnProperty('matrixY') ? params.matrixY : 0,
							params.hasOwnProperty('matrix') ? params.matrix : null,
							params.hasOwnProperty('divisor') ? params.divisor : 1.0,
							params.hasOwnProperty('bias') ? params.bias : 0.0,
							params.hasOwnProperty('preserveAlpha') ? params.preserveAlpha : true,
							params.hasOwnProperty('clamp') ? params.clamp : true,
							params.hasOwnProperty('color') ? params.color : 0,
							params.hasOwnProperty('alpha') ? params.alpha : 0.0);						
						break;
						
					case 'displacementmapfilter':						
						if(len>index++)
							params.mapBitmap = getElmValue(sublist, index, contexts);
							
						if(len>index++)
						{
							params.mapPointList = getElm(sublist, index).toString();
							params.mapPointListLen = length(params.mapPointList);
							
							if(params.mapPointListLen != 2)
								throw new RunTimeError(null, 9007, ['2']);		
							
							params.mapPoint = new Point(Number(getElmValue(params.mapPointList, 1, contexts)),
														Number(getElmValue(params.mapPointList, 2, contexts)));
						}
						
						if(len>index++)
							params.componentX = uint(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.componentY = uint(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.scaleX = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.scaleY = Number(getElmValue(sublist, index, contexts));

						if(len>index++)
							params.mode = getElmValue(sublist, index, contexts).toString();
						if(len>index++)
							params.color = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.alpha = Number(getElmValue(sublist, index, contexts))/100;

						filter = new DisplacementMapFilter(
							params.hasOwnProperty('mapBitmap') ? params.mapBitmap : null,
							params.hasOwnProperty('mapPoint') ? params.mapPoint : null,
							params.hasOwnProperty('componentX') ? params.componentX : 0,
							params.hasOwnProperty('componentY') ? params.componentY : 0,
							params.hasOwnProperty('scaleX') ? params.scaleX : 0.0,
							params.hasOwnProperty('scaleY') ? params.scaleY : 0.0,
							params.hasOwnProperty('mode') ? params.mode : 'wrap',
							params.hasOwnProperty('color') ? params.color : 0,
							params.hasOwnProperty('alpha') ? params.alpha : 0.0);
						break;
						
					case 'dropshadowfilter':
						if(len>index++)
							params.distance = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.angle = Number(getElmValue(sublist, index, contexts));
							
						if(len>index++)
							params.color = uint(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.alpha = Number(getElmValue(sublist, index, contexts))/100;
							
						if(len>index++)
							params.blurX = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.blurY = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.strength = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.inner = getElmValue(sublist, index, contexts);
						if(len>index++)
							params.hideObject = getElmValue(sublist, index, contexts);
											
						filter = new DropShadowFilter(
							params.hasOwnProperty('distance') ? params.distance : 4,
							params.hasOwnProperty('angle') ? params.angle : 45,
							params.hasOwnProperty('color') ? params.color : 0,
							params.hasOwnProperty('alpha') ? params.alpha : 1,							
							params.hasOwnProperty('blurX') ? params.blurX : 4,
							params.hasOwnProperty('blurY') ? params.blurY : 4,							
							params.hasOwnProperty('strength') ? params.strength : 1,
							params.hasOwnProperty('quality') ? params.quality : 1,							
							params.hasOwnProperty('inner') ? params.inner : false,
							params.hasOwnProperty('knockout') ? params.knockout : false,
							params.hasOwnProperty('hideObject') ? params.hideObject : false);
						break;
						
					case 'glowfilter':
						if(len>index++)
							params.color = uint(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.alpha = Number(getElmValue(sublist, index, contexts))/100;
							
						if(len>index++)
							params.blurX = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.blurY = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.strength = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.inner = getElmValue(sublist, index, contexts);
											
						filter = new GlowFilter(
							params.hasOwnProperty('color') ? params.color : 0xFF0000,
							params.hasOwnProperty('alpha') ? params.alpha : 1.0,							
							params.hasOwnProperty('blurX') ? params.blurX : 6,
							params.hasOwnProperty('blurY') ? params.blurY : 6,							
							params.hasOwnProperty('strength') ? params.strength : 2,
							params.hasOwnProperty('quality') ? params.quality : 1,							
							params.hasOwnProperty('inner') ? params.inner : false,
							params.hasOwnProperty('knockout') ? params.knockout : false);
						break;
						
					case 'gradientbevelfilter':
						filter = new GradientBevelFilter();
					case 'gradientglowfilter':
						if(!filter)
							filter = new GradientGlowFilter();

						if(len>index++)
							params.distance = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.angle = Number(getElmValue(sublist, index, contexts));

						if(len>index++) {
							params.colorList = getElm(sublist, index).toString();
							params.colorListLen = length(params.colorList);
							
							params.colors = [];
							for (i=0; i<params.colorListLen; i++)
								params.colors.push(uint(getElmValue(params.colorList, i+1, contexts)));
						}

						if(len>index++) {
							params.alphaList = getElm(sublist, index).toString();
							params.alphaListLen = length(params.alphaList);
							
							params.alphas = [];
							for (i=0; i<params.alphaListLen; i++)
								params.alphas.push(Number(getElmValue(params.alphaList, i+1, contexts))/100);
						}

						if(len>index++) {
							params.ratioList = getElm(sublist, index).toString();
							params.ratioListLen = length(params.ratioList);
							
							params.ratios = [];
							for (i=0; i<params.ratioListLen; i++)
								params.ratios.push(uint(getElmValue(params.ratioList, i+1, contexts)));
						}
													
						if(len>index++)
							params.blurX = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.blurY = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.strength = Number(getElmValue(sublist, index, contexts));
						if(len>index++)
							params.type = getElmValue(sublist, index, contexts);
							
						filter.distance = params.hasOwnProperty('distance') ? params.distance : 4;
						filter.angle = params.hasOwnProperty('angle') ? params.angle : 45;
						filter.colors = params.hasOwnProperty('colors') ? params.colors : null;
						filter.alphas = params.hasOwnProperty('alphas') ? params.alphas : null;														
						filter.ratios = params.hasOwnProperty('ratios') ? params.ratios : null;							
						filter.blurX = params.hasOwnProperty('blurX') ? params.blurX : 4;
						filter.blurY = params.hasOwnProperty('blurY') ? params.blurY : 4;							
						filter.strength = params.hasOwnProperty('strength') ? params.strength : 1;
						filter.quality = params.hasOwnProperty('quality') ? params.quality : 1;						
						filter.type = params.hasOwnProperty('type') ? params.type : 'inner';
						filter.knockout = params.hasOwnProperty('knockout') ? params.knockout : false;
						break;
				}
				
				ret = filter;
				break;
				
			case 'font':
				if(len<4)
					throw new RunTimeError(null, 9007, ['>3']);		
	
				var format:TextFormat = new TextFormat();
				var fArg:String;
	
	            format.font = getElmValue(sublist, 2, contexts);
	            format.size = int(getElmValue(sublist, 3, contexts));
	            format.color = uint(getElmValue(sublist, 4, contexts));
				
				for (i=4; i<len; i++)
				{
					fArg = getElmValue(sublist, i+1, contexts).toString().toLowerCase();
					switch( fArg )
					{
						case 'bold':
	            			format.bold = true;
							break;
						
						case 'italic':
	            			format.italic = true;
							break;
						
						case 'underline':
	            			format.underline = true;
							break;
							
						case 'center':
						case 'justify':
						case 'left':
						case 'right':
							format.align = fArg;
							break;
					}	
				}
	            ret = format;
				break;
		}
					
		return ret;	
	}

	private static function processList(
		list:String, 
		type:Object=null, 
		position:Object=null, 
		value:Object=null, 
		operation:String="get"):*
	{
		var _position:int = -1;
		var _type:int = -1;
		var len:int;
		var ret:*;
		var i:int;
		var arr:ArrayCollection;
		var listObj:Object = Parser.processList(list);
		
		if(!listObj.result) {
			throw listObj.error;
		}
	
		len = listObj.string.length-2;
		arr = new ArrayCollection(listObj.array);
	
		_position = processElmPosition(list, position, operation); 
		
		if(_position<0)
			throw new RunTimeError(null, 9011);
		
		/**
		 * 1 - Word
		 * 2 - String
		 * 3 - List
		 * 4 - Variable  
		 */		 
		_type = processElmType(type);
		
		if(_type<=0 && (operation=='exist' || operation=='update' || operation=='put'))
			throw new RunTimeError(null, 9011);
	
		if(operation=="put")
		{		
			if(_position<0 || _position>len)
				throw new RunTimeError(null, 9013);
		}
		else
		{
			if(_position<0 || _position>=len)
				throw new RunTimeError(null, 9013);
		}
		
		var str:String = processElmValue(value);
				
		if(operation=="update" || operation=="put")
		{
			switch(_type)
			{
				case 1:
					break;
				case 2:
					str = Utils.doubleQuotes(str);
					break;
				case 3:
					str = StringUtil.trim(str);
					break;
				case 4:
					str = "$"+StringUtil.trim(str);
					break;
			}
			
			if(operation=='put')
				arr.addItemAt(new LexemStruct(str, 'w', -1, null), _position+1);
			else
				arr.getItemAt(_position+1).origValue = str;
				
			ret = "";
			for(i=0; i<arr.length; i++)
				ret += (i>0?" ":"") + arr.getItemAt(i).origValue; 
		}
		else if(operation=="delete")
		{
			arr.removeItemAt(_position+1); 
	
			ret = "";
			for(i=0; i<arr.length; i++)
				ret += (i>0?" ":"") + arr.getItemAt(i).origValue; 
		}
		else if(operation=="get")
		{ 
			ret = arr.getItemAt(_position+1).origValue;
			ret = StringUtil.trim(ret);
			
			/*if(listObj.string.charAt(_position+1)=='A' || Parser.processList( ret ).result)
			{
				ret = StringUtil.trim(ret);
			}*/
		}
		else if(operation=="getType")
		{
			switch((listObj.string as String).charAt(_position+1))
			{
				case 'n':
				case 'o':
				case 'b':
				case 'i':
				case 'f':
				case 'w':
					ret = 1; // word
					break;
				case 's':
				case 'c':
					ret = 2; // string
					if( Parser.processList( arr.getItemAt(_position+1).origValue ).result )
						ret = 3; // list
					break;
				case 'A':			
					ret = 3; // list
					break;
				case 'v':
					ret = 4; // variable
					break;
				default:
					ret = 0; // undefined
			}
		}
		return ret;
	}
	
	public static function length(list:String):int
	{
		var length:int = 0;
		
		var listObj:Object = Parser.processList(list);
			
		if(listObj.result)
			length = listObj.string.length-2;
		else
			length = list.length	
		
		return length;	
	}

	public static function getElm(list:String, position:*):*
	{
		return processList(list, null, position);
	}

	public static function getElmValue(list:String, position:*, contexts:Array):*
	{
		var strElm:String = getElm(list, position).toString();
		
		var lexems:Array = Parser.getLexemArray(strElm);
		Parser.processLexemArray(lexems);
		lexems = Parser.convertLexemArray(lexems);
		var lexemObj:Object = Parser.processConvertedLexemArray(lexems, contexts);
		lexems = lexemObj.array;
		
		var prog:String = '';
		
		for (var i:int=0; i<lexems.length; i++)		
			prog += ' '+(lexems[i].type=='n' ? Utils.doubleQuotes(lexems[i].value) : lexems[i].value);
		
		var evalRes:*;
		
		try {
			evalRes = Parser.eval(prog, contexts);
		} catch(e:*) {
			evalRes = strElm;
		}
		
		return evalRes;
	}
	
	public static function getType(list:String, position:*):*
	{
		return processList(list, null, position, null, 'getType');
	}

	public static function exists(list:String, type:*, value:*):*
	{
		var len:int = length(list);
		var _type:int = processElmType(type);
		var _strVal:String = processElmValue(value);
		var _pos:int = -1;
		
		for(var i:int=1; i<=len; i++)
		{
			if(	_type==processList(list, null, i, null, 'getType') &&
				_strVal==processList(list, null, i, null, "get") )
			{
				_pos = i;
				break;
			}
		} 

		return _pos;	
	}

	public static function remove(list:String, position:*):*
	{
		return processList(list, null, position, null, 'delete');
	}
	
	public static function put(list:String, position:*, type:*, value:*):*
	{
		return processList(list, type, position, value, "put");
	}
	
	public static function update(list:String, position:*, type:*, value:*):*
	{
		return processList(list, type, position, value, "update");
	}

}
}