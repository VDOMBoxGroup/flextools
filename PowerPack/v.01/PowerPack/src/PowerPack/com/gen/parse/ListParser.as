package PowerPack.com.gen.parse
{
import ExtendedAPI.com.utils.Utils;

import GraphicAPI.drawing.BrushPatternStyle;
import GraphicAPI.drawing.PStroke;
import GraphicAPI.drawing.StrokePatternStyle;

import PowerPack.com.gen.errorClasses.RunTimeError;
import PowerPack.com.gen.parse.listClasses.ElmType;
import PowerPack.com.gen.parse.parseClasses.CodeFragment;
import PowerPack.com.gen.parse.parseClasses.LexemStruct;
import PowerPack.com.gen.parse.parseClasses.ParsedBlock;

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
	public static function list2Array(list:String):Array
	{
		var arr:Array = [];
		var block:ParsedBlock = Parser.fragmentLexems(Parser.getLexemArray(list.concat(), true), 'code');
  		
    	if(block.errFragment)
    		return null;
		
		Parser.validateFragmentedBlock(block);
		
    	if(block.errFragment)
    		return null;
    	
    	if(block.type != 'A')
    		return null;

		Parser.processListGroups(block.fragments);

		var curFragment:LexemStruct;
		var prevFragment:LexemStruct;
		var wordBuf:String = '';
		var grp:int = -1;
		var str:String;
		 
		for (var i:int=0; i<block.fragments.length; i++)
		{			
			curFragment = block.fragments[i];

			switch(curFragment.type)
			{
				case '[':
				case ']':
				case ';':
					curFragment.listGroup = grp--;
					pushWord();
					break;
						
				case 's':
				case 'c':
					curFragment.listGroup = grp--;
					pushWord();
					//str = replaceAllBracers(curFragment.origValue);
					//arr.push(Utils.replaceQuotes(str));
					arr.push( curFragment );
					break;
					
				case 'v':
					curFragment.listGroup = grp--;
					pushWord();
					//str = replaceAllBracers(curFragment.origValue);
					arr.push( curFragment );
					break;
					
				case 'W':
					curFragment.listGroup = grp--;
					pushWord();
					//str = replaceAllBracers(curFragment.origValue);
					arr.push( curFragment );
					break;
					
				case 'A':
					curFragment.listGroup = grp--;
					pushWord();
					//str = replaceAllBracers(curFragment.origValue);
					//arr.push( list2Array(str) );
					arr.push( curFragment );
					break;
					
				default:
					if(curFragment.listGroup == prevFragment.listGroup)
						wordBuf += curFragment.origValue;
					else if(!wordBuf)
						wordBuf = curFragment.origValue;
					else
						pushWord();
					break;
			}
			prevFragment = curFragment;
		}
		
       	return arr;
       	
       	function pushWord():void {
			if(wordBuf)
			{
				arr.push( {type:'w', value:wordBuf} );
				wordBuf = '';
			}
       	}
       	
       	function replaceAllBracers(_str:String):String {
       		var _buf:String = _str.concat();
			var _len:int = _buf.length;
			
			do {
				_len = _buf.length;
				_buf = StringUtil.trim(_buf);
				_buf = Utils.replaceBracers(_buf, '(');       		
			} while(_len!=_buf.length);
			
			return _buf;
       	}
	}
	
	public static function array2List(arr:Array):String
	{
		var listStr:String = '[ ';
		for (var i:int=0; i<arr.length; i++)
		{
			var curElm:Object = arr[i];
			
			if(curElm is Array)
			{
				listStr += array2List(curElm as Array);
			}
			else if(curElm is CodeFragment)
			{
				listStr += CodeFragment(curElm).origValue;
			}
			else if(curElm.hasOwnProperty('type') && curElm.hasOwnProperty('value'))
			{
				switch(curElm.type)
				{
					case 'v':
					case 'W':
					case 'w':					
					default:
						listStr += curElm.value;
						break;
				}
			}
			else
				listStr += curElm.toString();
			
			listStr += ' ';
		}	
		listStr += ']';
		return listStr;
	}
	
	/*
	public static function elm2Value(elm:Object):Object
	{
		var code:String = '';
		var retVal:Object;
		if(elm is String)
		{
			retVal = elm;
		}
		else if(elm is Array)
		{
			retVal = array2List(elm);
		}
		else if(elm.hasOwnProperty('type') && elm.hasOwnProperty('value'))
		{
			switch(elm.type)
			{
				case 'v':
				case 'W':
					code = '$'+elm.value;
					break;
					
				case 'w':
					code = elm.value;
					break;
			}
			
			var block:ParsedBlock = Parser.fragmentLexems(Parser.getLexemArray(elm.value.concat(), false), 'text');
			executeCodeFragment(curFragment, contexts, stepReturn);
		}
		
		return retVal;
	}
	*/
	
	/*
	public static function processElmValue(obj:Object):String
	{
		var str:String = "";
		
		if(obj!=null && obj.hasOwnProperty('type') && obj.hasOwnProperty('value'))
		{
			str = obj.value.toString();
		}
		else if(obj!=null)
		{
			str = obj.toString();
		}
		
		return str;
	}
	*/
	
	public static function processElmType(type:Object):int
	{
		var _type:int = ElmType.UNKNOWN;
		var strType:String;
		 
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
							_type = ElmType.WORD;
							break;
						case 'string':
							_type = ElmType.STRING;
							break;
						case 'list':
							_type = ElmType.LIST;
							break;
						case 'variable':
							_type = ElmType.VARIABLE;
							break;
					}
				}
				else
					_type = int(strType)
				break;
		}
		
		return _type;	
	}
	
	public static function processElmPosition(listLen:int, position:Object, operation:String=null):int
	{
		var _position:int = -1;
		var str:String;
		var len:int = listLen;
		
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
	
	public static function processFlipDirection(drct:Object):int
	{
		var _drct:int = 0;
		var _str:String = null;
		
		switch(typeof drct)
		{
			case 'number':
				_drct = int(drct);
				break;
			
			case 'string':
				if(!_str && drct) 
					_str = drct.toString().toLowerCase();
			case 'object':
				if(!_str && drct && 
					drct.hasOwnProperty('type') && drct.hasOwnProperty('value') && 
					drct.type=='n')
					_str = drct.value.toLowerCase();
		
				switch(_str)
				{
					case 'horizontal':
						_drct = 0;
						break;
	
					case 'vertical':
						_drct = 1;
						break;
	
					default:
						_drct = int(drct)
						break;
				}
				break;
		}
		
		return _drct;	
	}
	
	public static function processStrokeType(type:Object):Object
	{
		var ret:Object = StrokePatternStyle.SOLID;
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
				if(!_str && type && 
					type.hasOwnProperty('type') && type.hasOwnProperty('value') &&
					type.type=='n' )
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
	
	public static function processBrushType(type:Object, color:uint):Object
	{
		var ret:Object;
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
				if(!_str && type && 
					type.hasOwnProperty('type') && type.hasOwnProperty('value') && 
					type.type=='n')
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

	public static function processPoints(list:String, contexts:Array):Array
	{
		var arr:Array = list2Array(String(list)); 
		var ret:Array = []; 
		
		for(var i:int=0; i<arr.length; i++)
		{
			var strSublist:String = getElm(arr,i+1);
			var arrSublist:Array = list2Array(String(strSublist));
			
			if(arrSublist.length!=2)
				throw new RunTimeError(null, 9007, [2]);
				
			ret.push(new Point(	int(getElmValue(arrSublist,1,contexts)),
								int(getElmValue(arrSublist,2,contexts))	));
		}
			
		return ret;
	}
			
	public static function processSubFunc(sublist:String, contexts:Array):*
	{
		var arr:Array = list2Array(String(sublist)); 
		var len:int = arr.length;
		
		if(len==0)
			return null;
		
		var strVal:String = getElm(arr, 1);
		var ret:*;
		
		switch(strVal.toLowerCase())
		{
			case 'pen':
				if(len!=4)
					throw new RunTimeError(null, 9007, [4]);
					
				ret = new PStroke(
								uint(getElmValue(arr, 2, contexts)),
								uint(getElmValue(arr, 4, contexts)),
								processStrokeType(getElmValue(arr, 3, contexts)));													
				break;
				
			case 'brush':
				if(len!=3)
					throw new RunTimeError(null, 9007, [3]);
					
				var bColor:uint = uint(getElmValue(arr, 3, contexts));
				ret = processBrushType(getElmValue(arr, 2, contexts), bColor);				
				break;
				
			case 'gradientoneway':
			case 'gradienttwoway':
				if(len!=4)
					throw new RunTimeError(null, 9007, [4]);		
	
				var gCol1:uint = uint(getElmValue(arr, 2, contexts));
				var gCol2:uint = uint(getElmValue(arr, 3, contexts));
				var gAngle:int = int(getElmValue(arr, 4, contexts));
				
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
					
				ret = getElmValue(arr, 2, contexts);		
				break;
				
			case 'filter':
				if(len<2)
					throw new RunTimeError(null, 9007, ['>1']);

				var fName:String = getElmValue(arr, 2, contexts).toString().toLowerCase();
				var filter:*;
				var params:Object = {};				
				var index:int = 2;
				
				switch( fName )
				{
					case 'bevelfilter':
						if(len>index++)
							params.distance = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.angle = Number(getElmValue(arr, index, contexts));
							
						if(len>index++)
							params.hColor = uint(getElmValue(arr, index, contexts));
						if(len>index++)
							params.hAlpha = Number(getElmValue(arr, index, contexts))/100;
						if(len>index++)
							params.sColor = uint(getElmValue(arr, index, contexts));
						if(len>index++)
							params.sAlpha = Number(getElmValue(arr, index, contexts))/100;
							
						if(len>index++)
							params.blurX = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.blurY = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.strength = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.type = getElmValue(arr, index, contexts).toString();

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
							params.blurX = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.blurY = Number(getElmValue(arr, index, contexts));

						filter = new BlurFilter(
							params.hasOwnProperty('blurX') ? params.blurX : 4,
							params.hasOwnProperty('blurY') ? params.blurY : 4,
							params.hasOwnProperty('quality') ? params.quality : 1);
						break;

					case 'colormatrixfilter':
						if(len>index++) {
							params.matrixList = list2Array(getElm(arr, index).toString());
							params.matrixListLen = params.matrixList.length;
							
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
							params.matrixX = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.matrixY = Number(getElmValue(arr, index, contexts));
						
						if(len>index++) {
							params.matrixList = list2Array(getElm(arr, index).toString());
							params.matrixListLen = params.matrixList.length;
							
							if(params.matrixListLen != params.matrixX*params.matrixY)
								throw new RunTimeError(null, 9007, [params.matrixX*params.matrixY]);		
							
							params.matrix = [];
							for (var ci:int=0; ci<params.matrixListLen; ci++)
								params.matrix.push(Number(getElmValue(params.matrixList, ci+1, contexts)));
						}
													
						if(len>index++)
							params.divisor = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.bias = Number(getElmValue(arr, index, contexts));
							
						if(len>index++)
							params.preserveAlpha = getElmValue(arr, index, contexts);							
						if(len>index++)
							params.clamp = getElmValue(arr, index, contexts);
							
						if(len>index++)
							params.color = uint(getElmValue(arr, index, contexts));
						if(len>index++)
							params.alpha = Number(getElmValue(arr, index, contexts))/100;
												
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
							params.mapBitmap = getElmValue(arr, index, contexts);
							
						if(len>index++)
						{
							params.mapPointList = list2Array(getElm(arr, index).toString());
							params.mapPointListLen = params.mapPointList.length;
							
							if(params.mapPointListLen != 2)
								throw new RunTimeError(null, 9007, ['2']);		
							
							params.mapPoint = new Point(Number(getElmValue(params.mapPointList, 1, contexts)),
														Number(getElmValue(params.mapPointList, 2, contexts)));
						}
						
						if(len>index++)
							params.componentX = uint(getElmValue(arr, index, contexts));
						if(len>index++)
							params.componentY = uint(getElmValue(arr, index, contexts));
						if(len>index++)
							params.scaleX = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.scaleY = Number(getElmValue(arr, index, contexts));

						if(len>index++)
							params.mode = getElmValue(arr, index, contexts).toString();
						if(len>index++)
							params.color = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.alpha = Number(getElmValue(arr, index, contexts))/100;

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
							params.distance = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.angle = Number(getElmValue(arr, index, contexts));
							
						if(len>index++)
							params.color = uint(getElmValue(arr, index, contexts));
						if(len>index++)
							params.alpha = Number(getElmValue(arr, index, contexts))/100;
							
						if(len>index++)
							params.blurX = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.blurY = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.strength = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.inner = getElmValue(arr, index, contexts);
						if(len>index++)
							params.hideObject = getElmValue(arr, index, contexts);
											
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
							params.color = uint(getElmValue(arr, index, contexts));
						if(len>index++)
							params.alpha = Number(getElmValue(arr, index, contexts))/100;
							
						if(len>index++)
							params.blurX = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.blurY = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.strength = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.inner = getElmValue(arr, index, contexts);
											
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
							params.distance = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.angle = Number(getElmValue(arr, index, contexts));

						if(len>index++) {
							params.colorList = list2Array(getElm(arr, index).toString());
							params.colorListLen = params.colorList.length;
							
							params.colors = [];
							for (i=0; i<params.colorListLen; i++)
								params.colors.push(uint(getElmValue(params.colorList, i+1, contexts)));
						}

						if(len>index++) {
							params.alphaList = list2Array(getElm(arr, index).toString());
							params.alphaListLen = params.alphaList.length;
							
							params.alphas = [];
							for (i=0; i<params.alphaListLen; i++)
								params.alphas.push(Number(getElmValue(params.alphaList, i+1, contexts))/100);
						}

						if(len>index++) {
							params.ratioList = list2Array(getElm(arr, index).toString());
							params.ratioListLen = params.ratioList.length;
							
							params.ratios = [];
							for (i=0; i<params.ratioListLen; i++)
								params.ratios.push(uint(getElmValue(params.ratioList, i+1, contexts)));
						}
													
						if(len>index++)
							params.blurX = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.blurY = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.strength = Number(getElmValue(arr, index, contexts));
						if(len>index++)
							params.type = getElmValue(arr, index, contexts);
							
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
	
	            format.font = String(getElmValue(arr, 2, contexts));
	            format.size = int(getElmValue(arr, 3, contexts));
	            format.color = uint(getElmValue(arr, 4, contexts));
				
				for (i=4; i<len; i++)
				{
					fArg = getElmValue(arr, i+1, contexts).toString().toLowerCase();
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
	
	/*
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
	
		len = listObj.value.length-2;
		arr = new ArrayCollection(listObj.array);
	
		_position = processElmPosition(list, position, operation); 
		
		if(_position<0)
			throw new RunTimeError(null, 9011);
		
		
		 // 1 - Word
		 // 2 - String
		 // 3 - List
		 // 4 - Variable  
		 		 
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
					str = Utils.quotes(str);
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
			
			
			//if(listObj.value.charAt(_position+1)=='A' || Parser.processList( ret ).result)
			//{
			//	ret = StringUtil.trim(ret);
			//}
			
		}
		else if(operation=="getType")
		{
			switch((listObj.value as String).charAt(_position+1))
			{
				case 'n':
				case 'o':
				case 'b':
				case 'i':
				case 'f':
				case 'w':
					ret = ElmType.WORD; // word
					break;
				case 's':
				case 'c':
					ret = ElmType.STRING; // string
					if( Parser.processList( arr.getItemAt(_position+1).origValue ).result )
						ret = ElmType.LIST; // list
					break;
				case 'A':			
					ret = ElmType.LIST; // list
					break;
				case 'v':
					ret = ElmType.VARIABLE; // variable
					break;
				default:
					ret = ElmType.UNKNOWN; // undefined
			}
		}
		return ret;
	}
	*/
	
	public static function length(list:Object):int
	{		
		var arr:Array = [];
		
		if(list is String)
			arr = list2Array(String(list)); 
		else if(list is Array)
			arr = list as Array;
		
		return arr.length;	
	}

	public static function getElm(list:Object, position:Object):String
	{
		var arr:Array = [];
		var pos:int;
		var ret:String;
		
		if(list is String)
			arr = list2Array(String(list)); 
		else if(list is Array)
			arr = list as Array;	
		
		pos = processElmPosition(arr.length, position, 'get');
		
		if(pos<0)
			throw new RunTimeError(null, 9011);

		if(pos>=arr.length)
			throw new RunTimeError(null, 9013);			
		
		var elm:Object = arr[pos];
		
		if(elm is CodeFragment)
			ret = CodeFragment(elm).origValue;
		else if(elm.hasOwnProperty('type') && elm.hasOwnProperty('value'))
			ret = elm.value;
		else
			ret = elm.toString();
		
		return ret;
	}

	public static function getElmValue(list:Object, position:Object, contexts:Array):Object
	{
		var arr:Array = [];
		var pos:int;
		var ret:Object;
		
		if(list is String)
			arr = list2Array(String(list)); 
		else if(list is Array)
			arr = list as Array;	
		
		pos = processElmPosition(arr.length, position, 'get');
		
		if(pos<0)
			throw new RunTimeError(null, 9011);

		if(pos>=arr.length)
			throw new RunTimeError(null, 9013);			
		
		var elm:Object = arr[pos];
		
		if(elm is CodeFragment)
		{
			CodeParser.executeCodeFragment(CodeFragment(elm), contexts);			
			ret = CodeFragment(elm).retValue;
		}
		else if(elm is LexemStruct)
		{
			CodeParser.evaluateLexem(LexemStruct(elm), contexts);
			ret = Parser.eval(LexemStruct(elm).code, contexts);
		}
		else if(elm.hasOwnProperty('type') && elm.hasOwnProperty('value'))
			ret = elm.value;
		else
			ret = elm.toString();
		
		return ret;
	}
	
	public static function getType(list:Object, position:Object):int
	{
		var arr:Array = [];
		var pos:int;
		var ret:int;
		
		if(list is String)
			arr = list2Array(String(list)); 
		else if(list is Array)
			arr = list as Array;	
		
		pos = processElmPosition(arr.length, position, 'get');
		
		if(pos<0)
			throw new RunTimeError(null, 9011);

		if(pos>=arr.length)
			throw new RunTimeError(null, 9013);			
		
		var elm:Object = arr[pos];		
		
		if(elm is LexemStruct)
		{
			switch(LexemStruct(elm).type)
			{
				case 'n':
				case 'o':
				case 'b':
				case 'i':
				case 'f':
				case 'w':
					ret = ElmType.WORD;
					break;
				case 's':
				case 'c':
					ret = ElmType.STRING; 
					break;
				case 'A':			
					ret = ElmType.LIST;
					break;
				case 'v':
				case 'W':
					ret = ElmType.VARIABLE;
					break;
				default:
					ret = ElmType.UNKNOWN;
			}
		}
		else if(elm.hasOwnProperty('type') && elm.hasOwnProperty('value'))
			ret = ElmType.WORD;			
		else
			ret = ElmType.WORD;					
		
		return ret;
	}

	public static function exists(list:Object, type:Object, value:String):int
	{
		var arr:Array = [];
		var pos:int;
		var ret:int = 0;
		var _type:int = processElmType(type);
		
		if(list is String)
			arr = list2Array(String(list)); 
		else if(list is Array)
			arr = list as Array;	
					
		for(var i:int=1; i<=arr.length; i++)
		{
			if(	_type==getType(arr, i) &&
				value==getElm(arr, i) )
			{
				ret = i;
				break;
			}
		}
		
		return ret;
	}

	public static function remove(list:Object, position:Object):String
	{
		var arr:Array = [];
		var pos:int;
		var ret:int;
		
		if(list is String)
			arr = list2Array(String(list)); 
		else if(list is Array)
			arr = list as Array;	
		
		var arrCol:ArrayCollection = new ArrayCollection(arr);
		
		pos = processElmPosition(arr.length, position, 'get');
		
		if(pos<0)
			throw new RunTimeError(null, 9011);

		if(pos>=arr.length)
			throw new RunTimeError(null, 9013);
		
		arrCol.removeItemAt(pos);			
		
		return array2List(arr);
	}
		
	public static function put(list:Object, position:Object, type:Object, value:String):String
	{
		var arr:Array = [];
		var pos:int;
		var ret:int;
		var _type:int = processElmType(type);
		var _value:String;
		
		if(list is String)
			arr = list2Array(String(list)); 
		else if(list is Array)
			arr = list as Array;	
		
		var arrCol:ArrayCollection = new ArrayCollection(arr);
		
		pos = processElmPosition(arr.length, position, 'put');
		
		if(pos<0)
			throw new RunTimeError(null, 9011);

		if(pos>arr.length)
			throw new RunTimeError(null, 9013);

		switch(_type)
		{
			case ElmType.WORD:
				_value = value;
				break;
			case ElmType.STRING:
				_value = Utils.quotes(value);
				break;
			case ElmType.LIST:
				_value = StringUtil.trim(value);
				break;
			case ElmType.VARIABLE:
				_value = "$"+StringUtil.trim(_value);
				break;
		}
		
		arrCol.addItemAt(_value, pos);
					
		return array2List(arr);
	}
	
	public static function update(list:Object, position:Object, type:Object, value:String):String
	{
		var arr:Array = [];
		var pos:int;
		var ret:int;
		var _type:int = processElmType(type);
		var _value:String;
		
		if(list is String)
			arr = list2Array(String(list)); 
		else if(list is Array)
			arr = list as Array;	
		
		pos = processElmPosition(arr.length, position, 'put');
		
		if(pos<0)
			throw new RunTimeError(null, 9011);

		if(pos>=arr.length)
			throw new RunTimeError(null, 9013);
			
		switch(_type)
		{
			case ElmType.WORD:
				_value = value;
				break;
			case ElmType.STRING:
				_value = Utils.quotes(value);
				break;
			case ElmType.LIST:
				_value = StringUtil.trim(value);
				break;
			case ElmType.VARIABLE:
				_value = "$"+StringUtil.trim(_value);
				break;
		}
		
		arr[pos] = _value;
					
		return array2List(arr);
	}
}
}