package vdom.skins
{
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import mx.core.EdgeMetrics;
import mx.core.FlexShape;
import mx.core.IChildList;
import mx.core.IContainer;
import mx.core.IRawChildrenContainer;
import mx.skins.halo.HaloBorder;

import vdom.managers.FileManager;

public class ItemBorder extends HaloBorder
{
	private var loader:Loader = new Loader();
	
	private var _unscaledWidth:Number;
	private var _unscaledHeight:Number;
	
	private var backgroundId:String;
	
	private var repeatedBackgroundImage:Sprite;
	
	private var repeatedBackgroundImageWidth:Number;
	
	private var repeatedBackgroundImageHeight:Number;
	
	private var _backgroundImageBounds:Rectangle;
	
	public function ItemBorder()
	{
		super();
	}
	
	public function set resource(value:Object):void
	{
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
		loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, completeHandler );
		loader.loadBytes(value.data);
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, 
													unscaledHeight:Number):void
	{
		if (!parent)
			return;
		
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		// If background image has changed, then load new one.  
		var newStyle:String = getStyle("repeatedBackgroundImage");
		
		if(	newStyle && newStyle != backgroundId )
		{
			removedHandler(null);
			
			backgroundId = newStyle;
			var fm:FileManager = FileManager.getInstance();
			fm.loadResource("", newStyle, this, "resource");	
		}
		if( 
			_unscaledWidth != unscaledWidth
			||
			_unscaledHeight != unscaledHeight
		)
		{
			lyot();
		}
	}
	
	/* private function getBackgroundSize():Number
	{   
		var percentage:Number = NaN;
		var backgroundSize:Object = getStyle("backgroundSize");

		if (backgroundSize && backgroundSize is String)
		{
			var index:int = backgroundSize.indexOf("%");
			if (index != -1)
				percentage = Number(backgroundSize.substr(0, index));
		}
		
		return percentage;
	} */
	
	private function initBackgroundImage(image:DisplayObject):void
	{
		if (!(image is Loader))
			return;
		
		repeatedBackgroundImageWidth = Loader(image).contentLoaderInfo.width;
		repeatedBackgroundImageHeight = Loader(image).contentLoaderInfo.height;
		
		repeatedBackgroundImage = new Sprite();
		
		// To optimize memory use, we've declared RectangularBorder to be a Shape.
		// As a result, it cannot have any children.
		// Make the backgroundImage a sibling of this RectangularBorder,
		// which is positioned just on top of the RectangularBorder.
		var childrenList:IChildList = parent is IRawChildrenContainer ?
										 IRawChildrenContainer(parent).rawChildren :
										 IChildList(parent);
		
//		const backgroundMask:Shape = new FlexShape();
//		backgroundMask.name = "backgroundMask";
//		backgroundMask.x = 0;
//		backgroundMask.y = 0;
//		childrenList.addChild(backgroundMask);

		var myIndex:int = childrenList.getChildIndex(this);
		
		childrenList.addChildAt(repeatedBackgroundImage, myIndex + 1);
		//repeatedBackgroundImage.mask = backgroundMask;	  
	}
	
	private function lyot():void
	{
		if(!repeatedBackgroundImage)
			return;
		
		var p:DisplayObject = parent;
		
		var image:Loader = loader;
		
		var bm:EdgeMetrics = p is IContainer ?
							 IContainer(p).viewMetrics :
							 borderMetrics;
		
		//repeat, no-repeat, repeat-x, repeat-y
		var rpt:String = getStyle("backgroundRepeat");
		
		var sW:Number,
			sH:Number;
			
		switch(rpt)
		{
			case "repeat":
			{
				sW = width - bm.left - bm.right;
				sH = height - bm.top - bm.bottom;
				break;
			}
			case "no-repeat":
			{
				sW = Bitmap(image.content).width;
				sH = Bitmap(image.content).height;
				break;
			}
			case "repeat-x":
			{
				sW = width - bm.left - bm.right;
				sH = Bitmap(image.content).height;
				break;
			}
			case "repeat-y":
			{
				sW = Bitmap(image.content).width;
				sH = height - bm.top - bm.bottom;
				break;
			}
		}
		
		repeatedBackgroundImage.x = bm.left;
		repeatedBackgroundImage.y = bm.top;
		
		var offsetX:Number = 0;
		var offsetY:Number = 0;

		// Adjust offsets by scroll positions.
		if (p is IContainer)
		{
			offsetX -= IContainer(p).horizontalScrollPosition;
			offsetY -= IContainer(p).verticalScrollPosition;
		}

		// Adjust alpha to match backgroundAlpha
		//FIXME: деление надо убрать, когда подправятся RenderManager applyStyles
		repeatedBackgroundImage.alpha = 1//getStyle("backgroundAlpha")/100; 
		
//		repeatedBackgroundImage.x += offsetX;
//		repeatedBackgroundImage.y += offsetY;
		
		var maskWidth:Number = width - bm.left - bm.right;
		var maskHeight:Number = height - bm.top - bm.bottom; 
		
//		const backgroundMask:Shape = Shape(repeatedBackgroundImage.mask);
//		backgroundMask.x = bm.left;
//		backgroundMask.y = bm.top;
		
		var m:Matrix = new Matrix();
		m.translate(offsetX, offsetY);
		
		repeatedBackgroundImage.graphics.clear();
		repeatedBackgroundImage.graphics.beginBitmapFill(Bitmap(Loader(image).content).bitmapData, m, true);
		repeatedBackgroundImage.graphics.drawRect(0, 0, sW, sH);
		
//		if (backgroundMask.width != maskWidth ||
//			backgroundMask.height != maskHeight)
//		{
//			var g:Graphics = backgroundMask.graphics;
//			g.clear();
//			g.beginFill(0xFFFFFF);
//			g.drawRect(0, 0, maskWidth, maskHeight);
//			g.endFill();
//		}
	}
	
	private function completeHandler(event:Event):void
	{	
		if(event.type == IOErrorEvent.IO_ERROR)
			return;
			
		if(event && event.target && event.target is LoaderInfo)
		{
			initBackgroundImage(event.target.loader as Loader);
			lyot();
		}
	}
	
	 private function removedHandler(event:Event):void
	{
		if (repeatedBackgroundImage)
		{
			var childrenList:IChildList = parent is IRawChildrenContainer ?
											 IRawChildrenContainer(parent).rawChildren :
											 IChildList(parent);
											 
			childrenList.removeChild(repeatedBackgroundImage);
			repeatedBackgroundImage = null;
		}
	}
}
}