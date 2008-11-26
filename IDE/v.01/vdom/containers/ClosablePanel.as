package vdom.containers 
{

import flash.events.MouseEvent;

import mx.containers.Panel;
import mx.controls.Button;
import mx.core.EdgeMetrics;

import vdom.events.ClosablePanelEvent;

public class ClosablePanel extends Panel 
{
	protected var collapseButton : Button;
	private var _collapse : Boolean;
	private var _dataProvider : Object;
	
	public function ClosablePanel()
	{
		super();
		
		addEventListener( ClosablePanelEvent.PANEL_COLLAPSE, panelOpeningHandler );
	}
	
	public function get collapse() : Boolean
	{
		return _collapse;
	}
	
	public function set collapse( value : Boolean ) : void
	{
		if( value ) 
		{
			collapseButton.setStyle("upSkin", getStyle('CollapseButtonOffButtonUp'));
			collapseButton.setStyle("downSkin",getStyle('CollapseButtonOffButtonDown'));
			collapseButton.setStyle("overSkin",getStyle('CollapseButtonOffButtonOver'));
			collapseButton.setStyle("disabledSkin",getStyle('CollapseButtonOffButtonDisabled'));
			height = getStyle('headerHeight');
		}
		else 
		{
			collapseButton.setStyle("upSkin", getStyle('CollapseButtonOnButtonUp'));
			collapseButton.setStyle("downSkin",getStyle('CollapseButtonOnButtonDown'));
			collapseButton.setStyle("overSkin",getStyle('CollapseButtonOnButtonOver'));
			collapseButton.setStyle("disabledSkin",getStyle('CollapseButtonOnButtonDisabled'));
			height = NaN;
		}
		_collapse = value;
	}
	
	override public function set title( value : String ) : void 
	{
		value = value.toUpperCase();
		super.title = value;
	}
	
	override protected function createChildren() : void 
	{
		super.createChildren();
		
		if (!collapseButton ) 
		{
			collapseButton = new Button();
			collapseButton.explicitWidth = collapseButton.explicitHeight = 16;
			
			collapseButton.focusEnabled = false;
			
			collapseButton.enabled = enabled;
			collapseButton.styleName = this;	
			
			collapseButton.addEventListener( MouseEvent.CLICK, collapseButton_clickHandler );
		   
			titleBar.addChild( collapseButton );
			collapseButton.owner = this;
	   }
	   
	   collapse = false;
	}
	
	override protected function layoutChrome( unscaledWidth : Number, unscaledHeight : Number ) : void 
	{
		super.layoutChrome( unscaledWidth, unscaledHeight );
		
		var bm : EdgeMetrics = borderMetrics;

		collapseButton.setActualSize(
			collapseButton.getExplicitOrMeasuredWidth(),
			collapseButton.getExplicitOrMeasuredHeight()
		);

		collapseButton.move(
			unscaledWidth - bm.right - 10 -
			collapseButton.getExplicitOrMeasuredWidth(),
			( titleBar.height -
			collapseButton.getExplicitOrMeasuredHeight()) / 2 );
	}
	
	private function collapseButton_clickHandler( event : MouseEvent ) : void 
	{
		var cpe : ClosablePanelEvent = 
			new ClosablePanelEvent( ClosablePanelEvent.PANEL_COLLAPSE );
		
		cpe.collapse = !collapse;
		dispatchEvent( cpe );
	}
	
	private function panelOpeningHandler( event : ClosablePanelEvent ) : void 
	{
		collapse = !collapse;
	}
}
}