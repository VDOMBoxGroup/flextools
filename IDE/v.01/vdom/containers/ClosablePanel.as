package vdom.containers 
{

import flash.events.MouseEvent;

import mx.containers.HDividedBox;
HDividedBox
import mx.containers.Panel;
import mx.controls.Button;
import mx.core.EdgeMetrics;
import mx.events.FlexEvent;

import vdom.events.ClosablePanelEvent;

public class ClosablePanel extends Panel 
{
	protected var collapseButton : Button;
	private var _collapse : Boolean;
	private var _dataProvider : Object;
	private var oldHeight : Number;
	private var oldPercentHeight : Number;
	
	public function ClosablePanel()
	{
		super();
		
		addEventListener( ClosablePanelEvent.PANEL_COLLAPSE, panelOpeningHandler );
		addEventListener( FlexEvent.CREATION_COMPLETE, _test );
		minHeight = 20;
	}
	
	private function _test( event : FlexEvent ) : void 
	{
		explicitHeight = height;
	}
	
	public function get collapse() : Boolean
	{
		return _collapse;
	}
	
	public function set collapse( value : Boolean ) : void
	{
//		if( value == _collapse )
//			return;
		
		if( value ) 
		{
			collapseButton.setStyle( "upSkin", getStyle( "CollapseButtonOffButtonUp" ) );
			collapseButton.setStyle( "downSkin", getStyle( "CollapseButtonOffButtonDown" ) );
			collapseButton.setStyle( "overSkin", getStyle( "CollapseButtonOffButtonOver" ) );
			collapseButton.setStyle( "disabledSkin", getStyle( "CollapseButtonOffButtonDisabled" ) );
		}
		else 
		{
			collapseButton.setStyle( "upSkin", getStyle( "CollapseButtonOnButtonUp" ) );
			collapseButton.setStyle( "downSkin", getStyle( "CollapseButtonOnButtonDown" ) );
			collapseButton.setStyle( "overSkin", getStyle( "CollapseButtonOnButtonOver" ) );
			collapseButton.setStyle( "disabledSkin", getStyle( "CollapseButtonOnButtonDisabled" ) );
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
		
		if ( !collapseButton ) 
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
		
		if( unscaledHeight > titleBar.height)
		{			
			if( isNaN( percentHeight ) )
				oldHeight = unscaledHeight;
			else
				oldPercentHeight = percentHeight;
			
			collapse = false;
		}
		else
		{
			if( height != titleBar.height )
				height = titleBar.height;
			collapse = true;
		}
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
		if( !event.collapse )
		{
			if( !oldPercentHeight )
				height = oldHeight;
			else
				percentHeight = oldPercentHeight;
		}
		else
		{
			height = titleBar.height;
		}
			
	}
}
}