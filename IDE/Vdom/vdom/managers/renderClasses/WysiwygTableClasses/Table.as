package vdom.managers.renderClasses.WysiwygTableClasses {

import flash.display.Graphics;

import mx.containers.Box;
import mx.containers.Canvas;
import mx.containers.gridClasses.GridColumnInfo;
import mx.containers.gridClasses.GridRowInfo;
import mx.core.EdgeMetrics;

import vdom.containers.IItem;
import vdom.managers.renderClasses.WaitCanvas;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  Number of pixels between children in the horizontal direction. 
 *  The default value is 8.
 */
[Style(name="horizontalGap", type="Number", format="Length", inherit="no")]

/**
 *  Number of pixels between children in the vertical direction. 
 *  The default value is 6.
 */
[Style(name="verticalGap", type="Number", format="Length", inherit="no")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="direction", kind="property")]

[Exclude(name="focusIn", kind="event")]
[Exclude(name="focusOut", kind="event")]

[Exclude(name="focusBlendMode", kind="style")]
[Exclude(name="focusSkin", kind="style")]
[Exclude(name="focusThickness", kind="style")]

[Exclude(name="focusInEffect", kind="effect")]
[Exclude(name="focusOutEffect", kind="effect")]

[IconFile("Grid.png")]

public class Table extends Box implements IItem {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function Table(objectId:String) {

		super();
		
		_objectId = objectId;
		editableAttributes = [];
		_isStatic = false;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
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
	 *  Minimum, maximum, and preferred width of each column.
	 */
	private var columnWidths:Array /* of GridColumnInfo */;

	/**
	 *  @private
	 *  Minimum, maximum, and preferred height of each row.
	 */
	private var rowHeights:Array /* of GridRowInfo */;

	/**
	 *  @private
	 */
	private var needToRemeasure:Boolean = true;
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods:UIComponent
	//
	//--------------------------------------------------------------------------
	
	
	/**
	 *  @private
	 */
	override public function invalidateSize():void {
		// When the Grid's size is invalidated, the rowHeights
		// and columnWidths arrays need to be recalculated.
		// Those arrays are usually recalculated in measure(),
		// but set a flag in case measure() isn't called (which
		// will happen if the Grid's width and height are explicit).
		if (!isNaN(explicitWidth) && !isNaN(explicitHeight))		
			needToRemeasure = true;
		
		super.invalidateSize();
	}   

	override protected function measure():void {
		// 1. Determine the number of grid columns,
		// taking into account rowSpan and colSpan

		var numGridRows:int = 0;
		var numGridColumns:int = 0;
		var columnOccupiedUntilRow:Array = [];
		var gridRow:TableRow;
		var gridItem:TableCell;
		var i:int;
		var j:int;
		var colIndex:int;

		var rowList:Array = []; // GridRows

		for (var index:int = 0; index < numChildren; index++){
			if(!(getChildAt(index) is TableRow))
				continue;
			gridRow = TableRow(getChildAt(index));
			if (gridRow.includeInLayout) {
				rowList.push(gridRow);
				numGridRows++;
			}
		}


		for (i = 0; i < numGridRows; i++) {
			colIndex = 0;
			gridRow = rowList[i];

			// Cache the number of children as a property on the gridRow
			gridRow.numGridItems = gridRow.numChildren;

			// Tell the grid row what row number it is
			gridRow.rowIndex = i;
			for (j = 0; j < gridRow.numGridItems; j++) {
				if(!(gridRow.getChildAt(j) is TableCell)) {
					gridRow.numGridItems--;
					continue;
				}
				// If this column is occupied by a cell in the previous row,
				// then push cells in this row to the right.
				if (i > 0) {
					var occupied:int = columnOccupiedUntilRow[colIndex];
					while (!isNaN(occupied) && occupied >= i) {
						colIndex++;
						occupied = columnOccupiedUntilRow[colIndex];
					}
				}

				// Set the position of this GridItem to the next
				// available space.
				gridItem = TableCell(gridRow.getChildAt(j));
				gridItem.colIndex = colIndex;

				// If this cell extends to rows beyond this one, remember
				// which columns are occupied.
				if (gridItem.rowSpan > 1) {
					var lastRowOccupied:int = i + gridItem.rowSpan - 1;
					for (var k:int = 0; k < gridItem.colSpan; k++) {
						columnOccupiedUntilRow[colIndex + k] = lastRowOccupied;
					}
				}

				colIndex += gridItem.colSpan;
			}

			if (colIndex > numGridColumns)
				numGridColumns = colIndex;
		}

		// 2. Create the rowHeights and colWidths arrays.
		// Initially set all heights and widths to zero.

		rowHeights = new Array(numGridRows);
		columnWidths = new Array(numGridColumns);

		for (i = 0; i < numGridRows; i++) {
			rowHeights[i] = new GridRowInfo();
		}
		for (i = 0; i < numGridColumns; i++) {
			columnWidths[i] = new GridColumnInfo();
		}
		
		// 3. Visit all the GridItems again.
		// Expand each row and each column so it's large enough
		// to hold its GridItems.
		// We'll deal with rowSpans and colSpans of 1 first,
		// then rowSpans and colSpans of 2, and so on.

		var BIG_INT:int = int.MAX_VALUE;
		var curSpan:int;
		var nextSpan:int = 1;
		
		var horizontalGap:Number = getStyle("horizontalGap");
		var verticalGap:Number = getStyle("verticalGap");
		
		do {
			curSpan = nextSpan;
			nextSpan = BIG_INT;  

			for (i = 0; i < numGridRows; i++) {
				gridRow = rowList[i];

				// Store pointers to the columnWidths and rowHeights arrays
				// on each GridRow object.
				gridRow.columnWidths = columnWidths;
				gridRow.rowHeights = rowHeights;

				for (j = 0; j < gridRow.numGridItems; j++) {
					gridItem = TableCell(gridRow.getChildAt(j));
					var rowSpan:int = gridItem.rowSpan;
					var colSpan:int = gridItem.colSpan;

					// During this iteration of the outermost do-while loop,
					// we're dealing with rows and columns that have a rowSpan
					// or colSpan equal to curSpan.  If we encounter a row or
					// column with a larger span, remember its span in nextSpan
					// for the next iteration through the do-while loop.

					if (rowSpan == curSpan)
						distributeItemHeight(gridItem, i, verticalGap, rowHeights);
					else if (rowSpan > curSpan && rowSpan < nextSpan)
						nextSpan = rowSpan;

					if (colSpan == curSpan) {
						distributeItemWidth(gridItem, gridItem.colIndex,
											horizontalGap, columnWidths);
					}
					else if (colSpan > curSpan && colSpan < nextSpan) {
						nextSpan = colSpan;
					}
				}
			}
		}
		while (nextSpan < BIG_INT);

		// 4. Reconcile min/preferred/max values, so that min <= pref <= max.
		// Also compute sums of all measurements.

		var minWidth:Number = 0;
		var minHeight:Number = 0;
		var preferredWidth:Number = 0;
		var preferredHeight:Number = 0;

		for (i = 0; i < numGridRows; i++) {
			var rowInfo:GridRowInfo = rowHeights[i];

			if (rowInfo.min > rowInfo.preferred)
				rowInfo.min = rowInfo.preferred;
			if (rowInfo.max < rowInfo.preferred)
				rowInfo.max = rowInfo.preferred;

			minHeight += rowInfo.min;
			preferredHeight += rowInfo.preferred;
		}

		for (i = 0; i < numGridColumns; i++) {
			var columnInfo:GridColumnInfo = columnWidths[i];

			if (columnInfo.min > columnInfo.preferred)
				columnInfo.min = columnInfo.preferred;
			if (columnInfo.max < columnInfo.preferred)
				columnInfo.max = columnInfo.preferred;

			minWidth += columnInfo.min;
			preferredWidth += columnInfo.preferred;
		}

		// 5. Add horizontal space for the gaps between the grid cells
		// and the margins around them.

		// Add space for grid's left and right margins
		var vm:EdgeMetrics = viewMetricsAndPadding;
		var padding:Number = vm.left + vm.right;
		var row:TableRow;
		var rowVm:EdgeMetrics;
		var maxRowPadding:Number = 0;

		// Add space for horizontal gaps between grid items.
		if (numGridColumns > 1)
			padding += getStyle("horizontalGap") * (numGridColumns - 1);

		// Add space for the gridrow's left and right margins.
		for (i = 0; i < numGridRows; i++) {
			row = rowList[i];
			rowVm = row.viewMetricsAndPadding;
			var rowPadding:Number = rowVm.left + rowVm.right;
			if (rowPadding > maxRowPadding)
				maxRowPadding = rowPadding;
		}
		padding += maxRowPadding;

		minWidth += padding;
		preferredWidth += padding;

		// 6. Add vertical space for the gaps between grid cells
		// and the margins around them.

		// Add space for grid's left and right margins.
		padding = vm.top + vm.bottom;

		// Add space for vertical gaps between grid items.
		if (numGridRows > 1)
			padding += getStyle("verticalGap") * (numGridRows - 1);

		// Add each of the grid rows' margins.
		for (i = 0; i < numGridRows; i++) {
			row = rowList[i];
			rowVm = row.viewMetricsAndPadding;
			padding += rowVm.top + rowVm.bottom;
		}

		minHeight += padding;
		preferredHeight += padding;

		// 7. Now that the Grid is finished measuring itself,
		// update all the measurements of the child GridRows.

		for (i = 0; i < numGridRows; i++) {
			row = rowList[i];
			row.updateRowMeasurements();
		}

		// 8. Up until now, we've calculated all our measurements
		// based on the GridItems.
		// If someone has explicitly set the width (or percentWidth
		// or whatever) of a GridRow, we've been ignoring it.
		// Run the standard Box measurement algorithm, which will
		// take into account hard-coded values on the GridRow objects,
		// and combine the measured values with the ones
		// we've calculated based on GridItems.

		super.measure();
		
		measuredMinWidth = Math.max(measuredMinWidth, minWidth);
		measuredMinHeight = Math.max(measuredMinHeight, minHeight);
		measuredWidth = Math.max(measuredWidth, preferredWidth);
		measuredHeight = Math.max(measuredHeight, preferredHeight);
		
		needToRemeasure = false;		
	}

	override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void {	   
		// If the measure function wasn't called (because the widths
		// and heights of the Grid are explicitly set), then we need
		// to generate the rowHeights and columnWidths arrays now.
		if (needToRemeasure)
			measure();
			
		// Follow standard VBox rules for laying out the child rows.
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		var n:int = 0;
		var i:int;
		var child:TableRow;

		var rowList:Array = []; // GridRows

		for (var index:int = 0; index < numChildren; index++) {
			child = TableRow(getChildAt(index));
			if (child.includeInLayout) {
				rowList.push(child);
				n++;
			}
		}

		// Copy the row heights, which were calculated by the VBox layout
		// algorithm, into the rowHeights array.
		for (i = 0; i < n; i++) {
			child = rowList[i];
			
			rowHeights[i].y = child.y;
			rowHeights[i].height = child.height;
		}

		// Now that all the rows have been layed out, lay out the GridItems
		// in those rows, based on the info stored in the colWidths and
		// rowHeights arrays.
		for (i = 0; i < n; i++) {
			child = rowList[i];
			
			child.doRowLayout(child.width * child.scaleX,
							  child.height * child.scaleY);
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	private function distributeItemHeight(item:TableCell, rowIndex:Number,
										  verticalGap:Number,
										  rowHeights:Array):void {
		var maxHeight:Number = item.maxHeight;
		var preferredHeightToDistribute:Number =
			item.getExplicitOrMeasuredHeight();
		var minHeightToDistribute:Number = item.minHeight;
		var rowSpan:int = item.rowSpan;
		var totalFlex:Number = 0;
		var divideEqually:Boolean = false;
		var i:int;
		var rowInfo:GridRowInfo;

		// If the row(s) spanned by this GridItem are already non-empty,
		// subtract the existing sizes of those rows from the item's height.
		for (i = rowIndex; i < rowIndex + rowSpan; i++) {
			rowInfo = rowHeights[i];
			preferredHeightToDistribute -= rowInfo.preferred;
			minHeightToDistribute -= rowInfo.min;
			totalFlex += rowInfo.flex;
		}

		// Subtract space for gaps between the rows.
		if (rowSpan > 1) {
			var gap:Number = verticalGap * (rowSpan - 1);
			preferredHeightToDistribute -= gap;
			minHeightToDistribute -= gap;
		}

		// If none of the rows spanned by this item are resizable,
		// then divide space among the rows equally.
		if (totalFlex == 0) {
			totalFlex = rowSpan;
			divideEqually = true;
		}

		// If we haven't yet distributed the height of the object,
		// divide remaining height among the rows.
		// If some rows are resizable and others are not,
		// allocate space to the resizable ones.
		preferredHeightToDistribute =
			preferredHeightToDistribute > 0 ?
			Math.ceil(preferredHeightToDistribute / totalFlex) :
			0;
		minHeightToDistribute =
			minHeightToDistribute > 0 ?
			Math.ceil(minHeightToDistribute / totalFlex) :
			0;		  
		
		for (i = rowIndex; i < rowIndex + rowSpan; i++) {
			rowInfo = rowHeights[i];
			var flex:Number = divideEqually ? 1 : rowInfo.flex;
			rowInfo.preferred += preferredHeightToDistribute * flex;
			rowInfo.min += minHeightToDistribute * flex;
		}

		// The GridItem.maxHeight attribute is respected only for rows
		// with a rowSpan of 1.
		if (rowSpan == 1 && maxHeight < rowInfo.max)
			rowInfo.max = maxHeight;
	}

	private function distributeItemWidth(item:TableCell, colIndex:int,
										 horizontalGap:Number, columnWidths:Array):void {
		var maxWidth:Number = item.maxWidth;
		var preferredWidthToDistribute:Number = 
			item.getExplicitOrMeasuredWidth();
		var minWidthToDistribute:Number = item.minWidth;
		var colSpan:int = item.colSpan;
		var percentWidth:Number = item.percentWidth;
		var totalFlex:Number = 0;
		var divideEqually:Boolean = false;
		var i:int;
		var columnInfo:GridColumnInfo;

		// If the column(s) spanned by this GridItem are already non-empty,
		// subtract the existing sizes of those columns from the item's width.
		for (i = colIndex; i < colIndex + colSpan; i++) {
			columnInfo = columnWidths[i];
			preferredWidthToDistribute -= columnInfo.preferred;
			minWidthToDistribute -= columnInfo.min;
			totalFlex += columnInfo.flex;
		}

		// Subtract space for gaps between the columns.
		if (colSpan > 1) {
			var gap:Number = horizontalGap * (colSpan - 1);
			preferredWidthToDistribute -= gap;
			minWidthToDistribute -= gap;
		}

		// If none of the columns spanned by this item are resizable,
		// then divide space among the columns equally.
		if (totalFlex == 0) {
			totalFlex = colSpan;
			divideEqually = true;
		}

		// If we haven't yet distributed the width of the object,
		// divide remaining width among the columns.
		// If some columns are resizable and others are not,
		// allocate space to the resizable ones.
		preferredWidthToDistribute =
			preferredWidthToDistribute > 0 ?
			Math.ceil(preferredWidthToDistribute / totalFlex) :
			0;
		minWidthToDistribute =
			minWidthToDistribute > 0 ?
			Math.ceil(minWidthToDistribute / totalFlex) :
			0;
		
		for (i = colIndex; i < colIndex + colSpan; i++) {
			columnInfo = columnWidths[i];
			var flex:Number = divideEqually ? 1 : columnInfo.flex;
			columnInfo.preferred += preferredWidthToDistribute * flex;
			columnInfo.min += minWidthToDistribute * flex;
			if (percentWidth) {
				columnInfo.percent = Math.max(columnInfo.percent,
											  percentWidth / colSpan);
			}
		}

		// The GridItem.maxWidth attribute is respected only for columns
		// with a colSpan of 1.
		if (colSpan == 1 && maxWidth < columnInfo.max)
			columnInfo.max = maxWidth;
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
		
		if(color && color == 'none') {
			
			_highlightMarker.visible = false;
			return;
		}
			
		var graph:Graphics = _highlightMarker.graphics;
		
		graph.clear()
		graph.lineStyle(2, Number(color));
		graph.drawRect(0, 0, width, height);
		
		bringOnTop();
		
		_highlightMarker.visible = true;
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