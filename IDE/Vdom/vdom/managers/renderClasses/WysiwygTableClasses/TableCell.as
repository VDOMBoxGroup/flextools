////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package vdom.managers.renderClasses.WysiwygTableClasses {
	import mx.containers.Canvas;
	import mx.containers.HBox;
	
	import vdom.containers.IItem;
	import vdom.managers.renderClasses.WaitCanvas;
	

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="direction", kind="property")]
[Exclude(name="focusEnabled", kind="property")]
[Exclude(name="focusManager", kind="property")]
[Exclude(name="focusPane", kind="property")]
[Exclude(name="mouseFocusEnabled", kind="property")]

[Exclude(name="adjustFocusRect", kind="method")]
[Exclude(name="getFocus", kind="method")]
[Exclude(name="isOurFocus", kind="method")]
[Exclude(name="setFocus", kind="method")]

[Exclude(name="focusIn", kind="event")]
[Exclude(name="focusOut", kind="event")]
[Exclude(name="move", kind="event")]

[Exclude(name="focusBlendMode", kind="style")]
[Exclude(name="focusSkin", kind="style")]
[Exclude(name="focusThickness", kind="style")]
[Exclude(name="horizontalGap", kind="style")]
[Exclude(name="verticalGap", kind="style")]

[Exclude(name="focusInEffect", kind="effect")]
[Exclude(name="focusOutEffect", kind="effect")]
[Exclude(name="moveEffect", kind="effect")]


public class TableCell extends HBox implements IItem {

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function TableCell(objectId:String) {
    	
        super();
        
        _graphicsLayer = new Canvas();
        
        _objectId = objectId;
		editableAttributes = [];
		_isStatic = false;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
	private var _objectId:String;
	private var _waitMode:Boolean;
	private var _graphicsLayer:Canvas;
	private var _highlightMarker:Canvas;
	private var _isStatic:Boolean;
	private var _editableAttributes:Array;
	
    /**
     *  @private
     */
    internal var colIndex:int = 0;

    //--------------------------------------------------------------------------
    //
    //  Public Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  colSpan
    //----------------------------------

    /**
     *  @private
     *  Storage for the colSpan property.
     */
    private var _colSpan:int = 1;

    [Inspectable(category="General", defaultValue="1")]

    /**
     *  Number of columns of the Grid container spanned by the cell.
     *
     *  @default 1
     */
    public function get colSpan():int {
        return _colSpan;
    }

    /**
     *  @private
     */
    public function set colSpan(value:int):void {
        _colSpan = value;

        invalidateSize();
    }

    //----------------------------------
    //  rowSpan
    //----------------------------------

    /**
     *  @private
     *  Storage for the rowSpan property.
     */
    private var _rowSpan:int = 1;

    [Inspectable(category="General", defaultValue="1")]

    /**
     *  Number of rows of the Grid container spanned by the cell.
     *  You cannot extend a cell past the number of rows in the Grid.
     *
     *  @default 1
     */
    public function get rowSpan():int {
        return _rowSpan;
    }

    /**
     *  @private
     */
    public function set rowSpan(value:int):void {
        _rowSpan = value;

        invalidateSize();
    }
    
    public function get objectId():String {
		
		return _objectId;
	}
	
	public function get waitMode():Boolean {
		
		return _waitMode;
	}
	
	public function set waitMode(mode:Boolean):void {
		
		if(mode) {
			
			var waitLayout:Canvas = new WaitCanvas();
			
			addChild(waitLayout);
			
		}
	}
	
	public function get editableAttributes():Array {
		
		return _editableAttributes;
	}
	
	public function set editableAttributes(attributesArray:Array):void {
		
		_editableAttributes = attributesArray;
	}
	
	public function get isStatic():Boolean {
		
		return _isStatic;
	}
	
	public function set isStatic(flag:Boolean):void {
		
		_isStatic = flag;
	}
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		if(!_graphicsLayer) {
			
			_graphicsLayer = new Canvas();
			rawChildren.addChild(_graphicsLayer);
		}
		
		if(!_highlightMarker)
			_highlightMarker = new Canvas();
		
		_highlightMarker.visible = false;
		
		rawChildren.addChild(_highlightMarker);
	}
	
	public function get graphicsLayer():Canvas {
		
		return _graphicsLayer;
	}
	
	public function drawHighlight(color:String):void {
		
		/* if(color && color == 'none') {
			
			_highlightMarker.visible = false;
			return;
		}
			
		var graph:Graphics = _highlightMarker.graphics;
		
		graph.clear()
		graph.lineStyle(2, Number(color));
		graph.drawRect(0, 0, width, height);
		
		bringOnTop();
		
		_highlightMarker.visible = true; */
	}
	
	private function bringOnTop():void {
		
		var highlightMarkerIndex:int = rawChildren.getChildIndex(_highlightMarker);
		var topIndex:int = rawChildren.numChildren-1;
		
		if(highlightMarkerIndex != topIndex) {
			rawChildren.setChildIndex(_highlightMarker, topIndex);
		}
	}
}

}
