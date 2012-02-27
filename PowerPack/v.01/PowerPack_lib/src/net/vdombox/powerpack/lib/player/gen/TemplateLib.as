package net.vdombox.powerpack.lib.player.gen
{

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.filters.ConvolutionFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.ByteArray;

import memorphic.xpath.XPathQuery;

import mx.core.Application;
import mx.events.CloseEvent;
import mx.graphics.codec.JPEGEncoder;
import mx.graphics.codec.PNGEncoder;
import mx.managers.PopUpManager;
import mx.utils.Base64Encoder;
import mx.utils.UIDUtil;

import net.vdombox.powerpack.lib.extendedapi.codec.BMPEncoder;
import net.vdombox.powerpack.lib.extendedapi.utils.GeomUtils;
import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
import net.vdombox.powerpack.lib.graphicapi.GraphicUtils;
import net.vdombox.powerpack.lib.graphicapi.drawing.Draw;
import net.vdombox.powerpack.lib.graphicapi.drawing.PStroke;
import net.vdombox.powerpack.lib.player.connection.SOAPBaseLevel;
import net.vdombox.powerpack.lib.player.events.TemplateLibEvent;
import net.vdombox.powerpack.lib.player.gen.errorClasses.RunTimeError;
import net.vdombox.powerpack.lib.player.gen.functions.DataLoader;
import net.vdombox.powerpack.lib.player.gen.parse.ListParser;
import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.CodeFragment;
import net.vdombox.powerpack.lib.player.gen.structs.GraphStruct;
import net.vdombox.powerpack.lib.player.gen.structs.NodeStruct;
import net.vdombox.powerpack.lib.player.managers.LanguageManager;
import net.vdombox.powerpack.lib.player.popup.Question;

public dynamic class TemplateLib extends EventDispatcher
{
//	include "include/GeneralFunctions.as";
//	include "include/ListManipulationFunctions.as";
//	include "include/GraphicFunctions.as";
//	include "include/ImageProcessingFunctions.as";
//	include "include/ApplicationFunctions.as";
//    include "include/XMLFunctions.as";


	public var tplStruct : TemplateStruct;

	
	private function setReturnValue( value : * ) : void
	{

		var lastFrag : CodeFragment = tplStruct.curNodeContext.block.lastExecutedFragment;

		lastFrag.retValue = value;
		tplStruct.context[lastFrag.retVarName] = value;

		tplStruct.generate();
	}

	private function setTransition( value : String ) : void
	{
		var lastFrag : CodeFragment = tplStruct.curNodeContext.block.lastExecutedFragment;
		lastFrag.transition = value;
	}

	private function getContexts() : Array
	{
		return [tplStruct.context, tplStruct.curGraphContext.context];
	}
	
	override public function dispatchEvent(event:Event):Boolean
	{
		return super.dispatchEvent(event);
	}
	
	
	
	
	public function setApplicationValue( applicationXML : XML, queryStr : String, value : Object ) : XML
	{
		if ( !applicationXML )
			return null;
		
		queryStr = queryStr ? queryStr : "/";
		
		var myQuery : XPathQuery = new XPathQuery( queryStr );
		
		var queryResult : XMLList = myQuery.exec( applicationXML );
		
		for each ( var xml : XML in queryResult )
		{
			try
			{
				xml.appendChild( new XML( value ) );
			}
			catch ( error : Error )
			{
				xml.appendChild( value );
			}
		}
		
		applicationXML.normalize();
		
		return applicationXML;
	}

	public function drawLine( pic : Bitmap, x1 : int, y1 : int, x2 : int, y2 : int, pen : String, alpha : int ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		var bd2 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		
		bd1.draw( pic );
		
		var shape : Shape = new Shape();
		var stroke : PStroke;
		var _fill : *;
		
		stroke = ListParser.processSubFunc( pen, getContexts() );
		if ( !(stroke is PStroke) )
			stroke = new PStroke();
		
		Draw.applyStroke( shape.graphics, stroke );
		
		Draw.moveTo( shape.graphics, x1, y1 );
		Draw.lineTo( shape.graphics, x2, y2 );
		
		bd2.draw( shape );
		
		var ct : ColorTransform = new ColorTransform();
		ct.alphaOffset = -255 + alpha / 100 * 255;
		bd2.colorTransform( bd2.rect, ct );
		
		bd1.copyPixels( bd2, bd2.rect, new Point( 0, 0 ), null, null, true );
		
		return new Bitmap( bd1 );
	}
	
	private function drawFigure( pic : Bitmap, method : Function, params : Array, pen : String, fill : String, alpha : int ) : Object
	{
		var _params : Array;
		var rect : Rectangle;
		
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		var bd2 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		var alphaBD : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		var figureBD : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		
		var shape : Shape = new Shape();
		var aShape : Shape = new Shape();
		var stroke : PStroke;
		var _fill : *;
		
		bd1.draw( pic );
		
		aShape.graphics.beginFill( 0x000000 );
		
		_params = params.concat();
		_params.unshift( aShape.graphics );
		method.apply( null, _params );
		
		aShape.graphics.endFill();
		alphaBD.draw( aShape );
		
		rect = alphaBD.getColorBoundsRect( 0xff000000, 0x00000000, false );
		
		figureBD.copyPixels( bd1, bd1.rect, new Point( 0, 0 ), alphaBD, null, true );
		
		if ( fill )
			_fill = processFillList( fill, shape.graphics, rect );
		
		if ( _fill is BitmapFilter )
		{
			figureBD.applyFilter( figureBD, figureBD.rect, new Point( 0, 0 ), _fill );
			bd1.copyPixels( figureBD, figureBD.rect, new Point( 0, 0 ), null, null, true );
		}
		
		stroke = ListParser.processSubFunc( pen, getContexts() );
		if ( !(stroke is PStroke) )
			stroke = new PStroke();
		
		Draw.applyStroke( shape.graphics, stroke );
		
		_params = [];
		_params = params.concat();
		_params.unshift( shape.graphics );
		method.apply( null, _params );
		
		if ( _fill && !(_fill is BitmapFilter) )
			shape.graphics.endFill();
		
		bd2.draw( shape );
		
		var ct : ColorTransform = new ColorTransform();
		ct.alphaOffset = -255 + alpha / 100 * 255;
		bd2.colorTransform( bd2.rect, ct );
		
		bd1.copyPixels( bd2, bd2.rect, new Point( 0, 0 ), null, null, true );
		
		return new Bitmap( bd1 );
	}
	
	public function drawAngleArc( pic : Bitmap, x : int, y : int, radius : uint, startAngle : Number, endAngle : Number, pen : String, fill : String, alpha : int ) : Object
	{
		var ret : * = drawFigure( pic, Draw.pie,
			[x, y, startAngle, endAngle, radius, radius, 0],
			pen, fill, alpha );
		return ret;
	}
	
	public function drawEllipse( pic : Bitmap, x1 : int, y1 : int, x2 : int, y2 : int, pen : String, fill : String, alpha : int ) : Object
	{
		var ret : * = drawFigure( pic, Draw.ellipse,
			[x1 + (x2 - x1) / 2, y1 + (y2 - y1) / 2, x2 - x1, y2 - y1, 0],
			pen, fill, alpha );
		return ret;
	}
	
	public function drawRect( pic : Bitmap, x1 : int, y1 : int, x2 : int, y2 : int, pen : String, fill : String, alpha : int ) : Object
	{
		var ret : * = drawFigure( pic, Draw.rect,
			[x1, y1, x2 - x1, y2 - y1],
			pen, fill, alpha );
		return ret;
	}
	
	public function drawRoundRect( pic : Bitmap, x1 : int, y1 : int, x2 : int, y2 : int, radius : uint, pen : String, fill : String, alpha : int ) : Object
	{
		var ret : * = drawFigure( pic, Draw.roundRect,
			[x1, y1, x2 - x1, y2 - y1, radius],
			pen, fill, alpha );
		return ret;
	}
	
	public function drawBezier( pic : Bitmap, points : String, pen : String, alpha : int ) : Object
	{
		var _points : Array = ListParser.processPoints( points, getContexts() );
		var ret : * = drawFigure( pic, Draw.polyBezier,
			[_points],
			pen, null, alpha );
		return ret;
	}
	
	public function fillBezier( pic : Bitmap, points : String, pen : String, fill : String, alpha : int ) : Object
	{
		var _points : Array = ListParser.processPoints( points, getContexts() );
		var ret : * = drawFigure( pic, Draw.closedBezier,
			[_points],
			pen, fill, alpha );
		return ret;
	}
	
	public function drawPolygon( pic : Bitmap, points : String, pen : String, fill : String, alpha : int ) : Object
	{
		var _points : Array = ListParser.processPoints( points, getContexts() );
		var ret : * = drawFigure( pic, Draw.polygon,
			[_points],
			pen, fill, alpha );
		return ret;
	}
	
	public function writeText( pic : Bitmap, text : String, x : int, y : int, w : int, h : int, font : String, alpha : int ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
		var bd2 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
		
		bd1.draw( pic );
		
		var sprite : Sprite = new Sprite();
		var format : TextFormat;
		var tf : TextField;
		
		format = ListParser.processSubFunc( font, getContexts() );
		
		if ( !(format is TextFormat) )
			format = new TextFormat();
		
		tf = new TextField();
		tf.autoSize = TextFieldAutoSize.NONE
		tf.background = false;
		tf.border = false;
		tf.selectable = false;
		tf.multiline = true;
		tf.wordWrap = true;
		tf.width = w;
		tf.height = h;
		
		tf.defaultTextFormat = format;
		
		tf.text = text;
		
		sprite.addChild( tf );
		
		bd2.draw( sprite );
		
		var ct : ColorTransform = new ColorTransform();
		ct.alphaOffset = -255 + alpha / 100 * 255;
		bd2.colorTransform( bd2.rect, ct );
		
		bd1.copyPixels( bd2, bd2.rect, new Point( x, y ), null, null, true );
		
		return new Bitmap( bd1 );
	}
	
	
	public function getXMLValue( xml : XML, queryStr : String ) : XMLList
	{
		
		return  getQueryResult(xml, queryStr);
	}
	
	
	public function setXMLValue( xml : XML, path : String, value : Object ) : XML
	{
		var queryResult : XMLList = getQueryResult(xml, path) ;
		
		for each ( var xmlNode : XML in queryResult )
		{
			xmlNode.setChildren( value) ;
		}
		
		return xml;
	}
	
	
	public function addXMLValue( xml : XML, queryStr : String, value : Object ) : XML
	{
		var queryResult : XMLList = getQueryResult(xml, queryStr) ;
		
		for each ( var xmlNode : XML in queryResult )
		{
			xmlNode.appendChild( value);
		}
		
		return xml;
	}
	
	
	private function getQueryResult(xml : XML, path:String):XMLList
	{
		path = path ? path : "/";
		
		var xPathQuery:XPathQuery =  new XPathQuery( path );
		
		return  xPathQuery.exec( xml );
	}
	

	public function sub( graph : String, ...args ) : *
	{
		var prefix : String = '';
		args.unshift( graph, prefix );
		return subPrefix.apply( this, args );
	}
	
	public function subPrefix( graph : String, prefix : String, ...args ) : *
	{
		var subgraph : GraphStruct;
		
		for each ( var graphStruct : GraphStruct in tplStruct.graphs )
		{
			if ( graphStruct.name == graph )
				subgraph = graphStruct;
		}
		
		if ( subgraph )
		{
			return enterSubgraph.apply( this, [subgraph, prefix, args] );
		}
		else
		{
			throw new RunTimeError( "Undefined graph: " + graph + "." );
		}
	}
	
	private function enterSubgraph( subgraph : GraphStruct, prefix : String, params : Array = null ) : Function
	{
		var graphContext : GraphContext = new GraphContext( subgraph );
		var curNode : NodeStruct = tplStruct.curGraphContext.curNode;
		
		graphContext.varPrefix = prefix;
		
		tplStruct.curNodeContext.block.retValue = subgraph.name;
		
		tplStruct.nodeStack.push( tplStruct.curNodeContext );
		
		tplStruct.contextStack.push( graphContext );
		
		tplStruct.step = 'parseNewNode';
		
		if ( tplStruct.forced >= 0 )
			tplStruct.forced++;
		
		if ( params && params.length > 0 )
		{
			for ( var i : int = 0; i < params.length; i++ )
				tplStruct.curGraphContext.context['param' + (i + 1)] = params[i];
		}
		
		Application.application.callLater( tplStruct.generate );
		
		return new Function;
	}
	
	private function _dialog( closeHandler : Function, question : String, params : Array = null ) : Function
	{
		var popupParent		: Sprite = Sprite(Application.application);
		var questionPopup	: Question = new Question();
		
		questionPopup.question = question;
		questionPopup.context = getContexts();
		questionPopup.dataProvider = params;
		
		questionPopup.addEventListener( CloseEvent.CLOSE, closeHandler); 
		PopUpManager.addPopUp(questionPopup, popupParent, true);
		
		return closeHandler;
	}
	
	public function question( question : String, ...args ) : Function
	{
		return _dialog(questionCloseHandler, question, args);
		
		function questionCloseHandler( event : Event ) : void
		{
			setReturnValue( event.target.strAnswer );
		}
	}
	
	public function progress( value : Number, description : String ) : void
	{
		dispatchEvent( new TemplateLibEvent( TemplateLibEvent.SET_PROGRESS, 
			{value : value, description : description} ) );
	}
	
	public function qSwitch( question : String, ...args ) : Function
	{
		return _dialog( questionCloseHandler, question, args );
		
		function questionCloseHandler( event : Event) : void
		{
			var retVal : String = LanguageManager.sentences['other'] + '...';
			
			for each ( var arg : String in args )
			{
				if ( event.target.strAnswer == arg )
					retVal = event.target.strAnswer;
			}
			
			setReturnValue( retVal );
		}
	}
	
	public function _switch( value : String, ...args ) : String
	{
		for each ( var arg : String in args )
		{
			if ( value == arg )
				return value;
		}
		
		return LanguageManager.sentences['other'] + '...';
	}
	
	public function convert( type : String, value : Object ) : Function
	{
		var result : String;
		
		if ( value && type.toLowerCase() == "hexcolor" )
		{
			result = int( "0x" + value.toString().replace( /^#/g, "" ) ).toString();
		}
		else if ( value && type.toLowerCase() == "intcolor" )
		{
			result = int( value ).toString( 16 );
			while ( result.length < 6 )
			{
				result = result + "0";
			}
			result = "#" + result;
		}
		else if ( value && type.toLowerCase() == "base64" )
		{
			//		var fileToBase64 : FileToBase64 = new FileToBase64( value.toString() );
			//		fileToBase64.addEventListener( "dataConverted", completeConvertHandler );
			//		fileToBase64.loadAndConvert();
			return completeConvertHandler;
			
			function completeConvertHandler( event : Event ) : void
			{
				setReturnValue( event.target.data );
			}
		}
		
		Application.application.callLater( convertComplete, [result] );
		return convertComplete;
		
		function convertComplete( value : String ) : void
		{
			setReturnValue( value );
		}
	}
	
	public function imageToBase64( pic : Bitmap, type : String = null ) : String
	{
		var data : ByteArray = new ByteArray();
		
		if ( type.toLowerCase() == "jpg" ||
			type.toLowerCase() == "jpeg" )
		{
			var jpgEncoder : JPEGEncoder = new JPEGEncoder( 80 );
			data = jpgEncoder.encode( pic.bitmapData );
		}
		else if ( type.toLowerCase() == "bmp" )
		{
			data = BMPEncoder.encode( pic.bitmapData );
		}
		else
		{
			var pngEncoder : PNGEncoder = new PNGEncoder();
			data = pngEncoder.encode( pic.bitmapData );
		}
		
		var encoder : Base64Encoder = new Base64Encoder();
		
		encoder.encodeBytes( data );
		var strData : String = encoder.flush();
		
		return strData;
	}
	
	public function writeTo( filePath : String ) : void
	{
		var data : String = GraphContext( tplStruct.contextStack[0] ).buffer;
		data = Utils.replaceEscapeSequences( data, "\\-" );
		writeVarTo( filePath, data );
	}
	
	public function writeVarTo( filePath : String, value : Object ) : void
	{
		// TODO: return operation result  ['error' 'description'] ['ok']
		//	if ( !(value && filePath) )
		//		return;
		//	
		//	var file : File = new File( filePath );
		//
		//	if(file.isDirectory || file.isPackage ||file.isSymbolicLink)
		//		return;
		//
		//	var data : ByteArray = objectToByteArray(value, file.extension);
		//
		//	var fileStream : FileStream = new FileStream();
		//
		//	fileStream.open( file, FileMode.WRITE );
		//	fileStream.writeBytes( data );
		//	fileStream.close();
		
	}
	private function objectToByteArray( value : Object, extension : String  ) : ByteArray
	{
		var data : ByteArray = new ByteArray();
		
		if ( value is Bitmap )
		{
			var bitmap : Bitmap =  value as    Bitmap;
			
			switch (extension.toLowerCase() )
			{
				case "png":
				{
					var pngEncoder : PNGEncoder = new PNGEncoder();
					data = pngEncoder.encode( bitmap.bitmapData );
					
					break;
				}
				case "jpg":
				case "jpeg":
				{
					var jpgEncoder : JPEGEncoder = new JPEGEncoder( 80 );
					data = jpgEncoder.encode( bitmap.bitmapData );
					
					break;
				}
				default :
				{
					data = BMPEncoder.encode( bitmap.bitmapData );
				}
			}
		}
		else
		{
			data.writeUTFBytes( value.toString() );
		}
		
		return data;
		
	}
	
	public function loadDataFrom( filePath : String ) : Function
	{
		var file : DataLoader = new DataLoader();
		
		file.addEventListener(TemplateLibEvent.RESULT_GETTED, resultGettedHandler );
		
//		Application.application.callLater(file.load, [filePath]);
			
		file.load( filePath );
		
		function resultGettedHandler ( event : TemplateLibEvent): void
		{
			setTransition( event.transition );
			setReturnValue( event.result );
		}
		return resultGettedHandler;	
			
	}
	
	public function GUID() : String
	{
		var guid : String = UIDUtil.createUID();
		return guid.toLowerCase();
	}
	
	public function mid( start : int, length : int, string : String ) : String
	{
		var substr : String = string.substr( start, length );
		return substr;
	}
	
	public function replace( string : String, tgt : String, flags : String, src : String ) : String
	{
		var regExp : RegExp = new RegExp( tgt, flags );
		var str : String = string.replace( regExp, src );
		return str;
	}
	
	public function split( delimiter : String, string : String ) : String
	{
		var arr : Array = string.split( delimiter );
		var str : String = "[" + arr.join( " " ) + "]";
		return str;
	}
	
	public function random( value : int ) : String
	{
		var rnd : int = int( Math.round( Math.random() * value ) );
		return rnd.toString();
	}
	
	public function alert( strr : String ) : void
	{
		
	}
	
	public function wholeMethod( funct : String, ...args ) : Function
	{
		var soapBaseLevel : SOAPBaseLevel = new SOAPBaseLevel();
		
		soapBaseLevel.addEventListener( SOAPBaseLevel.RESULT_RECEIVED, rusulGettedHandler, false, 0, true );
		soapBaseLevel.execute( funct, args );
		
		function rusulGettedHandler( event : Event ) : void
		{
			soapBaseLevel.removeEventListener( SOAPBaseLevel.RESULT_RECEIVED, rusulGettedHandler );
			
			setTransition( soapBaseLevel.resultType );
			setReturnValue( soapBaseLevel.result );
			
			soapBaseLevel = null;
		}
		
		return rusulGettedHandler;
	}
	
	public function dialog( question : String, ...args ) : Function
	{
		return _dialog(dialogCloseHandler, question, args);
		
		function dialogCloseHandler( event : Event ) : void
		{
			setReturnValue( event.target.strAnswer );
		}
	}
	
	
	private function processFillList( list : String, g : Graphics, rect : Rectangle ) : *
	{
		var _fill : * = ListParser.processSubFunc( list, getContexts() );
		var matrix : Matrix = new Matrix();
		matrix.translate( rect.x, rect.y );
		
		if ( _fill is BitmapFilter )
		{
			//
		}
		else if ( _fill is BitmapData )
		{
			g.beginBitmapFill( _fill, matrix );
		}
		else if ( _fill is Bitmap )
		{
			g.beginBitmapFill( _fill.bitmapData, matrix );
		}
		else if ( _fill && typeof(_fill) == 'number' )
		{
			g.beginFill( _fill );
		}
		else if ( _fill && typeof(_fill) == 'object' &&
			_fill.hasOwnProperty( 'name' ) )
		{
			matrix = new Matrix();
			matrix.createGradientBox( rect.width / (_fill.name == 'gradientoneway' ? 1 : 2),
				rect.height / (_fill.name == 'gradientoneway' ? 1 : 2),
				_fill.rotation, 0, 0 );
			g.beginGradientFill( _fill.type, _fill.colors, _fill.alphas, _fill.ratios, matrix, _fill.spreadMethod );
		}
		
		return _fill;
	}
	
	public function loadImage( filePath : String ) : Function
	{
		//	if ( !filePath )
		//	{
		//		throw new BasicError( "Not valid filepath" );
		//	}
		//
		//	var file : File = new File( filePath );
		//
		//	if ( !file.exists )
		//	{
		//		throw new BasicError( "File does not exist" );
		//	}
		//
		//	var fileStream : FileStream = new FileStream();
		//	var bytes : ByteArray = new ByteArray();
		//	fileStream.open( file, FileMode.READ );
		//	fileStream.readBytes( bytes, 0, fileStream.bytesAvailable );
		//	fileStream.close();
		//
		//	var loader : Loader = new Loader();
		//	loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onImageLoaded );
		//	loader.loadBytes( bytes );
		//
		//	return onImageLoaded;
		//
		//	function onImageLoaded( event : Event ) : void
		//	{
		//		var content : DisplayObject = LoaderInfo( event.target ).content;
		//		var bitmapData : BitmapData = new BitmapData( content.width, content.height, true, 0x00000000 );
		//		bitmapData.draw( content );
		//		var bitmap : Bitmap = new Bitmap( bitmapData );
		//
		//		setReturnValue( bitmap );
		//	}
		return null;
	}
	
	
	public function createImage( width : int, height : int, bgColor : int ) : Object
	{
		if ( bgColor < 0x01000000 )
			bgColor += 0xff000000;
		if ( bgColor < 0 )
			bgColor = 0x00000000;
		
		var bitmapData : BitmapData = new BitmapData( width, height, true, bgColor );
		var bitmap : Bitmap = new Bitmap( bitmapData );
		
		return bitmap;
	}
	
	public function getWidth( pic : Bitmap ) : int
	{
		return pic.width;
	}
	
	public function getHeight( pic : Bitmap ) : int
	{
		return pic.height;
	}
	
	public function getPixel( pic : Bitmap, x : int, y : int ) : uint
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		
		bd1.draw( pic );
		
		return bd1.getPixel( x, y );
	}
	
	public function getPixel32( pic : Bitmap, x : int, y : int ) : uint
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		
		bd1.draw( pic );
		
		return bd1.getPixel32( x, y );
	}
	
	public function setPixel( pic : Bitmap, x : int, y : int, color : uint ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		
		bd1.draw( pic );
		
		if ( color > 0xffffff )
			bd1.setPixel32( x, y, color );
		else
			bd1.setPixel( x, y, color );
		
		return new Bitmap( bd1 );
	}
	
	public function addImage( ...args ) : Object
	{
		if ( args.length == 5 )
			args.unshift( args[0] );
		
		return _addImage.apply( this, args );
	}
	
	private function _addImage( pic1 : Bitmap, pic2 : Bitmap, x : int, y : int, alpha : int, alphaCol : int ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic1.width, pic1.height, true, 0x00ffffff );
		var bd2 : BitmapData = new BitmapData( pic2.width, pic2.height, true, 0x00ffffff );
		
		bd1.draw( pic1 );
		bd2.draw( pic2 );
		
		var ct : ColorTransform = new ColorTransform();
		ct.alphaOffset = -255 + alpha / 100 * 255;
		bd2.colorTransform( bd2.rect, ct );
		
		if ( alphaCol >= 0 )
			bd2.threshold( bd2, bd2.rect, new Point( 0, 0 ), '==', alphaCol, 0x00000000, 0x00ffffff, true );
		
		bd1.copyPixels( bd2, bd2.rect, new Point( x, y ), null, null, true );
		
		return new Bitmap( bd1 );
	}
	
	public function mergeImages( pic1 : Bitmap, pic2 : Bitmap, percent : uint ) : Object
	{
		return _addImage( pic1, pic2, 0, 0, percent, -1 );
	}
	
	public function brightness( pic : Bitmap, value : int ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
		
		bd1.draw( pic );
		
		var matrix : Array = [	1, 0, 0, 0, value,
			0, 1, 0, 0, value,
			0, 0, 1, 0, value,
			0, 0, 0, 1, 0 ];
		
		bd1.applyFilter( bd1, bd1.rect, new Point( 0, 0 ), new ColorMatrixFilter( matrix ) );
		
		return new Bitmap( bd1 );
	}
	
	public function contrast( pic : Bitmap, value : int ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		var bd2 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		
		bd1.draw( pic );
		
		if ( value < -100 ) value = -100;
		if ( value > 100 ) value = 100;
		
		var contrast : Number = (100.0 + value) / 100.0;
		contrast *= contrast;
		
		for ( var i : int = 0; i < pic.width; i++ )
		{
			for ( var j : int = 0; j < pic.height; j++ )
			{
				var argb : uint = bd1.getPixel32( i, j );
				
				var r : Number = (argb & 0xff0000) >> 16;
				var g : Number = (argb & 0x00ff00) >> 8;
				var b : Number = (argb & 0x0000ff);
				
				var pixel : Number;
				
				argb = argb >> 24;
				
				for each ( var c : Number in [r, g, b] )
				{
					pixel = c / 255.0;
					pixel -= 0.5;
					pixel *= contrast;
					pixel += 0.5;
					pixel *= 255;
					if ( pixel < 0 ) pixel = 0;
					if ( pixel > 255 ) pixel = 255;
					
					argb = argb << 8;
					argb += int( pixel );
				}
				
				bd2.setPixel32( i, j, argb );
			}
		}
		
		return new Bitmap( bd2 );
	}
	
	public function saturation( pic : Bitmap, value : int ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		var bd2 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		
		bd1.draw( pic );
		
		for ( var i : int = 0; i < pic.width; i++ )
		{
			for ( var j : int = 0; j < pic.height; j++ )
			{
				var argb : uint = bd1.getPixel32( i, j );
				var hsv : Object = GraphicUtils.RGB2HSV( argb );
				
				if ( hsv.s > 0.0 )
					hsv.s += value / 100 * (value > 0 ? hsv.s : hsv.s);
				
				if ( hsv.s < 0 )
					hsv.s = 0;
				else if ( hsv.s > 1 )
					hsv.s = 1;
				
				argb = GraphicUtils.HSV2RGB( hsv.h, hsv.s, hsv.v ) + (0xff000000 & argb);
				
				bd2.setPixel32( i, j, argb );
			}
		}
		
		return new Bitmap( bd2 );
	}
	
	public function createBlackWhite( pic : Bitmap ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
		var bd2 : BitmapData = new BitmapData( pic.width, pic.height, true, 0xffffffff );
		var bd3 : BitmapData = new BitmapData( pic.width, pic.height, true, 0xffffffff );
		
		bd1.draw( pic );
		
		var matrix : Array = [	0.33, 0.33, 0.33, 0, 0,
			0.33, 0.33, 0.33, 0, 0,
			0.33, 0.33, 0.33, 0, 0,
			0, 0, 0, 1, 0 ];
		
		bd1.applyFilter( bd1, bd1.rect, new Point( 0, 0 ), new ColorMatrixFilter( matrix ) );
		
		bd2.threshold( bd1, bd1.rect, new Point( 0, 0 ), '<', 0x7f000000, 0xffffffff, 0xff000000, true );
		bd3.threshold( bd2, bd2.rect, new Point( 0, 0 ), '<', 0x007f0000, 0xff000000, 0x00ff0000, false );
		
		return new Bitmap( bd3 );
	}
	
	public function createGrayScale( pic : Bitmap ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
		
		bd1.draw( pic );
		
		var matrix : Array = [	0.33, 0.33, 0.33, 0, 0,
			0.33, 0.33, 0.33, 0, 0,
			0.33, 0.33, 0.33, 0, 0,
			0, 0, 0, 1, 0 ];
		
		bd1.applyFilter( bd1, bd1.rect, new Point( 0, 0 ), new ColorMatrixFilter( matrix ) );
		
		return new Bitmap( bd1 );
	}
	
	public function createNegative( pic : Bitmap ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		
		bd1.draw( pic );
		
		var matrix : Array = [	-1, 0, 0, 0, 255,
			0, -1, 0, 0, 255,
			0, 0, -1, 0, 255,
			0, 0, 0, 1, 0 ];
		
		bd1.applyFilter( bd1, bd1.rect, new Point( 0, 0 ), new ColorMatrixFilter( matrix ) );
		
		return new Bitmap( bd1 );
	}
	
	public function cropImage( pic : Bitmap, x : int, y : int, w : int, h : int ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
		var bd2 : BitmapData = new BitmapData( w, h, true, 0x00000000 );
		
		bd1.draw( pic );
		
		bd2.copyPixels( bd1, new Rectangle( x, y, w, h ), new Point( 0, 0 ) );
		
		return new Bitmap( bd2 );
	}
	
	public function flipImage( pic : Bitmap, direction : * ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
		var bd2 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
		
		bd1.draw( pic );
		
		var _direction : int = ListParser.processFlipDirection( direction );
		
		for ( var i : int = 0; i < pic.width; i++ )
		{
			for ( var j : int = 0; j < pic.height; j++ )
			{
				bd2.setPixel32( _direction != 1 ? pic.width - 1 - i : i,
					_direction == 1 ? pic.height - 1 - j : j,
					bd1.getPixel32( i, j ) );
			}
		}
		
		return new Bitmap( bd2 );
	}
	
	public function resizeImage( pic : Bitmap, w : int, h : int ) : Object
	{
		var bd1 : BitmapData = new BitmapData( w, h, true, 0x00000000 );
		
		var matrix : Matrix = new Matrix();
		matrix.scale( w / pic.width, h / pic.height );
		
		bd1.draw( pic.bitmapData, matrix );
		
		return new Bitmap( bd1 );
	}
	
	public function rotateImage( pic : Bitmap, angle : int, bgColor : int ) : Object
	{
		var matrix : Matrix = new Matrix();
		matrix.rotate( angle / 360 * Math.PI * 2 );
		
		var rect : Rectangle = new Rectangle( 0, 0, pic.width, pic.height );
		var points : Array = [];
		
		points.push( matrix.transformPoint( rect.topLeft ) );
		points.push( matrix.transformPoint( rect.bottomRight ) );
		points.push( matrix.transformPoint( new Point( rect.right, rect.top ) ) );
		points.push( matrix.transformPoint( new Point( rect.left, rect.bottom ) ) );
		
		rect = GeomUtils.getObjectsRect( points );
		
		matrix.translate( -rect.left, -rect.top );
		
		if ( bgColor < 0 )
			bgColor = 0x00000000;
		else if ( bgColor < 0x01000000 )
			bgColor += 0xff000000;
		
		var bd1 : BitmapData = new BitmapData( rect.width, rect.height, true, bgColor );
		
		bd1.draw( pic.bitmapData, matrix, null, null, null, true );
		
		return new Bitmap( bd1 );
	}
	
	public function blur( pic : Bitmap, value : int ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
		
		bd1.draw( pic );
		
		bd1.applyFilter( bd1, bd1.rect, new Point( 0, 0 ), new BlurFilter( value, value ) );
		
		return new Bitmap( bd1 );
	}
	
	public function sharpen( pic : Bitmap, value : int ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
		
		bd1.draw( pic );
		
		// sharpen matrix
		var matrix : Array = [0, -1 - value / 4, 0,
			-1 - value / 4, 13 + value, -1 - value / 4,
			0, -1 - value / 4, 0];
		
		var matrixX : Number = 3;
		var matrixY : Number = 3;
		var divisor : Number = 9;
		var bias : Number = 0;
		
		bd1.applyFilter( bd1, bd1.rect, new Point( 0, 0 ), new ConvolutionFilter( matrixX, matrixY, matrix, divisor, bias ) );
		
		return new Bitmap( bd1 );
	}
	
	public function emboss( pic : Bitmap ) : Object
	{
		var bd1 : BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
		
		bd1.draw( pic );
		
		// emboss matrix
		var matrix : Array = [-6, -3, 0,
			-3, 9, 3,
			0, 3, 6];
		
		var matrixX : Number = 3;
		var matrixY : Number = 3;
		var divisor : Number = 9;
		var bias : Number = 0;
		
		bd1.applyFilter( bd1, bd1.rect, new Point( 0, 0 ), new ConvolutionFilter( matrixX, matrixY, matrix, divisor, bias ) );
		
		return new Bitmap( bd1 );
	}

}
}