package net.vdombox.ide.modules.wysiwyg.controller
{
	import flash.geom.Point;
	
	import mx.collections.ArrayList;
	import mx.core.Container;
	
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.LineVO;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	import net.vdombox.ide.modules.wysiwyg.utils.DisplayUtils;
	import net.vdombox.ide.modules.wysiwyg.utils.PointCoordinateComponent;
	import net.vdombox.ide.modules.wysiwyg.view.components.PageRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import spark.primitives.Line;

	public class CreateLineLinkingCommand extends SimpleCommand
	{
		private var render : RendererBase;
		private var pageRenderer : PageRenderer;
		private var minEpsX : Number = 100;
		private var minEpsY : Number = 100;
		
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			render = body.render as RendererBase;
			
			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			var rr : Array =  renderProxy.getRenderersByVO( (render.renderVO.vdomObjectVO as ObjectVO).pageVO );
			pageRenderer = renderProxy.getRenderersByVO( (render.renderVO.vdomObjectVO as ObjectVO).pageVO )[0] as PageRenderer;
			
			var listComponents : Array;
			if ( body.ctrlKey as Boolean )
				listComponents = foundComponents( pageRenderer.renderVO );
			else
				listComponents = foundComponentsPackage( pageRenderer.renderVO );
			
			var renderer : RendererBase;
			var renderVO : RenderVO;
			var pointRender : Array = getCoordinateComponent( render );
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
			if ( linesLinkingX.length > 0)
			{
				for each ( line in linesLinkingX )
				{
					if (line.eps == minEpsX)
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
				}
			}
			else
			{
				minEpsY = 0;
			}
			
			sendNotification( ApplicationFacade.LINE_LIST_GETTED, { listLines : listLines, render : render, stepX : minEpsX, stepY : minEpsY } );
		}
		
		private function foundComponents ( renderVO : RenderVO ) : Array
		{
			if (renderVO.children == null)
				return null;
			
			var listComponents : Array = renderVO.children;
			var component : RenderVO;
			var tempComponent : RenderVO;
			var components : Array;
			
			for each (component in listComponents)
			{
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
				{
					for each ( tempComponent in components )
					{
						listComponents.push( tempComponent );
					}
					return listComponents;
				}
			}
			
			return null;
			
		}
		
		private function getCoordinateComponent ( rendererBase : RendererBase ) : Array
		{
			var pointCoordinateComponent : Array = new Array();
			var point : Point = DisplayUtils.getConvertedPoint( rendererBase, pageRenderer.background);
			var temp : Point = point;
			pointCoordinateComponent.push( point );
			point = new Point( temp.x + rendererBase.width / 2, temp.y + rendererBase.height / 2 );
			pointCoordinateComponent.push( point );
			point = new Point( temp.x + rendererBase.width , temp.y + rendererBase.height );
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
			for ( i = 0; i < 3; i++ )
			{
				for ( j = 0; j < 3; j++ )
				{
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
			for ( i = 0; i < 3; i++ )
			{
				for ( j = 0; j < 3; j++ )
				{
					for ( k = 0; k <= 10; k++ )
					{
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