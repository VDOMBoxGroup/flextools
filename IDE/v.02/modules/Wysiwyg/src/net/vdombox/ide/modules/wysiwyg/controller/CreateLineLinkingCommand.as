package net.vdombox.ide.modules.wysiwyg.controller
{
	import flash.geom.Point;
	
	import mx.collections.ArrayList;
	import mx.core.Container;
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.LineVO;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	import net.vdombox.ide.modules.wysiwyg.utils.DisplayUtils;
	import net.vdombox.ide.modules.wysiwyg.utils.PointCoordinateComponent;
	import net.vdombox.ide.modules.wysiwyg.view.components.PageRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	import net.vdombox.ide.modules.wysiwyg.view.components.TransformMarker;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import spark.primitives.Line;

	public class CreateLineLinkingCommand extends SimpleCommand
	{
		private var render : RendererBase;
		private var component : UIComponent;
		private var pageRenderer : PageRenderer;
		private var minEpsX : Number = 100;
		private var minEpsY : Number = 100;
		
		private var minEpsX2 : Number = 100;
		private var minEpsY2 : Number = 100;
		
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			if (  body.component is RendererBase )
			{
				render = body.component as RendererBase;
				component = render as UIComponent;
			}
			else if (  body.component is TransformMarker )
			{
				render = body.component.renderer as RendererBase;
				if ( render == null )
					return;
				component = body.component as UIComponent;
			}
			
			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			pageRenderer = renderProxy.getRenderersByVO( (render.renderVO.vdomObjectVO as ObjectVO).pageVO )[0] as PageRenderer;
			
			var listComponents : Array;
			if ( body.ctrlKey as Boolean )
				listComponents = foundComponents( pageRenderer.renderVO );
			else
				listComponents = foundComponentsPackage( pageRenderer.renderVO );
			
			var renderer : RendererBase;
			var renderVO : RenderVO;
			var pointRender : Array = getCoordinateComponent( component );
			var point : Array;
			
			var linesLinkingX : Array = new Array();
			var linesLinkingRendererX : Array = new Array();
			
			var linesLinkingY : Array = new Array();
			var linesLinkingRendererY : Array = new Array();
			
			var line : LineVO;
			
			for each (renderVO in listComponents)  
			{
				renderer = renderProxy.getRenderersByVO( renderVO.vdomObjectVO )[0] as RendererBase;
				if ( render.vdomObjectVO.id != renderer.vdomObjectVO.id )
				{
					point = getCoordinateComponent( renderer );
				
					linesLinkingRendererX = getLineLinkingX( pointRender, point, renderer );
					if (linesLinkingRendererX)
						for each ( line in linesLinkingRendererX )
						{
							linesLinkingX.push( line );
						}
					
					linesLinkingRendererY = getLineLinkingY( pointRender, point, renderer );
					if (linesLinkingRendererY)
						for each ( line in linesLinkingRendererY )
						{
							linesLinkingY.push( line );
						}
				}	
			}
			
			var listLines : Array = new Array();
			var marker : TransformMarker;
			var equallyXFlag : Boolean;
			var equallyYFlag : Boolean;
			if ( component is TransformMarker )
			{
				marker = component as TransformMarker;
				equallyXFlag = marker.equallyWidth( component.measuredWidth );
				if ( equallyXFlag )
					minEpsX2 = 0;
				
				equallyYFlag = marker.equallyHeight( component.measuredHeight );
				if ( equallyYFlag )
					minEpsY2 = 0;
			}
			
				
			if ( linesLinkingX.length > 0)
			{
				for each ( line in linesLinkingX )
				{
					if (line.eps == minEpsX)
						listLines.push( line );
					if ( component is TransformMarker && !equallyXFlag && line.eps == minEpsX2 )
						listLines.push( line );
				}
			}
			else
			{
				minEpsX = 0;
			}
				
			if ( linesLinkingY.length > 0)
			{
				for each ( line in linesLinkingY )
				{
					if (line.eps == minEpsY)
						listLines.push( line );
					if ( component is TransformMarker && !equallyYFlag && line.eps == minEpsY2 )
						listLines.push( line );
				}
			}
			else
			{
				minEpsY = 0;
			}
			
			if ( minEpsX2 == 100 )
				minEpsX2 = 0;
			if ( minEpsY2 == 100 )
				minEpsY2 = 0;
			
			if ( component is TransformMarker && !marker.equallySize( component.measuredWidth, component.measuredHeight ))
				sendNotification( ApplicationFacade.LINE_LIST_GETTED, { listLines : listLines, component : component, stepX : minEpsX2, stepY : minEpsY2 } );
			else	
				sendNotification( ApplicationFacade.LINE_LIST_GETTED, { listLines : listLines, component : component, stepX : minEpsX, stepY : minEpsY } );
		}
		
		private function foundComponents ( renderVO : RenderVO ) : Array
		{
			if (renderVO.children == null)
				return null;
			
			var listComponents : Array = new Array();
			
			var component : RenderVO;
			var tempComponent : RenderVO;
			var components : Array;
			
			for each (component in renderVO.children)
			{
				listComponents.push( component );
				
				components = foundComponents( component );
				if (components != null)
				{
					for each ( tempComponent in components )
					{
						listComponents.push( tempComponent );
					}
				}
			}
			
			return listComponents;
			
		}
		
		private function foundComponentsPackage ( renderVO : RenderVO ) : Array
		{
			if (renderVO.children == null)
				return null;
			
			var listComponents : Array = renderVO.children;
			var component : RenderVO;
			var tempComponent : RenderVO;
			var components : Array;
			
			for each (component in listComponents)
			{
				if (component.vdomObjectVO.id == render.vdomObjectVO.id)
					return listComponents;
			}
			
			for each (component in listComponents)
			{
				components = foundComponentsPackage( component );
				if (components != null)
					return components;
			}
			
			return null;
		}
		
		private function getCoordinateComponent ( _component : UIComponent ) : Array
		{
			var pointCoordinateComponent : Array = new Array();
			var point : Point = DisplayUtils.getConvertedPoint( _component, pageRenderer.background);
			var temp : Point = new Point( point.x , point.y );
			var _width : Number;
			var _height : Number;
			if ( _component is TransformMarker )
			{
				_width = _component.measuredWidth;
				_height = _component.measuredHeight;
			}
			else
			{
				_width = _component.width;
				_height = _component.height;
			}
			pointCoordinateComponent.push( point );
			point = new Point( temp.x + Math.round( _width / 2 ), temp.y + Math.round( _height / 2 ) );
			pointCoordinateComponent.push( point );
			point = new Point( temp.x + _width , temp.y + _height );
			pointCoordinateComponent.push( point );
			return pointCoordinateComponent;
		}
		
		private function getLineLinkingX( point1 : Array, point2 : Array, render : RendererBase ) : Array
		{
			var i : int;
			var j : int;
			var k : int;
			var lines : Array = new Array();
			var line : LineVO;
			var startI : int = 0;
			var finishI : int = 3;
			/*if ( component is TransformMarker )
			{
				var marker : TransformMarker = component as TransformMarker;
				if ( !marker.equallySize( component.measuredWidth, component.measuredHeight ) )
				{
					if ( marker.equallyPoint( component.x, component.y ) )
						startI = 1;
					else
						finishI = 2;
				}
			}*/
			for ( i = startI; i < finishI; i++ )
			{
				for ( j = 0; j < 3; j++ )
				{
					if ( Math.abs( point1[i].x - point2[j].x ) > 10 )
						continue;
					for ( k = 0; k <= 10; k++ )
					{
						if ( point1[i].x == point2[j].x + k )
						{
							if ( i == 1 && j == 1 )
								line = new LineVO( point2[j].x, point1[i].y, point2[j].x, point2[j].y, k, 1, false, render );
							else if ( i != 1 && j == 1 )
							{
								if ( point1[i].y < point2[j].y )
									line = new LineVO( point2[j].x, point1[0].y, point2[j].x, point2[j].y, k, 0, false, render );
								else
									line = new LineVO( point2[j].x, point1[2].y, point2[j].x, point2[j].y, k, 0, false, render );
							}
							else if ( i == 1 && j != 1 )
							{
								if ( point1[i].y < point2[j].y )
									line = new LineVO( point2[j].x, point1[i].y, point2[j].x, point2[2].y, k, 1, false, render );
								else
									line = new LineVO( point2[j].x, point1[i].y, point2[j].x, point2[0].y, k, 1, false, render );
							}
							else
							{
								if ( point1[i].y < point2[j].y )
									line = new LineVO( point2[j].x, point1[0].y, point2[j].x, point2[2].y, k, 0, false, render );
								else
									line = new LineVO( point2[j].x, point1[2].y, point2[j].x, point2[0].y, k, 0, false, render );
							}
							lines.push( line );
							if ( Math.abs( minEpsX) > Math.abs( k ) )
								minEpsX = k;
							if ( Math.abs( minEpsX2) > Math.abs( k ) && k != 0 )
								minEpsX2 = k;
							break;
						}
						else if ( point1[i].x == point2[j].x - k )
						{
							if ( i == 1 && j == 1 )
								line = new LineVO( point2[j].x, point1[i].y, point2[j].x, point2[j].y, -k, 1, false, render );
							else if ( i != 1 && j == 1 )
							{
								if ( point1[i].y < point2[j].y )
									line = new LineVO( point2[j].x, point1[0].y, point2[j].x, point2[j].y, -k, 0, false, render );
								else
									line = new LineVO( point2[j].x, point1[2].y, point2[j].x, point2[j].y, -k, 0, false, render );
							}
							else if ( i == 1 && j != 1 )
							{
								if ( point1[i].y < point2[j].y )
									line = new LineVO( point2[j].x, point1[i].y, point2[j].x, point2[2].y, -k, 1, false, render );
								else
									line = new LineVO( point2[j].x, point1[i].y, point2[j].x, point2[0].y, -k, 1, false, render );
							}
							else
							{
								if ( point1[i].y < point2[j].y )
									line = new LineVO( point2[j].x, point1[0].y, point2[j].x, point2[2].y, -k, 0, false, render );
								else
									line = new LineVO( point2[j].x, point1[2].y, point2[j].x, point2[0].y, -k, 0, false, render );
							}
							lines.push( line );
							if ( Math.abs( minEpsX) > Math.abs( k ) )
								minEpsX = -k;
							if ( Math.abs( minEpsX2) > Math.abs( k ) && k != 0 )
								minEpsX2 = -k;
							break;
						}
					}
				}
			}
			
			if (lines.length > 0)
				return lines;
			return null;
		}
		
		private function getLineLinkingY( point1 : Array, point2 : Array, render : RendererBase ) : Array
		{
			var i : int;
			var j : int;
			var k : int;
			var lines : Array = new Array();
			var line : LineVO;
			var startI : int = 0;
			var finishI : int = 3;
			/*if ( component is TransformMarker )
			{
				var marker : TransformMarker = component as TransformMarker;
				if ( !marker.equallySize( component.measuredWidth, component.measuredHeight ) )
				{
					if ( marker.equallyPoint( component.x, component.y ) )
						startI = 1;
					else
						finishI = 2;
				}
			}*/
			for ( i = startI; i < finishI; i++ )
			{
				for ( j = 0; j < 3; j++ )
				{
					for ( k = 0; k <= 10; k++ )
					{
						if ( Math.abs( point1[i].y - point2[j].y ) > 10 )
							continue;
						if ( point1[i].y == point2[j].y + k )
						{
							if ( i == 1 && j == 1 )
								line = new LineVO( point1[i].x, point2[j].y, point2[j].x, point2[j].y, k, 1, true, render );
							else if ( i != 1 && j == 1 )
							{
								if ( point1[i].x < point2[j].x )
									line = new LineVO( point1[0].x, point2[j].y, point2[j].x, point2[j].y, k, 0, true, render );
								else
									line = new LineVO( point1[2].x, point2[j].y, point2[j].x, point2[j].y, k, 0, true, render );
							}
							else if ( i == 1 && j != 1 )
							{
								if ( point1[i].x < point2[j].x )
									line = new LineVO( point1[i].x, point2[j].y, point2[2].x, point2[j].y, k, 1, true, render );
								else
									line = new LineVO( point1[i].x, point2[j].y, point2[0].x, point2[j].y, k, 1, true, render );
							}
							else
							{
								if ( point1[i].x < point2[j].x )
									line = new LineVO( point1[0].x, point2[j].y, point2[2].x, point2[j].y, k, 0, true, render );
								else
									line = new LineVO( point1[2].x, point2[j].y, point2[0].x, point2[j].y, k, 0, true, render );
							}
							lines.push( line );
							if ( Math.abs( minEpsY) > Math.abs( k ) )
								minEpsY = k;
							if ( Math.abs( minEpsY2) > Math.abs( k ) && k != 0 )
								minEpsY2 = k;
							break;
						}
						else if ( point1[i].y == point2[j].y - k )
						{
							if ( i == 1 && j == 1 )
								line = new LineVO( point1[i].x, point2[j].y, point2[j].x, point2[j].y, -k, 1, true, render );
							else if ( i != 1 && j == 1 )
							{
								if ( point1[i].x < point2[j].x )
									line = new LineVO( point1[0].x, point2[j].y, point2[j].x, point2[j].y, -k, 0, true, render );
								else
									line = new LineVO( point1[2].x, point2[j].y, point2[j].x, point2[j].y, -k, 0, true, render );
							}
							else if ( i == 1 && j != 1 )
							{
								if ( point1[i].x < point2[j].x )
									line = new LineVO( point1[i].x, point2[j].y, point2[2].x, point2[j].y, -k, 1, true, render );
								else
									line = new LineVO( point1[i].x, point2[j].y, point2[0].x, point2[j].y, -k, 1, true, render );
							}
							else
							{
								if ( point1[i].x < point2[j].x )
									line = new LineVO( point1[0].x, point2[j].y, point2[2].x, point2[j].y, -k, 0, true, render );
								else
									line = new LineVO( point1[2].x, point2[j].y, point2[0].x, point2[j].y, -k, 0, true, render );
							}
							
							
							lines.push( line );
							if ( Math.abs( minEpsY) > Math.abs( k ) )
								minEpsY = -k;
							if ( Math.abs( minEpsY2) > Math.abs( k ) && k != 0 )
								minEpsY2 = -k;
							break;
						}
					}
				}
			}
			if (lines.length > 0)
				return lines;
			return null;
		}
	}
}